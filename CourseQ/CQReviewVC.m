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
#import "Course.h"


#define CQ_UNIT_IMGPATH @"imgLocalPath"
#define CQ_UNIT_SNDPATH @"sndLocalPath"
#define CQ_UNIT_PAGE @"pageNumber"

@interface CQReviewVC () <UITableViewDataSource,UITableViewDelegate>

@property (retain, nonatomic) IBOutlet UITableView *mainTable;
@property (retain, nonatomic) UINib *cellNib;
@property (retain, nonatomic) IBOutlet MicroCauseCell *tableCell;

// 课程首页
@property (retain, nonatomic) UINib *headerNib;
@property (retain, nonatomic) IBOutlet CourseBriefing *headerView;

@property (retain, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (retain, nonatomic) ASINetworkQueue *networkQueue;
@property (assign, nonatomic, getter = isFailed) BOOL failed;
@property (retain, nonatomic) NSMutableArray *courseUnit; //of dics for CoreData save
@property (retain, nonatomic) NSMutableArray *dataArray; //dataSource for tableView
@property (retain, nonatomic) Course *course;

@end

static NSString *_WebAdressOfFreeboxWS_DONWLOAD_2_0 = @"http://kechengpai.com/microcourse/file/";

@implementation CQReviewVC

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (void)passUnitDictionaries{
    //把数据存到CoreData
    for (NSDictionary *dic in self.courseUnit) {
        
        Unit *unit = [Unit unitWithUnitDictionary:dic withCourseFileName:self.courseFileName inManagedObjectContext:self.managedObjectContext];        [self.dataArray addObject:unit];
        
    }
    
    NSError *error = nil;
    [self.managedObjectContext save:&error];
    if (error) {
        NSLog(@"contextSaveError: %@", [error localizedDescription]);
    }
    
    [self showTableView];
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    // NSLog(@"%g,%g",scrollView.contentOffset.x,scrollView.contentOffset.y);
    
    // [self.mainTable reloadData];
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


#pragma mark - Table Delegations

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    NSLog(@"count:%d", [self.dataArray count]);
    return [self.dataArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 320;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (indexPath.row == 0)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        [cell.contentView addSubview:self.headerView];
        [cell.contentView setTransform:CGAffineTransformMakeRotation(M_PI_2)];
    }
    else if (cell == nil)
    {
        // cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        if (indexPath.row >0) {
            [self.cellNib instantiateWithOwner:self options:nil];
            cell = self.tableCell;
            self.tableCell = nil;
        }
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell.contentView setTransform:CGAffineTransformMakeRotation(M_PI_2)];
    
    NSLog(@"c==%@", self.course.uID);
    return cell;
}

#pragma mark - Defaults

- (void)configurHeader{
    
    // load header of MC
    self.headerNib = [UINib nibWithNibName:@"CourseBriefing" bundle:nil];
    [self.headerNib instantiateWithOwner:self options:nil];
    // [self.headerView setTransform:CGAffineTransformMakeRotation(M_PI_2)];
    // [self.mainTable setTableHeaderView:self.headerView];
    // [self.mainTable setTableFooterView:self.headerView];
    // 配置显示数据
    
    // 配置头像
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

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.cellNib = [UINib nibWithNibName:@"MicroCauseCell" bundle:nil];
    
    
    NSLog(@"loadUi");
    
    [self configurHeader];
    
    [self useDemoDocument];
}

- (void)showTableView {
    [self.mainTable setFrame:CGRectMake(-65, 110, 450, 320)];
    [self.mainTable setTransform:CGAffineTransformMakeRotation(-M_PI_2)];
    [self.view addSubview:self.mainTable];
    //[self.mainTable reloadData];
}

- (void)dealloc {
    
    [_courseUnit release];
    [_mainTable release];
    [_tableCell release];
    [_headerView release];
    [_cellNib release];
    [_headerNib release];
    [super dealloc];
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
        self.dataArray = [matches mutableCopy];
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
    UIManagedDocument *document = [[UIManagedDocument alloc] initWithFileURL:url];
    
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


@end
