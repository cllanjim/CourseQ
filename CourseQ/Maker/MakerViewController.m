//
//  MakerViewController.m
//  CourseQ
//
//  Created by Jing on 13-5-13.
//  Copyright (c) 2013年 jing. All rights reserved.
//

#import "MakerViewController.h"

#import "AudioViewController.h"
#import "CameraViewController.h"
#import "AlbumViewController.h"

#import "FilePathHelper.h"

@interface MakerViewController () <CameraViewControllerProtocol, AlbumViewControllerProtocol, AudioViewControllerProtocol>

@property (retain, nonatomic) FilePathHelper *filePathHelper;

@property (assign, nonatomic) BOOL isTheFirstTime;

@property (copy, nonatomic) NSString *imagePath;

@end

@implementation MakerViewController

#pragma mark - Camera

- (void)showCameraVCAnimated:(BOOL)flag
{
    CameraViewController *cameraVC = [[[CameraViewController alloc] initWithNibName:@"CameraViewController" bundle:nil] autorelease];
    
    [cameraVC setImageSavePath:[self.filePathHelper imagePath]];
    [cameraVC setDelegate:self];
    
    [self presentViewController:cameraVC animated:flag completion:NULL];
}

- (void)didMoveToAlbumVC
{
    [self dismissViewControllerAnimated:NO completion:^{
        [self showAlbumVCAnimated:NO];
    }];
}

- (void)didFinishWithCamera
{
    [self dismissViewControllerAnimated:NO completion:^{
        [self showAudioVCAnimated:YES];
    }];
}

- (void)didBackToListVC
{
    [self dismissViewControllerAnimated:NO completion:^{
        [self.delegate didCancelWithMaker:self];
    }];
}

#pragma mark - Album

- (void)showAlbumVCAnimated:(BOOL)flag
{
    AlbumViewController *albumVC = [[[AlbumViewController alloc] initWithNibName:@"AlbumViewController" bundle:nil] autorelease];
    
    [albumVC setImageSavePath:[self.filePathHelper imagePath]];
    [albumVC setDelegate:self];
    
    [self presentViewController:albumVC animated:flag completion:NULL];
}

- (void)didCancelWithAlbum
{
    [self dismissViewControllerAnimated:NO completion:^{
        [self showCameraVCAnimated:NO];
    }];
}

- (void)didFinishWithAlbum
{
    [self dismissViewControllerAnimated:NO completion:^{
        [self showAudioVCAnimated:YES];
    }];
}

#pragma mark - Audio

- (void)showAudioVCAnimated:(BOOL)flag
{
    AudioViewController *audioVC = [[[AudioViewController alloc] initWithNibName:@"AudioViewController" bundle:nil] autorelease];
    
    //savePath
    [audioVC setAudioSavePath:[self.filePathHelper audioPath]];
    [audioVC setImageSavePath:[self.filePathHelper imagePath]];
    [audioVC setPageNumber:[self.filePathHelper currentPage]];
    [audioVC setDelegate:self];
    
    [self presentViewController:audioVC animated:flag completion:NULL];
}

- (void)didCancelWithAudio
{
    [self dismissViewControllerAnimated:NO completion:^{
        [self.delegate didCancelWithMaker:self];
    }];
}

- (void)didFinishWithAudio
{
    [self dismissViewControllerAnimated:NO completion:^{
        
        NSInteger currentPath = self.filePathHelper.currentPage + 1;
        [self.filePathHelper setCurrentPage:currentPath];
        
        [self showCameraVCAnimated:YES];
    }];
}

- (void)didFinishWithMaker
{
    //预览& 上传
}

#pragma mark - VC lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.filePathHelper = [[FilePathHelper alloc] init];
    [self.filePathHelper setCurrentPage:0];
    
    self.isTheFirstTime = YES;
    [self.filePathHelper release];
}

- (void)viewDidAppear:(BOOL)animated {
    
    if (self.isTheFirstTime) {
        
        [self showCameraVCAnimated:NO];
        self.isTheFirstTime = NO;
    }
}

@end
