//
//  FCLocalResourceManager.m
//  FireChat
//
//  Created by Terry Worona on 12-03-31.
//  Copyright (c) 2012 FireChat. All rights reserved.
//

#import "FCLocalResourceManager.h"

// constants
#import "FCConstants.h"

@interface FCLocalResourceManager ()

@end

@implementation FCLocalResourceManager

+ (FCLocalResourceManager *)sharedInstance
{
    static FCLocalResourceManager *_sharedClient = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedClient = [[self alloc] init];
    });    
    return _sharedClient;
}

#pragma mark - Alloc/Init

- (id)init 
{
    self = [super init];
    if (!self) {
        return nil;
    }
	return self;
}

#pragma mark - Helpers

- (NSUserDefaults*)userDefaults
{
	return [NSUserDefaults standardUserDefaults];
}

#pragma mark - Getters & setters

- (NSString*)getUsername;
{
	NSString *currentUsername = [[self userDefaults] objectForKey:kFCUserDefaultUsername];
	return currentUsername ? currentUsername : @"JohnDoe";
}

- (NSString*)getChatroom
{
	NSString *currentChatroom = [[self userDefaults] objectForKey:kFCUserDefaultChatroom];
	return 	currentChatroom ? currentChatroom : @"chat";
}

- (void)setUsername:(NSString*)username
{
	if (username && [username length] > 0){
		[[self userDefaults] setObject:username forKey:kFCUserDefaultUsername];
		[[self userDefaults] synchronize];	
	}
}

- (void)setChatroom:(NSString*)chatroom
{
	if (chatroom && [chatroom length] > 0){
		[[self userDefaults] setObject:chatroom forKey:kFCUserDefaultChatroom];
		[[self userDefaults] synchronize];	
	}
}

@end