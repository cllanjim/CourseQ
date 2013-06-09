//
//  CameraViewController.m
//  CourseQ
//
//  Created by Jing on 13-5-16.
//  Copyright (c) 2013年 jing. All rights reserved.
//

#import "CameraViewController.h"

#import <CoreVideo/CoreVideo.h>
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>
#import <AssertMacros.h>

#import "PhotoMaskView.h"
#import "PhotoPreviewViewController.h"

@interface CameraViewController () <PhotoPreviewViewControllerDelegate ,UIAlertViewDelegate>
{
    AVCaptureStillImageOutput *stillImageOutput;
    AVCaptureVideoDataOutput *videoDataOutput;
    AVCaptureVideoPreviewLayer *previewLayer;
    AVCaptureSession *session;
    
    CGFloat effectiveScale;
}

@property (nonatomic) CGRect cropRect;
@property (retain, nonatomic) UIImage *capturedImage;
@property (retain, nonatomic) UIPinchGestureRecognizer *pinGesture;
@property (retain, nonatomic) IBOutlet UIView *previewView;
@property (retain, nonatomic) IBOutlet PhotoMaskView *photoMaskView;

@end

@implementation CameraViewController

#pragma mark - AVCapture

- (void)initAVCapture{
    
    if (session) {
        return;
    }
    
    NSError *error = nil;
    
    session = [AVCaptureSession new];
    
    //for iphone
    [session setSessionPreset:AVCaptureSessionPreset640x480];
    
    //add video input
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    
    require(error == nil, bail);
    {
        if ([session canAddInput:deviceInput]){
            [session addInput:deviceInput];
        }
        
        //add image output
        stillImageOutput = [AVCaptureStillImageOutput new];
        
        if ([session canAddOutput:stillImageOutput]) {
            [session addOutput:stillImageOutput];
        }
        
        //add video output
        videoDataOutput = [AVCaptureVideoDataOutput new];
        NSDictionary *rgbOutputSettings = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCMPixelFormat_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey];
        [videoDataOutput setVideoSettings:rgbOutputSettings];
        
        //discard if blocked(when processing the image)
        [videoDataOutput setAlwaysDiscardsLateVideoFrames:YES];
        
        /*
         //a serial queue to guarantee that video frames will be delivered in order
         videoDataOutputQueue=dispatch_queue_create("VideoDataOutputQueue", DISPATCH_QUEUE_SERIAL);
         [videoDataOutput setSampleBufferDelegate:self queue:videoDataOutputQueue];
         */
        
        if ([session canAddOutput:videoDataOutput]) {
            [session addOutput:videoDataOutput];
        }
        [[videoDataOutput connectionWithMediaType:AVMediaTypeVideo] setEnabled:NO];
        
        //video preview layer
        effectiveScale = 1.0;
        previewLayer = [[[AVCaptureVideoPreviewLayer alloc] initWithSession:session] autorelease];
        [previewLayer setBackgroundColor:[[UIColor clearColor] CGColor]];
        [previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
        
        //previewView
        [self.previewView setFrame:CGRectMake(0, 0, 320, 568-146)];
        [self.view sendSubviewToBack:self.previewView];
        CALayer *rootLayer = [self.previewView layer];
        [rootLayer setMasksToBounds:YES];
        [previewLayer setFrame:[rootLayer bounds]];
        [rootLayer addSublayer:previewLayer];
        
        //pin gesture to zoom camera view
        self.pinGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pin:)];
        [self.previewView addGestureRecognizer:self.pinGesture];
        
        [session startRunning];
    }
    
    //if error in device input, do following:
bail:
    {
        if (error) {
            UIAlertView *alertView=[[UIAlertView alloc]
                                    initWithTitle:[NSString stringWithFormat:@"Failed with error %d", (int)[error code]]
                                    message:[error localizedDescription]
                                    delegate:nil
                                    cancelButtonTitle:@"Dismiss"
                                    otherButtonTitles:nil];
            [alertView show];
            [previewLayer removeFromSuperlayer];
        }
    }
    
    [session release];
    [stillImageOutput release];
}

- (void)pin:(UIPinchGestureRecognizer *)gesture{
    
    BOOL allTouchesAreOnThePreviewLayer = YES;
    
	NSUInteger numTouches = [gesture numberOfTouches];
    
	for (int i = 0; i < numTouches; ++i) {
		CGPoint location = [gesture locationOfTouch:i inView:self.previewView];
		CGPoint convertedLocation = [previewLayer convertPoint:location fromLayer:previewLayer.superlayer];
		if ( ! [previewLayer containsPoint:convertedLocation] ) {
			allTouchesAreOnThePreviewLayer = NO;
			break;
		}
	}
	
	if (allTouchesAreOnThePreviewLayer) {
        
		effectiveScale = effectiveScale * (1+(gesture.scale-1)/20.0);
		if (effectiveScale < 1.0)
			effectiveScale = 1.0;
        
		CGFloat maxScaleAndCropFactor = [[stillImageOutput connectionWithMediaType:AVMediaTypeVideo] videoMaxScaleAndCropFactor];
		if (effectiveScale > maxScaleAndCropFactor)
			effectiveScale = maxScaleAndCropFactor;
        
		[CATransaction begin];
		[CATransaction setAnimationDuration:.025];
		[previewLayer setAffineTransform:CGAffineTransformMakeScale(effectiveScale, effectiveScale)];
		[CATransaction commit];
	}
}


