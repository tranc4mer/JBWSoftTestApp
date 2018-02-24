//
//  VVStoregeManager.m
//  JBWSoftTestApp
//
//  Created by Viacheslav Varusha on 19.02.2018.
//  Copyright © 2018 Viacheslav Varusha. All rights reserved.
//

#import "VVStoregeManager.h"

@interface VVStoregeManager ()

@property (strong, nonatomic) NSMutableDictionary *globalRecordForCurrentUser;
@property (assign, nonatomic) NSInteger currentUserId;
@property (strong, nonatomic) NSString *keyForCurentUserId;

- (NSMutableDictionary*) nSDataToMutableDict:(NSData*) data;

@end

@implementation VVStoregeManager

- (instancetype) initWithUserId:(NSInteger) currentUserId
{
    self = [super init];
    if (self) {
//        self.currentUserId = currentUserId;
        self.globalRecordForCurrentUser = [[NSMutableDictionary alloc] init];
        self.keyForCurentUserId = [NSString stringWithFormat:@"%ld", currentUserId];
        
        //in function
        NSData *buferData = [[NSUserDefaults standardUserDefaults] objectForKey:@"records"];
//        NSDictionary *dictForRecords = (NSDictionary*) [NSKeyedUnarchiver unarchiveObjectWithData:buferData];
        NSMutableDictionary *rootDictionaryUnarhivedFromNSData = [self nSDataToMutableDict:buferData];
//        [NSMutableDictionary dictionaryWithDictionary:dictForRecords];
        
        
        //in function
        
        if ([rootDictionaryUnarhivedFromNSData objectForKey:self.keyForCurentUserId]){
            
            NSData *currentUserDictInData = [rootDictionaryUnarhivedFromNSData objectForKey:self.keyForCurentUserId];
            
//            NSDictionary *curentUserDictInDict = (NSDictionary*) [NSKeyedUnarchiver unarchiveObjectWithData:currentUserDictInData];
            self.globalRecordForCurrentUser = [self nSDataToMutableDict:currentUserDictInData];
//            [NSMutableDictionary dictionaryWithDictionary:curentUserDictInDict];
            
            
        }
        else
        {
            NSMutableDictionary *newUserInitialDict = [[NSMutableDictionary alloc] init];
//            [newUserInitialDict setObject:@"YES" forKey:@"InitUserDict"];
            
//            [rootDictionaryUnarhivedFromNSData setObject:@"3" forKey:@"spaces"];
            
            self.globalRecordForCurrentUser = newUserInitialDict;
            // function
            rootDictionaryUnarhivedFromNSData = [self setDataFromDict:newUserInitialDict forKey:self.keyForCurentUserId toDict:rootDictionaryUnarhivedFromNSData];
            NSLog(@"Root Dict:%@", rootDictionaryUnarhivedFromNSData);
//
            NSData *rootDictToUserDefaultsInData = [NSKeyedArchiver archivedDataWithRootObject:rootDictionaryUnarhivedFromNSData];
            // function
            [[NSUserDefaults standardUserDefaults] setObject:rootDictToUserDefaultsInData forKey:@"records"];
            
//            [globalMutableDictForCurrentUserUnarchivedFromData setObject:self.globalRecordForCurrentUser forKey:self.keyForCurentUserId];
//            [[NSUserDefaults standardUserDefaults] setObject:globalMutableDictForCurrentUserUnarchivedFromData forKey:@"records"];
        }
    }
    return self;
}

+ (VVStoregeManager*) sharedManager {
    
    static VVStoregeManager* manager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[VVStoregeManager alloc] init];
    });
    
    return manager;
}

- (NSDictionary*)getHistoryRecord{
    NSLog(@"dict in method to return from VVStorage %@", self.globalRecordForCurrentUser);
    return (NSDictionary*)self.globalRecordForCurrentUser;
}

- (void) updateHistoryRecordWithDictionary:(NSDictionary*) dictionary{
    NSMutableDictionary *resultDict = [[NSMutableDictionary alloc] init];
    NSArray *arrayOfKeysInLocalDictionary = [dictionary allKeys];
    NSInteger count;
    NSString *countInString;
    for (NSString *key in arrayOfKeysInLocalDictionary){
        count = [[dictionary objectForKey:key] integerValue];
        if ([self.globalRecordForCurrentUser objectForKey:key]) {
            count = count + [[self.globalRecordForCurrentUser objectForKey:key] integerValue];
        }
        countInString = [NSString stringWithFormat:@"%ld", count];
        [self.globalRecordForCurrentUser setObject:countInString forKey:key];
    }
    NSData *currentUserDictInData = [NSKeyedArchiver archivedDataWithRootObject:self.globalRecordForCurrentUser];
    NSData *beforeUpdateData = [[NSUserDefaults standardUserDefaults] objectForKey:@"records"];
    
    resultDict = [self nSDataToMutableDict:beforeUpdateData];
    [resultDict setObject:currentUserDictInData forKey:self.keyForCurentUserId];
    
    NSData *afterUpdateData = [NSKeyedArchiver archivedDataWithRootObject:resultDict];

    [[NSUserDefaults standardUserDefaults] setObject:afterUpdateData forKey:@"records"];
}
#pragma mark - Convertor, Dictiorary load via NSData
- (NSMutableDictionary*) nSDataToMutableDict:(NSData*) data{
    
    NSDictionary *dictForRecords = (NSDictionary*) [NSKeyedUnarchiver unarchiveObjectWithData:data];
    NSMutableDictionary *resultMutableDict = [NSMutableDictionary dictionaryWithDictionary:dictForRecords];
    return resultMutableDict;
};
- (NSMutableDictionary*) setDataFromDict:(NSMutableDictionary*) dict forKey:(NSString*) key toDict:(NSMutableDictionary*) originalDict {
//     [self setDataFromDict:newUserInitialDict forKey:self.keyForCurentUserId toDict:rootDictionaryUnarhivedFromNSData];
    NSData *recordDataForCurrentUser = [NSKeyedArchiver archivedDataWithRootObject:dict];
    [originalDict setObject:recordDataForCurrentUser forKey:key];
    return originalDict;
}

@end
