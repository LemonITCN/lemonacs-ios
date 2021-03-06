//
//  ViewController.m
//  lemonacs
//
//  Created by 王炜光 on 2018/7/17.
//  Copyright © 2018年 Ezrea1. All rights reserved.
//

#import "ViewController.h"
#import "ScanQRCodeViewController.h"
#import "DrawingSingle.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    UIButton *scanQRCodeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [scanQRCodeBtn setTitle:@"扫描二维码/条形码" forState:UIControlStateNormal];
    [scanQRCodeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    scanQRCodeBtn.frame = CGRectMake(100, 100, 100, 100);
    [scanQRCodeBtn addTarget:self action:@selector(scanQRCode:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:scanQRCodeBtn];
    
    
    
    UIImageView *tempImageView = [[UIImageView alloc] initWithFrame:CGRectMake(100, 200, 21, 42)];
    [self.view addSubview:tempImageView];
    tempImageView.image = [[DrawingSingle shareDrawingSingle] getFlashLampSize:tempImageView.frame.size color:[UIColor redColor]];
    
}

- (void)scanQRCode:(UIButton *)btn{
    ScanQRCodeViewController *scanQRCodeVC = [[ScanQRCodeViewController alloc] init];
    scanQRCodeVC.scanY = 150;
    scanQRCodeVC.scanSize = CGSizeMake(250, 250);
    scanQRCodeVC.title = @"lemonacs";
    [self presentViewController:scanQRCodeVC animated:YES completion:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
