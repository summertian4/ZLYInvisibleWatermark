//
//  ZLYInvisibleWatermark.h
//  Pods-ZLYInvisibleWatermark_Example
//
//  Created by 周凌宇 on 2019/2/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZLYInvisibleWatermark : NSObject
+ (UIImage *)visibleWatermark:(UIImage *)image;
+ (UIImage *)addWatermark:(UIImage *)image
                     text:(NSString *)text;
+ (void)addWatermark:(UIImage *)image
                text:(NSString *)text
          completion:(void (^ __nullable)(UIImage *))completion;

+ (int)mixedCalculation:(int)originValue;
@end

NS_ASSUME_NONNULL_END
