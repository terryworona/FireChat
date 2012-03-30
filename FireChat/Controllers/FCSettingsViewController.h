//
//  FCSettingsViewController.h
//  FireChat
//
//  Created by Terry Worona on 12-03-29.
//  Copyright (c) 2012 FireChat. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FCSettingsViewControllerDelegate;

@interface FCSettingsViewController : UIViewController{
	id <FCSettingsViewControllerDelegate> delegate;
}

@property (nonatomic, assign) id <FCSettingsViewControllerDelegate> delegate;

@end

@protocol FCSettingsViewControllerDelegate <NSObject>

- (void)viewWillAppearWithSettingsViewController:(FCSettingsViewController*)controller;

@end
