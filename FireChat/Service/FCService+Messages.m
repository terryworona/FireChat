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

// models
#import "FCMessage.h"

@implementation FCService (Messages)

#pragma mark - CRUD

- (void)listMessagesWithCompletion:(ListMessagesCallback)completion
{	
	[self listObjects:kFCResoureChatroom withOptions:nil completion:^(id element, NSError *error) {
		if (!error){
			NSMutableArray *messagesArray = [NSMutableArray array];
			if ([element isKindOfClass:[NSDictionary class]]){
				for (NSDictionary *messageDict in [(NSDictionary*)element allValues]){
					FCMessage *message = [[FCMessage alloc] init];
					[message updateWithDictionary:messageDict];
					[messagesArray addObject:message];
				}
			}
			completion([NSArray arrayWithArray:messagesArray], nil);	
		}
		else{
			completion(nil, error);
		}
	}];
}

@end