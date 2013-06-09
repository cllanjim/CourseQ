//
//  AlbumViewController.m
//  CourseQ
//
//  Created by Jing on 13-5-16.
//  Copyright (c) 2013年 jing. All rights reserved.
//

#import "AlbumViewController.h"
#import "PhotoMaskView.h"
#import "PhotoPreviewViewController.h"

@interface AlbumViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIScrollViewDelegate, PhotoPreviewViewControllerDelegate>

@property (assign, nonatomic) BOOL isTheFirstTime;
@property (assign, nonatomic) CGRect cropRect;
@property (retain, nonatomic) UIImage *capturedImage;
@property (retain, nonatomic) UIImagePickerController *imagePicker;
@property (retain, nonatomic) UIImageView *imageView;
@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;


@end

@implementation AlbumViewController

#pragma mark - action

- (IBAction)cancelBtnPressed:(id)sender {
    //到cameraVC
    [self.delegate didCancelWithAlbum];
}

- (IBAction)cutBtnPressed:(id)sender {
    
    //到previewVC
    
    UIImage *albumImage = self.imageView.image;
    UIImage *modifiedImage = [self modifyImageOrientation:albumImage];
    
    //截图片
    CGFloat zoomScale = self.scrollView.zoomScale;
    CGFloat aX = (self.scrollView.contentOffset.x + self.cropRect.origin.x)/zoomScale;
    CGFloat aY = (self.scrollView.contentOffset.y + self.cropRect.origin.y)/zoomScale;
    CGFloat aWidth = self.cropRect.size.width/zoomScale;
    CGFloat aHeight = self.cropRect.size.height/zoomScale;
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([modifiedImage CGImage], CGRectMake(aX, aY, aWidth, aHeight));
    //截好的图片
    self.capturedImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    [self showPhotoPreviewVCWithImage:self.capturedImage];
}

- (UIImage *)modifyImageOrientation:(UIImage *)originImage {
    
    //调整 imageOrientation
    CGFloat imageWidth = originImage.size.width;
    CGFloat imageHeight = originImage.size.height;
    UIImage *endImage;
    
    switch (originImage.imageOrientation) {
            
        case 1: // down Orientation
        {
            UIGraphicsBeginImageContext(originImage.size);
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextRetain(context);
            //
            CGContextTranslateCTM(context, imageWidth, 0);
            CGContextScaleCTM(context, -1.0, 1.0);
            
            CGContextDrawImage(context, CGRectMake(0, 0, imageWidth, imageHeight), [originImage CGImage]);
            endImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            CGContextRelease(context);
            break;
        }
        case 2: // right Orientation
        {
            UIGraphicsBeginImageContext(originImage.size);
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextRetain(context);
            
            CGContextRotateCTM(context, -M_PI_2);
            CGContextScaleCTM(context, 1.0, -1.0);
            CGContextTranslateCTM(context, -imageHeight, -imageWidth);
            
            CGContextDrawImage(context, CGRectMake(0, 0, imageHeight, imageWidth), [originImage CGImage]);
            endImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            CGContextRelease(context);
            
            break;
        }
        case 3: // left Orientation
        {
            UIGraphicsBeginImageContext(originImage.size);
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextRetain(context);
            
            CGContextTranslateCTM(context, 0 , imageHeight);
            CGContextRotateCTM(context, M_PI_2);
            CGContextTranslateCTM(context, -imageHeight, 0);
            CGContextScaleCTM(context, 1.0, -1.0);
            
            CGContextDrawImage(context, CGRectMake(0, 0, imageHeight, imageWidth), [originImage CGImage]);
            endImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            CGContextRelease(context);
            
            break;
        }
        default:
            endImage=originImage;
            break;
    }
    
    return endImage;
}


#pragma mark - imagePicker

- (void)initImagePicker {
    
    if (!self.imagePicker) {
        self.imagePicker = [[UIImagePickerController alloc] init];
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        self.imagePicker.delegate = self;
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *originImage = [info valueForKey:UIImagePickerControllerOriginalImage];
    
    if (self.imageView) {
        [self.imageView removeFromSuperview];
        self.imageView = nil;
    }
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, originImage.size.width, originImage.size.height)];
    [self.imageView setImage:originImage];
    [self.imageView setUserInteractionEnabled:NO];
    
    [self.scrollView setContentSize:originImage.size];
    
    //scrollView scale
    CGFloat xScale = self.scrollView.bounds.size.width/originImage.size.width;
    CGFloat yScale = self.scrollView.bounds.size.height/originImage.size.height;
    CGFloat minScale = MAX(xScale, yScale);
    CGFloat maxScale = 1.0;
    if (minScale > maxScale) minScale = maxScale;
    
    [self.scrollView setMinimumZoomScale:minScale];
    [self.scrollView setMaximumZoomScale:maxScale];
    [self.scrollView setZoomScale:minScale];
    
    [self.scrollView addSubview:self.imageView];
    [self.view sendSubviewToBack:self.scrollView];
    
    [self dismissViewControllerAnimated:NO completion:NULL];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [self dismissViewControllerAnimated:NO completion:^{
        //回到cameraVC
        [self.delegate didCancelWithAlbum];
    }];
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
        
        [self dismissViewControllerAnimated:NO completion:^{
            //让makerVC dismiss自己
            [self.delegate didFinishWithAlbum];
        }];
        
    }else
    {
        [self dismissViewControllerAnimated:NO completion:^{
            [self.delegate didCancelWithAlbum];
        }];
    }
}

- (void)didBackToListVC
{
    [self dismissViewControllerAnimated:NO completion:^{
        [self.delegate didCancelWithAlbum];
    }];
}

#pragma mark - vc lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.cropRect = CGRectMake(10.0, 60.0, 300.0, 300.0);
    
    self.isTheFirstTime = YES;
    
    [self initImagePicker];
    
    [self.scrollView setDelegate:self];
    
}

- (void)viewDidAppear:(BOOL)animated {
    
    if (self.isTheFirstTime) {
        [self presentViewController:self.imagePicker animated:YES completion:NULL];
        self.isTheFirstTime = NO;
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_scrollView release];
    [super dealloc];
}
@end
