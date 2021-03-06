//
//  FCSettingsViewController.m
//  FireChat
//
//  Created by Terry Worona on 12-03-29.
//  Copyright (c) 2012 FireChat. All rights reserved.
//

#import "FCSettingsViewController.h"

// managers
#import "FCLocalResourceManager.h"

static NSString *CellIdentifier = @"SettingsCell";

@interface FCSettingsViewController ()


@end

@implementation FCSettingsViewController

@synthesize delegate, labels, placeholders;

#pragma mark - Alloc/Init

- (id)init
{
    self = [super init];
    if (self) {
        self.navigationItem.title = @"Settings";
		self.view.backgroundColor = [UIColor whiteColor];
		
		UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveButtonPressed:)];
		self.navigationItem.leftBarButtonItem = saveButton;
		[saveButton release];
	}
    return self;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.labels = [NSArray arrayWithObjects:@"Username", @"Chatroom", nil];
	self.placeholders = [NSArray arrayWithObjects:@"Enter Your Username", @"Enter A Chatroom", nil];	
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	if ([delegate respondsToSelector:@selector(viewWillAppearWithSettingsViewController:)]){
		[delegate viewWillAppearWithSettingsViewController:self];
	}
}

#pragma mark - Memory Management

- (void)dealloc
{
	[labels release];
	[placeholders release];
	[super dealloc];
}

#pragma mark - Table view data source

- (void)configureCell:(ELCTextfieldCell *)cell atIndexPath:(NSIndexPath *)indexPath 
{	
	cell.leftLabel.text = [self.labels objectAtIndex:indexPath.row];
	cell.rightTextField.placeholder = [self.placeholders objectAtIndex:indexPath.row];
	cell.indexPath = indexPath;
	cell.delegate = self;

	//Disables UITableViewCell from accidentally becoming selected.
	cell.selectionStyle = UITableViewCellEditingStyleNone;
	
	if (indexPath.row == 0){
		cell.rightTextField.text = [[FCLocalResourceManager sharedInstance] getUsername];
	}
	else if (indexPath.row == 1){
		cell.rightTextField.text = [[FCLocalResourceManager sharedInstance] getChatroom];	
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    return [labels count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{    
    ELCTextfieldCell *cell = (ELCTextfieldCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[ELCTextfieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
	
	cell.rightTextField.autocorrectionType = UITextAutocorrectionTypeNo;
	cell.rightTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
	
	[self configureCell:cell atIndexPath:indexPath];
    return cell;
}

#pragma mark - ELCTextFieldCellDelegate Methods

-(void)textFieldDidReturnWithIndexPath:(NSIndexPath*)indexPath 
{	
	if(indexPath.row < [labels count]-1) {
		NSIndexPath *path = [NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section];
		[[(ELCTextfieldCell*)[self.tableView cellForRowAtIndexPath:path] rightTextField] becomeFirstResponder];
		[self.tableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionTop animated:YES];
	}	
	else {
		[[(ELCTextfieldCell*)[self.tableView cellForRowAtIndexPath:indexPath] rightTextField] resignFirstResponder];
	}
}

- (void)updateTextLabelAtIndexPath:(NSIndexPath*)indexPath string:(NSString*)string 
{
	ELCTextfieldCell *changedCell = (ELCTextfieldCell*)[self.tableView cellForRowAtIndexPath:indexPath];
	
	BOOL enableSave = YES;
	for (int i=0; i < [self.tableView numberOfRowsInSection:0]; i++){
		ELCTextfieldCell *cell = (ELCTextfieldCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
		if (cell != changedCell){
			if ([cell.rightTextField.text length] <= 0){
				enableSave = NO;
			}
		}
	}
	self.navigationItem.leftBarButtonItem.enabled = enableSave && [string length] > 0;
}

#pragma mark - Button Actions

- (void)saveButtonPressed:(id)sender
{
	ELCTextfieldCell *usernameCell = (ELCTextfieldCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    ELCTextfieldCell *chatroomCell = (ELCTextfieldCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
	[[FCLocalResourceManager sharedInstance] setChatroom:chatroomCell.rightTextField.text andUsername:usernameCell.rightTextField.text];
	
	[usernameCell.rightTextField resignFirstResponder];
	[chatroomCell.rightTextField resignFirstResponder];
	
	[self.slidingViewController resetTopView];
	
	if ([delegate respondsToSelector:@selector(viewWillAppearWithSettingsViewController:)]){
		[delegate viewWillDisappearWithSettingsViewController:self];			
	}

}

@end