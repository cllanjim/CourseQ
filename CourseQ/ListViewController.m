//
//  ListViewController.m
//  CourseQ
//
//  Created by Jing on 13-5-13.
//  Copyright (c) 2013年 jing. All rights reserved.
//

#import "ListViewController.h"
#import <CoreData/CoreData.h>

#import "TouchTableView.h"
#import "CourseListCell.h"

#import "Course.h"
#import "Course+Fetcher.h"
#import "CourseDataFetcher.h"

#import "MBProgressHUD.h"

#define USER_ID @"MemberID"

#define ANIMATION_INTERVAL_BOTTOMBARHIGHLIGHT 0.3

@interface ListViewController () <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate>

@property (retain, nonatomic) IBOutlet TouchTableView *tableView;

//CoreData things
@property (retain, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic) BOOL suspendAutomaticTrackingOfChangesInManagedObjectContext;
@property (assign, nonatomic) BOOL beganUpdates;
@property BOOL debug;
- (void)performFetch;

@property (retain, nonatomic) NSManagedObjectContext *managedObjectContext;

//cell
@property (retain, nonatomic) UINib *cellNib;
@property (retain, nonatomic) IBOutlet CourseListCell *courseCell;
@property (retain, nonatomic) IBOutlet UILabel *bottomBarHighlight;
@property (retain, nonatomic) IBOutlet UIView *categoryView;


//@property (retain, nonatomic) NSMutableArray *categoryDataArray;


@end

@implementation ListViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.cellNib = [UINib nibWithNibName:@"CourseListCell" bundle:nil];
    
    [self.categoryView setFrame:CGRectMake(0, 47, 320, 456)];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    if (!self.managedObjectContext) {
        [self useDemoDocument];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_bottomBarHighlight release];
    [_categoryView release];
    [super dealloc];
}

#pragma mark - Action

- (IBAction)leftBarBtnTapped:(id)sender{
    
    [super leftBarBtnTapped:sender];
}

- (IBAction)rightBarBtnTapped:(id)sender {
    
}

- (IBAction)bottomLeftBtnPressed:(id)sender {
    
    if ([self.categoryView superview]) {
        [self.categoryView removeFromSuperview];
    }
    
    [UIView animateWithDuration:ANIMATION_INTERVAL_BOTTOMBARHIGHLIGHT animations:^{
        CGRect bottomBarHighlight = CGRectMake(30.0, 543, 50.0, 5.0);
        [self.bottomBarHighlight setFrame:bottomBarHighlight];
    }];
    
}

- (IBAction)bottomMiddleBtnPressed:(id)sender {
    
    if ([self.categoryView superview]) {
        [self.categoryView removeFromSuperview];
    }
    
    [UIView animateWithDuration:ANIMATION_INTERVAL_BOTTOMBARHIGHLIGHT animations:^{
        CGRect bottomBarHighlight = CGRectMake(135.0, 543, 50.0, 5.0);
        [self.bottomBarHighlight setFrame:bottomBarHighlight];
    }];
}

- (IBAction)bottomRightBtnPressed:(id)sender {
    
    [self.view addSubview:self.categoryView];
    
    [UIView animateWithDuration:ANIMATION_INTERVAL_BOTTOMBARHIGHLIGHT animations:^{
        CGRect bottomBarHighlight = CGRectMake(243.0, 543, 50.0, 5.0);
        [self.bottomBarHighlight setFrame:bottomBarHighlight];
    } completion:^(BOOL finished) {
        if (finished) {
            /*
             if (!self.categoryDataArray) {
             self.categoryDataArray = [[[NSMutableArray alloc] init] autorelease];
             self.categoryDataArray = [NSMutableArray arrayWithObjects:@"文学", @"摄影", @"编程", @"旅行", @"没事", @"会计", @"原画", @"UI设计", nil];
             }
             */
            
        }
    }];
}

#pragma mark - fetch data

- (void)startFetchingList {
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *memberID = [ud valueForKey:USER_ID];
    
    NSLog(@"id = %@", memberID);
    
    //NSArray *courses = [[CourseDataFetcher arrayOfCoursesDictionaryByMemberID:memberID withSkipX:0 withRangeY:20] copy];
    
    NSArray *courses = [CourseDataFetcher courseDictionariesWithMemberID:@"21" skip:0 range:20];
    
    [self.managedObjectContext performBlock:^{
        for (NSDictionary *courseDic in courses) {
            [Course courseWithCourseDictionary:courseDic inManagedObjectContext:self.managedObjectContext];
        }
    }];
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
}

#pragma mark - CoreData things

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Course *course = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NSLog(@"name:%@",course.courseFileName);
    [self.delegate didSelectRowWithCourseFileName:course.courseFileName pageCount:course.pageNumber];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Course *course = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    UITableViewCell *cell = nil;
    [self.cellNib instantiateWithOwner:self options:nil];
    
    //configure
    [self.courseCell.titleLabel setText:course.title];
    [self.courseCell.categoryLabel setText:course.category];
    [self.courseCell.likeLabel setText:course.likeCount];
    [self.courseCell.readerLabel setText:course.hitCount];
    [self.courseCell.forwardLabel setText:course.forwardCount];
    [self.courseCell.posterID setText:course.poster];
    //self.courseCell.posterPortrait sette
    [self.courseCell.postDate setText:course.postDate];
    [self.courseCell.thumbnailImageView setImage:[UIImage imageWithContentsOfFile:course.thumbnailPath]];
    
    cell = self.courseCell;
    self.courseCell = nil;
    
    return cell;
    
}

- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
    
    _managedObjectContext = managedObjectContext;
    
    if (managedObjectContext) {
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Course"];
        request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"postDate" ascending:NO selector:@selector(compare:)]];
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:nil];
        
    } else {
        self.fetchedResultsController = nil;
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
                  [self startFetchingList];//refresh data from server
              }
          }];
        
    }else if (document.documentState == UIDocumentStateClosed){
        //open it
        [document openWithCompletionHandler:^(BOOL success) {
            if (success) {
                self.managedObjectContext = document.managedObjectContext;
                [self startFetchingList];
            }
        }];
        
    }else{
        //try to use it
        self.managedObjectContext = document.managedObjectContext;
        [self startFetchingList];
    }
}

#pragma mark - Fetching

- (void)performFetch
{
    if (self.fetchedResultsController) {
        if (self.fetchedResultsController.fetchRequest.predicate) {
            if (self.debug) NSLog(@"[%@ %@] fetching %@ with predicate: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), self.fetchedResultsController.fetchRequest.entityName, self.fetchedResultsController.fetchRequest.predicate);
        } else {
            if (self.debug) NSLog(@"[%@ %@] fetching all %@ (i.e., no predicate)", NSStringFromClass([self class]), NSStringFromSelector(_cmd), self.fetchedResultsController.fetchRequest.entityName);
        }
        NSError *error = nil;
        [self.fetchedResultsController performFetch:&error];
        if (error) NSLog(@"[%@ %@] %@ (%@)", NSStringFromClass([self class]), NSStringFromSelector(_cmd), [error localizedDescription], [error localizedFailureReason]);
    } else {
        if (self.debug) NSLog(@"[%@ %@] no NSFetchedResultsController (yet?)", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    }
    [self.tableView reloadData];
}

- (void)setFetchedResultsController:(NSFetchedResultsController *)newfrc
{
    NSFetchedResultsController *oldfrc = _fetchedResultsController;
    if (newfrc != oldfrc) {
        _fetchedResultsController = newfrc;
        newfrc.delegate = self;
        if ((!self.title || [self.title isEqualToString:oldfrc.fetchRequest.entity.name]) && (!self.navigationController || !self.navigationItem.title)) {
            self.title = newfrc.fetchRequest.entity.name;
        }
        if (newfrc) {
            if (self.debug) NSLog(@"[%@ %@] %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), oldfrc ? @"updated" : @"set");
            [self performFetch];
        } else {
            if (self.debug) NSLog(@"[%@ %@] reset to nil", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
            [self.tableView reloadData];
        }
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[self.fetchedResultsController sections] objectAtIndex:section] numberOfObjects];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return [[[self.fetchedResultsController sections] objectAtIndex:section] name];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
	return [self.fetchedResultsController sectionForSectionIndexTitle:title atIndex:index];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return [self.fetchedResultsController sectionIndexTitles];
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    if (!self.suspendAutomaticTrackingOfChangesInManagedObjectContext) {
        [self.tableView beginUpdates];
        self.beganUpdates = YES;
    }
}

- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
		   atIndex:(NSUInteger)sectionIndex
	 forChangeType:(NSFetchedResultsChangeType)type
{
    if (!self.suspendAutomaticTrackingOfChangesInManagedObjectContext)
    {
        switch(type)
        {
            case NSFetchedResultsChangeInsert:
                [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
                break;
                
            case NSFetchedResultsChangeDelete:
                [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
                break;
        }
    }
}


- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
	   atIndexPath:(NSIndexPath *)indexPath
	 forChangeType:(NSFetchedResultsChangeType)type
	  newIndexPath:(NSIndexPath *)newIndexPath
{
    if (!self.suspendAutomaticTrackingOfChangesInManagedObjectContext)
    {
        switch(type)
        {
            case NSFetchedResultsChangeInsert:
                [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
                break;
                
            case NSFetchedResultsChangeDelete:
                [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                break;
                
            case NSFetchedResultsChangeUpdate:
                [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                break;
                
            case NSFetchedResultsChangeMove:
                [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
                break;
        }
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    if (self.beganUpdates) [self.tableView endUpdates];
}

- (void)endSuspensionOfUpdatesDueToContextChanges
{
    _suspendAutomaticTrackingOfChangesInManagedObjectContext = NO;
}

- (void)setSuspendAutomaticTrackingOfChangesInManagedObjectContext:(BOOL)suspend
{
    if (suspend) {
        _suspendAutomaticTrackingOfChangesInManagedObjectContext = YES;
    } else {
        [self performSelector:@selector(endSuspensionOfUpdatesDueToContextChanges) withObject:0 afterDelay:0];
    }
}

#pragma mark - category btns

- (IBAction)categoryBtnPressed:(id)sender {
    [self.categoryView removeFromSuperview];
}


@end
