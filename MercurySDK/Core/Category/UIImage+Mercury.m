//
//  UIImage+Mercury.m
//  MercurySDKExample
//
//  Created by CherryKing on 2020/4/27.
//  Copyright © 2020 mercury. All rights reserved.
//

#import "UIImage+Mercury.h"

@implementation UIImage (Mercury)

- (UIImage *)addWatermarkWithText:(NSString *)string {
    string = [NSString stringWithFormat:@" %@ ", string];
    //开启一个图形上下文
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0);
    //绘制上下文：1-添加文字到上下文
    NSDictionary *dic = @{
                          NSFontAttributeName:[UIFont systemFontOfSize:24],
                          NSForegroundColorAttributeName:[UIColor whiteColor],
                          NSBackgroundColorAttributeName:[UIColor colorWithRed:0.16 green:0.17 blue:0.21 alpha:1.00]
                          };
    
    CGSize size = [string boundingRectWithSize:CGSizeMake(MAXFLOAT, 30) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:dic context:nil].size;
    CGPoint point = CGPointMake(0, self.size.height-size.height);
    
    //绘制上下文：2-绘制图片
    [self drawAtPoint:CGPointZero];
    
    [string drawAtPoint:point withAttributes:dic];
    //从图形上下文中获取合成的图片
    UIImage *watermarkImage = UIGraphicsGetImageFromCurrentImageContext();
    //关闭上下文
    UIGraphicsEndImageContext();
    return watermarkImage;
}

@end
