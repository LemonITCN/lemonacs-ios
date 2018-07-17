//
//  DrawingSingle.h
//  wkWebview
//
//  Created by 王炜光 on 2018/6/12.
//  Copyright © 2018年 Ezrea1. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface DrawingSingle : NSObject

+(DrawingSingle *)shareDrawingSingle;
- (UIImage *)getFoucusImageSize:(CGSize)size themeColor:(UIColor *)color;
- (UIImage *)getLineColor:(CGSize)size color:(UIColor *)color;
@end
