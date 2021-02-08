//
//  UIImage+MUCommon.h
//  BigCalculate
//
//  Created by 罗文琦 on 16/10/27.
//  Copyright © 2016年 罗文琦. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

@interface UIImage (category)

#pragma mark - 修正图片旋转
+(UIImage *_Nonnull)fixOrientation:(UIImage *_Nonnull)image;

//1.图片的任意角度旋转
//首先将需要处理的图片渲染到她的context上，然后对得到的这个context进行我们需要的旋转处理，最后再将旋转过的context转化为UIImage的类型
-(UIImage* _Nonnull)imageRotateInDegree:(float)degree ;

//图片的任意位置裁剪
-(UIImage* _Nonnull)imageCutSize:(CGRect)cutRect ;


//旋转角度
- (UIImage *_Nonnull)imageRotatedByRadians:(CGFloat)radians;

- (UIImage *_Nonnull)imageRotatedByDegrees:(CGFloat)degrees;
@end
