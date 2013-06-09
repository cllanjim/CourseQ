//
//  TouchTableView.h
//  WebSchool
//
//  Created by Fee Val on 12-11-19.
//  Copyright (c) 2012年 Freebox. All rights reserved.
//

/*
 //=======================================
 用于重写UItableView的单元格触摸事件
 //=======================================
*/

#import <UIKit/UIKit.h>

@protocol TouchTableViewDelegate <NSObject>

@optional
- (void)tableView:(UITableView *)tableView
     touchesBegan:(NSSet *)touches
        withEvent:(UIEvent *)event;

- (void)tableView:(UITableView *)tableView
 touchesCancelled:(NSSet *)touches
        withEvent:(UIEvent *)event;

- (void)tableView:(UITableView *)tableView
     touchesEnded:(NSSet *)touches
        withEvent:(UIEvent *)event;

- (void)tableView:(UITableView *)tableView
     touchesMoved:(NSSet *)touches
        withEvent:(UIEvent *)event;
@end

@interface  TouchTableView : UITableView
{
@private
    id _touchDelegate;
}

@property (nonatomic,assign) id<TouchTableViewDelegate> touchDelegate;

@end
