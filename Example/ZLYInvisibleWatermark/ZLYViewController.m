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

@interface ZLYViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ZLYViewController

- (void)viewDidLoad {
    [super viewDidLoad];
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
@end
