//
//  UploadViewController.m
//  CourseQ
//
//  Created by Jing on 13-6-8.
//  Copyright (c) 2013年 jing. All rights reserved.
//

#import "UploadViewController.h"
#import "CoreDataManager.h"
#import <CoreData/CoreData.h>
#import "ConstantDefinition.h"
#import "MBProgressHUD.h"
#import "ASIFormDataRequest.h"
#import "Unit.h"

@interface UploadViewController ()
@property (retain, nonatomic) IBOutlet UITextField *textField;
@property (retain, nonatomic) NSManagedObjectContext *managedObjectContext;
@end

@implementation UploadViewController

- (IBAction)backBtnPressed:(id)sender {
    //显示alert，是否放弃制作
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"是否放弃制作"
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:@"是"
                                              otherButtonTitles:@"否", nil];
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self.delegate didCancelWithUpload];
    }
}

- (IBAction)uploadBtnPressed:(id)sender {
    
    if (![self.textField.text length]) {
        //显示hud
    }
    [self useDemoDocument];
}

- (IBAction)englishBtnPressed:(id)sender {
}


- (IBAction)textFieldEnd:(id)sender {
}

- (void)upload:(NSArray *)units
{
    NSURL *url = [NSURL URLWithString:_WebAdressOfFreeboxWS_Upload];
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:url];
    [request setRequestMethod:@"POST"];
    [request setFailedBlock:^{
        NSLog(@"fail: %@", request.responseString);
    }];
    [request setCompletionBlock:^{
        NSLog(@"complete: %@", request.responseString);
        [self.delegate didFinishWithUpload];
    }];
    
    
    //title
    [request setPostValue:self.textField.text forKey:@"title"];
    
    //category
    [request setPostValue:@"5" forKey:@"category"];
    
    //page
    NSInteger page = [units count];
    [request setPostValue:[NSString stringWithFormat:@"%d", page] forKey:@"page"];
    
    for (int i = 0; i < page; i++) {
        
        Unit *unit = units[i];
        [request setFile:unit.imagePath forKey:[NSString stringWithFormat:@"image%02d",i]];
        [request setFile:unit.audioPath forKey:[NSString stringWithFormat:@"sound%02d",i]];
    }
    
    [request startSynchronous];
    
}

#pragma mark - Core Data things

- (void)prepareForDataArray
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Unit"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"page" ascending:YES selector:@selector(compare:)]];
    request.predicate = [NSPredicate predicateWithFormat:@"belongTo.uID = %@", TEMP_COURSE_UID];
    
    NSArray *matches = [self.managedObjectContext executeFetchRequest:request error:nil];
    if ([matches count] > 0) {
        
        [self upload:matches];
        
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

#pragma mark - VC lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

}

- (void)dealloc {
    [_textField release];
    [super dealloc];
}
@end