- (AVCaptureVideoOrientation)AVOrientationForDeviceOrientation:(UIDeviceOrientation)deviceOrientation
{
    // 不支持转向
	AVCaptureVideoOrientation result = AVCaptureVideoOrientationPortrait;
    
    /*自动判别设备方向
     // =======================================
     if ( deviceOrientation == UIDeviceOrientationLandscapeLeft )
     result = AVCaptureVideoOrientationLandscapeRight;
     else if ( deviceOrientation == UIDeviceOrientationLandscapeRight )
     result = AVCaptureVideoOrientationLandscapeLeft;
     // ========================================
     */
    
	return result;
}

// utility routine to display error aleart if takePicture fails
- (void)displayErrorOnMainQueue:(NSError *)error withMessage:(NSString *)message
{
	dispatch_async(dispatch_get_main_queue(), ^(void) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@ (%d)", message, (int)[error code]]
															message:[error localizedDescription]
														   delegate:nil
												  cancelButtonTitle:@"Dismiss"
												  otherButtonTitles:nil];
		[alertView show];
	});
}

#pragma mark - action

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
        [self.delegate didBackToListVC];
    }
}

- (IBAction)cameraBtnPressed:(id)sender
{
    
    //open AVCapture
    AVCaptureConnection *stillImageConnection = [stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
    
    //scale
    [stillImageConnection setVideoScaleAndCropFactor:effectiveScale];
    
    //orientation
    UIDeviceOrientation currentDeviceOrientation = [[UIDevice currentDevice] orientation];
    AVCaptureVideoOrientation videoOrientation = [self AVOrientationForDeviceOrientation:currentDeviceOrientation];
    [stillImageConnection setVideoOrientation:videoOrientation];
    
    //image output setting
    [stillImageOutput setOutputSettings:[NSDictionary
                                         dictionaryWithObject:AVVideoCodecJPEG
                                         forKey:AVVideoCodecKey]];
    [stillImageOutput captureStillImageAsynchronouslyFromConnection:stillImageConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error)
     {
         if (error) {
             [self displayErrorOnMainQueue:error withMessage:@"Take Picture Failed"];
             
         }else{
             
             //capture row JPEG image
             NSData *jpegData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
             UIImage *rowImage = [UIImage imageWithData:jpegData];
             
             //modify the image orientation
             UIGraphicsBeginImageContext(rowImage.size);
             CGContextRef context = UIGraphicsGetCurrentContext();
             
             CGContextTranslateCTM(context, 0 , rowImage.size.height);
             CGContextRotateCTM(context, M_PI_2);
             CGContextTranslateCTM(context, -rowImage.size.height, 0);
             CGContextScaleCTM(context, 1.0, -1.0);
             
             CGContextDrawImage(context, CGRectMake(0, 0, rowImage.size.height, rowImage.size.width), [rowImage CGImage]);
             UIImage *endImage = UIGraphicsGetImageFromCurrentImageContext();
             UIGraphicsEndImageContext();
             
             //crop image
             CGFloat imageWidth = endImage.size.width;
             CGFloat imageHeight = endImage.size.height;
             CGFloat previewWidth = self.previewView.bounds.size.width;
             CGFloat previewHeight = self.previewView.bounds.size.height;
             
             CGRect crop = CGRectMake(
                                      self.cropRect.origin.x * imageWidth / previewWidth,
                                      self.cropRect.origin.y * imageHeight / previewHeight,
                                      self.cropRect.size.width * imageWidth / previewWidth,
                                      self.cropRect.size.height * imageHeight / previewHeight);
             CGImageRef imageRef = CGImageCreateWithImageInRect([endImage CGImage], crop);
             self.capturedImage = [UIImage imageWithCGImage:imageRef scale:1.0 orientation:UIImageOrientationUp];
             CGImageRelease(imageRef);
             
             //[previewLayer removeFromSuperlayer];
             //[session stopRunning];
             
             [self showPhotoPreviewVCWithImage:self.capturedImage];
         }
     }];
//[self showPhotoPreviewVCWithImage:self.capturedImage];
}

- (IBAction)albumBtnPressed:(id)sender {
    //告诉PhotoViewController，让它dismiss CameraVC，然后显示AlbumVC
    [self.delegate didMoveToAlbumVC];
}

#pragma mark - previewVC & delegate

- (void)showPhotoPreviewVCWithImage:(UIImage *)image {
    
    PhotoPreviewViewController *previewVC = [[[PhotoPreviewViewController alloc] initWithNibName:@"PhotoPreviewViewController" bundle:nil] autorelease];
    previewVC.capturedImage = image;
    previewVC.delegate = self;
    [self presentViewController:previewVC animated:NO completion:NULL];
}

- (void)didFinishWithPhotoPreview:(BOOL)photoAccepted {
    
    if (photoAccepted)
    {
        //存到本地
        NSData *imageData = UIImageJPEGRepresentation(self.capturedImage, 1.0);
        [imageData writeToFile:self.imageSavePath atomically:YES];
        
        //dismiss previewView
        [self dismissViewControllerAnimated:NO completion:^{
            
            //让makerVC dismiss自己
            [self.delegate didFinishWithCamera];
        }];
        
    }else
    {
        [self dismissViewControllerAnimated:NO completion:NULL];
    }
}

- (void)didBackToListVC
{
    [self dismissViewControllerAnimated:NO completion:^{
        [self.delegate didBackToListVC];
    }];
}

#pragma mark - vc lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.cropRect = CGRectMake(10.0, 60.0, 300.0, 300.0);
    
    [self.photoMaskView setUserInteractionEnabled:NO];
    [self.previewView setUserInteractionEnabled:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [self initAVCapture];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    
    [_pinGesture release];
    [_photoMaskView release];
    [_previewView release];
    [super dealloc];
}
@end
