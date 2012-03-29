//
//  AppDelegate.h
//  FireChat
//
//  Created by Terry Worona on 12-03-28.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

// controllers
#import "FCChatViewController.h"

@class FCChatViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) FCChatViewController *viewController;

@end
