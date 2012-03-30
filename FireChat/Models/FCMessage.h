//
//  FCMessage.h
//  FireChat
//
//  Created by Terry Worona on 12-03-28.
//  Copyright (c) 2012 FireChat. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FCMessage : NSObject

@property (nonatomic, retain) NSString *message_id;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *text;

- (void)updateWithDictionary:(NSDictionary *)dict;

@end
