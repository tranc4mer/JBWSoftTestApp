//
//  VVServerManager.m
//  JBWSoftTestApp
//
//  Created by Viacheslav Varusha on 11.02.2018.
//  Copyright © 2018 Viacheslav Varusha. All rights reserved.
//

#define BASE_URL @"https://apiecho.cf/api/"

#import "VVServerManager.h"
#import "AFNetworking.h"

@interface VVServerManager ()

@property (strong, nonatomic) AFHTTPSessionManager *manager;

@end
@implementation VVServerManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        NSURL *url = [NSURL URLWithString:BASE_URL];
        
        self.manager = [[AFHTTPSessionManager alloc] initWithBaseURL:url];
    }
    return self;
}

+ (VVServerManager*) sharedManager {
    
    static VVServerManager* manager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[VVServerManager alloc] init];
    });
    
    return manager;
}
- (void) postlogOutOnSuccess:(void(^)(void)) success
                   onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure{
    NSDictionary *params;
    
    [self.manager POST:@"logout/" parameters:params progress:nil success:^(NSURLSessionTask *task, id responseObject) {
     
        if (success){
           NSLog(@"Logoff compleate");
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        if (failure){
            failure(error, 0);
        }
        NSLog(@"Error: %@", error);
    }];
}



- (void) postSignupWithUserName:(NSString*) name
                       passWord:(NSString*) passWord
                       andEmail:(NSString*) email
                      onSuccess:(void(^)(NSDictionary *responseObject)) success
                      onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure{
    
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSDictionary *params = @{@"name": name,
                             @"email": email,
                             @"password": passWord};
   
    [self.manager POST:@"signup/" parameters:params progress:nil success:^(NSURLSessionTask *task, id responseObject) {
//        NSLog(@"JSON: %@", responseObject);
        if (success){
            success(responseObject);
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        if (failure){
            failure(error, 0);
        }
        NSLog(@"Error: %@", error);
    }];
}

    - (void) postLoginWithEmail:(NSString*) email
                       passWord:(NSString*) passWord
                      onSuccess:(void(^)(NSDictionary *responseObject)) success
                      onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure{
    
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSDictionary *params = @{@"email": email,
                             @"password": passWord};
        
    [self.manager POST:@"login/" parameters:params progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSDictionary *dict = [responseObject objectForKey:@"data"];
        if (success){
            success(dict);
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}
- (void) getTextWithLocale:(NSString*) locale
                 OnSuccess:(void(^)(NSDictionary *responce)) success
                onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure{
    
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    NSDictionary *params = @{@"locale": locale};
     NSLog(@"withLocale:%@", params);
//
    [self.manager GET:@"get/text/" parameters:params progress:nil success:^(NSURLSessionTask *task, id responseObject) {
//        NSLog(@"responseObject:%@", responseObject);
        NSDictionary *dict = responseObject;
        if (success){
            success(dict);
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

#pragma - mark Autorization
- (void)updateAuthorizationHeader:(NSString *)token
{
   [self.manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", token] forHTTPHeaderField:@"Authorization"];
}
@end
