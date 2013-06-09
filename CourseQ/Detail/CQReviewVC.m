//
//  CQReviewVC.m
//  CourseQ
//
//  Created by Fee Val on 13-5-27.
//  Copyright (c) 2013年 jing. All rights reserved.
//

#import "CQReviewVC.h"
#import "ASIFormDataRequest.h"
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"
#import <CoreData/CoreData.h>
#import "Unit+Fetcher.h"
#import  <AVFoundation/AVFoundation.h>
#import "CourseInfoView.h"
#import "Course.h"
#import "ConstantDefinition.h"


#define CQ_UNIT_IMGPATH @"imgLocalPath"
#define CQ_UNIT_SNDPATH @"sndLocalPath"
#define CQ_UNIT_PAGE @"pageNumber"

@interface CQReviewVC () <UITableViewDataSource,UITableViewDelegate,AVAudioPlayerDelegate,UIScrollViewDelegate>

@property (retain, nonatomic) IBOutlet UITableView *mainTable;
@property (retain, nonatomic) UINib *cellNib;
@property (retain, nonatomic) IBOutlet MicroCauseCell *tableCell;

// 课程首页
@property (retain, nonatomic) UINib *headerNib;
@property (retain, nonatomic) IBOutlet CourseBriefing *headerView;

@property (strong, nonatomic) UINib *footerNib;
@property (retain, nonatomic) IBOutlet CourseInfoView *footerView;

// Download Queue & status
@property (retain, nonatomic) ASINetworkQueue *networkQueue;
@property (assign, nonatomic, getter = isFailed) BOOL failed;

