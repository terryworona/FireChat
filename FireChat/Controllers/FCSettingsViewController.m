//
//  FCSettingsViewController.m
//  FireChat
//
//  Created by Terry Worona on 12-03-29.
//  Copyright (c) 2012 FireChat. All rights reserved.
//

#import "FCSettingsViewController.h"

@interface FCSettingsViewController ()

@end

@implementation FCSettingsViewController

@synthesize delegate;

#pragma mark - Alloc/Init

- (id)init
{
    self = [super init];
    if (self) {
        self.navigationItem.title = @"Settings";
		self.view.backgroundColor = [UIColor lightGrayColor];
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

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	if ([delegate respondsToSelector:@selector(viewWillAppearWithSettingsViewController:)]){
		[delegate viewWillAppearWithSettingsViewController:self];
	}
}

@end
