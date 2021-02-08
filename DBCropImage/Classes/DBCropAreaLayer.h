//
//  DBCropAreaLayer.h
//  DBCropImageView
//
//  Created by dy on 2017/11/29.
//  Copyright © 2017年 dy. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

@interface DBCropAreaLayer : CAShapeLayer

@property (strong, nonatomic) UIColor *lineColor; //边线颜色
@property (assign, nonatomic) CGFloat cropLineWidth;
@property (assign, nonatomic) bool isShowShaw;

@property(assign, nonatomic) NSInteger cropAreaLeft;
@property(assign, nonatomic) NSInteger cropAreaTop;
@property(assign, nonatomic) NSInteger cropAreaRight;
@property(assign, nonatomic) NSInteger cropAreaBottom;

//设置了宽高比，会自动重新计算宽高
@property(assign,nonatomic)CGFloat widthHeightRate;


- (void)setCropAreaLeft:(NSInteger)cropAreaLeft CropAreaTop:(NSInteger)cropAreaTop CropAreaRight:(NSInteger)cropAreaRight CropAreaBottom:(NSInteger)cropAreaBottom;


@end
