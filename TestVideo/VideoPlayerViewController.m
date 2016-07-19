//
//  VideoPlayerViewController.m
//  TestVideo
//
//  Created by 李乔娜 on 16/7/11.
//  Copyright © 2016年 ZY. All rights reserved.
//

#import "VideoPlayerViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "VideoDetailsModel.h"
@interface VideoPlayerViewController(){
    CGFloat totalTime;//视频总时间
    BOOL isHidenToolView;
}
@property(nonatomic,strong)AVPlayer *player;
@property(nonatomic,strong)AVPlayerItem *playerItem;
@property(nonatomic,strong)AVPlayerLayer *playerLayer;
@property(nonatomic,strong)UIActivityIndicatorView *activityIndicator;//小菊花

@property(nonatomic,assign)NSInteger definitIndex;//清晰度下标

@property(nonatomic,strong)UIView *topView;
@property(nonatomic,strong)UIView *bottomView;
@property(nonatomic,strong)UIButton *topBackButton;
@property(nonatomic,strong)UILabel *topTitleLabel;
@property(nonatomic,strong)UIButton *topDefinitionButton;
@property(nonatomic,strong)UIView *topDefinitionListView;//顶部清晰度列表视图

@property(nonatomic,strong)UISlider *progressSlider;//进度
@property(nonatomic,strong)UIProgressView *progressView;//缓冲进度
@property(nonatomic,strong)UILabel *timeLabel;//时间

@property(nonatomic,strong)UIView *volumeView;//音量试图
@property(nonatomic,strong)UISlider *volumeSlider;//侧滑块
@property(nonatomic,strong)UISlider *systemvolumeViewSlider;//系统音量滑块
@property(nonatomic,strong)UIImageView *volumeImageView;//音量图标;

@property(nonatomic,strong)UIButton *playButton;

