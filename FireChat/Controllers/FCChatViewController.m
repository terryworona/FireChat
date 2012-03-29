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

@interface FCChatViewController ()

- (void)refreshChat;

@end

@implementation FCChatViewController

@synthesize messages = _messages;

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
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	[self refreshChat]; // refresh chat everytime we bring the app into the fore-ground
}

#pragma mark - Model Helpers

- (void)refreshChat
{
	[SVProgressHUD showWithStatus:@"Syncing..."];
	[[FCService sharedInstance] listMessagesWithCompletion:^(NSArray *messages, NSError *error) {
		[SVProgressHUD dismiss];
		if (!error){
			self.messages = messages;
			[self.tableView reloadData];
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
	[_messages release];
	[super dealloc];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    return cell;
}
#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	// nothing to do here
}

@end
