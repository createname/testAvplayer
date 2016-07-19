//
//  VideoListTableView.m
//  TestVideo
//
//  Created by 李乔娜 on 16/7/8.
//  Copyright © 2016年 ZY. All rights reserved.
//

#import "VideoListTableView.h"
#import "VideoListTableViewCell.h"
#import "VideoListModel.h"
#import "VideoPlayerViewController.h"
#import "VideoDetailsModel.h"
#import "NSString+GetWidthHeight.h"
#define kUnion_VideoDetailsURL @"http://box.dwstatic.com/apiVideoesNormalDuowan.php?action=f&vid=%@"

@interface VideoListTableView()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong)NSMutableArray *tableArray;

@property(nonatomic,assign)NSInteger page;

@property (nonatomic ,retain) NSMutableArray *videoArray ;//视频详情数组

@property (nonatomic ,assign) NSInteger selectedCellIndex;//选中的Cell

@property (nonatomic ,assign) NSInteger lastSelectedCellIndex;//上一次选中的Cell
@property (nonatomic ,retain) UIImageView *reloadImageView;//重新加载图片视图
@end
@implementation VideoListTableView
-(NSMutableArray *)tableArray{
    if (!_tableArray) {
        self.tableArray =[NSMutableArray new];
    }
    return _tableArray;
}
-(NSMutableArray *)videoArray{
    if (!_videoArray) {
        self.videoArray = [NSMutableArray new];
    }
    return _videoArray;
}

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.dataSource = self;
        self.delegate = self;
    }
    return self;
}
-(void)setUrl:(NSString *)url{
    _url = url;

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"GET"];
    [request setTimeoutInterval:12];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error==nil) {
            NSMutableArray *array =[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            
            for (NSDictionary *dic in array) {
                VideoListModel *model =[[VideoListModel alloc]init];
                NSString *uploadTime = [[dic valueForKey:@"upload_time"] substringWithRange:NSMakeRange(5, 5)];
                model.video_length = [self getStringWithTime:[[dic objectForKey:@"video_length"] integerValue]];
                model.vid = [dic objectForKey:@"vid"];
                model.cover_url = [dic objectForKey:@"cover_url"];
                model.title = [dic objectForKey:@"title"];
                model.upload_time = uploadTime;
                [self.tableArray addObject:model];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self reloadData];
            });
        }else{
            NSLog(@"error:%@",error);
        }
    }];
    [task resume];
}
/**将秒转换成指定时间格式*/
-(NSString *)getStringWithTime:(NSInteger)timer{
    NSString *timeString = nil;
    NSInteger MM =0;
    NSInteger HH =0;
    if (59<timer) {
        MM = timer/60;
        timeString = [NSString stringWithFormat:@"%.2ld:%.2ld",(long)MM,timer-MM*60];
        if (3599<timer) {
            HH = timer/3600;
            timeString = [NSString stringWithFormat:@"%.2ld:%.2ld:%.2ld",(long)HH,MM>59?MM-60:MM,timer-MM*60];
        }
    }
    return timeString;
}
-(NSInteger)numberOfRowsInSection:(NSInteger)section{
    return 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 90;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.tableArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identfier = @"cell";
    VideoListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identfier];
    if (cell==nil) {
        cell = [[VideoListTableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identfier];
    }
    [cell setModel:self.tableArray[indexPath.row]];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    VideoListModel *mode = self.tableArray[indexPath.row];
    [self getVideoDetailsWithVID:mode.vid title:mode.title];
    
}
/**请求视频详情*/
-(void)getVideoDetailsWithVID:(NSString *)vid title:(NSString *)title{
    [self.videoArray removeAllObjects];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[[NSString stringWithFormat:kUnion_VideoDetailsURL , vid] URLEncodedString]]];
    [request setHTTPMethod:@"GET"];
    [request setTimeoutInterval:12];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error==nil) {
            NSDictionary *dic =[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            
            NSDictionary *resultDic = [dic valueForKey:@"result"];
            
            NSDictionary *itemsDic = [resultDic valueForKey:@"items"];
            
            for (NSString *key in itemsDic) {
                
                NSDictionary *itemDic = [itemsDic valueForKey:key];
                
                //创建视频详情对象
                
                VideoDetailsModel *VDModel = [[VideoDetailsModel alloc]init];
                
                VDModel.vid = [itemDic valueForKey:@"vid"] ;
                
                VDModel.transcode_id = [itemDic valueForKey:@"transcode_id"];
                
                VDModel.video_name = [itemDic valueForKey:@"video_name"];
                
                VDModel.definition = [itemDic valueForKey:@"definition"];
                
                VDModel.size = [[itemDic valueForKey:@"transcode"] valueForKey:@"size"];
                
                VDModel.width = [[itemDic valueForKey:@"transcode"] valueForKey:@"width"];
                
                VDModel.height = [[itemDic valueForKey:@"transcode"] valueForKey:@"height"];
                
                VDModel.duration = [[itemDic valueForKey:@"transcode"] valueForKey:@"duration"];
                
                VDModel.urls = [[itemDic valueForKey:@"transcode"] valueForKey:@"urls"];
                
                //添加数组
                
                [self.videoArray addObject:VDModel];
            }
//            NSLog(@"videoArray===:%@",self.videoArray);
            [self.videoArray sortUsingComparator:^NSComparisonResult(VideoDetailsModel *obj1, VideoDetailsModel *obj2) {
                return [obj1.definition integerValue]>[obj2.definition integerValue];
            }];
            dispatch_async(dispatch_get_main_queue(), ^{
                
                VideoPlayerViewController *player = [[VideoPlayerViewController alloc]init];
                player.videoArray = self.videoArray;
                player.videoTitle = title;
                [self.rootVC presentViewController:player animated:YES completion:nil];
            });
        }else{
            NSLog(@"error:%@",error);
        }
    }];
    [task resume];
}
@end