@property (retain, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (retain, nonatomic) NSMutableArray *courseUnit; //of dics for CoreData save
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

// @property (copy, nonatomic) NSString *currentTitle;

@property (retain, nonatomic) Course *course;

@property (assign, nonatomic, getter = isPageControlUsed) BOOL pageControlUsed;

@end

static NSString *_WebAdressOfFreeboxWS_DONWLOAD_2_0 = @"http://kechengpai.com/microcourse/file/";

@implementation CQReviewVC

- (IBAction)leftBarBtnPressed:(id)sender {
    [self.delegate shouldBackToListVC:self];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - other helper functions

// 关注, 赞，等按钮

#pragma mark - sound player delegations

/* audioPlayerDidFinishPlaying:successfully: is called when a sound has finished playing. This method is NOT called if the player is stopped due to an interruption. */
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    // 如果当前页为微课程的最后一页，则什么都不要做
    if (self.pageController.currentPage >= self.dataArray.count){
        
        CGPoint lastPageP = CGPointMake(0, PAGE_WIDTH * (self.dataArray.count +1));
        [self.mainTable setContentOffset:lastPageP animated:YES];
        self.pageController.currentPage = self.dataArray.count +1;
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
    MicroCauseCell *cell = nil;
    if (self.pageController.currentPage) {
        cell = [self findMicroCauseCellByPageNumber:self.pageController.currentPage];
    }
    // [self.totalProgress setProgress:progress animated:NO];
    [cell.pieceProgress setProgress:progress];
}

- (void)soundStop{
    
    [self.soundPlayer pause];
}

- (void)soundPlay{
    
    [self.soundPlayer play];
}

- (void)soundChangeToPage:(NSUInteger)page{
    
    // 设置时间后播放
    if (self.soundPlayer)
    {
        [self.soundPlayer pause];
    }
    // 重置progress
    // [self.pageProgress setProgress:0];
    // NSLog(@">>>>>%f",self.currentCell.startTime);
    
    NSLog(@"%d - %d",page,[self.dataArray count]);
    
    Unit *aUnit = [self.dataArray objectAtIndex:page - 1];
    
    // NSLog(@">>>>>%@",a.soundName);
    // [self.soundPlayer setCurrentTime:[a.startTime floatValue]];
    
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
    [self.soundPlayer play];
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

#pragma mark - page control

- (MicroCauseCell *)findMicroCauseCellByPageNumber:(NSUInteger)page{
    
    MicroCauseCell *cell = (MicroCauseCell *) [self.mainTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:page inSection:0]];
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
        MicroCauseCell *cell = [self findMicroCauseCellByPageNumber:self.lastPage];
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
    
    if (page > [self.dataArray count]) {
        self.lastPage = -1;
    }
    
    // NSLog(@"%d !! %d",self.pageController.currentPage,page);
}

- (IBAction)playInCellTouched:(UIButton *)sender
{
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
    
    if (self.pageController.currentPage) {
        
        [self soundChangeToPage:self.pageController.currentPage];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    [self setPageControlUsed:NO];
    
    NSLog(@"CP >>>> %d LP >>>> %d",self.pageController.currentPage,self.lastPage);
    
    if (self.lastPage == self.pageController.currentPage && self.pageController.currentPage)
    {
        [self soundPlay];
    }
    else
    {
        if (self.pageController.currentPage && self.pageController.currentPage <= [self.dataArray count]) {
            [self soundChangeToPage:self.pageController.currentPage];
        }
    }
    
    // 更新当前页面的播放按钮
    // NSLog(@"====### L:%d,C:%d",self.lastPage,self.pageController.currentPage);
    
    MicroCauseCell *currentCell = nil;
    if (self.pageController.currentPage) {
        currentCell = [self findMicroCauseCellByPageNumber:self.pageController.currentPage];
    }
    
    [currentCell.cellBtnPlay setHidden:NO];
    [currentCell.cellBtnPlay setImage:[UIImage imageNamed:@"btn_pause.png"] forState:UIControlStateNormal];
    [self.mainTable reloadData];
}

#pragma mark - Actions

- (void)passUnitDictionaries{
    //把数据存到CoreData
    for (NSDictionary *dic in self.courseUnit) {
        
        Unit *unit = [Unit unitWithUnitDictionary:dic withCourseFileName:self.courseFileName inManagedObjectContext:self.managedObjectContext];
        [self.dataArray addObject:unit];
        
    }
    
    NSError *error = nil;
    [self.managedObjectContext save:&error];
    if (error) {
        NSLog(@"contextSaveError: %@", [error localizedDescription]);
    }
    
    [self showTableView];
}

- (NSMutableArray *)courseUnit{
    
    if (_courseUnit == nil) {
        
        _courseUnit = [[[NSMutableArray alloc] initWithCapacity:0]autorelease];
        
        [_courseUnit retain];
    }
    
    return _courseUnit;
}

- (NSMutableArray *)dataArray {
    
    if (_dataArray == nil) {
        _dataArray = [[[NSMutableArray alloc] init] autorelease];
        [_dataArray retain];
    }
    return _dataArray;
}

#pragma mark - Request Delegations

- (void)allFetchComplete:(ASINetworkQueue *)queue{
    
    if (self.isFailed){
        
        return;
    }
    
    //把信息给到dataArray
    
    //存到CoreData
    [self passUnitDictionaries];
}

- (void)microCourseFetchComplete:(ASIHTTPRequest *)request{
    
}

- (void)microCourseFetchFailed:(ASIHTTPRequest *)request{
    
	if (!self.isFailed){
		if ([[request error] domain] != NetworkRequestErrorDomain || [[request error] code] != ASIRequestCancelledErrorType) {
			UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"Download failed" message:@"Failed to download images" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
			[alertView show];
		}
		[self setFailed:YES];
	}
}

- (void)fetchCourseFiles{
    
    if (!_networkQueue) {
		_networkQueue = [[ASINetworkQueue alloc] init];
	}
    
	[self setFailed:NO];
	[_networkQueue reset];
    // [_networkQueue setShowAccurateProgress:YES];
	[_networkQueue setRequestDidFinishSelector:@selector(microCourseFetchComplete:)];
	[_networkQueue setRequestDidFailSelector:@selector(microCourseFetchFailed:)];
    [_networkQueue setQueueDidFinishSelector:@selector(allFetchComplete:)];
	[_networkQueue setDelegate:self];
    
    NSString *filename = self.courseFileName;
    NSString *localPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *mcFilePath = [[NSString stringWithFormat:@"%@",_WebAdressOfFreeboxWS_DONWLOAD_2_0] stringByAppendingString:filename];
    
    int count = [self.pageCount integerValue];
    
    for (int i = 0; i < count; i++){
        
        ASIHTTPRequest *reqImg;
        ASIHTTPRequest *reqSnd;
        
        NSString *imgURL = [[mcFilePath stringByAppendingFormat:@"_image%02d",i] stringByAppendingString:@".jpg"];
        
        // local filename
        NSString *imgFileName = [[filename stringByAppendingFormat:@"_image%02d",i] stringByAppendingString:@".jpg"];
        
        NSString *sndURL = [[mcFilePath stringByAppendingFormat:@"_sound%02d",i] stringByAppendingString:@".aac"];
        // local filename
        NSString *sndFileName = [[filename stringByAppendingFormat:@"_sound%02d",i] stringByAppendingString:@".aac"];
        
        reqImg = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:imgURL]];
        
        NSString *imgDestination = [localPath stringByAppendingPathComponent:imgFileName];
        [reqImg setDownloadDestinationPath:imgDestination];
        [reqImg setUserInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"reqIMG%d",i] forKey:@"name"]];
        // NSLog(@">>> %@",sndURL);
        reqSnd = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:sndURL]];
        NSString *sndDestination = [localPath stringByAppendingPathComponent:sndFileName];
        [reqSnd setDownloadDestinationPath:sndDestination];
        [reqSnd setUserInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"reqSnd%d",i] forKey:@"name"]];
        
        NSMutableDictionary *unitDic = [NSMutableDictionary dictionaryWithCapacity:count];
        
        [unitDic setObject:imgDestination forKey:CQ_UNIT_IMGPATH];
        [unitDic setObject:sndDestination forKey:CQ_UNIT_SNDPATH];
        [unitDic setObject:[NSString stringWithFormat:@"%d",i] forKey:CQ_UNIT_PAGE];
        
        [self.courseUnit addObject:unitDic];
        
        [_networkQueue addOperation:reqImg];
        [_networkQueue addOperation:reqSnd];
    }
    
    [_networkQueue go];
}

