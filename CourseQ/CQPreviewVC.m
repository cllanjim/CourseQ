//
//  CQPreviewVC.m
//  CourseQ
//
//  Created by Fee Val on 13-6-3.
//  Copyright (c) 2013年 jing. All rights reserved.
//

#import "CQPreviewVC.h"
#import "PreviewCell.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreData/CoreData.h>
#import "ConstantDefinition.h"
#import "CoreDataManager.h"

@interface CQPreviewVC () <UITableViewDataSource, UITableViewDelegate, AVAudioPlayerDelegate, UIScrollViewDelegate>

// 表单元格
@property (retain, nonatomic) IBOutlet UITableView *mainTable;
@property (retain, nonatomic) UINib *cellNib;
@property (retain, nonatomic) IBOutlet PreviewCell *tableCell;

@property (retain, nonatomic) NSMutableArray *dataArray; //dataSource for tableView

@property (retain,nonatomic) AVAudioPlayer *soundPlayer;
@property (retain,nonatomic) NSTimer *progressTimer;

// 页面控制器
@property (retain, nonatomic) IBOutlet UIPageControl *pageController;
@property (assign, nonatomic, getter = isPageControlUsed) BOOL pageControlUsed;

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

#pragma mark - sound player delegations

/* audioPlayerDidFinishPlaying:successfully: is called when a sound has finished playing. This method is NOT called if the player is stopped due to an interruption. */
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    // 如果当前页为微课程的最后一页，则什么都不要做
    if (self.pageController.currentPage >= self.dataArray.count - 1){
        
        [self soundStop];
        return;
    }
    
    if (flag){
        
        [self gotoNextPage];
    }
    
    //[self.navigationController popViewControllerAnimated:YES];
}

/* if an error occurs while decoding it will be reported to the delegate. */
- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
    NSLog(@"Decode Error");
}

#pragma mark - sound play control

- (void)updateSoundProgress
{
    float progress = self.soundPlayer.currentTime / self.soundPlayer.duration;
    PreviewCell *cell = nil;
    cell = [self findMicroCauseCellByPageNumber:self.pageController.currentPage];
    [cell.pieceProgress setProgress:progress];
}

- (void)soundStop{
    
    PreviewCell *currentCell = nil;
    currentCell = [self findMicroCauseCellByPageNumber:self.pageController.currentPage];
    [currentCell.cellBtnPlay setImage:[UIImage imageNamed:@"btn_play.png"] forState:UIControlStateNormal];
    [self.mainTable reloadData];
    [self.soundPlayer pause];
}

- (void)soundPlay{
    
    PreviewCell *currentCell = nil;
    currentCell = [self findMicroCauseCellByPageNumber:self.pageController.currentPage];
    [currentCell.cellBtnPlay setImage:[UIImage imageNamed:@"btn_pause.png"] forState:UIControlStateNormal];
    [self.mainTable reloadData];
    [self.soundPlayer play];
}

- (void)soundChangeToPage:(NSUInteger)page{
    
    // 设置时间后播放
    if (self.soundPlayer)
    {
      //  [self.soundPlayer pause];
        [self soundStop];
    }
    
    NSLog(@"%d - %d",page,[self.dataArray count]);
    
    Unit *aUnit = [self.dataArray objectAtIndex:page];
    NSLog(@"%@",aUnit.audioPath);

    NSData *soundData = [NSData dataWithContentsOfFile:aUnit.audioPath];
    self.soundPlayer = [[[AVAudioPlayer alloc]initWithData:soundData error:nil]autorelease];
    [self.soundPlayer setMeteringEnabled:YES];
    [self.soundPlayer setDelegate:self];
    [self.soundPlayer setVolume:1.0];
    [self.soundPlayer setEnableRate:NO];
    [self.soundPlayer setRate:10.0];
    [self.soundPlayer prepareToPlay];
    
    // 计时器，注意内存问题
    if (self.progressTimer)
    {
        [self.progressTimer invalidate];
        [self setProgressTimer:nil];
    }
    
    if (self.progressTimer == nil)
    {
        // 自定义timer
        self.progressTimer = [[[NSTimer alloc] initWithFireDate:[NSDate dateWithTimeIntervalSinceNow:0.0] interval:0.25 target:self selector:@selector(updateSoundProgress) userInfo:nil repeats:YES]autorelease];
        [[NSRunLoop currentRunLoop] addTimer:self.progressTimer forMode:NSDefaultRunLoopMode];
    }
    
   //  [self.soundPlayer play];
    [self soundPlay];
}

#pragma mark - interruption for iPhone

// =========== 中断 =============
- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player
{
    [self soundStop];
}

- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player
{
    [self soundPlay];
}

#pragma mark - Page Control

- (PreviewCell *)findMicroCauseCellByPageNumber:(NSUInteger)page{
    
    PreviewCell *cell = (PreviewCell *) [self.mainTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:page inSection:0]];
    return cell;
}

// At the begin of scroll dragging, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self soundStop];
    [self setPageControlUsed:NO];
    self.lastPage = self.pageController.currentPage;
    // NSLog(@"LP >>>> %d",self.lastPage);
    
    if (self.lastPage > 0) {
        
        // page switch effect
        // ================
        PreviewCell *cell = [self findMicroCauseCellByPageNumber:self.lastPage];
        [cell.cellBtnPlay setImage:[UIImage imageNamed:@"btn_play.png"] forState:UIControlStateNormal];
        //================
    }
}

