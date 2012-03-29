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

#define kStatusBarHeight 20
#define kDefaultToolbarHeight 40
#define kKeyboardHeightPortrait 216
#define kKeyboardHeightLandscape 140

static NSString *CellIdentifier = @"Cell";

@interface FCChatViewController () <UIInputToolbarDelegate, UITableViewDelegate, UITableViewDataSource>

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
        self.navigationItem.title = @"FireChat";
		UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshButtonPressed:)];
		self.navigationItem.rightBarButtonItem = refreshButton;
		[refreshButton release];
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
	tableView.backgroundColor = [UIColor redColor];
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

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
	
	[self refreshChat]; // refresh chat everytime we bring the app into the fore-ground
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
}

#pragma mark - Button Presses

- (void)refreshButtonPressed:(id)sender
{
	[self refreshChat];
}

#pragma mark - Memory Management

- (void)dealloc
{
	[inputToolbar release];
	[messages release];
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
	UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:CellIdentifier];	
	if (!cell) {
		cell = (UITableViewCell*)[[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
	}
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	cell.textLabel.text = message.text;
	cell.detailTextLabel.text = message.name;
	return cell;
}
#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	// nothing to do here
}

#pragma mark -
#pragma mark Notifications

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
    NSLog(@"Pressed button with text: '%@'", inputText);
}

@end
