//
//  ScanQRCodeViewController.m
//  lemonacs
//
//  Created by 王炜光 on 2018/7/17.
//  Copyright © 2018年 Ezrea1. All rights reserved.
//
/* 屏幕宽 */
#define LWSCREEN_WIDTH   [UIScreen mainScreen].bounds.size.width
/* 屏幕高 */
#define LWSCREENH_HEIGHT [UIScreen mainScreen].bounds.size.height
#import <AVFoundation/AVFoundation.h>
#import "ViewController.h"
#import "QRCodeScanView.h"
#import "QRCodeBackgroundView.h"
#import <AudioToolbox/AudioToolbox.h>
#import "ScanQRCodeViewController.h"

@interface ScanQRCodeViewController ()<AVCaptureMetadataOutputObjectsDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>
@property(nonatomic,strong)AVCaptureDevice *device;//创建相机
@property(nonatomic,strong)AVCaptureDeviceInput *input;//创建输入设备
@property(nonatomic,strong)AVCaptureMetadataOutput *output;//创建输出设备
@property(nonatomic,strong)AVCaptureSession *session;//创建捕捉类
@property(strong,nonatomic)AVCaptureVideoPreviewLayer *preview;//视觉输出预览层
@property(strong,nonatomic)QRCodeScanView *scanView;//自定义的扫描视图

@end

@implementation ScanQRCodeViewController
static CGFloat ScanHeight;
static CGFloat ScanWidth;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    ScanHeight = _scanSize.height;
    ScanWidth = _scanSize.width;
    [self createUI];
    [self capture];
}

#pragma mark - 初始化扫描设备
- (void)capture {
    //如果是模拟器返回（模拟器获取不到摄像头）
    if (TARGET_IPHONE_SIMULATOR) {
        return;
    }
    
    // 下面的是比较重要的,也是最容易出现崩溃的原因,就是我们的输出流的类型
    // 1.这里可以设置多种输出类型,这里必须要保证session层包括输出流
    // 2.必须要当前项目访问相机权限必须通过,所以最好在程序进入当前页面的时候进行一次权限访问的判断
    
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if(authStatus ==AVAuthorizationStatusRestricted|| authStatus ==AVAuthorizationStatusDenied){
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"请在iPhone的“设置”-“隐私”-“相机”功能中，打开APP相机访问权限" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:sureAction];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    //初始化基础"引擎"Device
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    //初始化输入流 Input,并添加Device
    self.input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    //初始化输出流Output
    self.output = [[AVCaptureMetadataOutput alloc] init];
    
    //设置输出流的相关属性
    // 确定输出流的代理和所在的线程,这里代理遵循的就是上面我们在准备工作中提到的第一个代理,至于线程的选择,建议选在主线程,这样方便当前页面对数据的捕获.
    [self.output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    //设置扫描区域的大小 rectOfInterest  默认值是CGRectMake(0, 0, 1, 1) 按比例设置
    self.output.rectOfInterest = CGRectMake(_scanY/LWSCREENH_HEIGHT,((LWSCREEN_WIDTH-ScanWidth)/2)/LWSCREEN_WIDTH,ScanHeight/LWSCREENH_HEIGHT,ScanWidth/LWSCREEN_WIDTH);

    
    // 初始化session
    self.session = [[AVCaptureSession alloc]init];
    // 设置session类型,AVCaptureSessionPresetHigh 是 sessionPreset 的默认值。
    [_session setSessionPreset:AVCaptureSessionPresetHigh];
    
    //将输入流和输出流添加到session中
    // 添加输入流
    if ([_session canAddInput:self.input]) {
        [_session addInput:self.input];
    }
    // 添加输出流
    if ([_session canAddOutput:self.output]) {
        [_session addOutput:self.output];
        
        //扫描格式
        NSMutableArray *metadataObjectTypes = [NSMutableArray array];
        [metadataObjectTypes addObjectsFromArray:@[
                                                   AVMetadataObjectTypeQRCode,
                                                   AVMetadataObjectTypeEAN13Code,
                                                   AVMetadataObjectTypeEAN8Code,
                                                   AVMetadataObjectTypeCode128Code,
                                                   AVMetadataObjectTypeCode39Code,
                                                   AVMetadataObjectTypeCode93Code,
                                                   AVMetadataObjectTypeCode39Mod43Code,
                                                   AVMetadataObjectTypePDF417Code,
                                                   AVMetadataObjectTypeAztecCode,
                                                   AVMetadataObjectTypeUPCECode,
                                                   ]];
        
        // >= ios 8
        if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1) {
            [metadataObjectTypes addObjectsFromArray:@[AVMetadataObjectTypeInterleaved2of5Code,
                                                       AVMetadataObjectTypeITF14Code,
                                                       AVMetadataObjectTypeDataMatrixCode]];
        }
        //设置扫描格式
        self.output.metadataObjectTypes= metadataObjectTypes;
    }
    
    
    //设置输出展示平台AVCaptureVideoPreviewLayer
    // 初始化
    self.preview =[AVCaptureVideoPreviewLayer layerWithSession:_session];
    // 设置Video Gravity,顾名思义就是视频播放时的拉伸方式,默认是AVLayerVideoGravityResizeAspect
    // AVLayerVideoGravityResizeAspect 保持视频的宽高比并使播放内容自动适应播放窗口的大小。
    // AVLayerVideoGravityResizeAspectFill 和前者类似，但它是以播放内容填充而不是适应播放窗口的大小。最后一个值会拉伸播放内容以适应播放窗口.
    // 因为考虑到全屏显示以及设备自适应,这里我们采用fill填充
    self.preview.videoGravity =AVLayerVideoGravityResizeAspectFill;
    // 设置展示平台的frame
    self.preview.frame = CGRectMake(0, 0, LWSCREEN_WIDTH, LWSCREENH_HEIGHT);
    // 因为 AVCaptureVideoPreviewLayer是继承CALayer,所以添加到当前view的layer层
    [self.view.layer insertSublayer:self.preview atIndex:0];
    
    //开始
    [self.session startRunning];
}
#pragma mark - AVCaptureMetadataOutputObjectsDelegate
#pragma mark - 扫描结果处理
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    //扫描成功播放音效
    AudioServicesPlaySystemSound(1054);
    
    // 判断扫描结果的数据是否存在
    if ([metadataObjects count] >0){
        // 如果存在数据,停止扫描
        [self.session stopRunning];
        [self.scanView stopAnimaion];
        // AVMetadataMachineReadableCodeObject是AVMetadataObject的具体子类定义的特性检测一维或二维条形码。
        // AVMetadataMachineReadableCodeObject代表一个单一的照片中发现机器可读的代码。这是一个不可变对象描述条码的特性和载荷。
        // 在支持的平台上,AVCaptureMetadataOutput输出检测机器可读的代码对象的数组
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex:0];
        // 获取扫描到的信息
        NSString *stringValue = metadataObject.stringValue;
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"扫描结果" message:stringValue preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [self.session startRunning];
            [self.scanView startAnimaion];
        }];
        [alert addAction:sureAction];
        [self presentViewController:alert animated:YES completion:nil];
        
    }
}

