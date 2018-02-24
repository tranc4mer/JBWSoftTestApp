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
#import <AudioToolbox/AudioToolbox.h>
#import "VVStoregeManager.h"

@interface VVLoginViewController () <UITextFieldDelegate> {
    NSLayoutConstraint *nameFieldConstraints;
    NSLayoutConstraint *submitButonConstraints;
}
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
- (BOOL) NSStringIsValidEmail:(NSString *)checkString;

//condtrsints for nameFieldAnimation
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *submitButtonTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameTextFieldLeadingConstraint;




@end

@implementation VVLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.nameFrame = self.nameTextField.frame;
    self.submitFrame = self.submitButton.frame;
    nameFieldConstraints.constant = self.nameTextFieldLeadingConstraint.constant;
    submitButonConstraints.constant = self.submitButtonTopConstraint.constant;

//    self.emailTextField.text = @"abba@gmail.com";
//    self.passwordTextField.text = @"1qaz2wsx";
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    
    
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
                                                    if ([response objectForKey:@"success"]){
                                                        
                                                        if (self.alertReJoinFix) {
                                                            [self login];
                                                        }
                                                      
UIAlertController * view=   [UIAlertController
                             alertControllerWithTitle:nil
                             message:nil

                             preferredStyle:UIAlertControllerStyleActionSheet];

UIAlertAction* SignupAndLogin = [UIAlertAction
                                     actionWithTitle:@"Signup and Login"
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction * action)
{
    [self login];
}];
                                                        
UIAlertAction* JustSignup = [UIAlertAction
                             actionWithTitle:@"Just Signup"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
{
    self.loginSegmentedControl.selectedSegmentIndex = 1;
    [self loginSchem];
    self.passwordTextField.text = @"";
}];
                                                        

[SignupAndLogin setValue:[UIColor redColor] forKey:@"titleTextColor"];
                                                        
[view addAction:SignupAndLogin];
[view addAction:JustSignup];
                                                        id rootViewController=[UIApplication sharedApplication].delegate.window.rootViewController;
                                                        if([rootViewController isKindOfClass:[UINavigationController class]])
                                                        {
                                                            rootViewController=[((UINavigationController *)rootViewController).viewControllers objectAtIndex:0];
                                                        }
                                                        [rootViewController presentViewController:view animated:YES completion:nil];
                                                  }
                                                    else{
                                                        self.passwordTextField.text = @"";
                                                        self.nameTextField.text = @"";
                                                        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                                                    }
                                                  } onFailure:^(NSError *error, NSInteger statusCode) {
                                                      NSLog(@"XXX Failed sending singUp Data XXX\n Error:%@\n Status code:%ld", error, statusCode);
                                                      if (statusCode == 0){
                                                          self.passwordTextField.text = @"";
                                                          self.nameTextField.text = @"";
                                                          AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                                                      }
                                                  }];
}
- (void) login{
    NSLog(@"Start login");
    [[VVServerManager sharedManager] postLoginWithEmail:self.emailTextField.text
                                                   passWord:self.passwordTextField.text
                                                  onSuccess:^(NSDictionary *response) {
                                                      NSLog(@"Start fetch login...\nResponce:%@", response);
//                                                      if ([response objectForKey:@"success"]){
                                                          [self obtainAccessToken:response];
//                                                      }
                                                  } onFailure:^(NSError *error, NSInteger statusCode) {
                                                      
                                                      NSLog(@"XXX Failed sending singUp Data XXX\n Error:%@\n Status code:%ld", error, statusCode);
                                                     
                                                      
                                                  }];
    // couldnot catch error when login not succes, so put a timer
    [NSTimer timerWithTimeInterval:6 repeats:NO block:^(NSTimer * _Nonnull timer) {
        self.emailTextField.text = @"";
        self.passwordTextField.text = @"";
        self.nameTextField.text = @"";
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }];
    
}

#pragma mark - token

- (void) obtainAccessToken:(NSDictionary *) responce {
//    [responce objectForKey:@"data"];
    NSString *token = [responce objectForKey:@"access_token"];
    [[VVServerManager sharedManager] updateAuthorizationHeader:token];
    NSInteger uid = [[responce objectForKey:@"uid"] integerValue];
    
    [[VVStoregeManager sharedManager] initWithUserId:uid];
    
    VVBaseViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"VVBaseViewController"];
    
    [self presentViewController:vc animated:YES completion:^{
        
    }];
    
}


#pragma mark - Actions

- (IBAction)submit:(id)sender {
    [self dismissKeyboard];
    if (self.loginSegmentedControl.selectedSegmentIndex == 0 ) {
        [self signup];
    }
    else{
        [self login];
    }
    
}

- (IBAction)loginSegmentedAction:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex == 1) {
        [self loginSchem];
    }
    else
    {
        [self signupSchem];
    }
}
#pragma  mark - Animations
- (void) loginSchem{
    [self.view layoutIfNeeded];
    self.nameTextFieldLeadingConstraint.constant = 2400;
    self.submitButtonTopConstraint.constant = submitButonConstraints.constant - CGRectGetHeight(self.nameTextField.frame);
    
    [UIView animateWithDuration:1
                     animations:^{
                         [self.view layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {
           }];
}
- (void) signupSchem{
[self.view layoutIfNeeded];
self.nameTextFieldLeadingConstraint.constant = nameFieldConstraints.constant;
self.submitButtonTopConstraint.constant = submitButonConstraints.constant + 20;
[UIView animateWithDuration:1
                 animations:^{
                     [self.view layoutIfNeeded];
                 }];
}
#pragma mark - gestures
- (void)dismissKeyboard {
    [self.nameTextField resignFirstResponder];
    [self.emailTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
}
// UITextFieldDelegate
#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if ([textField isEqual:self.emailTextField]){
        [self.passwordTextField becomeFirstResponder];
    }
    else if([textField isEqual:self.passwordTextField]) {
        if (self.loginSegmentedControl.selectedSegmentIndex == 0) {
             [self.nameTextField becomeFirstResponder];
        }
        else{
            [self dismissKeyboard];
        }
    }
    else if([textField isEqual:self.nameTextField]){
        [self signup];
        [self dismissKeyboard];
    }
    return YES;
}
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    if ([textField isEqual:self.emailTextField]){
        if([self NSStringIsValidEmail:self.emailTextField.text]){
            return YES;
        }
        else
        {
            textField.text = @"";
            textField.placeholder = @"Enter valid E-mail";
            return NO;
        };
    }
    else if ([textField isEqual:self.passwordTextField]){
        if(textField.text.length < 6){
            textField.text = @"";
            textField.placeholder = @"Password too short";
            return NO;
        }
        else return YES;
    }
    return YES;
}
#pragma mark - Validation

-(BOOL) NSStringIsValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = NO;
    NSString *stricterFilterString = @"^[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}$";
    NSString *laxString = @"^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}




@end