@end
@implementation VideoPlayerViewController
-(void)viewDidLoad{
    [super viewDidLoad];
    _definitIndex=0;
    self.view.backgroundColor =[UIColor whiteColor];
    _activityIndicator = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(0, 0, 60, 60)];
    self.view.backgroundColor =[UIColor clearColor];
    _activityIndicator.center = self.view.center;
    [self.view addSubview:_activityIndicator];
    [self.view addSubview:self.topView];
    [self.view addSubview:self.volumeView];
    [self.view addSubview:self.bottomView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(systemVolumeChanged:) name:@"AVSystemController_SystemVolumeDidChangeNotification" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    UIImageView *img = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
    img.backgroundColor = [UIColor blackColor];
    
    //设置播放页面
    _playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    //设置播放页面的大小
//    layer.frame = img.frame;
    _playerLayer.frame =self.view.bounds;
    _playerLayer.backgroundColor = [UIColor blackColor].CGColor;
    //设置播放窗口和当前视图之间的比例显示内容
    _playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    //添加播放视图到self.view
    [self.view.layer addSublayer:_playerLayer];
//    [img.layer addSublayer:layer];
    //进行播放
    [self.player play];
//    [self.view addSubview:img];
    [self.view bringSubviewToFront:self.topView];
    [self.view bringSubviewToFront:self.volumeView];
    [self.view bringSubviewToFront:self.bottomView];
    [self.view bringSubviewToFront:_activityIndicator];
    [self.view bringSubviewToFront:_topDefinitionListView];
    [_activityIndicator startAnimating];
    UITapGestureRecognizer *sinTap =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideToolView:)];
    [self.view addGestureRecognizer:sinTap];
    
    UITapGestureRecognizer *doubleTap =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doubleTap:)];
    [doubleTap setNumberOfTapsRequired:2];
    [self.view addGestureRecognizer:doubleTap];
    
    [sinTap requireGestureRecognizerToFail:doubleTap];
    
}
/**全屏*/
-(void)doubleTap:(UITapGestureRecognizer *)tap{
    if ([UIDevice currentDevice].orientation == UIDeviceOrientationPortrait) {
        //这句话是防止手动先把设备置为横屏,导致下面的语句失效.
        
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationPortrait] forKey:@"orientation"];
        
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationLandscapeLeft] forKey:@"orientation"];
        self.topView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 64);
        _topDefinitionButton.frame = CGRectMake(CGRectGetWidth(_topView.frame) - 70, 27, 60, 30);
        _topDefinitionListView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 100, 150)];
        _topDefinitionListView.center = self.view.center;

        self.bottomView.frame = CGRectMake(0, CGRectGetHeight(self.view.frame)-60, CGRectGetWidth(self.view.frame), 60);
        self.volumeView.frame = CGRectMake(CGRectGetWidth(self.view.frame)-40, 0, 40, 160);
        _volumeView.center = CGPointMake(_volumeView.center.x, CGRectGetHeight(self.view.frame) / 2) ;
        self.playerLayer.frame= self.view.bounds;
    }else{
        //这句话是防止手动先把设备置为竖屏,导致下面的语句失效.
        
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationLandscapeLeft] forKey:@"orientation"];
        
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationPortrait] forKey:@"orientation"];
        self.topView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 64);
        _topDefinitionButton.frame = CGRectMake(CGRectGetWidth(_topView.frame) - 70, 27, 60, 30);
        _topDefinitionListView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 100, 150)];
        _topDefinitionListView.center = self.view.center;

        self.bottomView.frame = CGRectMake(0, CGRectGetHeight(self.view.frame)-60, CGRectGetWidth(self.view.frame), 60);
        self.volumeView.frame = CGRectMake(CGRectGetWidth(self.view.frame)-40, 0, 40, 160);
        _volumeView.center = CGPointMake(_volumeView.center.x, CGRectGetHeight(self.view.frame) / 2) ;
        self.playerLayer.frame= self.view.bounds;
    }
}
/**播放完成*/
-(void)moviePlayDidEnd:(NSNotification *)notification{
    [self.player seekToTime:kCMTimeZero];
    [self.player pause];
    
    _playButton.selected=YES;
    
}
-(void)hideToolView:(UIGestureRecognizer *)ges{
    if (isHidenToolView) {
        [UIView animateWithDuration:0.2 animations:^{
            self.topView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 64);
            self.bottomView.frame = CGRectMake(0, CGRectGetHeight(self.view.frame)-60, CGRectGetWidth(self.view.frame), 60);
            self.volumeView.frame = CGRectMake(CGRectGetWidth(self.view.frame)-40, 0, 40, 160);
            _volumeView.center = CGPointMake(_volumeView.center.x, CGRectGetHeight(self.view.frame) / 2) ;
        }];
        isHidenToolView=NO;
    }else{
    
        [UIView animateWithDuration:0.3 animations:^{
            self.topView.frame = CGRectMake(0, -64, CGRectGetWidth(self.view.frame), 64);
            self.bottomView.frame = CGRectMake(0, CGRectGetHeight(self.view.frame)+60, CGRectGetWidth(self.view.frame), 60);
            self.volumeView.frame = CGRectMake(CGRectGetWidth(self.view.frame), 0, 40, 160);
            _volumeView.center = CGPointMake(_volumeView.center.x, CGRectGetHeight(self.view.frame) / 2) ;
        }];
        isHidenToolView=YES;
    }
}
/**
 *  系统音量改变
 *
 *  @param notification 通知对象
 */

