//
//  FCLocalResourceManager.h
//  FireChat
//
//  Created by Terry Worona on 12-03-31.
//  Copyright (c) 2012 FireChat. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FCLocalResourceManager : NSObject

+ (FCLocalResourceManager *)sharedInstance;

#pragma mark - Getters & Setters 

// (ivars are not needed)

- (NSString*)getUsername;
- (NSString*)getChatroom;

- (void)setUsername:(NSString*)username;
- (void)setChatroom:(NSString*)chatroom;
- (void)setChatroom:(NSString *)chatroom andUsername:(NSString*)username;

@end
