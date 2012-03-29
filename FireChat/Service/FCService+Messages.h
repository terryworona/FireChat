//
//  FCService+Messages.h
//  FireChat
//
//  Created by Terry Worona on 12-03-28.
//  Copyright (c) 2012 FireChat. All rights reserved.
//

#import "FCService.h"

typedef void (^ListMessagesCallback)(NSArray* messages, NSError *error);

@interface FCService (Messages)

#pragma mark - CRUD

- (void)listMessagesWithCompletion:(ListMessagesCallback)completion;

@end