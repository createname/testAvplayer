//
//  NSString+GetWidthHeight.h
//  TestVideo
//
//  Created by 李乔娜 on 16/7/9.
//  Copyright © 2016年 ZY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface NSString (GetWidthHeight)
//获取字符串显示的高度
+(CGFloat)getHeightWithstring:(NSString *)str width:(CGFloat)widht fontSize:(CGFloat)fontsize;

//获取字符串显示的高度
+(CGFloat)getWidthWithstring:(NSString *)str Width:(CGFloat)width FontSize:(CGFloat)fontsize;
//URL转Encoded

- (NSString *)URLEncodedString;
@end
