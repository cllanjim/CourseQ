//
//  ContentsViewController.m
//  CourseQ
//
//  Created by Jing on 13-5-13.
//  Copyright (c) 2013年 jing. All rights reserved.
//

#import "ContentsViewController.h"

@interface ContentsViewController () <UITableViewDelegate,UITableViewDataSource>

@property (retain, nonatomic) IBOutlet UITableView *titleList;
@property (copy,nonatomic) NSArray *tableTitles;

@end

@implementation ContentsViewController

- (void)didReceiveMemoryWarning{
    
    [super didReceiveMemoryWarning];
}

#pragma mark - Initilization
- (NSArray *)tableTitles{
    
    if (_tableTitles == nil) {
        
        _tableTitles = [NSArray arrayWithObjects:
                        @"",
                        @"个人中心",
                        @"微课程",
                        @"设置",
                        nil];
    }
    
    return _tableTitles;
}

#pragma mark - Action

#pragma mark - Menu

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 1:
        {
            [self.delegate didPressProfileVCBtn];
            break;
        }
        case 2:
        {
            [self.delegate didPressListVCBtn];
            break;
        }
        case 3:
        {
            [self.delegate didPressSettingVCBtn];
            break;
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [self.tableTitles count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *CellIdentifier = @"LeftViewTableCell";
	UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        if (indexPath.row == 0)
        {
            cell.accessoryType = UITableViewCellAccessoryNone;
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        }
        else
        {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
        }
	}
    cell.textLabel.text = [self.tableTitles objectAtIndex:indexPath.row];
    cell.textLabel.textColor = [UIColor grayColor];
    
	return cell;
}

@end
