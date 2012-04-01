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

// managers
#import "FCLocalResourceManager.h"

@implementation FCService (Messages)

#pragma mark - CRUD

- (void)listMessagesWithCompletion:(ListMessagesCallback)completion
{	
	[self listObjects:[NSString stringWithFormat:@"%@.json", [[FCLocalResourceManager sharedInstance] getChatroom]] withOptions:nil completion:^(id element, NSError *error) {
		if (!error){
			NSMutableArray *messagesArray = [NSMutableArray array];
			if ([element isKindOfClass:[NSDictionary class]]){
				for (NSString *messageKey in [(NSDictionary*)element allKeys]){
					NSDictionary *messageDict = [((NSDictionary*)element) objectForKey:messageKey];
					FCMessage *message = [[FCMessage alloc] init];
					[message updateWithDictionary:messageDict];
					message.message_id = messageKey;
					[messagesArray addObject:message];
				}
			}
			else{
				completion([NSArray arrayWithArray:messagesArray], nil);
			}
			
			if ([messagesArray count] > 0){
				completion([messagesArray sortedArrayUsingComparator:^(id a, id b) {
					NSString *first = [(FCMessage*)a message_id];
					NSString *second = [(FCMessage*)b message_id];
					return [first compare:second];
				}], nil);
			}
		}
		else{
			completion(nil, error);
		}
	}];
}

@end