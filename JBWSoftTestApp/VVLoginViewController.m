//
//  ViewController.m
//  JBWSoftTestApp
//
//  Created by Viacheslav Varusha on 11.02.2018.
//  Copyright © 2018 Viacheslav Varusha. All rights reserved.
//

#import "VVLoginViewController.h"
#import "VVServerManager.h"
#import "VVBaseViewController.h"

@interface VVLoginViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@property (weak, nonatomic) IBOutlet UISegmentedControl *loginSegmentedControl;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;

@property (assign, nonatomic) CGRect nameFrame;
@property (assign, nonatomic) CGRect submitFrame;

- (IBAction)submit:(id)sender;

- (IBAction)loginSegmentedAction:(UISegmentedControl *)sender;

- (void) obtainAccess_token:(NSDictionary *) responce;





@end

@implementation VVLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.nameFrame = self.nameTextField.frame;
    self.submitFrame = self.submitButton.frame;
    //
    self.emailTextField.text = @"abba@gmail.com";
    self.passwordTextField.text = @"1qaz2wsx";
    
    
    
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - API

- (void) signup{
    
    [[VVServerManager sharedManager] postSignupWithUserName:self.nameTextField.text
                                                   passWord:self.passwordTextField.text
                                                   andEmail:self.emailTextField.text
                                                  onSuccess:^(NSDictionary *response){
                                                      NSLog(@"sending...\nResponce:%@", response);
//                                                    if ([response objectForKey:@"success"] == 1){
                                                      [self obtainAccessToken:response];
//                                                  }
                                                  } onFailure:^(NSError *error, NSInteger statusCode) {
                                                      NSLog(@"XXX Failed sending singUp Data XXX\n Error:%@\n Status code:%ld", error, statusCode);
                                                  }];
}
- (void) login{
    NSLog(@"Start login");
    [[VVServerManager sharedManager] postLoginWithEmail:self.emailTextField.text
                                                   passWord:self.passwordTextField.text
                                                  onSuccess:^(NSDictionary *response) {
                                                      NSLog(@"Start fetch login...\nResponce:%@", response);
//                                                      if ([response objectForKey:@"success"] == 1){
                                                          [self obtainAccessToken:response];
//                                                      }
                                                  } onFailure:^(NSError *error, NSInteger statusCode) {
                                                      NSLog(@"XXX Failed sending singUp Data XXX\n Error:%@\n Status code:%ld", error, statusCode);
                                                  }];
}

#pragma mark - token

- (void) obtainAccessToken:(NSDictionary *) responce {
//    [responce objectForKey:@"data"];
    NSString *token = [responce objectForKey:@"access_token"];
    [[VVServerManager sharedManager] updateAuthorizationHeader:token];
    
    
    VVBaseViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"VVBaseViewController"];
    
    [self presentViewController:vc animated:YES completion:^{
        
    }];
    
}


#pragma mark - Actions

- (IBAction)submit:(id)sender {
    if (self.loginSegmentedControl.selectedSegmentIndex == 0 ) {
        [self signup];
    }
    else{
        [self login];
    }
    
}

- (IBAction)loginSegmentedAction:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex == 1) {
        
        [UIView animateWithDuration:1
                         animations:^{
                             self.nameTextField.frame = CGRectMake(2400.f, CGRectGetMidY(self.nameFrame), 0.f, 0.f);
                             self.submitButton.frame = self.nameFrame;
                         }];
    }
    else
    {
        [UIView animateWithDuration:1
                         animations:^{
                             self.nameTextField.frame = self.nameFrame;
                             self.submitButton.frame = self.submitFrame;
                         }];
    }
}
@end
