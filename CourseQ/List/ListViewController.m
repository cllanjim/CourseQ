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
#import "ConstantDefinition.h"
#import "CoreDataManager.h"

#define ANIMATION_INTERVAL_BOTTOMBARHIGHLIGHT 0.3

@interface ListViewController () <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, TouchTableViewDelegate>

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

@property (retain, nonatomic) UIRefreshControl *refreshControl;

@end

@implementation ListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.cellNib = [UINib nibWithNibName:@"CourseListCell" bundle:nil];
    [self.tableView setTouchDelegate:self];
    [self.categoryView setFrame:CGRectMake(0, 47, 320, 456)];
    
    self.refreshControl = [[[UIRefreshControl alloc] init] autorelease];
    [self.refreshControl addTarget:self action:@selector(followDataRefresh) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.rightSideLocked = YES;
    
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
    
    [_refreshControl release];
    [_tableView release];
    [_fetchedResultsController release];
    [_managedObjectContext release];
    [_cellNib release];
    [_courseCell release];
    [_bottomBarHighlight release];
    [_categoryView release];
    [super dealloc];
}

#pragma mark - Action

- (IBAction)rightBarBtnTapped:(id)sender {
    [self.delegate shouldMoveToMakerVC];
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

- (void)followDataRefresh {
    
    [self.refreshControl beginRefreshing];
    
    dispatch_queue_t fetchQ = dispatch_queue_create("Mongo Fetcher", NULL);
    dispatch_async(fetchQ, ^{
        
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        NSString *memberID = [ud valueForKey:USER_ID];
        
        NSArray *courses = [CourseDataFetcher courseDictionariesWithMemberID:memberID skip:0 range:20];
        
        NSLog(@"====%d", [courses count]);
        
        [self.managedObjectContext performBlockAndWait:^{
            
            for (NSDictionary *courseDic in courses) {
                [Course courseWithCourseDictionary:courseDic inManagedObjectContext:self.managedObjectContext];
            }
            
            [self.managedObjectContext save:nil];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.refreshControl endRefreshing];
            });
        }];
    });
}

- (void)startFetchingList {
    
    if (self.refresh) {
        [self followDataRefresh];
        
    }
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    self.rightSideLocked = NO;
}

- (void)followRequestUpdate
{
    if (self.fetchedResultsController) {
        self.fetchedResultsController = nil;
    }
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Course"];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"postDate" ascending:NO selector:@selector(compare:)]];
    request.predicate = [NSPredicate predicateWithFormat:@"isFollowed = %@", @YES];
    self.fetchedResultsController = [[[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil] autorelease];
}

#pragma mark - CoreData things

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
                  [self followRequestUpdate];
                  [self startFetchingList];//refresh data from server
              }
          }];
        
    }else if (document.documentState == UIDocumentStateClosed){
        //open it
        [document openWithCompletionHandler:^(BOOL success) {
            if (success) {
                self.managedObjectContext = document.managedObjectContext;
                [self followRequestUpdate];
                [self startFetchingList];
            }
        }];
        
    }else{
        //try to use it
        self.managedObjectContext = document.managedObjectContext;
        [self followRequestUpdate];
        [self startFetchingList];
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Course *course = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NSLog(@"name:%@",course.courseFileName);
    [self.delegate didSelectRowWithCourseFileName:course.courseFileName pageCount:course.pageNumber VC:self];
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
        //是否要retain？之前alloc的时候autorelease了
        [_fetchedResultsController retain];
        
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

#pragma mark - touchTable delegate


- (void)tableView:(UITableView *)tableView touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesBegan:touches withEvent:event];
}

- (void)tableView:(UITableView *)tableView touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesEnded:touches withEvent:event];
}



- (void)tableView:(UITableView *)tableView touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesEnded:touches withEvent:event];
}


- (void)tableView:(UITableView *)tableView touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesMoved:touches withEvent:event];
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
