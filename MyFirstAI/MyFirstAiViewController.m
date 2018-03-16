//
//  MyFirstAiViewController.m
//  MyFirstAI
//
//  Created by xunli on 2018/3/16.
//  Copyright © 2018年 caoji. All rights reserved.
//

#import "MyFirstAiViewController.h"
#import <objc/runtime.h>
#import <AipOcrSdk/AipOcrSdk.h>
@interface MyFirstAiViewController ()<UIAlertViewDelegate>

@end
/**
 [self.actionList addObject:@[@"通用文字识别", @"generalBasicOCR"]];
 [self.actionList addObject:@[@"通用文字识别(高精度版)", @"generalAccurateBasicOCR"]];
 [self.actionList addObject:@[@"通用文字识别(含位置信息版)", @"generalOCR"]];
 [self.actionList addObject:@[@"通用文字识别(高精度含位置版)", @"generalAccurateOCR"]];
 [self.actionList addObject:@[@"通用文字识别(含生僻字版)", @"generalEnchancedOCR"]];
 [self.actionList addObject:@[@"网络图片文字识别", @"webImageOCR"]];
 [self.actionList addObject:@[@"身份证正面拍照识别", @"idcardOCROnlineFront"]];
 [self.actionList addObject:@[@"身份证反面拍照识别", @"idcardOCROnlineBack"]];
 [self.actionList addObject:@[@"身份证正面(嵌入式质量控制+云端识别)", @"localIdcardOCROnlineFront"]];
 [self.actionList addObject:@[@"身份证反面(嵌入式质量控制+云端识别)", @"localIdcardOCROnlineBack"]];
 [self.actionList addObject:@[@"银行卡正面拍照识别", @"bankCardOCROnline"]];
 [self.actionList addObject:@[@"驾驶证识别", @"drivingLicenseOCR"]];
 [self.actionList addObject:@[@"行驶证识别", @"vehicleLicenseOCR"]];
 [self.actionList addObject:@[@"车牌识别", @"plateLicenseOCR"]];
 [self.actionList addObject:@[@"营业执照识别", @"businessLicenseOCR"]];
 [self.actionList addObject:@[@"票据识别", @"receiptOCR"]];
 */
@implementation MyFirstAiViewController{
    // 默认的识别成功的回调
    void (^_successHandler)(id);
    // 默认的识别失败的回调
    void (^_failHandler)(NSError *);
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor =[UIColor whiteColor];
    self.title =@"文字识别";
    //     授权方法1：在此处填写App的Api Key/Secret Key
    [[AipOcrService shardService] authWithAK:@"jss2wQ58eRCYbGwZAzuacNKi" andSK:@"zoj2LdNcxPpf3ugERHM9cQRWtTpooyF7"];
    [self configCallback];
    //替换str
    SEL funSel = NSSelectorFromString(@"idcardOCROnlineFront");
    if (funSel) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self performSelector:funSel];
