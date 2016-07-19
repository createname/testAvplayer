//
//  ViewController.m
//  TestVideo
//
//  Created by 李乔娜 on 16/7/8.
//  Copyright © 2016年 ZY. All rights reserved.
//

#import "ViewController.h"
#import "VideoListTableView.h"
#define kUnion_Video_NewURL @"http://box.dwstatic.com/apiVideoesNormalDuowan.php?src=duowan&action=l&sk=&pageUrl=&heroEnName=&tag=newest&p=%ld"
#import "NSString+GetWidthHeight.h"
@interface ViewController ()
@property(nonatomic,strong)VideoListTableView *tableView;
@end

@implementation ViewController
-(VideoListTableView *)tableView{
    if (!_tableView) {
        self.tableView = [[VideoListTableView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height-64)];
        
//        self.tableView.url =;
        NSString *url = kUnion_Video_NewURL;
        NSString *page = 0;
        self.tableView.url = [[NSString stringWithFormat:url,page] URLEncodedString];
        self.tableView.rootVC = self;
    }
    return _tableView;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.tableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