// At the end of scroll animation, reset the boolean used when scrolls originate from the UIPageControl

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // We don't want a "feedback loop" between the UIPageControl and the scroll delegate in
    // which a scroll event generated from the user hitting the page control triggers updates from
    // the delegate method. We use a boolean to disable the delegate logic when the page control is used.
    if (self.isPageControlUsed)
    {
        // do nothing - the scroll was initiated from the page control, not the user dragging
        return;
    }
    
    CGFloat pageWidth = PAGE_WIDTH;
    int page = self.motoPage = floor((scrollView.contentOffset.y - pageWidth / 2) / pageWidth) + 1;
    
    // NSLog(@"&&&&&& %d",self.motoPage);
    self.pageController.currentPage = page;
    
    if (page >= [self.dataArray count]) {
        self.lastPage = -1;
    }
    
    // NSLog(@"%d !! %d",self.pageController.currentPage,page);
}

- (IBAction)playInCellTouched:(UIButton *)sender {
    
    if (self.soundPlayer == nil)
    {
        [self soundChangeToPage:sender.tag];
    }
    
    if ([self.soundPlayer isPlaying])
    {
        [self soundStop];
        [sender setImage:[UIImage imageNamed:@"btn_play.png"] forState:UIControlStateNormal];
    }
    else
    {
        [self soundPlay];
        [sender setImage:[UIImage imageNamed:@"btn_pause.png"] forState:UIControlStateNormal];
    }
}

- (void)gotoNextPage
{
    CGFloat pageWidth = PAGE_WIDTH;
    
    // update the scroll view to the appropriate page
    CGRect frame = self.mainTable.bounds;
    frame.origin.y = frame.origin.y + pageWidth;
    frame.origin.x = 0;
    [self.mainTable scrollRectToVisible:frame animated:YES];
    
	// Set the boolean used when scrolls originate from the UIPageControl. See scrollViewDidScroll: above.
    
    [self setPageControlUsed:YES];
    self.lastPage = self.pageController.currentPage;
    self.pageController.currentPage += 1;
    [self soundChangeToPage:self.pageController.currentPage];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    [self setPageControlUsed:NO];
    
    NSLog(@"CP >>>> %d LP >>>> %d",self.pageController.currentPage,self.lastPage);
    
    if (self.lastPage == self.pageController.currentPage)
    {
        [self soundPlay];
    }
    else
    {
        if  (self.pageController.currentPage <= [self.dataArray count]) {
            [self soundChangeToPage:self.pageController.currentPage];
        }
    }
    
    // 更新当前页面的播放按钮
    // NSLog(@"====### L:%d,C:%d",self.lastPage,self.pageController.currentPage);
    
    PreviewCell *currentCell = nil;
    
    currentCell = [self findMicroCauseCellByPageNumber:self.pageController.currentPage];
    [currentCell.cellBtnPlay setImage:[UIImage imageNamed:@"btn_pause.png"] forState:UIControlStateNormal];
    [self.mainTable reloadData];
}


#pragma mark - Tableview

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return PAGE_WIDTH;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSLog(@"%f,%f,%f,%f",tableView.frame.origin.x,tableView.frame.origin.y,tableView.frame.size.width,tableView.frame.size.height);
    
    // NSLog(@"%% %d ####  %@",[self.dataArray count], unit);
    
    static NSString *CellIdentifier = @"CellPreview";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        [self.cellNib instantiateWithOwner:self options:nil];
        Unit *page = self.dataArray[indexPath.row];
        [self.tableCell.cellBtnPlay setTag:indexPath.row];
        [self.tableCell configurMicroCause:page];
        cell = self.tableCell;
        self.tableCell = nil;
    }

    // [cell.textLabel setText:@"xxxxx"];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell.contentView setTransform:CGAffineTransformMakeRotation(M_PI_2)];
    
    return cell;
}

#pragma mark - Actions

- (IBAction)backBtnPressed:(id)sender {
    [self.delegate didCancelWithPreview];
}


- (IBAction)uploading:(id)sender {
    [self.delegate shouldUpload];
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
    [self soundChangeToPage:0];
}

- (void)showTableView {
    
    [self.view addSubview:self.mainTable];
    [self.view sendSubviewToBack:self.mainTable];
    [self.mainTable setShowsVerticalScrollIndicator:NO];
    [self.mainTable setShowsHorizontalScrollIndicator:NO];
    [self.mainTable setPagingEnabled:YES];
    [self.mainTable setAllowsSelection:YES];
    
    [self.mainTable setFrame:CGRectMake(0, CELL_SIZE+47, CELL_SIZE, PAGE_WIDTH)];
    [self.mainTable.layer setAnchorPoint:self.mainTable.bounds.origin];
    
    [self.mainTable.layer setPosition:CGPointMake(0, CELL_SIZE+47)];
    [self.mainTable setTransform:CGAffineTransformMakeRotation(-M_PI_2)];
    
    NSLog(@"%f,%f,%f,%f", self.mainTable.frame.origin.x, self.mainTable.frame.origin.y,self.mainTable.frame.size.width, self.mainTable.frame.size.height);

    [self configurPlayer];
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
    
    [self showTableView];
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
    if (!_dataArray) {
        _dataArray = [[[NSMutableArray alloc] init] autorelease];
        [_dataArray retain];
    }
    
    return _dataArray;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self useDemoDocument];
    self.cellNib = [UINib nibWithNibName:@"PreviewCell" bundle:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.progressTimer invalidate];
    self.progressTimer = nil;
    [self.soundPlayer stop];
}

- (void)dealloc {
    
    [_mainTable release];
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
