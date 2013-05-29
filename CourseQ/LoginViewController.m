//
//  LoginViewController.m
//  CourseQ
//
//  Created by Jing on 13-5-13.
//  Copyright (c) 2013年 jing. All rights reserved.
//

#import "LoginViewController.h"
#import "WebSchoolLoginViewController.h"
#import "LoginViewControllerDelegate.h"

@interface LoginViewController () <LoginViewControllerDelegate>
@property (assign, nonatomic) BOOL isFirstTime;
@end

@implementation LoginViewController

#pragma mark - show VCs

- (void)showWebSchoolLoginAnimated:(BOOL)flag {
    
    WebSchoolLoginViewController *webSchoolLoginVC = [[[WebSchoolLoginViewController alloc] initWithNibName:@"WebSchoolLoginViewController" bundle:nil] autorelease];
    [webSchoolLoginVC setDelegate:self];
    
    [self presentViewController:webSchoolLoginVC animated:flag completion:NULL];
    
}

#pragma mark - delegate

- (void)didFinishLogin {
    
    [self dismissViewControllerAnimated:NO completion:^{
        self.loginFinish = YES;
    }];
}

- (void)didCancelLogin {
    [self dismissViewControllerAnimated:YES completion:NULL];
}


#pragma mark - VC lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.isFirstTime = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    
    if (self.isFirstTime) {
        [self showWebSchoolLoginAnimated:NO];
        self.isFirstTime = NO;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [super dealloc];
}
@end
