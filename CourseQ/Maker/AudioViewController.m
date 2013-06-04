//
//  AudioViewController.m
//  CourseQ
//
//  Created by Jing on 13-5-14.
//  Copyright (c) 2013年 jing. All rights reserved.
//

#import "AudioViewController.h"

#import <AVFoundation/AVFoundation.h>
#import "CapturedImageDisplayView.h"

#define TIMER_INTERVAL 1.0

@interface AudioViewController () <AVAudioRecorderDelegate, UIActionSheetDelegate>

@property (retain, nonatomic) AVAudioRecorder *recorder;

@property (retain, nonatomic) IBOutlet CapturedImageDisplayView *imageDisplayView;
@property (retain, nonatomic) UIImage *image;

@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (retain, nonatomic) IBOutlet UILabel *timeLabel;
@property (retain, nonatomic) IBOutlet UIButton *recordBtn;
@property (retain, nonatomic) IBOutlet UIButton *deleteBtn;
@property (retain, nonatomic) IBOutlet UIButton *finishBtn;
@property (retain, nonatomic) IBOutlet UIButton *nextBtn;

@property (retain, nonatomic) NSTimer *timer;

@property (assign, nonatomic, getter = isRecording) BOOL recording;

@end

@implementation AudioViewController

#pragma mark - AVAudioRecorder

- (void)configureAudioRecorder {
    
    /*
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [session setActive:YES withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
    */
    
    NSLog(@"%@", self.audioSavePath);
     
    NSDictionary *settings =
  @{AVFormatIDKey: [NSNumber numberWithInt:kAudioFormatMPEG4AAC],
    AVSampleRateKey: [NSNumber numberWithFloat:22050.0],
    AVNumberOfChannelsKey: [NSNumber numberWithInt:1],
    AVEncoderBitDepthHintKey: [NSNumber numberWithInt:16],
    AVEncoderAudioQualityKey: [NSNumber numberWithInt:AVAudioQualityMax]};
    
    NSURL *url = [NSURL fileURLWithPath:self.audioSavePath];
    
    NSError *error;
    self.recorder = [[AVAudioRecorder alloc] initWithURL:url settings:settings error:&error];
    if (error) {
        NSLog(@"error: %@", [error description]);
    }
    [self.recorder setDelegate:self];
    [self.recorder prepareToRecord];
    [self.recorder setMeteringEnabled:YES];
}

#pragma mark - interruption for iPhone

// =========== 中断代码 =============
#if TARGET_OS_IPHONE
/* audioRecorderBeginInterruption: is called when the audio session has been interrupted while the recorder was recording. The recorded file will be closed. */
- (void)audioRecorderBeginInterruption:(AVAudioRecorder *)recorder{
    
    [self pause];
}

- (void)audioRecorderEndInterruption:(AVAudioRecorder *)recorder withFlags:(NSUInteger)flags NS_DEPRECATED_IOS(4_0, 6_0) {
    
    [self record];
}

#endif // TARGET_OS_IPHONE


- (void)record {
    
    
    [self.recorder record];
    
    [self showPauseBtn];
    
    //timer
    self.timer = [NSTimer scheduledTimerWithTimeInterval:TIMER_INTERVAL target:self selector:@selector(syncTimeLabel) userInfo:nil repeats:YES];
    
    self.recording = YES;
}

- (void)pause {
    
    [self.timer invalidate];
    
    [self.recorder pause];
    
    [self showRecordBtn];
    
    self.recording = NO;
    
}

#pragma mark - record btn appearence

- (void)showRecordBtn
{
    UIImage *image = [UIImage imageNamed:@"Audio_recordBtn@2x.png"];
    [self.recordBtn setImage:image forState:UIControlStateNormal];
}

- (void)showPauseBtn
{
    UIImage *image = [UIImage imageNamed:@"Audio_recordPauseBtn@2x.png"];
    [self.recordBtn setImage:image forState:UIControlStateNormal];
    
}

