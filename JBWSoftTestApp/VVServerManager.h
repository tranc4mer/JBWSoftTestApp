//
//  VVServerManager.h
//  JBWSoftTestApp
//
//  Created by Viacheslav Varusha on 11.02.2018.
//  Copyright © 2018 Viacheslav Varusha. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VVServerManager : NSObject

@property (strong, nonatomic) NSString *token;

+ (VVServerManager*) sharedManager;

- (void) postSignupWithUserName:(NSString*) name
                       passWord:(NSString*) passWord
                       andEmail:(NSString*) email
                      onSuccess:(void(^)(NSDictionary *responce)) success
                      onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure;

 - (void) postLoginWithEmail:(NSString*) email
                    passWord:(NSString*) passWord
                   onSuccess:(void(^)(NSDictionary *responce)) success
                   onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure;

- (void) postlogOutOnSuccess:(void(^)(void)) success
                   onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure;

- (void)updateAuthorizationHeader:(NSString *)token;

- (void) getTextWithLocale:(NSString*) locale
                 OnSuccess:(void(^)(NSDictionary *responce)) success
                 onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure;
@end
