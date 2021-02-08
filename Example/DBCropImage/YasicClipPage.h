//
//  YasicClipPage.h
//  DynamicClipImage
//
//  Created by yasic on 2017/11/29.
//  Copyright © 2017年 yasic. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YasicClipPage : UIViewController

@property (strong, nonatomic) UIImage *targetImage;
/// 取消裁剪
@property (nonatomic, copy) void (^cancelClipBlock)(void);

/// 裁剪完成的回调
@property (nonatomic, copy) void (^clippedBlock)(UIImage *clippedImage);

@end