#pragma mark - Table Delegations

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    // NSLog(@"count:%d", [self.dataArray count]);
    return [self.dataArray count] + 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return PAGE_WIDTH;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSLog(@"%f,%f,%f,%f", self.mainTable.frame.origin.x, self.mainTable.frame.origin.y,self.mainTable.frame.size.width, self.mainTable.frame.size.height);
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (indexPath.row == 0)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
        [cell.contentView addSubview:self.headerView];
    }
    else if (cell == nil)
    {
        // cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        if (indexPath.row >0) {
            
            [self.cellNib instantiateWithOwner:self options:nil];
            Unit *page = self.dataArray[indexPath.row - 1];
            [self.tableCell.cellBtnPlay setTag:indexPath.row];
            [self.tableCell configurMicroCause:page];
            cell = self.tableCell;
            self.tableCell = nil;
        }
    }
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell.contentView setTransform:CGAffineTransformMakeRotation(M_PI_2)];
    return cell;
}

#pragma mark - CoreData things

- (void)obtainCourseFromCoreData {
    
    Course *course = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Course"];
    request.predicate = [NSPredicate predicateWithFormat:@"courseFileName = %@", self.courseFileName];
    
    NSError *error = nil;
    NSArray *matches = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    if (!matches || [matches count]>1) {
        NSLog(@"obtainCourseError: %@", [error localizedDescription]);
    }
    
    else {
        course = [matches lastObject];
    }
    
    self.course = course;
}

- (void)startFetchingUnit {
    
    //get the Course from CoreData
    [self obtainCourseFromCoreData];
    
    //check if the units are already existed
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Unit"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"page" ascending:YES selector:@selector(compare:)]];
    request.predicate = [NSPredicate predicateWithFormat:@"belongTo.courseFileName = %@", self.courseFileName];
    
    NSError *error = nil;
    NSArray *matches = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    if (!matches) {
        NSLog(@"unit error: %@", [error localizedDescription]);
    }
    
    else if ([matches count]) {
        //赋给tableView的dataArray
        self.dataArray = [NSMutableArray arrayWithArray:matches];
        [self showTableView];
    }
    
    else {
        //从网上下载
        [self fetchCourseFiles];
    }
}