#pragma mark - timer

- (void)syncTimeLabel {
    
    [self.recorder updateMeters];
    
    NSLog(@"intv:%f", self.recorder.currentTime);
    
    NSInteger interval = (NSInteger)self.recorder.currentTime;
    
    [self.timeLabel setText:[self getTimeStr:interval]];
}

- (NSString *)getTimeStr:(NSInteger)timeInterval{
    
    NSString *hour;
    NSString *min;
    NSString *sec;
    
    if (timeInterval/3600 > 0)
        hour = [NSString stringWithFormat:@"%d:", timeInterval/3600];
    else
        hour = @" ";
    
    min = [NSString stringWithFormat:@"%d\'", timeInterval%3600/60];
    
    if (timeInterval%3600%60 < 10)
        sec = [NSString stringWithFormat:@"0%d\"",timeInterval%3600%60];
    else
        sec = [NSString stringWithFormat:@"%d\"",timeInterval%3600%60];
    
    NSString *timeStr = [[hour stringByAppendingString:min] stringByAppendingString:sec];
    
    return timeStr;
}

#pragma mark - actionSheet delegate 

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        NSLog(@"0");
        
    }else if (buttonIndex == 1) {
        NSLog(@"1");
    }
}

- (void)showActionSheet
{
    UIActionSheet *action = [[UIActionSheet alloc]
                             initWithTitle:@"完成制作"
                             delegate:self
                             cancelButtonTitle:@"取消"
                             destructiveButtonTitle:@"预览&上传"
                             otherButtonTitles: nil];
    [action setDelegate:self];
    [action showInView:self.view];
}

#pragma mark - action


- (IBAction)deleteBtnPressed:(id)sender
{
    [self.deleteBtn setHidden:YES];
    [self.finishBtn setHidden:YES];
    [self.nextBtn setHidden:YES];
    
    [self showRecordBtn];
    [self.timeLabel setText:@" 0'00''"];
    
    if (self.isRecording) {
        [self.timer invalidate];
    }
    
    [self.recorder stop];
    
    [self setRecording:NO];
}

- (IBAction)backBtnPressed:(id)sender
{
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
        [self.delegate didCancelWithAudio];
    }
}


- (IBAction)finishBtnPressed:(id)sender
{
    if (self.isRecording) {
        [self.recorder stop];
        [self.timer invalidate];
        [self showRecordBtn];
        [self setRecording:NO];
    }
    
    [self showActionSheet];
}


- (IBAction)nextBtnPressed:(id)sender
{
    if (self.isRecording) {
        [self pause];
    }
    
    if (self.pageNumber == 5) {
        [self showActionSheet];
        
    }else {
        [self.delegate didFinishWithAudio];
    }
}

- (IBAction)recordBtnPressed:(id)sender {
    
    [self.deleteBtn setHidden:NO];
    [self.finishBtn setHidden:NO];
    [self.nextBtn setHidden:NO];
    
    
    if (self.isRecording) {
        
        [self pause];
        
    }else {
        
        [self record];
    }
    
}

#pragma mark - VC lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.image = [UIImage imageWithContentsOfFile:self.imageSavePath];
    [self.imageDisplayView setCapturedImage:self.image];
    
    NSString *title = [NSString stringWithFormat:@"%d/6", self.pageNumber+1];
    [self.titleLabel setText:title];
    
    [self.deleteBtn setHidden:YES];
    [self.finishBtn setHidden:YES];
    [self.nextBtn setHidden:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [self configureAudioRecorder];
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.recorder = nil;
}

- (void)dealloc {
    NSLog(@"dealloc");
    [_imageDisplayView release];
    [_titleLabel release];
    [_timeLabel release];
    [_recordBtn release];
    [_deleteBtn release];
    [_finishBtn release];
    [_nextBtn release];
    [super dealloc];
}
@end
