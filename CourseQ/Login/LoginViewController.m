//
//  LoginViewController.m
//  CourseQ
//
//  Created by Jing on 13-5-13.
//  Copyright (c) 2013年 jing. All rights reserved.
//

#import "LoginViewController.h"
#import "WebSchoolLoginViewController.h"

@interface LoginViewController () <WebSchoolLoginViewControllerProtocol>
@property (assign, nonatomic) BOOL isFirstTime;//avoid repeatly viewWillAppear function
@end

@implementation LoginViewController

#pragma mark - webschool

- (void)showWebSchoolLoginAnimated:(BOOL)flag
{
    WebSchoolLoginViewController *webSchoolLoginVC = [[[WebSchoolLoginViewController alloc] initWithNibName:@"WebSchoolLoginViewController" bundle:nil] autorelease];
    [webSchoolLoginVC setDelegate:self];
    
    [self presentViewController:webSchoolLoginVC animated:flag completion:NULL];
}

- (void)didFinishLogin
{
    [self dismissViewControllerAnimated:NO completion:^{
        [self.delegate didFinishLogin:self];
    }];
}

- (void)didCancelLogin
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - VC lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.isFirstTime = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
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
