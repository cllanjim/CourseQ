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

@interface RootViewController ()

@property (retain, nonatomic) LoginViewController *loginVC;
@property (retain, nonatomic) ContentsViewController *contentsVC;
@property (retain, nonatomic) ListViewController *listVC;
@property (retain, nonatomic) MakerViewController *makerVC;
@property (retain, nonatomic) ProfileViewController *profileVC;

@end

@implementation RootViewController

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
    // NSLog(@"rootVC");
}

- (void)viewWillAppear:(BOOL)animated {
    
    self.loginVC = [[[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil] autorelease];
    [self.loginVC addObserver:self forKeyPath:@"loginFinish" options:NSKeyValueObservingOptionNew context:nil];
    [self displayContentController:self.loginVC];
}

- (void)viewWillDisappear:(BOOL)animated {
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if ([keyPath isEqualToString:@"loginFinish"]) {
        
        //show ListVC
        self.listVC = [[[ListViewController alloc] initWithNibName:@"ListViewController" bundle:nil] autorelease];
        [self.listVC addObserver:self forKeyPath:@"leftPressed" options:NSKeyValueObservingOptionNew context:nil];
        [self displayContentController:self.listVC];
        
        //kill loginVC
        [self hideContentController:self.loginVC];
        [self.loginVC removeObserver:self forKeyPath:@"loginFinish"];
        self.loginVC = nil;
        [_loginVC release];
    }
    
    else if ([keyPath isEqualToString:@"leftPressed"]) {
        
        // NSLog(@"left");
        //add contentsVC below ListVC
        self.contentsVC = [[[ContentsViewController alloc] initWithNibName:@"ContentsViewController" bundle:nil] autorelease];
        [self.contentsVC addObserver:self forKeyPath:@"listPressed" options:NSKeyValueObservingOptionNew context:nil];
        [self.contentsVC addObserver:self forKeyPath:@"profilePressed" options:NSKeyValueObservingOptionNew context:nil];
        [self.contentsVC addObserver:self forKeyPath:@"settingPressed" options:NSKeyValueObservingOptionNew context:nil];
        [self displayContentController:self.contentsVC below:self.listVC.view];
        
        //move ListVC
        [self.listVC.view setFrame:CGRectMake(kLeftMaxBounds, 0, self.view.bounds.size.width, self.view.bounds.size.height)]; // 向左移动
        
    }
    
    else if ([keyPath isEqualToString:@"profilePressed"]) {
        
        //show profileVC
        self.profileVC = [[[ProfileViewController alloc] initWithNibName:@"ProfileViewController" bundle:nil] autorelease];
        [self displayContentController:self.profileVC];
        
        //kill ListVC
        [self hideContentController:self.listVC];
        [self.listVC removeObserver:self forKeyPath:@"leftPressed"];
        self.listVC = nil;
        [_listVC release];
        
        //kill contentsVC
        [self hideContentController:self.contentsVC];
        [self.contentsVC removeObserver:self forKeyPath:@"listPressed"];
        [self.contentsVC removeObserver:self forKeyPath:@"profilePressed"];
        [self.contentsVC removeObserver:self forKeyPath:@"settingPressed"];
        self.contentsVC = nil;
        [_contentsVC release];
    }
}

#pragma mark - transition of view controller

- (void)displayContentController:(UIViewController *)content{
    
    [self addChildViewController:content];
    [content.view setFrame:self.view.bounds];
    [self.view addSubview:content.view];
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
