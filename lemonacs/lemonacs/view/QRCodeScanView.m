//
//  LWQRCodeScanView.m
//  QRCodeCamera
//
//  Created by 王炜光 on 2018/7/10.
//  Copyright © 2018年 Ezrea1. All rights reserved.
//
#import "QRCodeScanView.h"
#import "DrawingSingle.h"
@interface QRCodeScanView()

//记录当前线条绘制的位置
@property (nonatomic,assign) CGPoint position;
//  定时器
@property (nonatomic,strong)NSTimer  *timer;
//横线
@property (nonatomic,strong)UIImageView *lineImage;

@end

@implementation QRCodeScanView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self someInit];
    }
    return self;
}

- (void)someInit
{
    //边框图片
    UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    imageview.image = [[DrawingSingle shareDrawingSingle] getFoucusImageSize:imageview.frame.size themeColor:[UIColor greenColor]];
    [self addSubview:imageview];
    
    //横线
    self.lineImage = [[UIImageView alloc] init];
    self.lineImage.frame = CGRectMake(0, 0, self.frame.size.width, 4);
    self.lineImage.image = [[DrawingSingle shareDrawingSingle] getLineColor:self.lineImage.frame.size color:[UIColor greenColor]];
    [self addSubview:self.lineImage];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(lineAnimation) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)lineAnimation
{
    CGPoint newPosition = self.position;
    newPosition.y += 1;
    
    //判断y到达底部，从新开始下降
    if (newPosition.y > self.frame.size.height-self.lineImage.frame.size.height) {
        newPosition.y = 0;
    }
    //重新赋值position
    self.position = newPosition;
    
    CGRect frame = self.lineImage.frame;
    frame.origin.y = self.position.y;
    [UIView animateWithDuration:0.01 animations:^{
        self.lineImage.frame = frame;
    }];
}

-(void)startAnimaion{
    [self.timer setFireDate:[NSDate date]];
}

-(void)stopAnimaion{
    [self.timer setFireDate:[NSDate distantFuture]];
}

- (void)dealloc
{
    [self.timer setFireDate:[NSDate distantFuture]];
    self.timer = nil;
}
@end