- (void)systemVolumeChanged:(NSNotification *)notification{
    _volumeSlider.value = _systemvolumeViewSlider.value;
    [self VolumeSliderAction:_volumeSlider];
}
-(UIView *)topView{
    if (!_topView) {
        _topView =[[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 64)];
        _topView.backgroundColor =[[UIColor blackColor]colorWithAlphaComponent:0.6];
        
        _topBackButton =[UIButton buttonWithType:UIButtonTypeCustom];
        _topBackButton.backgroundColor =[UIColor clearColor];
        _topBackButton.tintColor =[UIColor whiteColor];
        [_topBackButton setImage:[[UIImage imageNamed:@"iconfont-fanhui"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        _topBackButton.frame = CGRectMake(0, 20, 60, 44);
        [_topBackButton addTarget:self action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_topView addSubview:_topBackButton];
        
        //初始化清晰度按钮
        _topDefinitionButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _topDefinitionButton.frame = CGRectMake(CGRectGetWidth(_topView.frame) - 70, 27, 60, 30);
        _topDefinitionButton.layer.borderWidth=1.0f;
        _topDefinitionButton.layer.borderColor= [[[UIColor grayColor] colorWithAlphaComponent:0.7f]CGColor];
        [_topDefinitionButton addTarget:self action:@selector(DefinitionButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        _topDefinitionButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
        [_topDefinitionButton setTitle:@"标清" forState:UIControlStateNormal];
        [_topDefinitionButton setTitleColor: [UIColor lightGrayColor] forState:UIControlStateNormal];
        [_topView addSubview:_topDefinitionButton];
        
        //初始化清晰度列表图
        _topDefinitionListView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 100, 150)];
        _topDefinitionListView.center = self.view.center;
        _topDefinitionListView.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.0f];
        _topDefinitionListView.hidden=YES;
        _topDefinitionListView.alpha = 0;
        [self.view addSubview:_topDefinitionListView];
        
        //初始化清晰度列表选项button
        UIButton *BDButton = [UIButton buttonWithType:0];
        BDButton.frame = CGRectMake(0, 10, CGRectGetWidth(_topDefinitionListView.frame), 40);
        BDButton.backgroundColor =[[UIColor blackColor]colorWithAlphaComponent:0.6];
        [BDButton setTitle:@"标清" forState:UIControlStateNormal];
        [BDButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [BDButton addTarget:self action:@selector(BDButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_topDefinitionListView addSubview:BDButton];
        
        UIButton *HDButton = [UIButton buttonWithType:0];
        HDButton.frame = CGRectMake(0, 60, CGRectGetWidth(_topDefinitionListView.frame), 40);
        HDButton.backgroundColor =[[UIColor blackColor]colorWithAlphaComponent:0.6];
        [HDButton setTitle:@"高清" forState:UIControlStateNormal];
        [HDButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [HDButton addTarget:self action:@selector(HDButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_topDefinitionListView addSubview:HDButton];
        
        UIButton *FHDButton = [UIButton buttonWithType:0];
        FHDButton.frame = CGRectMake(0, 110, CGRectGetWidth(_topDefinitionListView.frame), 40);
        FHDButton.backgroundColor =[[UIColor blackColor]colorWithAlphaComponent:0.6];
        [FHDButton setTitle:@"超清" forState:UIControlStateNormal];
        [FHDButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [FHDButton addTarget:self action:@selector(FHDButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_topDefinitionListView addSubview:FHDButton];
        
        //初始标题
        _topTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(65 , 20 , CGRectGetWidth(_topView.frame) - 135 , 44)];
        _topTitleLabel.text = self.videoTitle;
        _topTitleLabel.textColor = [UIColor whiteColor];
        _topTitleLabel.textAlignment = NSTextAlignmentCenter;
        _topTitleLabel.font = [UIFont systemFontOfSize:16];
        [_topView addSubview:_topTitleLabel];
        
    }
    return _topView;
}
-(void)backButtonAction:(UIButton *)btn{
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)DefinitionButtonAction:(UIButton *)btn{
    if (_topDefinitionListView.hidden) {
        [_topDefinitionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        for (int i=0; i<self.videoArray.count; i++) {
            if (_definitIndex==1) {
                [_topDefinitionListView.subviews[i]setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            }else{
                [_topDefinitionListView.subviews[i]setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            }
        }
        _topDefinitionListView.hidden=NO;
        
        [UIView animateWithDuration:0.3 animations:^{
            _topDefinitionListView.alpha=1;
        }completion:^(BOOL finished) {
            
        }];
    }else{
        [_topDefinitionButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [UIView animateWithDuration:0.3f animations:^{
            _topDefinitionListView.alpha=0;
        }completion:^(BOOL finished) {
            _topDefinitionListView.hidden=YES;
        }];
    }
}
/**标清*/
-(void)BDButtonAction:(UIButton *)btn{
    self.definitIndex=0;
    [_topDefinitionButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [UIView animateWithDuration:0.2f animations:^{
        _topDefinitionListView.alpha=0;
    }completion:^(BOOL finished) {
        _topDefinitionListView.hidden=YES;
    }];

}
/**高清*/
-(void)HDButtonAction:(UIButton *)btn{
    self.definitIndex=1;
    [_topDefinitionButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [UIView animateWithDuration:0.2f animations:^{
        _topDefinitionListView.alpha=0;
    }completion:^(BOOL finished) {
        _topDefinitionListView.hidden=YES;
    }];

//    [self getNetworkUrl];
}
/**超清*/
-(void)FHDButtonAction:(UIButton *)btn{
    self.definitIndex=2;
    [_topDefinitionButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [UIView animateWithDuration:0.2f animations:^{
        _topDefinitionListView.alpha=0;
    }completion:^(BOOL finished) {
        _topDefinitionListView.hidden=YES;
    }];

}
-(void)dealloc{
    [self removeNotification];
    [self removeObserverFromPlayerItem];
}
-(void)setDefinitIndex:(NSInteger)definitIndex{
    _definitIndex = definitIndex;
    if (self.videoArray.count-1>=definitIndex) {
        NSString *definTitle = @"";
        switch (definitIndex) {
            case 0:
                definTitle = @"标清";
                break;
            case 1:
                definTitle = @"高清";
                break;
            case 2:
                definTitle = @"超清";
                break;
            default:
                break;
        }
        [_topDefinitionButton setTitle:definTitle forState:UIControlStateNormal];
        [self removeNotification];
        [self removeObserverFromPlayerItem];
        
        self.playerItem = [self getPlayItem:0];
        [self.player replaceCurrentItemWithPlayerItem:self.playerItem];
        [self addObserver];
        [self.player play];
    }
}
#pragma mark-移除playeritem
-(void)removeObserverFromPlayerItem{
    [self.player.currentItem removeObserver:self forKeyPath:@"status"];
    [self.player.currentItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
}
-(AVPlayerItem *)getPlayItem:(int)videoIndex{
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:[self getNetworkUrl]];
    return playerItem;
}
/**侧音量滑块*/
-(UIView *)volumeView{
    if (!_volumeView) {
        _volumeView = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame)-40, 0, 40, 160)];
        _volumeView.center = CGPointMake(_volumeView.center.x, CGRectGetHeight(self.view.frame) / 2) ;
        _volumeView.backgroundColor =[[UIColor blackColor]colorWithAlphaComponent:0.5f];
        
        //初始化音量控制滑块视图
        _volumeSlider = [[UISlider alloc]initWithFrame:CGRectMake(0 - 40, 60, 120, 20)];
        _volumeSlider.transform = CGAffineTransformMakeRotation(M_PI_2 * 3);
        _volumeSlider.minimumTrackTintColor=[UIColor colorWithRed:105/255.0 green:149/255.0 blue:246/255.0 alpha:1];
        _volumeSlider.maximumTrackTintColor = [UIColor lightGrayColor];
        _volumeSlider.tintColor =[UIColor whiteColor];
        _volumeSlider.maximumValue=1.0f;
        _volumeSlider.minimumValue=0.0f;
        [_volumeSlider setThumbImage:[UIImage imageNamed:@"iconfont-dian"] forState:UIControlStateNormal];
        [_volumeSlider addTarget:self action:@selector(VolumeSliderAction:) forControlEvents:UIControlEventValueChanged];
        [_volumeView addSubview:_volumeSlider];
        
        //初始化音量图标
        _volumeImageView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 135, 20, 20)];
        _volumeImageView.tintColor = [UIColor whiteColor];
        _volumeImageView.image = [[UIImage imageNamed:@"iconfont-yinliangxiao"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [_volumeView addSubview:_volumeImageView];
        
        //获取系统音量
        MPVolumeView *systemVolumeView = [MPVolumeView new];
        systemVolumeView.center = CGPointMake(-1000, -1000);
        systemVolumeView.hidden = NO;
        for (UIView *view in [systemVolumeView subviews]){
            
            if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
                
                _systemvolumeViewSlider = (UISlider*)view;
                
                break;
            }
        }
        //同步系统音量
        _volumeSlider.value = _systemvolumeViewSlider.value;
    }
    return _volumeView;
}
/**音量控制*/
-(void)VolumeSliderAction:(UISlider *)slider{
    if (slider.value==0) {
        _volumeImageView.image = [[UIImage imageNamed:@"iconfont-yinliangjingyin"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }else if (slider.value>=0.8){
        _volumeImageView.image = [[UIImage imageNamed:@"iconfont-yinliangda"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }else{
        _volumeImageView.image = [[UIImage imageNamed:@"iconfont-yinliangxiao"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    [_systemvolumeViewSlider setValue:slider.value animated:YES];
}
-(UIView *)bottomView{
    if (!_bottomView) {
         _bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.frame) - 60, CGRectGetWidth(self.view.frame), 60)];
        _bottomView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
        
        //初始化播放按钮
        _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _playButton.backgroundColor = [UIColor clearColor];
        _playButton.tintColor = [UIColor whiteColor];
        [_playButton setImage:[[UIImage imageNamed:@"iconfont-zanting"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [_playButton setImage:[[UIImage imageNamed:@"iconfont-bofang"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateSelected];
        _playButton.frame = CGRectMake( 5 , 5, 50, 50 );
        [_playButton addTarget:self action:@selector(playButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_bottomView addSubview:_playButton];
        
        //缓冲进度
        _progressView =[[UIProgressView alloc]initWithProgressViewStyle:UIProgressViewStyleDefault];
        _progressView.frame = CGRectMake(70, 29, CGRectGetWidth(self.view.frame) - 100 , 10);
        _progressView.trackTintColor = [UIColor blackColor];
        _progressView.progressTintColor = [UIColor lightGrayColor];
        _progressView.userInteractionEnabled=NO;
        [_bottomView addSubview:_progressView];
        
        //进度
        _progressSlider =[[UISlider alloc]initWithFrame:CGRectMake(68 , 15 , CGRectGetWidth(self.view.frame) - 96 , 30)];
        _progressSlider.minimumTrackTintColor =[UIColor colorWithRed:105/255.0 green:149/255.0 blue:246/255.0 alpha:1];
        _progressSlider.maximumTrackTintColor = [UIColor clearColor];
        _progressSlider.tintColor =[UIColor whiteColor];
        _progressSlider.minimumValue=0.0f;
        [_progressSlider setThumbImage:[UIImage imageNamed:@"iconfont-dian"] forState:UIControlStateNormal];
        [_progressSlider addTarget:self action:@selector(proSlide:) forControlEvents:UIControlEventValueChanged];
        [_bottomView addSubview:_progressSlider];
        
        
        //时间
        _timeLabel =[[UILabel alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame) - 150 , 30 , 120 , 30)];
        _timeLabel.text = @"00:00:00:00:00:00";
        _timeLabel.textColor = [UIColor whiteColor];
        _timeLabel.textAlignment = NSTextAlignmentRight;
        _timeLabel.font = [UIFont systemFontOfSize:12];
        [_bottomView addSubview:_timeLabel];
    }
    return _bottomView;
}
/**暂停播放*/
-(void)pausePlayer{
    [_player pause];
    _playButton.selected=YES;
    
}
/**开始播放*/
-(void)startPlayer{
    [_player play];
    _playButton.selected=NO;
}
/**播放进度*/
-(void)proSlide:(UISlider *)slide{
     NSInteger dragedSeconds = floorf(totalTime*slide.value);//快进的进度
    [self pausePlayer];
    [self.player seekToTime:CMTimeMake(dragedSeconds, 1) completionHandler:^(BOOL finished) {
        [self startPlayer];
    }];
}
-(void)playButtonAction:(UIButton *)btn{
    if (_playButton.selected) {
        [self.player play];
    }else{
        [self.player pause];
    }
    _playButton.selected =!_playButton.selected;
}
-(AVPlayer *)player{
    if (!_player) {
        self.playerItem = [self getPlayItem:0];
        self.player =[AVPlayer playerWithPlayerItem:self.playerItem];;
        [self addObserver];
    }
    return _player;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"status"]) {
        if (_playerItem.status == AVPlayerStatusReadyToPlay) {
            [_activityIndicator stopAnimating];
            [self loadData];
            
            NSLog(@"开始播放...");
        }else{
            NSLog(@"播放失败...");
        }
    }else if ([keyPath isEqualToString:@"loadedTimeRanges"]){
        NSTimeInterval timeInterval = [self availableDuration];//当前缓冲进度
//        NSLog(@"Time Interval:%f",timeInterval);
        CMTime duration = self.player.currentItem.duration;
        CGFloat totalDuration = CMTimeGetSeconds(duration);//总长度
        [_progressView setProgress:timeInterval/totalDuration];
//        NSLog(@"==:%f",timeInterval/totalDuration);
    }
}

-(void)loadData
{
    __weak typeof(self) weakSelf=self;
    [weakSelf.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:NULL usingBlock:^(CMTime time) {
        //当前播放时间
        CGFloat  currentime=_playerItem.currentTime.value/_playerItem.currentTime.timescale;
        //总时长z
        CMTime  time1=weakSelf.playerItem.duration;
        float X=CMTimeGetSeconds(time1);
        totalTime = X;
        [_progressSlider setValue:currentime/X];
        _timeLabel.text = [NSString stringWithFormat:@"%@:%@",[self getStringWithTime:currentime],[self getStringWithTime:X]];
        
    }];
}
/**缓冲进度*/
-(NSTimeInterval)availableDuration{
    NSArray *loadedTimeRanges = [[self.player currentItem]loadedTimeRanges];
    CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
    
    float startSeconds = CMTimeGetSeconds(timeRange.start);
    float durationSeconds = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result = startSeconds +durationSeconds;//计算缓冲进度
    return result;
}
/**将秒转换成指定时间格式*/
-(NSString *)getStringWithTime:(NSInteger)time{
    if (time < 0) {
        time = 0 - time;
    }

    NSString *timeString = nil;
    NSInteger MM = 0;
    NSInteger HH = 0;
    
    if (59 < time) {
        
        MM = time / 60 ;
        if (3599 < time) {
            
            HH = time / 3600 ;
        }
    }
    timeString = [NSString stringWithFormat:@"%.2ld:%.2ld:%.2ld", (long)HH , MM > 59 ? MM - 60 : MM ,time - MM * 60];
    
    return timeString;
}

-(void)setVideoArray:(NSMutableArray *)videoArray{
    _videoArray = videoArray;
    if (videoArray !=nil) {
        if (videoArray.count>0) {
            if (self.definitIndex>videoArray.count-1) {
                self.definitIndex = videoArray.count-1;
            }
            for (UIButton *itemButton in _topDefinitionListView.subviews) {
                itemButton.hidden=YES;
            }
            //显示清晰度列表选项
            for (int i=0; i<videoArray.count; i++) {
                UIButton *tempButton = (UIButton *)_topDefinitionListView.subviews[i];
                
                tempButton.hidden = NO;
            }
        }
        
    }
}
#pragma mark-kvc监听
-(void)addObserver{
    [self.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [self .playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}
#pragma mark-移除所有kvc监听
-(void)removeNotification{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
//-(AVPlayerItem *)playerItem{
//    if (!_playerItem) {
//        self.playerItem = [[AVPlayerItem alloc]initWithURL:[self getNetworkUrl]];
//        [self.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
//        [self .playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
//        [self.playerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
//    }
//    return _playerItem;
//}
/**取得网络文件路径*/
-(NSURL *)getNetworkUrl{
    VideoDetailsModel *VDModel = self.videoArray[self.definitIndex];
    NSArray *urlArray = VDModel.urls;
    NSString *urlStr = [urlArray objectAtIndex:0];
    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:urlStr];
    
    return url;
}
@end
