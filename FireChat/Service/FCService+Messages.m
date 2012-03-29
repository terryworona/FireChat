//
//  FCService+Messages.m
//  FireChat
//
//  Created by Terry Worona on 12-03-28.
//  Copyright (c) 2012 FireChat. All rights reserved.
//

#import "FCService+Messages.h"

// constants
#import "FCConstants.h"

@implementation FCService (Messages)

#pragma mark - CRUD

- (void)listMessagesWithCompletion:(ListMessagesCallback)completion
{	
	[self listObjects:kFCResoureChatroom withOptions:nil completion:^(id element, NSError *error) {
		if (!error){
			NSLog(@"JSON! %@", element);
			
			
			
		}
		else{
			completion(nil, error);
		}
	}];
}

@end