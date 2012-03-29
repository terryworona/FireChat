//
//  FCService.h
//  FireChat
//
//  Created by Terry Worona on 12-03-28.
//  Copyright (c) 2012 FireChat. All rights reserved.
//

#import <Foundation/Foundation.h>

// AFNetworking
#import "AFHTTPClient.h"
#import "AFJSONRequestOperation.h"

typedef void (^ObjectCallback)(id element, NSError *error);

typedef enum {
	RequestCreate,
	RequestUpdate,
	RequestGet,
	RequestDelete,
	RequestList,
} Request;

@interface FCService : AFHTTPClient

+ (FCService *)sharedInstance;

- (void)listObjects:(NSString *)objectType withOptions:(NSDictionary *)options completion:(ObjectCallback)completion;

@end
