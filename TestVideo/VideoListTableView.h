//
//  VideoListTableView.h
//  TestVideo
//
//  Created by 李乔娜 on 16/7/8.
//  Copyright © 2016年 ZY. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^SelectedVideoBlock)(NSMutableArray *videoArray , NSString *videoTitle);
@interface VideoListTableView : UITableView
@property(nonatomic,copy)NSString *url;
@property(nonatomic,copy)SelectedVideoBlock selectedVideoBlock;
@property(nonatomic,strong)UIViewController *rootVC;
//-(void)netWorkingGestVideoDetailsWithVID:(NSString *)vid Title:(NSString *)title;
@end