#pragma clang diagnostic pop
    }
}
- (void)configCallback {
    __weak typeof(self) weakSelf = self;
    
    // 这是默认的识别成功的回调
    _successHandler = ^(id result){
        NSLog(@"%@", result);
        NSString *title = @"识别结果";
        NSMutableString *message = [NSMutableString string];
        
        if(result[@"words_result"]){
            if([result[@"words_result"] isKindOfClass:[NSDictionary class]]){
                [result[@"words_result"] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                    if([obj isKindOfClass:[NSDictionary class]] && [obj objectForKey:@"words"]){
                        [message appendFormat:@"%@: %@\n", key, obj[@"words"]];
                    }else{
                        [message appendFormat:@"%@: %@\n", key, obj];
                    }
                    
                }];
            }else if([result[@"words_result"] isKindOfClass:[NSArray class]]){
                for(NSDictionary *obj in result[@"words_result"]){
                    if([obj isKindOfClass:[NSDictionary class]] && [obj objectForKey:@"words"]){
                        [message appendFormat:@"%@\n", obj[@"words"]];
                    }else{
                        [message appendFormat:@"%@\n", obj];
                    }
                    
                }
            }
            
        }else{
            [message appendFormat:@"%@", result];
        }
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:weakSelf cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alertView show];
        }];
    };
    
    _failHandler = ^(NSError *error){
        NSLog(@"%@", error);
        NSString *msg = [NSString stringWithFormat:@"%li:%@", (long)[error code], [error localizedDescription]];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [[[UIAlertView alloc] initWithTitle:@"识别失败" message:msg delegate:weakSelf cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
        }];
    };
}
#pragma mark - Action
- (void)generalOCR{
    
    UIViewController * vc = [AipGeneralVC ViewControllerWithHandler:^(UIImage *image) {
        // 在这个block里，image即为切好的图片，可自行选择如何处理
        NSDictionary *options = @{@"language_type": @"CHN_ENG", @"detect_direction": @"true"};
        [[AipOcrService shardService] detectTextFromImage:image
                                              withOptions:options
                                           successHandler:_successHandler
                                              failHandler:_failHandler];
        
    }];
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)generalEnchancedOCR{
    
    UIViewController * vc = [AipGeneralVC ViewControllerWithHandler:^(UIImage *image) {
        NSDictionary *options = @{@"language_type": @"CHN_ENG", @"detect_direction": @"true"};
        [[AipOcrService shardService] detectTextEnhancedFromImage:image
                                                      withOptions:options
                                                   successHandler:_successHandler
                                                      failHandler:_failHandler];
        
    }];
    [self presentViewController:vc animated:YES completion:nil];
}


- (void)generalBasicOCR{
    
    UIViewController * vc = [AipGeneralVC ViewControllerWithHandler:^(UIImage *image) {
        NSDictionary *options = @{@"language_type": @"CHN_ENG", @"detect_direction": @"true"};
        [[AipOcrService shardService] detectTextBasicFromImage:image
                                                   withOptions:options
                                                successHandler:_successHandler
                                                   failHandler:_failHandler];
        
    }];
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)generalAccurateOCR{
    
    UIViewController * vc = [AipGeneralVC ViewControllerWithHandler:^(UIImage *image) {
        NSDictionary *options = @{@"language_type": @"CHN_ENG", @"detect_direction": @"true"};
        [[AipOcrService shardService] detectTextAccurateFromImage:image
                                                      withOptions:options
                                                   successHandler:_successHandler
                                                      failHandler:_failHandler];
        
    }];
    [self presentViewController:vc animated:YES completion:nil];
}


- (void)generalAccurateBasicOCR{
    
    UIViewController * vc = [AipGeneralVC ViewControllerWithHandler:^(UIImage *image) {
        NSDictionary *options = @{@"language_type": @"CHN_ENG", @"detect_direction": @"true"};
        [[AipOcrService shardService] detectTextAccurateBasicFromImage:image
                                                           withOptions:options
                                                        successHandler:_successHandler
                                                           failHandler:_failHandler];
        
    }];
    [self presentViewController:vc animated:YES completion:nil];
}


- (void)webImageOCR{
    
    UIViewController * vc = [AipGeneralVC ViewControllerWithHandler:^(UIImage *image) {
        
        [[AipOcrService shardService] detectWebImageFromImage:image
                                                  withOptions:nil
                                               successHandler:_successHandler
                                                  failHandler:_failHandler];
    }];
    [self presentViewController:vc animated:YES completion:nil];
}


- (void)idcardOCROnlineFront {
    
    UIViewController * vc =
    [AipCaptureCardVC ViewControllerWithCardType:CardTypeIdCardFont
                                 andImageHandler:^(UIImage *image) {
                                     
                                     [[AipOcrService shardService] detectIdCardFrontFromImage:image
                                                                                  withOptions:nil
                                                                               successHandler:_successHandler
                                                                                  failHandler:_failHandler];
                                 }];
    
    [self presentViewController:vc animated:YES completion:nil];
    
}

- (void)localIdcardOCROnlineFront {
    
    UIViewController * vc =
    [AipCaptureCardVC ViewControllerWithCardType:CardTypeLocalIdCardFont
                                 andImageHandler:^(UIImage *image) {
                                     
                                     [[AipOcrService shardService] detectIdCardFrontFromImage:image
                                                                                  withOptions:nil
                                                                               successHandler:^(id result){
                                                                                   _successHandler(result);
                                                                                   // 这里可以存入相册
                                                                                   //UIImageWriteToSavedPhotosAlbum(image, nil, nil, (__bridge void *)self);
                                                                               }
                                                                                  failHandler:_failHandler];
                                 }];
    [self presentViewController:vc animated:YES completion:nil];
    
    
}



