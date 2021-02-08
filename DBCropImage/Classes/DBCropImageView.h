//
//  DBCropImageView.h
//  DDQP-Swift
//
//  Created by dy on 2021/1/27.
//  Copyright © 2021 9Tong. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DBCropImageView : UIView

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


/**
 *  图片剪裁
 *
 *  @param imageView 图片视图源
 *
 *  @return 返回剪裁后的图片
 */
- (UIImage *)clipImageWithSoucreImageView:(UIImageView *)imageView;


@end

NS_ASSUME_NONNULL_END
