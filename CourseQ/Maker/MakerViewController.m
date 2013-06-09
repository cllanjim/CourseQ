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
#import "CQPreviewVC.h"

#import "FilePathHelper.h"
#import "CoreDataManager.h"
#import <CoreData/CoreData.h>
#import "Unit+Fetcher.h"
#import "ConstantDefinition.h"
#import "UploadViewController.h"


@interface MakerViewController () <CameraViewControllerProtocol, AlbumViewControllerProtocol, AudioViewControllerProtocol, CQPreviewVCProtocol, UploadViewControllerProtocol>

@property (retain, nonatomic) FilePathHelper *filePathHelper;

@property (assign, nonatomic) BOOL isTheFirstTime;

@property (copy, nonatomic) NSString *imagePath;

@property (retain, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (retain, nonatomic) UINavigationController *naviC;

@end

@implementation MakerViewController

#pragma mark - Camera

- (void)showCameraVCAnimated:(BOOL)flag
{
    CameraViewController *cameraVC = [[CameraViewController alloc] initWithNibName:@"CameraViewController" bundle:nil];
    
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
    AlbumViewController *albumVC = [[AlbumViewController alloc] initWithNibName:@"AlbumViewController" bundle:nil];
    
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
    AudioViewController *audioVC = [[AudioViewController alloc] initWithNibName:@"AudioViewController" bundle:nil];
    
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
        
        if (self.filePathHelper) {
            NSLog(@"y");
            
        }else{
            NSLog(@"n");
        }
        
        NSInteger currentPath = self.filePathHelper.currentPage + 1;
        [self.filePathHelper setCurrentPage:currentPath];
        
        [self showCameraVCAnimated:YES];
         
    }];

}

- (void)didFinishWithMaker
{
    //预览& 上传
    //把路径存到CoreData里面
    if (!self.managedObjectContext) {
        [self useDemoDocument];
    }
}

#pragma mark - Preview

- (void)showPreviewVC
{
    CQPreviewVC *previewVC = [[CQPreviewVC alloc] initWithNibName:@"CQPreviewVC" bundle:nil];
    [previewVC setDelegate:self];
    [self presentViewController:previewVC animated:NO completion:NULL];
}

- (void)shouldUpload
{
    [self dismissViewControllerAnimated:NO completion:^{
        [self showUploadVC];
    }];
}

- (void)didCancelWithPreview
{
    [self dismissViewControllerAnimated:NO completion:^{
        [self.delegate didCancelWithMaker:self];
    }];
}

#pragma mark - Upload

- (void)showUploadVC
{
    UploadViewController *uploadVC = [[UploadViewController alloc] initWithNibName:@"UploadViewController" bundle:nil];
    [uploadVC setDelegate:self];
    [self presentViewController:uploadVC animated:NO completion:NULL];
}

- (void)didFinishWithUpload
{
    [self dismissViewControllerAnimated:NO completion:^{
        [self.delegate didCancelWithMaker:self];
    }];
}

- (void)didCancelWithUpload
{
    [self dismissViewControllerAnimated:NO completion:^{
        [self.delegate didCancelWithMaker:self];
    }];
}

#pragma mark - CoreData things

- (void)deleteLastTempDataFromCoreData
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Unit"];
    request.predicate = [NSPredicate predicateWithFormat:@"belongTo.uID = %@", TEMP_COURSE_UID];
    
    NSError *error = nil;
    NSArray *matches = [self.managedObjectContext executeFetchRequest:request error:&error];
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
        
    }else if ([matches count] > 0) {
        
        for (int i = 0; i < [matches count]; i++) {
            [self.managedObjectContext deleteObject:matches[i]];
        }
    }
    
}

- (void)startInsertInfoToCoreData
{
    NSInteger pageCount = [self.filePathHelper currentPage];
    
    [self.managedObjectContext performBlockAndWait:^{
        
        //删除原来的
        [self deleteLastTempDataFromCoreData];
        
        //添加新的
        for (int i = 0; i <= pageCount; i++) {
            [self.filePathHelper setCurrentPage:i];
            NSString *imgP = [self.filePathHelper imagePath];
            NSString *audP = [self.filePathHelper audioPath];
            NSString *page = [NSString stringWithFormat:@"%d", i];
            
            [Unit unitWithImagePath:imgP audioPath:audP page:page courseUID:TEMP_COURSE_UID inManagedObjectContext:self.managedObjectContext];
        }
        
        NSError *error = nil;
        [self.managedObjectContext save:&error];
        if (error) {
            NSLog(@"error: %@", [error localizedDescription]);
        }
    }];
    
    //dismiss audioVC
    //then show reviewVC
    [self dismissViewControllerAnimated:NO completion:^{
        [self showPreviewVC];
    }];
}

- (void)useDemoDocument{
    
    CoreDataManager *cdm = [CoreDataManager sharedInstance];
    UIManagedDocument *document = cdm.managedDocument;
    
    NSFileManager *fm = [NSFileManager defaultManager];
    
    if (![fm fileExistsAtPath:[cdm.documentURL path]]) {
        //create it
        [document saveToURL:cdm.documentURL
           forSaveOperation:UIDocumentSaveForCreating
          completionHandler:^(BOOL success) {
              if (success) {
                  self.managedObjectContext = document.managedObjectContext;
                  [self startInsertInfoToCoreData];
              }
          }];
        
    }else if (document.documentState == UIDocumentStateClosed){
        //open it
        [document openWithCompletionHandler:^(BOOL success) {
            if (success) {
                self.managedObjectContext = document.managedObjectContext;
                [self startInsertInfoToCoreData];
            }
        }];
        
    }else{
        //try to use it
        self.managedObjectContext = document.managedObjectContext;
        [self startInsertInfoToCoreData];
    }
}

#pragma mark - VC lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    /*
    PreviewViewController *pre = [[PreviewViewController alloc] initWithNibName:@"PreviewViewController" bundle:nil];
    self.naviC = [[UINavigationController alloc] initWithRootViewController:pre];
    [self.naviC.view setFrame:self.view.bounds];
    [self.view addSubview:self.naviC.view];
    */
    
    self.filePathHelper = [[FilePathHelper alloc] init];
    [self.filePathHelper setCurrentPage:0];
    
    self.isTheFirstTime = YES;
    [self.filePathHelper release];
}

- (void)viewDidAppear:(BOOL)animated {
    
    //PreviewViewController *pre = [[PreviewViewController alloc] initWithNibName:@"PreviewViewController" bundle:nil];
    //[self presentViewController:pre animated:NO completion:NULL];
    
    if (self.isTheFirstTime) {
        
        [self showCameraVCAnimated:NO];
        self.isTheFirstTime = NO;
    }
}

- (void)dealloc
{
    NSLog(@"maker dealloc");
    [super dealloc];
}

@end
