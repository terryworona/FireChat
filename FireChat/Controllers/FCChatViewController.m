//
//  FCChatViewController.m
//  FireChat
//
//  Created by Terry Worona on 12-03-28.
//  Copyright (c) 2012 FireChat. All rights reserved.
//

#import "FCChatViewController.h"

// views
#import "SVProgressHUD.h"

// services
#import "FCService.h"
#import "FCService+Messages.h"

// models
#import "FCMessage.h"

// templates
#import "FCHtmlTemplates.h"

// controllers
#import "FCSettingsViewController.h"

// managers
#import "FCLocalResourceManager.h"

#define kStatusBarHeight 20
#define kDefaultToolbarHeight 40
#define kKeyboardHeightPortrait 216
#define kKeyboardHeightLandscape 140

#define kFCChatCellPadding 10
#define kFCChatCellUsernameSize 14
#define kFCChatCellMessageSize 16

static NSString *CellIdentifier = @"ChatCell";

@interface FCChatViewController () <UIInputToolbarDelegate, FCSettingsViewControllerDelegate, UITableViewDelegate, UITableViewDataSource, UIWebViewDelegate>

- (void)refreshChat;
- (void)scrollToBottom;

@end

@implementation FCChatViewController

@synthesize messages, inputToolbar;

#pragma mark - Alloc/Init

- (id)init
{
    self = [super init];
    if (self) {		
		UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshButtonPressed:)];
		self.navigationItem.rightBarButtonItem = refreshButton;
		[refreshButton release];

		UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(settingsButtonPressed:)];
		self.navigationItem.leftBarButtonItem = settingsButton;
		[settingsButton release];
		
		/*
		 * Firebase web view - listens to notifications sent via firebase.
		 * It is not added as a subview - but rather acts as a notification center. 
		 */		
		webView = [[FCWebView alloc] init];
		webView.delegate = self;
	}
    return self;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	keyboardIsVisible = NO;
	
	self.view.backgroundColor = [UIColor whiteColor];

	CGRect tableViewRect = CGRectMake(self.view.frame.origin.x, 
									  self.view.bounds.origin.y, 
									  self.view.bounds.size.width, 
									  self.view.bounds.size.height - self.navigationController.navigationBar.bounds.size.height - kDefaultToolbarHeight);
	tableView = [[UITableView alloc] initWithFrame:tableViewRect style:UITableViewStylePlain];
	tableView.backgroundColor = [UIColor clearColor];
	tableView.delegate = self;
	tableView.dataSource = self;
	[self.view addSubview:tableView];
	
	CGRect inputBarRect = CGRectMake(self.view.frame.origin.x, 
									 self.view.bounds.size.height - self.navigationController.navigationBar.bounds.size.height - kDefaultToolbarHeight, 
									 self.view.bounds.size.width, 
									 kDefaultToolbarHeight);

    self.inputToolbar = [[UIInputToolbar alloc] initWithFrame:inputBarRect];
    [self.view addSubview:self.inputToolbar];
    inputToolbar.delegate = self;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
	[inputToolbar release];
	inputToolbar = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
		
	if (![self.slidingViewController.underLeftViewController isKindOfClass:[FCSettingsViewController class]]) {
		FCSettingsViewController *settingsController = [[[FCSettingsViewController alloc] init] autorelease];
		settingsController.delegate = self;
		UINavigationController *navController = [[[UINavigationController alloc] initWithRootViewController:settingsController] autorelease];
		self.slidingViewController.underLeftViewController  = navController;
	}
	
	[self.view addGestureRecognizer:self.slidingViewController.panGesture];
	[self.slidingViewController setAnchorRightRevealAmount:320.0f];
}
- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

	[self refreshChat]; // refresh anytime view shows up
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return NO;
}

#pragma mark - View Helpers

- (void)scrollToBottom
{
	if ([[self messages] count] > 0){
		[tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.messages count] - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
	}
}

#pragma mark - Model Helpers

- (void)refreshChat
{
	[SVProgressHUD showWithStatus:@"Syncing..."];			
	[[FCService sharedInstance] listMessagesWithCompletion:^(NSArray *newMessages, NSError *error) {
		[SVProgressHUD dismiss];			
		if (!error){
			self.messages = newMessages;
			[tableView reloadData];
			[self scrollToBottom];
		}
		else{
			[SVProgressHUD showErrorWithStatus:@"Sync Error!"];
		}
	}];
	
	self.navigationItem.title = [NSString stringWithFormat:@"#%@", [[FCLocalResourceManager sharedInstance] getChatroom]];
	
	NSString *html = [NSString stringWithFormat:kFCHtmlChatTemplate, [[FCLocalResourceManager sharedInstance] getChatroom]];		
	[webView loadHTMLString:html baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]]];  
}

#pragma mark - Button Presses

- (void)refreshButtonPressed:(id)sender
{
	[self refreshChat];
}

- (void)settingsButtonPressed:(id)sender
{
	[self.slidingViewController anchorTopViewTo:ECRight];
}

#pragma mark - Memory Management

