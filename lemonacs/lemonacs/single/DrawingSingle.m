//
//  DrawingSingle.m
//  wkWebview
//
//  Created by 王炜光 on 2018/6/12.
//  Copyright © 2018年 Ezrea1. All rights reserved.
//

#import "DrawingSingle.h"

@implementation DrawingSingle
+(DrawingSingle *)shareDrawingSingle{
    static DrawingSingle *single = nil;
    static dispatch_once_t takeOnce;
    dispatch_once(&takeOnce,^{
        single = [[DrawingSingle alloc]init];
    });
    return single;
}


- (UIImage *)getFoucusImageSize:(CGSize)size themeColor:(UIColor *)color{
    size = CGSizeMake(size.width-4, size.height-4);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    //获取颜色RGB
    CGFloat red = 0.0;
    CGFloat green = 0.0;
    CGFloat blue = 0.0;
    CGFloat alpha = 0.0;
    
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    CGContextSetRGBStrokeColor(ctx,red,green,blue,1.0);//画笔线的颜色
    CGContextSetLineWidth(ctx, 5.0);//线的宽度
    CGPoint sPoints[3];//坐标点
    sPoints[0] = CGPointMake(0, size.height/5*2);
    sPoints[1] = CGPointMake(0, 0);
    sPoints[2] = CGPointMake(size.width/5*2, 0);
    CGContextAddLines(ctx, sPoints, 3);//添加线
    CGContextDrawPath(ctx, kCGPathStroke);
    
    sPoints[0] = CGPointMake(0, size.height/5*3);
    sPoints[1] = CGPointMake(0, size.height);
    sPoints[2] = CGPointMake(size.width/5*2,size.height);
    CGContextAddLines(ctx, sPoints, 3);//添加线
    CGContextDrawPath(ctx, kCGPathStroke);
    
    sPoints[0] = CGPointMake(size.width/5*3, size.height);
    sPoints[1] = CGPointMake(size.width, size.height);
    sPoints[2] = CGPointMake(size.width, size.height/5*3);
    CGContextAddLines(ctx, sPoints, 3);//添加线
    CGContextDrawPath(ctx, kCGPathStroke);
    
    
    sPoints[0] = CGPointMake(size.width/5*3, 0);
    sPoints[1] = CGPointMake(size.width, 0);
    sPoints[2] = CGPointMake(size.width, size.height/5*2);
    CGContextAddLines(ctx, sPoints, 3);//添加线
    CGContextDrawPath(ctx, kCGPathStroke);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    //关闭图形上下文
    UIGraphicsEndImageContext();
    return newImage;
}


- (UIImage *)getLineColor:(CGSize)size color:(UIColor *)color{
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
    //获取颜色RGB
    CGFloat red = 0.0;
    CGFloat green = 0.0;
    CGFloat blue = 0.0;
    CGFloat alpha = 0.0;
    
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    CGFloat colors[] =
    {
        red,green,blue, 0.00,
        red,green,blue, alpha,
        red,green,blue, 0.00,
    };
    CGGradientRef gradient = CGGradientCreateWithColorComponents
    (rgb, colors, NULL, sizeof(colors)/(sizeof(colors[0])*4));//形成梯形，渐变的效果
    CGColorSpaceRelease(rgb);
    //画线形成一个矩形
    //CGContextSaveGState与CGContextRestoreGState的作用
    /*
     CGContextSaveGState函数的作用是将当前图形状态推入堆栈。之后，您对图形状态所做的修改会影响随后的描画操作，但不影响存储在堆栈中的拷贝。在修改完成后，您可以通过CGContextRestoreGState函数把堆栈顶部的状态弹出，返回到之前的图形状态。这种推入和弹出的方式是回到之前图形状态的快速方法，避免逐个撤消所有的状态修改；这也是将某些状态（比如裁剪路径）恢复到原有设置的唯一方式。
     */
    CGContextSaveGState(context);
    CGContextMoveToPoint(context, 0, 0);
    CGContextAddLineToPoint(context, 0, size.height);
    CGContextAddLineToPoint(context, size.width, size.height);
    CGContextAddLineToPoint(context, size.width, 0);
    CGContextClip(context);//context裁剪路径,后续操作的路径
    //CGContextDrawLinearGradient(CGContextRef context,CGGradientRef gradient, CGPoint startPoint, CGPoint endPoint,CGGradientDrawingOptions options)
    //gradient渐变颜色,startPoint开始渐变的起始位置,endPoint结束坐标,options开始坐标之前or开始之后开始渐变
    CGContextDrawLinearGradient(context, gradient,CGPointMake
                                (0,0) ,CGPointMake(size.width,0),
                                kCGGradientDrawsAfterEndLocation);
    CGContextRestoreGState(context);// 恢复到之前的context

    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    //关闭图形上下文
    UIGraphicsEndImageContext();
    return newImage;
}



@end
