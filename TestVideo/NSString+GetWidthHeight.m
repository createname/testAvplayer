//
//  NSString+GetWidthHeight.m
//  TestVideo
//
//  Created by 李乔娜 on 16/7/9.
//  Copyright © 2016年 ZY. All rights reserved.
//

#import "NSString+GetWidthHeight.h"

@implementation NSString (GetWidthHeight)
+(CGFloat)getHeightWithstring:(NSString *)str width:(CGFloat)widht fontSize:(CGFloat)fontsize{
    NSDictionary *dic = @{NSFontAttributeName:[UIFont systemFontOfSize:fontsize]};
    CGRect rect = [str boundingRectWithSize:CGSizeMake(widht, MAXFLOAT) options:(NSStringDrawingUsesFontLeading |NSStringDrawingUsesLineFragmentOrigin) attributes:dic context:nil];
    return rect.size.height;
}
+(CGFloat)getWidthWithstring:(NSString *)str Width:(CGFloat)width FontSize:(CGFloat)fontsize{
    //获取字符串显示高度
    NSDictionary *dic=@{NSFontAttributeName:[UIFont systemFontOfSize:fontsize]};
    
    CGRect rect=[str boundingRectWithSize:CGSizeMake(width, 1000000000) options:(NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin) attributes:dic context:nil];
    
    return rect.size.width;
}
- (NSString *)URLEncodedString
{
    NSString *encodedString = (NSString *)
    CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                              (CFStringRef)self,
                                                              (CFStringRef)@"!$&'()*+,-./:;=?@_~%#[]",
                                                              NULL,
                                                              kCFStringEncodingUTF8));
    return encodedString;
}
@end
