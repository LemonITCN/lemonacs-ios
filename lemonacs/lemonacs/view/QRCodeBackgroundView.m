//
//  LWQRCodeBackgroundView.m
//  QRCodeCamera
//
//  Created by 王炜光 on 2018/7/10.
//  Copyright © 2018年 Ezrea1. All rights reserved.
//

#import "QRCodeBackgroundView.h"

@implementation QRCodeBackgroundView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //填充区域颜色
    [[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5] set];
    
    //扫码区域上面填充
    CGRect notScanRect = CGRectMake(0, 0, self.frame.size.width, _scanFrame.origin.y);
    CGContextFillRect(context, notScanRect);
    
    //扫码区域左边填充
    rect = CGRectMake(0, _scanFrame.origin.y, _scanFrame.origin.x,_scanFrame.size.height);
    CGContextFillRect(context, rect);
    
    //扫码区域右边填充
    rect = CGRectMake(CGRectGetMaxX(_scanFrame), _scanFrame.origin.y, _scanFrame.origin.x,_scanFrame.size.height);
    CGContextFillRect(context, rect);
    
    //扫码区域下面填充
    rect = CGRectMake(0, CGRectGetMaxY(_scanFrame), self.frame.size.width,self.frame.size.height - CGRectGetMaxY(_scanFrame));
    CGContextFillRect(context, rect);
}

@end
