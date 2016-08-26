//
//  HelpViewController.m
//  MyTake
//
//  Created by Ranosys on 19/08/16.
//  Copyright © 2016 Ranosys. All rights reserved.
//

#import "HelpViewController.h"

@interface HelpViewController ()
@property (weak, nonatomic) IBOutlet UIView *mainContainerView;
@property (weak, nonatomic) IBOutlet UITextView *popUpTextView;
@property (strong, nonatomic) IBOutlet UIButton *okOutlet;

@end

@implementation HelpViewController
@synthesize helpText;

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.popUpTextView.text=helpText;
    //View customize according to help text
    [self viewCustomization];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - end

#pragma mark - Custom accessors
- (void)viewCustomization {
    
    [self.mainContainerView setCornerRadius:5.0f];
    [self.okOutlet setCornerRadius:20.0f];
    self.mainContainerView.translatesAutoresizingMaskIntoConstraints=YES;
    //Get dynamic height of textView
    float textViewHeight=([self.popUpTextView sizeThatFits:CGSizeMake([[UIScreen mainScreen] bounds].size.width-30, 185)].height<60?80:[self.popUpTextView sizeThatFits:CGSizeMake([[UIScreen mainScreen] bounds].size.width-30, 185)].height+10);
    //Resize mainContainerView according to help text and max height of mainContainerView is less than [[UIScreen mainScreen] bounds].size.height-150
    if ((textViewHeight+131)>[[UIScreen mainScreen] bounds].size.height-150) {
        
        self.mainContainerView.frame=CGRectMake(10,75, [[UIScreen mainScreen] bounds].size.width-20, [[UIScreen mainScreen] bounds].size.height-150);//here mainContainer view height=[[UIScreen mainScreen] bounds].size.height-150(here subtract 150 when size is more than (textViewHeight+131))
    }
    else {
        self.mainContainerView.frame=CGRectMake(10, ([[UIScreen mainScreen] bounds].size.height/2)-((textViewHeight+131)/2), [[UIScreen mainScreen] bounds].size.width-20, textViewHeight+131);//here mainContainer view height=textViewHeight+131(40(helpTitle height)+17(textView top space)+17(textView bottom space)+40(ok button height)+17(ok button bottom space))
    }
}
#pragma mark - end

#pragma mark - IBActions
- (IBAction)okAction:(UIButton *)sender {
    
    [self.presentingViewController dismissViewControllerAnimated:NO completion:nil];
}
#pragma mark - end
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
@end