- (void)useDemoDocument{
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSURL *url = [[fm URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    url = [url URLByAppendingPathComponent:@"CourseDocument"];
    UIManagedDocument *document = [[[UIManagedDocument alloc] initWithFileURL:url] autorelease];
    
    if (![fm fileExistsAtPath:[url path]]) {
        //create it
        [document saveToURL:url
           forSaveOperation:UIDocumentSaveForCreating
          completionHandler:^(BOOL success) {
              if (success) {
                  self.managedObjectContext = document.managedObjectContext;
                  [self startFetchingUnit];//refresh data from server
              }
          }];
        
    }else if (document.documentState == UIDocumentStateClosed){
        //open it
        [document openWithCompletionHandler:^(BOOL success) {
            if (success) {
                self.managedObjectContext = document.managedObjectContext;
                [self startFetchingUnit];
            }
        }];
        
    }else{
        //try to use it
        self.managedObjectContext = document.managedObjectContext;
        [self startFetchingUnit];
    }
}

#pragma mark - Loading & Configur Views

- (NSString *)findPathOfLocalMicroCourse
{
    NSString *userPath=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *fileName = @"";
    userPath = [userPath stringByAppendingPathComponent:@"microCourses"];
    NSString *recordSavePath=[userPath stringByAppendingPathComponent:fileName];
    return recordSavePath;
}

- (void)configurHeader{
    
    // load header of MC
    self.headerNib = [UINib nibWithNibName:@"CourseBriefing" bundle:nil];
    [self.headerNib instantiateWithOwner:self options:nil];
    self.cellNib = [UINib nibWithNibName:@"MicroCauseCell" bundle:nil];
    
    // 配置显示数据
    [self.headerView.titleLabel setText:[self.course.title stringByAppendingString:@" > "]];
    [self.headerView.posterDateLabel setText:self.course.postDate];
    [self.headerView.posterLabel setText:self.course.poster];
    [self.headerView.hitsLabel setText:self.course.hitCount];
    [self.headerView.favorLabel setText:self.course.likeCount];
    [self.headerView.forwardLabel setText:self.course.forwardCount];
    
    // 配置头像
    // NSLog(@"OOOO %@",self.course.posterPortrait);
    NSString *portraitURL = [_WebAdressOfFreeboxWS_PORTRAIT_2_0 stringByAppendingPathComponent:self.course.posterPortrait];
    NSURL *URL = [NSURL URLWithString:portraitURL];
    NSData *imgData = [NSData dataWithContentsOfURL:URL];
    UIImage *pic = [UIImage imageWithData:imgData];
    [self.headerView.userPortrait setImage:pic];
}

- (void)configurFooter{
    
    // load footer of MC
    self.footerNib = [UINib nibWithNibName:@"CourseInfoView" bundle:nil];
    [self.footerNib instantiateWithOwner:self options:nil];
    
    [self.footerView setTransform:CGAffineTransformMakeRotation(M_PI_2)];
    [self.mainTable setTableFooterView:self.footerView];
    
    // 配置数据
    [self.footerView.posterLabel setText:self.course.poster];
    // 配置头像
    NSString *portraitURL = [_WebAdressOfFreeboxWS_PORTRAIT_2_0 stringByAppendingPathComponent:self.course.posterPortrait];
    NSURL *URL = [NSURL URLWithString:portraitURL];
    NSData *imgData = [NSData dataWithContentsOfURL:URL];
    UIImage *pic = [UIImage imageWithData:imgData];
    [self.footerView.userPotrait setImage:pic];
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
    
    
    [self.pageController setNumberOfPages:self.dataArray.count + 2];
}

- (void)showTableView {
    
    [self.view addSubview:self.mainTable];
    [self.view sendSubviewToBack:self.mainTable];
    [self.mainTable setFrame:CGRectMake(0, CELL_SIZE+47, CELL_SIZE, PAGE_WIDTH)];
    
    [self.mainTable.layer setAnchorPoint:self.mainTable.bounds.origin];
    [self.mainTable.layer setPosition:CGPointMake(0, CELL_SIZE+47)];
    
    [self.mainTable setTransform:CGAffineTransformMakeRotation(-M_PI_2)];
    
    NSLog(@"%f,%f,%f,%f", self.mainTable.frame.origin.x, self.mainTable.frame.origin.y,self.mainTable.frame.size.width, self.mainTable.frame.size.height);
    
    [self configurPlayer];
    [self configurHeader];
    [self configurFooter];
    //[self.mainTable reloadData];
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
    self.cellNib = [UINib nibWithNibName:@"MicroCauseCell" bundle:nil];
}

#pragma mark - Defaults

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self useDemoDocument];
    [self loadingViewController];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.progressTimer invalidate];
    self.progressTimer = nil;
    [self.soundPlayer stop];
}

- (void)dealloc {
    
    [_courseUnit release];
    [_mainTable release];
    [_tableCell release];
    [_headerView release];
    [_cellNib release];
    [_headerNib release];
    [_soundPlayer release];
    [_progressTimer release];
    [_footerNib release];
    [_footerView release];
    [_networkQueue release];
    [_managedObjectContext release];
    [_dataArray release];
    [_pageController release];
    [_course release];
    [_courseFileName release];
    [_pageCount release];
    
    [super dealloc];
}

@end
