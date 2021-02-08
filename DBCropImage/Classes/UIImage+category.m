//
//  UIImage+MUCommon.h
//  BigCalculat
//
//  Created by 罗文琦 on 16/10/27.
//  Copyright © 2016年 罗文琦. All rights reserved.
//
//

#import "UIImage+category.h"
#import <Accelerate/Accelerate.h>

CGFloat DegreesToRadians(CGFloat degrees) {return degrees * M_PI / 180;};
CGFloat RadiansToDegrees(CGFloat radians) {return radians * 180/M_PI;};

@implementation UIImage (category)

#pragma mark - 修正图片旋转
+(UIImage *_Nonnull)fixOrientation:(UIImage *_Nonnull)image{
    if (image.imageOrientation == UIImageOrientationUp)
        return image;
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (image.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, image.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, image.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    switch (image.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    CGContextRef ctx = CGBitmapContextCreate(NULL, image.size.width, image.size.height,
                                             CGImageGetBitsPerComponent(image.CGImage), 0,
                                             CGImageGetColorSpace(image.CGImage),
                                             CGImageGetBitmapInfo(image.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (image.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.height,image.size.width), image.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.width,image.size.height), image.CGImage);
            break;
    }
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

//1.图片的任意角度旋转
//首先将需要处理的图片渲染到她的context上，然后对得到的这个context进行我们需要的旋转处理，最后再将旋转过的context转化为UIImage的类型
-(UIImage* )imageRotateInDegree:(float)degree {
    //获取图片款高
    size_t width  = (size_t)self.size.width * self.scale;
    size_t height = (size_t)self.size.height * self.scale;
   
    //每行图片数据字节
    size_t bytesPerRow = width * 4;
    //设置图片的透明度
    CGImageAlphaInfo alphaInfo = kCGImageAlphaPremultipliedFirst;
    
    //配置上下文参数
    CGContextRef bmContext = CGBitmapContextCreate(NULL, width, height, 8, bytesPerRow, CGColorSpaceCreateDeviceRGB(), kCGBitmapByteOrderDefault | alphaInfo);
    if (!bmContext) {
        return  nil;
    }
    
    CGContextDrawImage(bmContext, CGRectMake(0, 0, width, height), self.CGImage);
    
    //旋转
    UInt8 *data = (UInt8* )CGBitmapContextGetData(bmContext);
    
    vImage_Buffer src  = {data,height,width,bytesPerRow};
    vImage_Buffer dest = {data,height,width,bytesPerRow};
    Pixel_8888 bgColor = {0,0,0,0};
    
    vImageRotate_ARGB8888(&src, &dest, NULL, degree, bgColor, kvImageBackgroundColorFill);
    
    //context --> UIImage
    CGImageRef rotateImage_ref = CGBitmapContextCreateImage(bmContext);
    UIImage* rotateImage = [UIImage imageWithCGImage:rotateImage_ref scale:self.scale orientation:self.imageOrientation];
    
    return rotateImage;

}
//2.图片的任意位置裁剪
//首先获取自己需要处理的图片，然后对他的图形上下文进行剪切绘制处理，最后将处理后的内容转化为图片形式。
-(UIImage* )imageCutSize:(CGRect)cutRect {
    CGImageRef subImageRef = CGImageCreateWithImageInRect(self.CGImage, cutRect);
    CGRect smallRect = CGRectMake(0, 0, CGImageGetWidth(subImageRef), CGImageGetHeight(subImageRef));
    
    UIGraphicsBeginImageContext(smallRect.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context, smallRect, subImageRef);
    
    UIImage* cutImage = [UIImage imageWithCGImage:subImageRef];
    UIGraphicsEndImageContext();
    return  cutImage;
 
}
//3.图片的任意拉伸
-(UIImage*)imageStretchWithSize:(CGSize)size {
    UIGraphicsBeginImageContext(size);
    
    //根据 drawInRect 方法和新的 size 重新绘制
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}


//旋转角度
- (UIImage *)imageRotatedByRadians:(CGFloat)radians
{
    return [self imageRotatedByDegrees:RadiansToDegrees(radians)];
}

- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees
{
    UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.size.width, self.size.height)];
    CGAffineTransform t = CGAffineTransformMakeRotation(DegreesToRadians(degrees));
    rotatedViewBox.transform = t;
    CGSize rotatedSize = rotatedViewBox.frame.size;
    
    UIGraphicsBeginImageContext(rotatedSize);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();
    
    CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);
    
    CGContextRotateCTM(bitmap, DegreesToRadians(degrees));
    
    CGContextScaleCTM(bitmap, 1.0, -1.0);
    CGContextDrawImage(bitmap, CGRectMake(-self.size.width / 2, -self.size.height / 2, self.size.width, self.size.height), [self CGImage]);
    
    UIImage *resImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resImage;
}

@end
