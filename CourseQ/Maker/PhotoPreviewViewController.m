//
//  PhotoPreviewViewController.m
//  CourseQ
//
//  Created by Jing on 13-5-15.
//  Copyright (c) 2013年 jing. All rights reserved.
//

#import "PhotoPreviewViewController.h"
#import "CapturedImageDisplayView.h"

@interface PhotoPreviewViewController ()

@property (retain, nonatomic) IBOutlet CapturedImageDisplayView *imageDisplayView;

@end

@implementation PhotoPreviewViewController

- (IBAction)backBtnPressed:(id)sender
{
    [self.delegate didBackToListVC];
}


- (IBAction)yesBtnPressed:(id)sender
{
    
    [self.delegate didFinishWithPhotoPreview:YES];
    
}

- (IBAction)noBtnPressed:(id)sender
{
    
    [self.delegate didFinishWithPhotoPreview:NO];
}

#pragma mark - VC lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.imageDisplayView setCapturedImage:self.capturedImage];
}

- (void)dealloc {
    [_capturedImage release];
    [_imageDisplayView release];
    [super dealloc];
}
@end
