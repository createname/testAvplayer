//
//  VideoListTableViewCell.m
//  TestVideo
//
//  Created by 李乔娜 on 16/7/8.
//  Copyright © 2016年 ZY. All rights reserved.
//

#import "VideoListTableViewCell.h"
#import "VideoListModel.h"
#import "UIImageView+WebCache.h"
#import "NSString+GetWidthHeight.h"
@interface VideoListTableViewCell()
@property(nonatomic,strong)UIImageView *cover_url;
@property(nonatomic,strong)UILabel *titleLabel;
@property(nonatomic,strong)UILabel *video_length;
@property(nonatomic,strong)UILabel *upload_time;

@end

@implementation VideoListTableViewCell
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle =UITableViewCellSelectionStyleNone;
        self.frame = CGRectMake(0, 0, CGRectGetWidth([[UIScreen mainScreen] bounds]), 90);
        
        _cover_url =[[UIImageView alloc]initWithImage:[[UIImage imageNamed:@"imagedefault"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];// 始终根据Tint Color绘制图片，忽略图片的颜色信息
        _cover_url.tintColor = [UIColor lightGrayColor];
        [self addSubview:_cover_url];
        
        _titleLabel =[[UILabel alloc]initWithFrame:CGRectMake(120, 10, self.frame.size.width - 180, self.frame.size.height - 40)];
        _titleLabel.numberOfLines=0;
        _titleLabel.font = [UIFont systemFontOfSize:14];
        _titleLabel.textColor = [UIColor blackColor];
        [self addSubview:_titleLabel];
        
        _video_length = [[UILabel alloc]init];
        _video_length.textAlignment = NSTextAlignmentRight;
        _video_length.textColor = [UIColor grayColor];
        _video_length.font = [UIFont systemFontOfSize:12];
        [self addSubview:_video_length];
        
        _upload_time = [[UILabel alloc]init];
        _upload_time.textAlignment = NSTextAlignmentCenter;
        _upload_time.textColor = [UIColor grayColor];
        _upload_time.font = [UIFont systemFontOfSize:12];
        [self addSubview:_upload_time];

    }
    return self;
}
-(void)layoutSubviews{
    [super layoutSubviews];
    _cover_url.frame = CGRectMake(10, 10, 100, 70);
    
    _video_length.frame = CGRectMake(self.frame.size.width - 125, self.frame.size.height - 25, 50 , 15);
    _upload_time.frame = CGRectMake(120, self.frame.size.height - 25, 35, 15);
}
-(void)setModel:(VideoListModel *)model{
    _model = model;
    NSURL *picUrl = [NSURL URLWithString:model.cover_url];
    [_cover_url sd_setImageWithURL:picUrl placeholderImage:[[UIImage imageNamed:@"imagedefault"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate ]];
    _titleLabel.text = model.title;
    _video_length.text = model.video_length;
    _upload_time.text =  model.upload_time;
    
    CGFloat titleLabelHeight = [NSString getHeightWithstring:model.title width:self.frame.size.width fontSize:14];
    
    _titleLabel.frame = CGRectMake(_titleLabel.frame.origin.x , _titleLabel.frame.origin.y , _titleLabel.frame.size.width , titleLabelHeight);
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
