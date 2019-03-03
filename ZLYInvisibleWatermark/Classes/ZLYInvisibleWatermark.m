//
//  ZLYInvisibleWatermark.m
//  Pods-ZLYInvisibleWatermark_Example
//
//  Created by 周凌宇 on 2019/2/21.
//

#import "ZLYInvisibleWatermark.h"

#define Mask8(x) ( (x) & 0xFF )
#define R(x) ( Mask8(x) )
#define G(x) ( Mask8(x >> 8 ) )
#define B(x) ( Mask8(x >> 16) )
#define A(x) ( Mask8(x >> 24) )
#define RGBAMake(r, g, b, a) ( Mask8(r) | Mask8(g) << 8 | Mask8(b) << 16 | Mask8(a) << 24 )

@implementation ZLYInvisibleWatermark

+ (UIImage *)visibleWatermark:(UIImage *)image {
    // 1. Get the raw pixels of the image
    // 定义 32位整形指针 *inputPixels
    UInt32 * inputPixels;

    //转换图片为CGImageRef,获取参数：长宽高，每个像素的字节数（4），每个R的比特数
    CGImageRef inputCGImage = [image CGImage];
    NSUInteger inputWidth = CGImageGetWidth(inputCGImage);
    NSUInteger inputHeight = CGImageGetHeight(inputCGImage);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();

    NSUInteger bytesPerPixel = 4;
    NSUInteger bitsPerComponent = 8;

    // 每行字节数
    NSUInteger inputBytesPerRow = bytesPerPixel * inputWidth;

    // 开辟内存区域,指向首像素地址
    inputPixels = (UInt32 *)calloc(inputHeight * inputWidth, sizeof(UInt32));

    // 根据指针，前面的参数，创建像素层
    CGContextRef context = CGBitmapContextCreate(inputPixels, inputWidth, inputHeight,
                                                 bitsPerComponent, inputBytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    //根据目前像素在界面绘制图像
    CGContextDrawImage(context, CGRectMake(0, 0, inputWidth, inputHeight), inputCGImage);

    // 像素处理
    for (int j = 0; j < inputHeight; j++) {
        for (int i = 0; i < inputWidth; i++) {
            @autoreleasepool {
                UInt32 *currentPixel = inputPixels + (j * inputWidth) + i;
                UInt32 color = *currentPixel;
                UInt32 thisR,thisG,thisB,thisA;
                // 这里直接移位获得RBGA的值,以及输出写的非常好！
                thisR = R(color);
                thisG = G(color);
                thisB = B(color);
                thisA = A(color);

                UInt32 newR,newG,newB;
                newR = [self mixedCalculation:thisR];
                newG = [self mixedCalculation:thisG];
                newB = [self mixedCalculation:thisB];

                *currentPixel = RGBAMake(newR,
                                         newG,
                                         newB,
                                         thisA);
            }
        }
    }
    //创建新图
    // 4. Create a new UIImage
    CGImageRef newCGImage = CGBitmapContextCreateImage(context);
    UIImage * processedImage = [UIImage imageWithCGImage:newCGImage];
    //释放
    // 5. Cleanup!
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    free(inputPixels);

    return processedImage;
}

+ (int)mixedCalculation:(int)originValue {
    // 结果色 = 基色 —（基色反相×混合色反相）/ 混合色
    int mixValue = 1;
    int resultValue = 0;
    if (mixValue == 0) {
        resultValue = 0;
    } else {
        resultValue = originValue - (255 - originValue) * (255 - mixValue) / mixValue;
    }
    if (resultValue < 0) {
        resultValue = 0;
    }
    return resultValue;
}

+ (UIImage *)addWatermark:(UIImage *)image
                     text:(NSString *)text {
    UIFont *font = [UIFont systemFontOfSize:32];
    NSDictionary *attributes = @{NSFontAttributeName: font,
                                 NSForegroundColorAttributeName: [UIColor colorWithRed:0
                                                                                 green:0
                                                                                  blue:0
                                                                                 alpha:0.01]};
    UIImage *newImage = [image copy];
    CGFloat x = 0.0;
    CGFloat y = 0.0;
    CGFloat idx0 = 0;
    CGFloat idx1 = 0;
    CGSize textSize = [text sizeWithAttributes:attributes];
    while (y < image.size.height) {
        y = (textSize.height * 2) * idx1;
        while (x < image.size.width) {
            @autoreleasepool {
                x = (textSize.width * 2) * idx0;
                newImage = [self addWatermark:newImage
                                         text:text
                                    textPoint:CGPointMake(x, y)
                             attributedString:attributes];
            }
            idx0 ++;
        }
        x = 0;
        idx0 = 0;
        idx1 ++;
    }
    return newImage;
}

+ (void)addWatermark:(UIImage *)image
                     text:(NSString *)text
               completion:(void (^ __nullable)(UIImage *))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *result = [self addWatermark:image text:text];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(result);
            }
        });
    });
}

+ (UIImage *)addWatermark:(UIImage *)image
                     text:(NSString *)text
                textPoint:(CGPoint)point
         attributedString:(NSDictionary *)attributes {

    UIGraphicsBeginImageContext(image.size);
    [image drawInRect:CGRectMake(0,0, image.size.width, image.size.height)];

    CGSize textSize = [text sizeWithAttributes:attributes];
    [text drawInRect:CGRectMake(point.x, point.y, textSize.width, textSize.height) withAttributes:attributes];

    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return newImage;
}

@end
