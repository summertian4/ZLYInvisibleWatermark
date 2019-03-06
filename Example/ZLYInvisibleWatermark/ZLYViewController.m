//
//  ZLYViewController.m
//  ZLYInvisibleWatermark
//
//  Created by cocoa.lingyu on 02/21/2019.
//  Copyright (c) 2019 cocoa.lingyu. All rights reserved.
//

#import "ZLYViewController.h"
#import <ZLYInvisibleWatermark/ZLYInvisibleWatermark.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import <Photos/Photos.h>

@interface ZLYViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@end

@implementation ZLYViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    int result = [ZLYInvisibleWatermark mixedCalculation:255];
    NSLog(@"%@", result);
}

- (IBAction)showWaterMarkButtonClicked:(UIButton *)sender {
    self.imageView.image = [ZLYInvisibleWatermark visibleWatermark:self.imageView.image];
}

- (IBAction)addWatermarkButtonClicked:(UIButton *)sender {
    __weak __typeof(self)weakSelf = self;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [ZLYInvisibleWatermark addWatermark:self.imageView.image
                                   text:@"233" completion:^ (UIImage *image) {
                                       __strong __typeof(weakSelf)strongSelf = weakSelf;
                                       if (strongSelf) {
                                           self.imageView.image = image;
                                           [MBProgressHUD hideHUDForView:self.view animated:YES];
                                       }
                                   }];
}

- (IBAction)exportImageButtonClicked:(UIButton *)sender {
    PHAuthorizationStatus lastStatus = [PHPhotoLibrary authorizationStatus];
    __weak __typeof(self)weakSelf = self;
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if (strongSelf) {
            dispatch_async(dispatch_get_main_queue(), ^{
                //用户拒绝
                if(status == PHAuthorizationStatusDenied) {
                    if (lastStatus == PHAuthorizationStatusNotDetermined) {
                        // 保存失败
                        return;
                    }
                    // 请在系统设置中开启访问相册权限
                } else if(status == PHAuthorizationStatusAuthorized) {
                    [ZLYViewController syncSaveImageWithPhotos:self.imageView.image];
                    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                    hud.mode = MBProgressHUDModeText;
                    hud.label.text = @"导出成功";
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [hud hideAnimated:YES];
                    });
                } else if (status == PHAuthorizationStatusRestricted) {
                    // 系统原因，无法访问相册
                }
            });
        }
    }];
}

+ (PHFetchResult<PHAsset *> *)syncSaveImageWithPhotos:(UIImage *)image {
    __block NSString *createdAssetID = nil;

    NSError *error = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        createdAssetID = [PHAssetChangeRequest creationRequestForAssetFromImage:image].placeholderForCreatedAsset.localIdentifier;
    } error:&error];

    if (error) {
        return nil;
    }

    PHFetchResult<PHAsset *> *assets = [PHAsset fetchAssetsWithLocalIdentifiers:@[createdAssetID] options:nil];
    return assets;
}

- (IBAction)selectImageButtonClicked:(UIButton *)sender {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [[[UIApplication sharedApplication].delegate window].rootViewController presentViewController:imagePicker animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info  {
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    if (image) {
        self.imageView.image = image;
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Getter Setter
@end
