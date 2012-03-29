//
//  FCService.m
//  FireChat
//
//  Created by Terry Worona on 12-03-28.
//  Copyright (c) 2012 FCService. All rights reserved.
//

#import "FCService.h"

#import "FCConstants.h"

@implementation FCService

#pragma mark - Singleton

+ (FCService *)sharedInstance
{
    static FCService *_sharedClient = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:kFCBaseUrl]];
    });    
    return _sharedClient;
}

#pragma mark - Alloc/Init

- (id)initWithBaseURL:(NSURL *)url 
{
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];	
	[self setDefaultHeader:@"Accept" value:@"application/json"];
	return self;
}

#pragma mark - CRUD

- (void)listObjects:(NSString *)objectType withOptions:(NSDictionary *)options completion:(ObjectCallback)completion
{
	NSLog(@"Service - list for object type %@", objectType);
	[self getPath:objectType parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
		completion(responseObject, nil);
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		completion(nil, error);
	}];
}

@end