- (void)idcardOCROnlineBack{
    
    UIViewController * vc =
    [AipCaptureCardVC ViewControllerWithCardType:CardTypeIdCardBack
                                 andImageHandler:^(UIImage *image) {
                                     
                                     [[AipOcrService shardService] detectIdCardBackFromImage:image
                                                                                 withOptions:nil
                                                                              successHandler:_successHandler
                                                                                 failHandler:_failHandler];
                                 }];
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)localIdcardOCROnlineBack{
    
    UIViewController * vc =
    [AipCaptureCardVC ViewControllerWithCardType:CardTypeLocalIdCardBack
                                 andImageHandler:^(UIImage *image) {
                                     
                                     [[AipOcrService shardService] detectIdCardBackFromImage:image
                                                                                 withOptions:nil
                                                                              successHandler:^(id result){
                                                                                  _successHandler(result);
                                                                                  // 这里可以存入相册
                                                                                  // UIImageWriteToSavedPhotosAlbum(image, nil, nil, (__bridge void *)self);
                                                                              }
                                                                                 failHandler:_failHandler];
                                 }];
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)bankCardOCROnline{
    
    UIViewController * vc =
    [AipCaptureCardVC ViewControllerWithCardType:CardTypeBankCard
                                 andImageHandler:^(UIImage *image) {
                                     
                                     [[AipOcrService shardService] detectBankCardFromImage:image
                                                                            successHandler:_successHandler
                                                                               failHandler:_failHandler];
                                     
                                 }];
    [self presentViewController:vc animated:YES completion:nil];
    
}


- (void)drivingLicenseOCR{
    
    UIViewController * vc = [AipGeneralVC ViewControllerWithHandler:^(UIImage *image) {
        
        [[AipOcrService shardService] detectDrivingLicenseFromImage:image
                                                        withOptions:nil
                                                     successHandler:_successHandler
                                                        failHandler:_failHandler];
        
    }];
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)vehicleLicenseOCR{
    
    UIViewController * vc = [AipGeneralVC ViewControllerWithHandler:^(UIImage *image) {
        
        [[AipOcrService shardService] detectVehicleLicenseFromImage:image
                                                        withOptions:nil
                                                     successHandler:_successHandler
                                                        failHandler:_failHandler];
    }];
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)plateLicenseOCR{
    
    UIViewController * vc = [AipGeneralVC ViewControllerWithHandler:^(UIImage *image) {
        
        [[AipOcrService shardService] detectPlateNumberFromImage:image
                                                     withOptions:nil
                                                  successHandler:_successHandler
                                                     failHandler:_failHandler];
        
    }];
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)receiptOCR{
    
    UIViewController * vc = [AipGeneralVC ViewControllerWithHandler:^(UIImage *image) {
        
        [[AipOcrService shardService] detectReceiptFromImage:image
                                                 withOptions:nil
                                              successHandler:_successHandler
                                                 failHandler:_failHandler];
        
    }];
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)businessLicenseOCR{
    
    UIViewController * vc = [AipGeneralVC ViewControllerWithHandler:^(UIImage *image) {
        
        [[AipOcrService shardService] detectBusinessLicenseFromImage:image
                                                         withOptions:nil
                                                      successHandler:_successHandler
                                                         failHandler:_failHandler];
        
    }];
    [self presentViewController:vc animated:YES completion:nil];
}
- (void)mockBundlerIdForTest {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    [self mockClass:[NSBundle class] originalFunction:@selector(bundleIdentifier) swizzledFunction:@selector(sapicamera_bundleIdentifier)];
#pragma clang diagnostic pop
}

- (void)mockClass:(Class)class originalFunction:(SEL)originalSelector swizzledFunction:(SEL)swizzledSelector {
    
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    
    BOOL didAddMethod = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod) {
        class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
    
}
-(BOOL)shouldAutorotate{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}
#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
