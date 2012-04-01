//
//  FCSettingsViewController.h
//  FireChat
//
//  Created by Terry Worona on 12-03-29.
//  Copyright (c) 2012 FireChat. All rights reserved.
//

#import <UIKit/UIKit.h>

// views
#import "ELCTextfieldCell.h"

// controllers
#import "ECSlidingViewController.h"

@protocol FCSettingsViewControllerDelegate;

@interface FCSettingsViewController : UITableViewController <ELCTextFieldDelegate> {
	id <FCSettingsViewControllerDelegate> delegate;
	
	NSArray *labels;
	NSArray *placeholders;
}

@property (nonatomic, retain) NSArray *labels;
@property (nonatomic, retain) NSArray *placeholders;

@property (nonatomic, assign) id <FCSettingsViewControllerDelegate> delegate;

@end

@protocol FCSettingsViewControllerDelegate <NSObject>

- (void)viewWillAppearWithSettingsViewController:(FCSettingsViewController*)controller;

@end
