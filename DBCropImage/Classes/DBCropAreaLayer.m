//
//  DBCropAreaLayer.m
//  DBCropImageView
//
//  Created by dy on 2017/11/29.
//  Copyright © 2017年 dy. All rights reserved.
//

#import "DBCropAreaLayer.h"
#import <UIKit/UIKit.h>

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height


@interface DBCropAreaLayer()
//阴影色
@property(nonatomic,strong)UIColor* shawdwColor;

@end


@implementation DBCropAreaLayer

- (instancetype)init
{
    self = [super init];
    if (self) {
        _cropAreaLeft =  15;
        _cropAreaTop = 50;
        _cropAreaRight = SCREEN_WIDTH - self.cropAreaLeft * 2 ;
        _cropAreaBottom = 400;
        
        _cropLineWidth = 3;
        _lineColor = [UIColor whiteColor];
        _isShowShaw = false;
        
        
    }
    return self;
}



- (void)drawInContext:(CGContextRef)ctx
{
    UIGraphicsPushContext(ctx);

    CGContextSetStrokeColorWithColor(ctx, self.lineColor.CGColor);
    CGContextSetLineWidth(ctx, _cropLineWidth);
    CGContextMoveToPoint(ctx, self.cropAreaLeft, self.cropAreaTop);
    CGContextAddLineToPoint(ctx, self.cropAreaLeft, self.cropAreaBottom);
    if (_isShowShaw == true) {
       CGContextSetShadow(ctx, CGSizeMake(2, 0), 2.0);
       CGContextSetShadowWithColor(ctx, CGSizeMake(2, 0), 1, self.shawdwColor.CGColor);
    }
    CGContextStrokePath(ctx);
    
    CGContextSetStrokeColorWithColor(ctx, self.lineColor.CGColor);
    CGContextSetLineWidth(ctx, _cropLineWidth);
    CGContextMoveToPoint(ctx, self.cropAreaLeft, self.cropAreaTop);
    CGContextAddLineToPoint(ctx, self.cropAreaRight, self.cropAreaTop);
    if (_isShowShaw == true) {
        CGContextSetShadow(ctx, CGSizeMake(0, 2), 2.0);
        CGContextSetShadowWithColor(ctx, CGSizeMake(0, 2), 1, self.shawdwColor.CGColor);
    }
    CGContextStrokePath(ctx);
    
    CGContextSetStrokeColorWithColor(ctx, self.lineColor.CGColor);
    CGContextSetLineWidth(ctx, _cropLineWidth);
    CGContextMoveToPoint(ctx, self.cropAreaRight, self.cropAreaTop);
    CGContextAddLineToPoint(ctx, self.cropAreaRight, self.cropAreaBottom);
    if (_isShowShaw == true) {
       CGContextSetShadow(ctx, CGSizeMake(-2, 0), 2.0);
       CGContextSetShadowWithColor(ctx, CGSizeMake(-2, 0), 1, self.shawdwColor.CGColor);
    }
    CGContextStrokePath(ctx);
    
    CGContextSetStrokeColorWithColor(ctx, self.lineColor.CGColor);
    CGContextSetLineWidth(ctx, _cropLineWidth);
    CGContextMoveToPoint(ctx, self.cropAreaLeft, self.cropAreaBottom);
    CGContextAddLineToPoint(ctx, self.cropAreaRight, self.cropAreaBottom);
    if (_isShowShaw == true) {
       CGContextSetShadow(ctx, CGSizeMake(0, -2), 2.0);
       CGContextSetShadowWithColor(ctx, CGSizeMake(0, -2), 1, self.shawdwColor.CGColor);
    }
    CGContextStrokePath(ctx);
    
    UIGraphicsPopContext();
}

- (void)setCropAreaLeft:(NSInteger)cropAreaLeft CropAreaTop:(NSInteger)cropAreaTop CropAreaRight:(NSInteger)cropAreaRight CropAreaBottom:(NSInteger)cropAreaBottom
{
    _cropAreaLeft = cropAreaLeft;
    _cropAreaRight = cropAreaRight;
    _cropAreaTop = cropAreaTop;
    _cropAreaBottom = cropAreaBottom;
    
    self.shawdwColor = [self getNewColorWith:self.lineColor];
  
    [self setNeedsDisplay];
}

// 获取颜色的 RGB和Alpha
- (NSArray *)getRGBWithColor:(UIColor *)color {
    CGFloat red = 0.0;
    CGFloat green = 0.0;
    CGFloat blue = 0.0;
    CGFloat alpha = 0.0;
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    return @[@(red), @(green), @(blue), @(alpha)];
}
 
// 改变UIColor的Alpha
- (UIColor *)getNewColorWith:(UIColor *)color {
    CGFloat red = 0.0;
    CGFloat green = 0.0;
    CGFloat blue = 0.0;
    CGFloat alpha = 0.0;
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    UIColor *newColor = [UIColor colorWithRed:red green:green blue:blue alpha:0.3];
    return newColor;
}


@end