- (void)dealloc
{
	[inputToolbar release];
	[messages release];
	[webView reload];
	[super dealloc];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [messages count];
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	FCMessage *message = [messages objectAtIndex:indexPath.row];
	FCChatCell *cell = [_tableView dequeueReusableCellWithIdentifier:CellIdentifier];	
	if (!cell) {
		cell = (FCChatCell*)[[[FCChatCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
	}
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	cell.messageLabel.text = message.text;
	cell.usernameLabel.text = message.name;
	return cell;
}

- (CGFloat)tableView:(UITableView *)_tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	FCMessage *message = [messages objectAtIndex:indexPath.row];

	CGFloat width = self.view.frame.size.width - (kFCChatCellPadding*2);
	
	CGSize usernameSize = [message.name sizeWithFont:[UIFont systemFontOfSize:kFCChatCellUsernameSize] constrainedToSize:CGSizeMake(width, INT_MAX) lineBreakMode:UILineBreakModeTailTruncation];
	CGSize messageSize = [message.text sizeWithFont:[UIFont systemFontOfSize:kFCChatCellMessageSize] constrainedToSize:CGSizeMake(width, INT_MAX) lineBreakMode:UILineBreakModeTailTruncation];
	
	return (kFCChatCellPadding*2) + usernameSize.height + messageSize.height;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	// nothing to do here
}

#pragma mark - Notifications

- (void)keyboardWillShow:(NSNotification *)notification 
{
    /* Move the toolbar to above the keyboard */
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.25];
	
	CGRect inputBarFrame = self.inputToolbar.frame;
	inputBarFrame.origin.y = self.view.frame.size.height - inputBarFrame.size.height - kKeyboardHeightPortrait;
	self.inputToolbar.frame = inputBarFrame;
		
	CGRect tableViewFrame = tableView.frame;
	tableViewFrame.size.height = self.view.bounds.size.height - kKeyboardHeightPortrait - inputBarFrame.size.height;
	tableView.frame = tableViewFrame;
	
	[self scrollToBottom];
	
	[UIView commitAnimations];
    keyboardIsVisible = YES;
	
}

- (void)keyboardWillHide:(NSNotification *)notification 
{
    /* Move the toolbar back to bottom of the screen */
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.25];

	CGRect inputBarFrame = self.inputToolbar.frame;
	inputBarFrame.origin.y = self.view.frame.size.height - inputBarFrame.size.height;
	self.inputToolbar.frame = inputBarFrame;
	
	tableView.frame = CGRectMake(self.view.frame.origin.x, 
								 self.view.bounds.origin.y, 
								 self.view.bounds.size.width, 
								 self.view.frame.size.height - kDefaultToolbarHeight);
	
	[self scrollToBottom];

	[UIView commitAnimations];
    keyboardIsVisible = NO;
}

-(void)inputButtonPressed:(NSString *)inputText
{
	NSString *function = [[NSString alloc] initWithFormat:@"send_message(\"%@\", \"%@\")", [[FCLocalResourceManager sharedInstance] getUsername], inputText];
	[webView stringByEvaluatingJavaScriptFromString:function];
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType 
{	
	NSLog(@"New message URL : %@", [[request URL] pathComponents]);

	NSArray *pathComponents = [[request URL] pathComponents];
	if ([pathComponents count] == 4){
		
		NSString *sender = [pathComponents objectAtIndex:1];
		NSString *message = [pathComponents objectAtIndex:2];
		NSString *identifier = [pathComponents objectAtIndex:3];
		
		BOOL duplicateMessage = NO;
		if ([messages count] > 0){
			FCMessage *lastMessage = [messages lastObject];
			
			if ([lastMessage.message_id isEqualToString:identifier]){
				duplicateMessage = YES;
			}
		}
		
		// add message if not dupe
		if (!duplicateMessage){
			FCMessage *newMessage = [[FCMessage alloc] init];
			newMessage.name = sender;
			newMessage.text = message;
			newMessage.message_id = identifier;
			
			NSMutableArray *newMessageArray = [NSMutableArray arrayWithArray:messages];
			[newMessageArray addObject:newMessage];
			
			self.messages = [NSArray arrayWithArray:newMessageArray];
			[tableView reloadData];
			[self scrollToBottom];
		}
	}
	
	return YES;
}

#pragma mark - FCSettingsViewController

- (void)viewWillAppearWithSettingsViewController:(FCSettingsViewController *)controller
{
	[inputToolbar.textView resignFirstResponder];
}

- (void)viewWillDisappearWithSettingsViewController:(FCSettingsViewController *)controller
{
	[self refreshChat];
}

@end

@implementation FCChatCell

@synthesize messageLabel, usernameLabel;

#pragma mark - Alloc/Init

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if (self){
		messageLabel = [[UILabel alloc] init];
		messageLabel.font = [UIFont systemFontOfSize:kFCChatCellMessageSize];
		messageLabel.lineBreakMode = UILineBreakModeTailTruncation;
		messageLabel.textColor = [UIColor blackColor];
		messageLabel.numberOfLines = 0;
		[self addSubview:messageLabel];
		
		usernameLabel = [[UILabel alloc] init];
		usernameLabel.font = [UIFont boldSystemFontOfSize:kFCChatCellUsernameSize];
		usernameLabel.lineBreakMode = UILineBreakModeTailTruncation;
		usernameLabel.textColor = [UIColor grayColor];
		[self addSubview:usernameLabel];
	}
	return self;
}

#pragma mark - Layout

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	CGFloat xOffset = kFCChatCellPadding;
	CGFloat yOffset = kFCChatCellPadding;
	CGFloat width = self.bounds.size.width - (xOffset*2);
	
	CGSize usernameSize = [usernameLabel.text sizeWithFont:usernameLabel.font constrainedToSize:CGSizeMake(width, INT_MAX) lineBreakMode:usernameLabel.lineBreakMode];
	CGSize messageSize = [messageLabel.text sizeWithFont:messageLabel.font constrainedToSize:CGSizeMake(width, INT_MAX) lineBreakMode:usernameLabel.lineBreakMode];

	usernameLabel.frame = CGRectMake(xOffset, yOffset, usernameSize.width, usernameSize.height);
	yOffset += usernameLabel.frame.size.height;
	messageLabel.frame = CGRectMake(xOffset, yOffset, messageSize.width, messageSize.height);

}

#pragma mark - Memory Management

- (void)dealloc
{
	[messageLabel release];
	[usernameLabel release];
	[super dealloc];
}

@end