- (void)createUI{
    //扫描区域
    CGRect scanFrame = CGRectMake((LWSCREEN_WIDTH-ScanWidth)/2, _scanY, ScanWidth, ScanHeight);
    
    // 创建view,用来辅助展示扫描的区域
    self.scanView = [[QRCodeScanView alloc] initWithFrame:scanFrame];
    [self.view addSubview:self.scanView];
    
    //扫描区域外的背景
    QRCodeBackgroundView *qrcodeBackgroundView = [[QRCodeBackgroundView alloc] initWithFrame:self.view.bounds];
    qrcodeBackgroundView.scanFrame = scanFrame;
    [self.view addSubview:qrcodeBackgroundView];
    
    //提示文字
    UILabel *label = [UILabel new];
    label.text = @"将二维码/条形码放入框内，即可自动扫描";
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:15];
    label.textColor = [UIColor colorWithRed:224/255.0 green:224/255.0 blue:224/255.0 alpha:1.0];
    label.frame = CGRectMake(0, CGRectGetMaxY(self.scanView.frame)+10, LWSCREEN_WIDTH, 20);
    [self.view addSubview:label];
    
    
    //灯光和相册
    NSArray *arr = @[@"灯光",@"相册"];
    for (int i = 0; i < 2; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:arr[i] forState:UIControlStateNormal];
        btn.tag = i;
        btn.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.5];
        btn.frame = CGRectMake(LWSCREEN_WIDTH/2*i, LWSCREENH_HEIGHT-50, LWSCREEN_WIDTH/2, 50);
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
    }
}

#pragma mark - 菜单按钮点击事件
- (void)btnClick:(UIButton *)sender
{
    if (sender.tag == 0) {
        Class capture = NSClassFromString(@"AVCaptureDevice");
        if (capture != nil) {
            if ([self.device hasTorch] && [self.device hasFlash]) {
                [self.device lockForConfiguration:nil];
                
                sender.selected = !sender.selected;
                
                if (sender.selected) {
                    [self.device setTorchMode:AVCaptureTorchModeOn];
                } else {
                    [self.device setTorchMode:AVCaptureTorchModeOff];
                }
                [self.device unlockForConfiguration];
            }
        }
    } else {
        
        
//        UIImage *image = [UIImage imageNamed:@"temp"];
//        ZBarReaderController* read = [ZBarReaderController new];
//        CGImageRef cgImageRef = image.CGImage;
//        ZBarSymbol* symbol = nil;
//        for(symbol in  [read scanImage:cgImageRef]){
//            break;
//        }
//        NSString *QRCodeString =  symbol.data;
//        NSLog(@"%@",QRCodeString);
        
        
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.session stopRunning];
    [self.scanView stopAnimaion];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.session startRunning];
    [self.scanView startAnimaion];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}
- (BOOL)shouldAutorotate{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
