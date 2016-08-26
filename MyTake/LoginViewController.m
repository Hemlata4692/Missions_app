//
//  ViewController.m
//  MyTake
//
//  Created by Hema on 12/07/16.
//  Copyright © 2016 Ranosys. All rights reserved.
//

#import "LoginViewController.h"
#import "LoginModel.h"
#import "UIImage+deviceSpecificMedia.h"
#import "MainSideBarViewController.h"
#import "BSKeyboardControls.h"
#import "UITextField+Validations.h"
#import "UITextField+Padding.h"
#import "UIView+RoundedCorner.h"

@interface LoginViewController ()<UITextFieldDelegate,BSKeyboardControlsDelegate> {
    NSArray *textFieldArray;
}
@property (weak, nonatomic) IBOutlet UIScrollView *loginScrollView;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIView *loginContainerView;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *accessCodeTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (strong, nonatomic) BSKeyboardControls *keyboardControls;
@end

@implementation LoginViewController
@synthesize backgroundImageView;
@synthesize loginScrollView;
@synthesize loginContainerView;
@synthesize usernameTextField;
@synthesize passwordTextField;
@synthesize accessCodeTextField;
@synthesize loginButton;

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    //Adding textfield to keyboard controls array
    textFieldArray = @[usernameTextField,passwordTextField,accessCodeTextField];
    [self setKeyboardControls:[[BSKeyboardControls alloc] initWithFields:textFieldArray]];
    [self.keyboardControls setDelegate:self];
    //set background image according to device
    UIImage * tempImg =[UIImage imageNamed:@"bg"];
    backgroundImageView.image = [UIImage imageNamed:[tempImg imageForDeviceWithName:@"bg"]];
    //add border and corner radius to textfields
    [self addBorderCornerRadius];
    //set username saved in defautls
    usernameTextField.text=[UserDefaultManager getValue:@"userName"];
    accessCodeTextField.text=[UserDefaultManager getValue:@"accessCode"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}
#pragma mark - end

#pragma mark - Custom accessors
//add corner radius and border to objects
- (void)addBorderCornerRadius {
    [usernameTextField setTextBorder:usernameTextField color:[UIColor whiteColor]];
    [passwordTextField setTextBorder:passwordTextField color:[UIColor whiteColor]];
    [accessCodeTextField setTextBorder:accessCodeTextField color:[UIColor whiteColor]];
    [usernameTextField setCornerRadius:20.0];
    [passwordTextField setCornerRadius:20.0];
    [accessCodeTextField setCornerRadius:20.0];
    [loginButton setCornerRadius:20.0];
}
#pragma mark - end

#pragma mark - Keyboard control delegate
- (void)keyboardControls:(BSKeyboardControls *)keyboardControls selectedField:(UIView *)field inDirection:(BSKeyboardControlsDirection)direction{
    UIView *view;
    view = field.superview.superview.superview;
}

- (void)keyboardControlsDonePressed:(BSKeyboardControls *)keyboardControls{
    [loginScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    [keyboardControls.activeField resignFirstResponder];
}
#pragma mark - end

#pragma mark - Textfield delegates
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    [self.keyboardControls setActiveField:textField];
    if (textField==usernameTextField) {
        if([[UIScreen mainScreen] bounds].size.height<568)  {
            [loginScrollView setContentOffset:CGPointMake(0, 45) animated:YES];
        }
    }
    else if (textField==passwordTextField) {
        if([[UIScreen mainScreen] bounds].size.height<568){
            [loginScrollView setContentOffset:CGPointMake(0, 90) animated:YES];
        }
    }
    else if (textField==accessCodeTextField) {
        if([[UIScreen mainScreen] bounds].size.height<568){
            [loginScrollView setContentOffset:CGPointMake(0, 90) animated:YES];
        }
        else  if([[UIScreen mainScreen] bounds].size.height==568){
            [loginScrollView setContentOffset:CGPointMake(0, 75) animated:YES];
        }
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    //allow only numeric value in access text field
    if (textField==accessCodeTextField) {
        // allow backspace
        if (!string.length)
        {
            return YES;
        }
        if ([string intValue] || [string isEqualToString:@"0"])
        {
            return YES;
        }
        return NO;
    }
    else {
        return YES;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [loginScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    [textField resignFirstResponder];
    return YES;
}
#pragma mark - end

#pragma mark - Login validation
- (BOOL)performValidationsForLogin{
    if ([usernameTextField isEmpty] || [passwordTextField isEmpty] || [accessCodeTextField isEmpty]) {
        SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
        [alert showWarning:self title:@"Alert" subTitle:@"All fields are mandatory." closeButtonTitle:@"Done" duration:0.0f];
        return NO;
    }
    else {
        return YES;
    }
}
#pragma mark - end

#pragma mark - IBActions
- (IBAction)loginButtonAction:(UIButton *)sender {
    [self.keyboardControls.activeField resignFirstResponder];
    [loginScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    //perform login validations
    if([self performValidationsForLogin]) {
        [myDelegate showIndicator];
        [self performSelector:@selector(getCommunitycode) withObject:nil afterDelay:.1];
    }
}

#pragma mark - end

#pragma mark - Webservice
//community code webservice called
- (void)getCommunitycode {
    LoginModel *getCommunitycode = [LoginModel sharedUser];
    getCommunitycode.code=accessCodeTextField.text;
    [getCommunitycode communityCodeOnSuccess:^(LoginModel *userData) {
        NSLog(@"login view controller COde %@",userData);
        [self userLogin];
    } onfailure:^(NSError *error) {
        
    }];
}

//user login webservice called
- (void)userLogin {
    LoginModel *userLogin = [LoginModel sharedUser];
    userLogin.userName = usernameTextField.text;
    userLogin.password = passwordTextField.text;
    [userLogin loginUserOnSuccess:^(LoginModel *userData) {
        [self saveDeviceToken];
        NSLog(@"login view controller userLogin %@",userData);
        [UserDefaultManager setValue:userLogin.userName key:@"userName"];
        [UserDefaultManager setValue:userLogin.userImage key:@"userImage"];
        [UserDefaultManager setValue:userLogin.userId key:@"userId"];
        [UserDefaultManager setValue:userLogin.password key:@"password"];
        [UserDefaultManager setValue:userLogin.code key:@"accessCode"];
        [UserDefaultManager setValue:userLogin.apiKey key:@"apiKey"];
        [UserDefaultManager setValue:userLogin.baseUrl key:@"communityLink"];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        MainSideBarViewController * homeView = [storyboard instantiateViewControllerWithIdentifier:@"MainSideBarViewController"];
        [myDelegate.window setRootViewController:homeView];
        [myDelegate.window makeKeyAndVisible];
    } onfailure:^(NSError *error) {
        
    }];
}

//save device token for push notifications
-(void)saveDeviceToken {
     LoginModel *saveDeviceToken = [LoginModel sharedUser];
    [saveDeviceToken saveDeviceToken:^(LoginModel *deviceToken) {
        NSLog(@"login view controller userLogin %@",deviceToken);
        [myDelegate stopIndicator];
    } onfailure:^(NSError *error) {
        
    }];
}
#pragma mark - end

@end
