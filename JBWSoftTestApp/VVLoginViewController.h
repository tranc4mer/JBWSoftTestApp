//
//  ViewController.h
//  JBWSoftTestApp
//
//  Created by Viacheslav Varusha on 11.02.2018.
//  Copyright © 2018 Viacheslav Varusha. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VVLoginViewController : UIViewController

@property (assign, nonatomic) BOOL alertReJoinFix;

- (void)updateAuthorizationHeader:(NSString *)token;




@end

