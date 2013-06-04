//
//  AlbumViewController.h
//  CourseQ
//
//  Created by Jing on 13-5-16.
//  Copyright (c) 2013年 jing. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AlbumViewControllerProtocol <NSObject>
- (void)didCancelWithAlbum;
- (void)didFinishWithAlbum;
@end

@interface AlbumViewController : UIViewController
@property (assign, nonatomic) id<AlbumViewControllerProtocol> delegate;
@property (copy, nonatomic) NSString *imageSavePath;
@end
