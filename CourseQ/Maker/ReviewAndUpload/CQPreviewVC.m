//
//  CQPreviewVC.m
//  CourseQ
//
//  Created by Fee Val on 13-6-3.
//  Copyright (c) 2013年 jing. All rights reserved.
//

#import "CQPreviewVC.h"
#import "MicroCauseCell.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreData/CoreData.h>
#import "ConstantDefinition.h"
#import "CoreDataManager.h"

@interface CQPreviewVC () <UITableViewDataSource, UITableViewDelegate, AVAudioPlayerDelegate, UIScrollViewDelegate>

// 表单元格
@property (retain, nonatomic) IBOutlet UITableView *mainTable;
@property (retain, nonatomic) UINib *cellNib;
@property (retain, nonatomic) IBOutlet MicroCauseCell *tableCell;

@property (retain, nonatomic) NSMutableArray *dataArray; //dataSource for tableView

@property (retain,nonatomic) AVAudioPlayer *soundPlayer;
@property (retain,nonatomic) NSTimer *progressTimer;

// 页面控制器
@property (retain, nonatomic) IBOutlet UIPageControl *pageController;

// ==== 自定义初始化方法 ==== //
- (void)updateSoundProgress; // 进度条

// ==== page involve ==== //
@property (assign,nonatomic) NSUInteger lastPage;
@property (assign, nonatomic) NSInteger motoPage;

@property (retain, nonatomic) NSManagedObjectContext *managedObjectContext;

@end

@implementation CQPreviewVC

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (void)updateSoundProgress{
    
}

#pragma mark - Page Control

#pragma mark - Data

#pragma mark - Table

- (void)showTableView {
    
    [self.view addSubview:self.mainTable];
    [self.view sendSubviewToBack:self.mainTable];
    [self.mainTable setFrame:CGRectMake(0, CELL_SIZE+47, CELL_SIZE, PAGE_WIDTH)];
    
    // 设置锚点 和 旋转起始位置
    [self.mainTable.layer setAnchorPoint:self.mainTable.bounds.origin];
    [self.mainTable.layer setPosition:CGPointMake(0, CELL_SIZE+47)];
    
    [self.mainTable setTransform:CGAffineTransformMakeRotation(-M_PI_2)];
    
    // NSLog(@"%f,%f,%f,%f", self.mainTable.frame.origin.x, self.mainTable.frame.origin.y,self.mainTable.frame.size.width, self.mainTable.frame.size.height);
    
    [self configurPlayer];
}

- (void)configurPlayer{
    
    // load player
    
    // ==== sessions 使得扬声器播放称为可能==== //
    AVAudioSession *audioSession=[AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    int flag = AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation;
    [audioSession setActive:YES withOptions:flag error:nil];
    // [audioSession setActive:YES withFlags:flag error:nil];
    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
    AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,sizeof (audioRouteOverride),&audioRouteOverride);
    // ================= //
    
    [self.pageController setNumberOfPages:self.dataArray.count];
}

- (void)loadingViewController
{
    // info button
    //  [self.infoBtn setHidden:!self.isShowInfo];
    // table view
    
    [self.mainTable setShowsVerticalScrollIndicator:NO];
    [self.mainTable setShowsHorizontalScrollIndicator:NO];
    [self.mainTable setPagingEnabled:YES];
    [self.mainTable setAllowsSelection:YES];
    self.cellNib = [UINib nibWithNibName:@"PreviewCell" bundle:nil];
}

#pragma mark - Core Data things

- (void)prepareForDataArray
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Unit"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"page" ascending:YES selector:@selector(compare:)]];
    request.predicate = [NSPredicate predicateWithFormat:@"belongTo.uID = %@", TEMP_COURSE_UID];
    
    NSArray *matches = [self.managedObjectContext executeFetchRequest:request error:nil];
    if ([matches count] > 0) {
        
        self.dataArray = [NSMutableArray arrayWithArray:matches];
        
    }else{
        NSLog(@"unit error");
    }
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
                  [self prepareForDataArray];
              }
          }];
        
    }else if (document.documentState == UIDocumentStateClosed){
        //open it
        [document openWithCompletionHandler:^(BOOL success) {
            if (success) {
                self.managedObjectContext = document.managedObjectContext;
                [self prepareForDataArray];
            }
        }];
        
    }else{
        //try to use it
        self.managedObjectContext = document.managedObjectContext;
        [self prepareForDataArray];
    }
}

#pragma mark - Defaults

- (NSMutableArray *)dataArray
{
    if (_dataArray) {
        _dataArray = [[[NSMutableArray alloc] init] autorelease];
        [_dataArray retain];
    }
    
    return _dataArray;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self loadingViewController];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.progressTimer invalidate];
    self.progressTimer = nil;
    [self.soundPlayer stop];
}

- (void)dealloc {
    
    [_mainTable release];
    [_tableCell release];
    [_cellNib release];
    [_soundPlayer release];
    [_progressTimer release];
    [_dataArray release];
    [_pageController release];
    [_mainTable release];
    [_tableCell release];
    [super dealloc];
}
@end
