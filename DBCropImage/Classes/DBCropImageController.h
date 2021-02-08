//
//  DBCropImageController.h
//  DDQP-Swift
//
//  Created by dy on 2021/1/27.
//  Copyright © 2021 9Tong. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DBCropImageController : UIViewController

@property (assign, nonatomic) bool isShowShaw;          //是否显示阴影
@property (nonatomic,strong) UIColor *lineColor;        //边线颜色
@property (nonatomic,assign) CGFloat lineWidth;         //边线宽度

// 裁剪区域属性
@property(assign, nonatomic) CGFloat cropAreaX;
@property(assign, nonatomic) CGFloat cropAreaY;
@property(assign, nonatomic) CGFloat cropAreaWidth;
@property(assign, nonatomic) CGFloat cropAreaHeight;

//设置了宽高比，会自动重新计算宽高
@property(assign,nonatomic)CGFloat widthHeightRate;

@property(nonatomic,assign)bool isFixCropArea;           //是否固定裁剪区域
@property(nonatomic,assign)CGFloat minCropAreaHeight;    //最小裁剪高度

//必传
@property (nonatomic,strong) UIImage *image;

/// 取消裁剪
@property (nonatomic, copy) void (^cancelClipBlock)(void);

//裁剪完成的回调
@property (nonatomic, copy) void (^clippedBlock)(UIImage *clippedImage);

@end

NS_ASSUME_NONNULL_END
