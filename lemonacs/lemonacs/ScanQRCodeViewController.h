//
//  ScanQRCodeViewController.h
//  lemonacs
//
//  Created by 王炜光 on 2018/7/17.
//  Copyright © 2018年 Ezrea1. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScanQRCodeViewController : UIViewController
/**
 @brief 扫描区域高度
 */
@property (nonatomic, assign)CGFloat scanY;
/**
 @brief 扫描范围
 */
@property (nonatomic, assign)CGSize scanSize;
@end
