//
//  RootViewController.m
//  CourseQ
//
//  Created by Jing on 13-5-13.
//  Copyright (c) 2013年 jing. All rights reserved.
//

#import "RootViewController.h"
#import "LoginViewController.h"
#import "ContentsViewController.h"
#import "ListViewController.h"
#import "MakerViewController.h"
#import "ProfileViewController.h"
#import "MainPage.h"
#import "BaseViewController.h"
#import "SettingViewController.h"

@interface RootViewController ()

@property (retain, nonatomic) LoginViewController *loginVC;
@property (retain, nonatomic) ContentsViewController *contentsVC;
@property (retain, nonatomic) ListViewController *listVC;
@property (retain, nonatomic) MakerViewController *makerVC;
@property (retain, nonatomic) ProfileViewController *profileVC;
@property (retain, nonatomic) SettingViewController *settingVC;

@end

@implementation RootViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Defaults

- (void)viewWillAppear:(BOOL)animated {
    
    //如果是第一次登陆，显示loginVC
    if (1) {
        self.loginVC = [[[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil] autorelease];
        [self.loginVC addObserver:self forKeyPath:@"loginFinish" options:NSKeyValueObservingOptionNew context:nil];
        [self displayContentController:self.loginVC animated:NO];
        
    }else {
        
        //如果不是第一次登陆，直接显示listVC
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    //当用户完成login时
    //加载listVC在loginVC上面
    //然后把loginVC干掉
    if ([keyPath isEqualToString:@"loginFinish"]) {
        
        //show ListVC
        self.listVC = [[[ListViewController alloc] initWithNibName:@"ListViewController" bundle:nil] autorelease];
        [self.listVC addObserver:self forKeyPath:@"leftPressed" options:NSKeyValueObservingOptionNew context:nil];
        [self displayContentController:self.listVC animated:NO];
        
        //kill loginVC
        [self hideContentController:self.loginVC];
        [self.loginVC removeObserver:self forKeyPath:@"loginFinish"];
        self.loginVC = nil;
        [_loginVC release];
    }
    
    //profileVC
    else if ([keyPath isEqualToString:@"profilePressed"]) {
        
        //kill all baseVC
        [self killAllBaseVCs];
        
        //show profileVC
        self.profileVC = [[[ProfileViewController alloc] initWithNibName:@"ProfileViewController" bundle:nil] autorelease];
        [self.profileVC addObserver:self forKeyPath:@"leftPressed" options:NSKeyValueObservingOptionNew context:nil];
        [self displayContentController:self.profileVC animated:YES];
        
        //kill contentsVC
        [self hideContentsVC];
    }
    
    else if ([keyPath isEqualToString:@"listPressed"]) {
        
        //kill all baseVC
        [self killAllBaseVCs];
        
        //show listVC
        self.listVC = [[[ListViewController alloc] initWithNibName:@"ListViewController" bundle:nil] autorelease];
        [self.listVC addObserver:self forKeyPath:@"leftPressed" options:NSKeyValueObservingOptionNew context:nil];
        [self displayContentController:self.listVC animated:YES];
        
        //kill contentsVC
        [self hideContentsVC];
    }
    
    else if ([keyPath isEqualToString:@"settingPressed"]) {
        
        //kill all baseVC
        [self killAllBaseVCs];
        
        //show settingVC
        self. settingVC= [[[SettingViewController alloc] initWithNibName:@"SettingViewController" bundle:nil] autorelease];
        [self.settingVC addObserver:self forKeyPath:@"leftPressed" options:NSKeyValueObservingOptionNew context:nil];
        [self displayContentController:self.settingVC   animated:YES];
        
        //kill contentsVC
        [self hideContentsVC];
    }

    //contentsVC
    else if ([keyPath isEqualToString:@"leftPressed"]) {
        
        //插入contentsVC
        [self showContentsVCBelow:(UIViewController *)object];
        
        //把原来的VC往右移
        [(BaseViewController *)object animateHomeViewToSide:CGRectMake(kLeftMaxBounds, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    }
    
}

#pragma mark - create & kill VC

- (void)killAllBaseVCs {
    
    if (self.listVC) {
        NSLog(@"list");
        [self hideContentController:self.listVC];
        [self.listVC removeObserver:self forKeyPath:@"leftPressed"];
        self.listVC = nil;
        [_listVC release];
    }
    
    if (self.profileVC) {
        NSLog(@"profile");
        [self hideContentController:self.profileVC];
        [self.profileVC removeObserver:self forKeyPath:@"leftPressed"];
        self.profileVC = nil;
        [_profileVC release];
    }
}

- (void)showContentsVCBelow:(UIViewController *)vc {
    
    if (!self.contentsVC) {
        self.contentsVC = [[[ContentsViewController alloc] initWithNibName:@"ContentsViewController" bundle:nil] autorelease];
        [self.contentsVC addObserver:self forKeyPath:@"listPressed" options:NSKeyValueObservingOptionNew context:nil];
        [self.contentsVC addObserver:self forKeyPath:@"profilePressed" options:NSKeyValueObservingOptionNew context:nil];
        [self.contentsVC addObserver:self forKeyPath:@"settingPressed" options:NSKeyValueObservingOptionNew context:nil];
    }
    [self displayContentController:self.contentsVC below:vc.view];
}

- (void)hideContentsVC {
    
    if (self.contentsVC) {
        [self hideContentController:self.contentsVC];
        [self.contentsVC removeObserver:self forKeyPath:@"listPressed"];
        [self.contentsVC removeObserver:self forKeyPath:@"profilePressed"];
        [self.contentsVC removeObserver:self forKeyPath:@"settingPressed"];
        self.contentsVC = nil;
        [_contentsVC release];
        
    }
    
}

#pragma mark - transition of view controller

- (void)displayContentController:(UIViewController *)content animated:(BOOL)animated{
    
    [self addChildViewController:content];
    [self.view addSubview:content.view];
    if (animated)
    {
        [content.view setFrame:CGRectMake(kLeftMaxBounds, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        [UIView animateWithDuration:kMenuSlideAnimationDuration animations:^{
            [content.view setFrame:self.view.bounds];
        }];
    }
    else
    {
        [content.view setFrame:self.view.bounds];
    }
    [content didMoveToParentViewController:self];
}

- (void)displayContentController:(UIViewController *)content below:(UIView *)view{
    
    [self addChildViewController:content];
    [content.view setFrame:self.view.bounds];
    [self.view insertSubview:content.view belowSubview:view];
    [content didMoveToParentViewController:self];
}

- (void)hideContentController:(UIViewController *)content{
    
    [content willMoveToParentViewController:nil];
    [content.view removeFromSuperview];
    [content removeFromParentViewController];
}

@end
