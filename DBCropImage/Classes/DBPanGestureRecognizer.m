//
//  DBPanGestureRecognizer.m
//  DBCropImageView
//
//  Created by dy on 2017/11/29.
//  Copyright © 2017年 dy. All rights reserved.
//

#import "DBPanGestureRecognizer.h"
#import <UIKit/UIGestureRecognizerSubclass.h>

@interface DBPanGestureRecognizer()

@property(strong, nonatomic) UIView *targetView;

@end

@implementation DBPanGestureRecognizer

-(instancetype)initWithTarget:(id)target action:(SEL)action inview:(UIView*)view{
    
    self = [super initWithTarget:target action:action];
    if(self) {
        self.targetView = view;
    }
    return self;
}

//传入了一个 view，用于将手势触发的位置转换为 view 中的坐标值。
//得到了手势开始时的触发点 beginPoint
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent*)event{
    
    [super touchesBegan:touches withEvent:event];
    UITouch *touch = [touches anyObject];
    self.beginPoint = [touch locationInView:self.targetView];
}
//手势进行时的触发点 movePoint。
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    UITouch *touch = [touches anyObject];
    self.movePoint = [touch locationInView:self.targetView];
}

@end
