//
//  RootViewController.m
//  CourseQ
//
//  Created by Jing on 13-5-13.
//  Copyright (c) 2013年 jing. All rights reserved.
//

#import "RootViewController.h"


#import "ContentsViewController.h"
#import "ListViewController.h"
#import "MakerViewController.h"
#import "ProfileViewController.h"
#import "MainPage.h"
#import "BaseViewController.h"
#import "SettingViewController.h"
#import "CourseDataFetcher.h"
#import "CQReviewVC.h"


#import "CoverViewController.h"
#import "LoginViewController.h"
#import "LoginManager.h"

@interface RootViewController () <CoverViewControllerProtocol, LoginViewControllerProtocol, ListViewControllerDelegate, SettingViewControllerProtocol, ContentsViewControllerProtocol, CQReviewVCProtocol>

@property (retain, nonatomic) LoginViewController *loginVC;
@property (retain, nonatomic) ContentsViewController *contentsVC;
@property (retain, nonatomic) ListViewController *listVC;
@property (retain, nonatomic) MakerViewController *makerVC;
@property (retain, nonatomic) ProfileViewController *profileVC;
@property (retain, nonatomic) SettingViewController *settingVC;



@property (assign, nonatomic) BOOL isFirstTime; //to avoid repeatly viewWillAppear fuc
@property (retain, nonatomic) NSMutableArray *viewControllerStack;//only contain the one that currently shown in screen

@end

@implementation RootViewController

#pragma mark - VC lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.isFirstTime = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    
    if (self.isFirstTime) {
        
        //插入contentsVC
        [self showContentsVC];
        //[self.contentsVC.view setUserInteractionEnabled:NO];
        
        //if no login info saved in NSUserDefault, show loginVC
        LoginManager *loginManager = [[[LoginManager alloc] init] autorelease];
        BOOL isSavedUserInfo = [loginManager isSavedUserInfo];
        
        if (isSavedUserInfo) {
            [self showCoverVC];
            
        }else {
            [self showLoginVC];
        }
        
        self.isFirstTime = NO;
    }
}

- (NSMutableArray *)viewControllerStack
{
    if (_viewControllerStack == nil) {
        _viewControllerStack = [[[NSMutableArray alloc] init] autorelease];
        [_viewControllerStack retain];
    }
    return _viewControllerStack;
}

#pragma mark - Cover

- (void)showCoverVC
{
    CoverViewController *coverVC = [[[CoverViewController alloc] initWithNibName:@"CoverViewController" bundle:nil] autorelease];
    [coverVC setDelegate:self];
    [self displayContentController:coverVC animated:NO];
}

- (void)didSucceedAutomaticLogin:(UIViewController *)controller
{
    [self hideContentController:controller];
    [self showListVCRefresh:YES animated:NO];
}

- (void)didFailAutomaticLogin:(UIViewController *)controller
{
    [self hideContentController:controller];
    [self showListVCRefresh:YES animated:NO];
}

- (void)didFailToServer:(UIViewController *)controller
{
    //联网失败怎么办？
}

#pragma mark - Login

