//
//  VideoListModel.h
//  TestVideo
//
//  Created by 李乔娜 on 16/7/8.
//  Copyright © 2016年 ZY. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VideoListModel : NSObject
@property (nonatomic ,copy) NSString *vid;

@property (nonatomic ,copy) NSString *cover_url;

@property (nonatomic ,copy) NSString *title;

@property (nonatomic ,copy) NSString *video_length;

@property (nonatomic ,copy) NSString *upload_time;
@end
