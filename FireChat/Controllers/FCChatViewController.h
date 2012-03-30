//
//  FCChatViewController.h
//  FireChat
//
//  Created by Terry Worona on 12-03-28.
//  Copyright (c) 2012 FireChat. All rights reserved.
//

#import <UIKit/UIKit.h>

// views
#import "UIInputToolbar.h"
#import "FCWebView.h"

// controllers
#import "ECSlidingViewController.h"

@interface FCChatViewController : UIViewController{
	UIInputToolbar *inputToolbar;
	UITableView *tableView;
	
	FCWebView *webView;
		
@private
    BOOL keyboardIsVisible;
}

@property (nonatomic, retain) NSArray* messages;
@property (nonatomic, retain) UIInputToolbar *inputToolbar;

@end