- (void)showLoginVC
{
    LoginViewController *loginVC = [[[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil] autorelease];
    [loginVC setDelegate:self];
    
    [self displayContentController:loginVC animated:NO];
}

- (void)didFinishLogin:(UIViewController *)controller
{
    [self hideContentController:controller];
    [self showListVCRefresh:YES animated:NO];
}

#pragma mark - List

- (void)showListVCRefresh:(BOOL)refresh animated:(BOOL)flag
{
    [self hideOnscreenViewController];
    
    ListViewController *listVC = [[[ListViewController alloc] initWithNibName:@"ListViewController" bundle:nil] autorelease];
    [listVC setDelegate:self];
    [listVC setRefresh:refresh];
    [listVC addObserver:self forKeyPath:@"isAnimating" options:NSKeyValueObservingOptionNew context:nil];
    
    [self displayContentController:listVC animated:flag];
    [self.viewControllerStack insertObject:listVC atIndex:0];
}

- (void)didSelectRowWithCourseFileName:(NSString *)name pageCount:(NSString *)count VC:(UIViewController *)controller
{
    [self hideContentController:controller];
    [self showDetailVCWithCourseFileName:name pageCount:count Animated:NO];
}

#pragma mark - Detail

- (void)showDetailVCWithCourseFileName:(NSString *)name pageCount:(NSString *)count Animated:(BOOL)flag 
{
    CQReviewVC *reviewVC = [[[CQReviewVC alloc] initWithNibName:@"CQReviewVC" bundle:nil] autorelease];
    [reviewVC setCourseFileName:name];
    [reviewVC setPageCount:count];
    [reviewVC setDelegate:self];
    //还要有个delegate，回到List页
    [self displayContentController:reviewVC animated:flag];
}

- (void)shouldBackToListVC:(UIViewController *)controller {
    [self hideContentController:controller];
    [self showListVCRefresh:NO animated:NO];
}

#pragma mark - Profile

- (void)showProfileVCAnimated:(BOOL)flag
{
    [self hideOnscreenViewController];
    
    ProfileViewController *profileVC = [[[ProfileViewController alloc] initWithNibName:@"ProfileViewController" bundle:nil] autorelease];
    [profileVC addObserver:self forKeyPath:@"isAnimating" options:NSKeyValueObservingOptionNew context:nil];
    
    [self displayContentController:profileVC animated:flag];
    [self.viewControllerStack insertObject:profileVC atIndex:0];
}

#pragma mark - Setting

- (void)showSettingVCAnimated:(BOOL)flag
{
    [self hideOnscreenViewController];
    
    SettingViewController *settingVC = [[[SettingViewController alloc] initWithNibName:@"SettingViewController" bundle:nil] autorelease];
    [settingVC setDelegate:self];
    [settingVC addObserver:self forKeyPath:@"isAnimating" options:NSKeyValueObservingOptionNew context:nil];
    
    [self displayContentController:settingVC animated:flag];
    [self.viewControllerStack insertObject:settingVC atIndex:0];
}

- (void)didFinishLogout
{
    [self hideOnscreenViewController];
    [self showLoginVC];
}

#pragma mark - Contents

- (void)showContentsVC
{
    [self displayContentController:self.contentsVC animated:NO];
}

- (ContentsViewController *)contentsVC
{
    if (_contentsVC == nil) {
        _contentsVC = [[[ContentsViewController alloc] initWithNibName:@"ContentsViewController" bundle:nil] autorelease];
        [_contentsVC setDelegate:self];
        [_contentsVC retain];
    }
    return _contentsVC;
}

- (void)didPressListVCBtn
{
    [self showListVCRefresh:NO animated:YES];
}

- (void)didPressProfileVCBtn
{
    [self showProfileVCAnimated:YES];
}

- (void)didPressSettingVCBtn
{
    [self showSettingVCAnimated:YES];
}

#pragma mark - hide onscreen vc

- (void)hideOnscreenViewController
{
    if ([self.viewControllerStack count]>0) {
        UIViewController *vc = self.viewControllerStack[0];
        if ([vc respondsToSelector:@selector(isAnimating)]) {
            [vc removeObserver:self forKeyPath:@"isAnimating"];
        }
        [self hideContentController:vc];
        [self.viewControllerStack removeObjectAtIndex:0];
    }
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {

    if ([keyPath isEqualToString:@"isAnimating"]) {
        if (((BaseViewController *)object).isAnimating) {
            [self.contentsVC.view setUserInteractionEnabled:NO];
        }else {
            [self.contentsVC.view setUserInteractionEnabled:YES];
        }
    }
}

#pragma mark - transition of view controller

- (void)displayContentController:(UIViewController *)content animated:(BOOL)animated{
    
    [self addChildViewController:content];
    [self.view addSubview:content.view];
    if (animated)
    {
        [content.view setFrame:CGRectMake(kLeftMaxBounds, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        [UIView animateWithDuration:0.3 animations:^{
            [content.view setFrame:self.view.bounds];
        }];
    }
    else
    {
        [content.view setFrame:self.view.bounds];
    }
    [content didMoveToParentViewController:self];
}

- (void)hideContentController:(UIViewController *)content{
    
    [content willMoveToParentViewController:nil];
    [content.view removeFromSuperview];
    [content removeFromParentViewController];
}

@end
