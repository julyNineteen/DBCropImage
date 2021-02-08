//
//  DBPanGestureRecognizer.h
//  DBCropImageView
//
//  Created by dy on 2017/11/29.
//  Copyright © 2017年 dy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DBPanGestureRecognizer : UIPanGestureRecognizer

@property(assign, nonatomic) CGPoint beginPoint;
@property(assign, nonatomic) CGPoint movePoint;


-(instancetype)initWithTarget:(id)target action:(SEL)action inview:(UIView*)view;


@end
