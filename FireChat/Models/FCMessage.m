//
//  FCMessage.m
//  FireChat
//
//  Created by Terry Worona on 12-03-28.
//  Copyright (c) 2012 FireChat. All rights reserved.
//

#import "FCMessage.h"

@implementation FCMessage

@synthesize name, text, message_id;

#pragma mark - Init/Alloc

- (id)init
{
	self = [super init];
	if (self){
		// nothing to do here
	}
	return self;
}

#pragma mark - Update

- (void)updateWithDictionary:(NSDictionary *)dict
{
	if (dict){
		self.name = [dict objectForKey:@"name"];
		self.text = [dict objectForKey:@"text"];
	}
}

#pragma mark - Memory Management

- (void)dealloc
{
	[name release];
	[text release];
	[message_id release];
	[super dealloc];
}

@end