//
//  BaseViewController.m
//  CourseQ
//
//  Created by Fee Val on 13-5-13.
//  Copyright (c) 2013年 jing. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

#pragma mark Override touch methods

// Check touch position in this method (Add by Ethan, 2011-11-27)
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch=[touches anyObject];
    touchBeganPoint = [touch locationInView:[[UIApplication sharedApplication] keyWindow]];
}

// Scale or move select view when touch moved (Add by Ethan, 2011-11-27)
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:[[UIApplication sharedApplication] keyWindow]];
    
    CGFloat xOffSet = touchPoint.x - touchBeganPoint.x;
    
    // if (self.isRightSideLocked && touchPoint.x < touchBeganPoint.x) 先锁住右侧屏幕
    if (touchPoint.x < touchBeganPoint.x)
    {
        xOffSet = 0;
    }
    
    if(self.isLeftSideLocked && touchPoint.x > touchBeganPoint.x)
    {
        xOffSet = 0;
    }
    
    if (xOffSet >= kLeftMaxBounds) {
        xOffSet = kLeftMaxBounds;
    }
    
    if (xOffSet <= kRightMaxBounds) {
        // if (xOffSet <= kRightMaxBounds - kTriggerOffSet*2) { // 弹性
        xOffSet = kRightMaxBounds;
    }
    
   // WebSAppDelegate *appDelegate = (WebSAppDelegate *)[[UIApplication sharedApplication] delegate];
    if (xOffSet < 0) {
        // [appDelegate makeRightViewVisible];
    }
    else if (xOffSet > 0) {
      //  [appDelegate makeLeftViewVisible];
    }
    
    self.view.frame = CGRectMake(xOffSet,
                                                      self.view.frame.origin.y,
                                                      self.view.frame.size.width,
                                                      self.view.frame.size.height);
}

// reset indicators when touch ended (Add by Ethan, 2011-11-27)
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    // animate to left side
    if (self.view.frame.origin.x < -kTriggerOffSet + kTriggerOffSet)
        [self moveToLeftSide];
    // animate to right side
    else if (self.view.frame.origin.x > kTriggerOffSet)
        [self moveToRightSide];
    // reset
    else
        [self restoreViewLocation];
}

#pragma mark Other methods

// restore view location
- (void)restoreViewLocation{
    homeViewIsOutOfStage = NO;
    
    BaseViewController *weakNaviC = self;
    [UIView animateWithDuration:0.3
                     animations:^{
                         weakNaviC.view.frame = CGRectMake(0,
                                                           weakNaviC.view.frame.origin.y,
                                                           weakNaviC.view.frame.size.width,
                                                           weakNaviC.view.frame.size.height);
                     }
                     completion:^(BOOL finished){
                         
                         UIControl *overView = (UIControl *)[[[UIApplication sharedApplication] keyWindow] viewWithTag:10086];
                         [overView removeFromSuperview];
                     }];
}

// move view to left side
- (void)moveToLeftSide {
    homeViewIsOutOfStage = YES;
    
    [self animateHomeViewToSide:CGRectMake(kRightMaxBounds,
                                           self.view.frame.origin.y,
                                           self.view.frame.size.width,
                                           self.view.frame.size.height)];
}

// move view to right side
- (void)moveToRightSide {
    homeViewIsOutOfStage = YES;
    [self animateHomeViewToSide:CGRectMake(kLeftMaxBounds,
                                           self.view.frame.origin.y,
                                           self.view.frame.size.width,
                                           self.view.frame.size.height)];
}

// animate home view to side rect
- (void)animateHomeViewToSide:(CGRect)newViewRect {
    [UIView animateWithDuration:0.2
                     animations:^{
                         self.view.frame = newViewRect;
                     }
                     completion:^(BOOL finished){
                         UIControl *overView = [[UIControl alloc] init];
                         overView.tag = 10086;
                         // overView.backgroundColor = [UIColor clearColor];
                         overView.frame = self.view.frame;
                         [overView addTarget:self action:@selector(restoreViewLocation) forControlEvents:UIControlEventTouchDown];
                         [[[UIApplication sharedApplication] keyWindow] addSubview:overView];
                         [overView release];
                     }];
}

#pragma mark - Handlers

// handle left bar btn
- (IBAction)leftBarBtnTapped:(id)sender {
    
    self.leftPressed = YES;
    [self moveToRightSide];
}

// handle right bar btn
- (IBAction)rightBarBtnTapped:(id)sender {
    

    [self moveToLeftSide];
}


#pragma mark - Defaults
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
