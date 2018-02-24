//
//  VVStoregeManager.h
//  JBWSoftTestApp
//
//  Created by Viacheslav Varusha on 19.02.2018.
//  Copyright © 2018 Viacheslav Varusha. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VVStoregeManager : NSObject

+ (VVStoregeManager*) sharedManager;

- (instancetype) initWithUserId:(NSInteger) currentUserId;

- (NSDictionary*)getHistoryRecord;

- (void) updateHistoryRecordWithDictionary:(NSDictionary*) dictionary;

@end
