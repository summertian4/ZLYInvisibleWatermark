//
//  ZLYViewController.m
//  ZLYInvisibleWatermark
//
//  Created by cocoa.lingyu on 02/21/2019.
//  Copyright (c) 2019 cocoa.lingyu. All rights reserved.
//

#import "ZLYViewController.h"
#import <ZLYInvisibleWatermark/ZLYInvisibleWatermark.h>

@interface ZLYViewController ()
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
    self.imageView.image = [ZLYInvisibleWatermark addWatermark:self.imageView.image
                                                          text:@"233"];
}

@end
