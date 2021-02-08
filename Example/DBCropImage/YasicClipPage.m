//
//  YasicClipPage.m
//  DynamicClipImage
//
//  Created by yasic on 2017/11/29.
//  Copyright © 2017年 yasic. All rights reserved.
//

#import "YasicClipPage.h"
#import "DBCropAreaLayer.h"
#import "DBPanGestureRecognizer.h"
#import "UIImage+category.h"

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

//https://github.com/Yasic/DynamicClipImage
typedef NS_ENUM(NSInteger, ACTIVEGESTUREVIEW) {
    CROPVIEWLEFT,
    CROPVIEWRIGHT,
    CROPVIEWTOP,
    CROPVIEWBOTTOM,
    BIGIMAGEVIEW
};

@interface YasicClipPage ()


@property(strong, nonatomic) UIImageView *bigImageView;
@property(strong, nonatomic) UIView *cropView;

@property(assign, nonatomic) ACTIVEGESTUREVIEW activeGestureView;

// 图片 view 原始 frame
@property(assign, nonatomic) CGRect originalFrame;

// 裁剪区域属性
@property(assign, nonatomic) CGFloat cropAreaX;
@property(assign, nonatomic) CGFloat cropAreaY;
@property(assign, nonatomic) CGFloat cropAreaWidth;
@property(assign, nonatomic) CGFloat cropAreaHeight;

@property(nonatomic, assign) CGFloat clipHeight;
@property(nonatomic, assign) CGFloat clipWidth;


@property (nonatomic,strong) UIView *backGroundView;
@end

@implementation YasicClipPage

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    
    
    self.clipWidth = SCREEN_WIDTH-30;
    self.clipHeight =  (SCREEN_WIDTH-30)*0.2845;// self.clipWidth * 9/16;
    
    self.cropAreaX = (SCREEN_WIDTH - self.clipWidth)/2;
    self.cropAreaY = (SCREEN_HEIGHT - self.clipHeight)/2;
    self.cropAreaWidth = self.clipWidth;
    self.cropAreaHeight = self.clipHeight;
    
   

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.cropView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [self.view addSubview:self.cropView];
    
    self.bigImageView.image = self.targetImage;
   
    CGFloat tempWidth = 0.0;
    CGFloat tempHeight = 0.0;
    
    if (self.targetImage.size.width/self.cropAreaWidth <= self.targetImage.size.height/self.cropAreaHeight) {
        tempWidth = self.cropAreaWidth;
        tempHeight = (tempWidth/self.targetImage.size.width) * self.targetImage.size.height;
    } else if (self.targetImage.size.width/self.cropAreaWidth > self.targetImage.size.height/self.cropAreaHeight) {
        tempHeight = self.cropAreaHeight;
        tempWidth = (tempHeight/self.targetImage.size.height) * self.targetImage.size.width;
    }
    CGFloat x = self.cropAreaX - (tempWidth - self.cropAreaWidth)/2;
    CGFloat y = self.cropAreaY - (tempHeight - self.cropAreaHeight)/2;
    CGFloat width = tempWidth;
    CGFloat height = tempHeight;
    
    self.bigImageView.frame = CGRectMake(x, y, width, height);
    [self.view addSubview:self.bigImageView];
    
    
    self.originalFrame = CGRectMake(self.cropAreaX - (tempWidth - self.cropAreaWidth)/2, self.cropAreaY - (tempHeight - self.cropAreaHeight)/2, tempWidth, tempHeight);
   
   
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self setUpCropLayer];
    
    [self addAllGesture];
}

-(void)addAllGesture
{
    // 捏合手势
    UIPinchGestureRecognizer *pinGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handleCenterPinGesture:)];
    [self.cropView addGestureRecognizer:pinGesture];

    // 拖动手势
    DBPanGestureRecognizer *panGesture = [[DBPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleDynamicPanGesture:) inview:self.cropView];
    [panGesture setMinimumNumberOfTouches:1];
    [panGesture setMaximumNumberOfTouches:1];
    [self.cropView addGestureRecognizer:panGesture];

    //旋转手势
    UIRotationGestureRecognizer *rotationGes = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(backGroundViewRotationAction:)];
    rotationGes.delegate = self;
    [self.cropView addGestureRecognizer:rotationGes];
    
    
//    UIView *backGroundView = [[UIView alloc] initWithFrame:self.view.bounds];
//    //旋转手势
//    UIRotationGestureRecognizer *rotationGes = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(backGroundViewRotationAction:)];
//    rotationGes.delegate = self;
//    [backGroundView addGestureRecognizer:rotationGes];
    //缩放手势
//    UIPinchGestureRecognizer *pinchGes = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handleCenterPinGesture:)];
//    pinchGes.delegate = self;
//    [backGroundView addGestureRecognizer:pinchGes];
    //拖动手势
//    UIPanGestureRecognizer *panGes = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(backGroundViewPanAction:)];
//    [panGes setMinimumNumberOfTouches:1];
//    [panGes setMaximumNumberOfTouches:1];
//    panGes.delegate = self;
//    [backGroundView addGestureRecognizer:panGes];
    
//    self.backGroundView = backGroundView;
//
//    [self.view addSubview:backGroundView];
//    [self.view insertSubview:backGroundView atIndex:0];
//
}
// 拖动手势
-(void)handleDynamicPanGesture:(DBPanGestureRecognizer *)panGesture
{
    UIView * view = self.bigImageView;
    CGPoint translation = [panGesture translationInView:view.superview];
    
    CGPoint beginPoint = panGesture.beginPoint;
    CGPoint movePoint = panGesture.movePoint;
    CGFloat judgeWidth = 20;
    
    // 开始滑动时判断滑动对象是 ImageView 还是 Layer 上的 Line
    if (panGesture.state == UIGestureRecognizerStateBegan) {
        if (beginPoint.x >= self.cropAreaX - judgeWidth && beginPoint.x <= self.cropAreaX + judgeWidth && beginPoint.y >= self.cropAreaY && beginPoint.y <= self.cropAreaY + self.cropAreaHeight && self.cropAreaWidth >= 50) {
            self.activeGestureView = CROPVIEWLEFT;
        } else if (beginPoint.x >= self.cropAreaX + self.cropAreaWidth - judgeWidth && beginPoint.x <= self.cropAreaX + self.cropAreaWidth + judgeWidth && beginPoint.y >= self.cropAreaY && beginPoint.y <= self.cropAreaY + self.cropAreaHeight &&  self.cropAreaWidth >= 50) {
            self.activeGestureView = CROPVIEWRIGHT;
        } else if (beginPoint.y >= self.cropAreaY - judgeWidth && beginPoint.y <= self.cropAreaY + judgeWidth && beginPoint.x >= self.cropAreaX && beginPoint.x <= self.cropAreaX + self.cropAreaWidth && self.cropAreaHeight >= 50) {
            self.activeGestureView = CROPVIEWTOP;
        } else if (beginPoint.y >= self.cropAreaY + self.cropAreaHeight - judgeWidth && beginPoint.y <= self.cropAreaY + self.cropAreaHeight + judgeWidth && beginPoint.x >= self.cropAreaX && beginPoint.x <= self.cropAreaX + self.cropAreaWidth && self.cropAreaHeight >= 50) {
            self.activeGestureView = CROPVIEWBOTTOM;
        } else {
            self.activeGestureView = BIGIMAGEVIEW;
            [view setCenter:CGPointMake(view.center.x + translation.x, view.center.y + translation.y)];
            [panGesture setTranslation:CGPointZero inView:view.superview];
        }
    }
    
    // 滑动过程中进行位置改变
    if (panGesture.state == UIGestureRecognizerStateChanged) {
        CGFloat diff = 0;
        switch (self.activeGestureView) {
            case CROPVIEWLEFT: {
                diff = movePoint.x - self.cropAreaX;
                if (diff >= 0 && self.cropAreaWidth > 50) {
                    self.cropAreaWidth -= diff;
                    self.cropAreaX += diff;
                } else if (diff < 0 && self.cropAreaX > self.bigImageView.frame.origin.x && self.cropAreaX >= 15) {
                    self.cropAreaWidth -= diff;
                    self.cropAreaX += diff;
                }
                [self setUpCropLayer];
                break;
            }
            case CROPVIEWRIGHT: {
                diff = movePoint.x - self.cropAreaX - self.cropAreaWidth;
                if (diff >= 0 && (self.cropAreaX + self.cropAreaWidth) < MIN(self.bigImageView.frame.origin.x + self.bigImageView.frame.size.width, self.cropView.frame.origin.x + self.cropView.frame.size.width - 15)){
                    self.cropAreaWidth += diff;
                } else if (diff < 0 && self.cropAreaWidth >= 50) {
                    self.cropAreaWidth += diff;
                }
                [self setUpCropLayer];
                break;
            }
            case CROPVIEWTOP: {
                diff = movePoint.y - self.cropAreaY;
                if (diff >= 0 && self.cropAreaHeight > 50) {
                    self.cropAreaHeight -= diff;
                    self.cropAreaY += diff;
                } else if (diff < 0 && self.cropAreaY > self.bigImageView.frame.origin.y && self.cropAreaY >= 15) {
                    self.cropAreaHeight -= diff;
                    self.cropAreaY += diff;
                }
                [self setUpCropLayer];
                break;
            }
            case CROPVIEWBOTTOM: {
                diff = movePoint.y - self.cropAreaY - self.cropAreaHeight;
                if (diff >= 0 && (self.cropAreaY + self.cropAreaHeight) < MIN(self.bigImageView.frame.origin.y + self.bigImageView.frame.size.height, self.cropView.frame.origin.y + self.cropView.frame.size.height - 15)){
                    self.cropAreaHeight += diff;
                } else if (diff < 0 && self.cropAreaHeight >= 50) {
                    self.cropAreaHeight += diff;
                }
                [self setUpCropLayer];
                break;
            }
            case BIGIMAGEVIEW: {
                [view setCenter:CGPointMake(view.center.x + translation.x, view.center.y + translation.y)];
                [panGesture setTranslation:CGPointZero inView:view.superview];
                break;
            }
            default:
                break;
        }
    }
    
    // 滑动结束后进行位置修正
    if (panGesture.state == UIGestureRecognizerStateEnded) {
        switch (self.activeGestureView) {
            case CROPVIEWLEFT: {
                if (self.cropAreaWidth < 50) {
                    self.cropAreaX -= 50 - self.cropAreaWidth;
                    self.cropAreaWidth = 50;
                }
                if (self.cropAreaX < MAX(self.bigImageView.frame.origin.x, 15)) {
                    CGFloat temp = self.cropAreaX + self.cropAreaWidth;
                    self.cropAreaX = MAX(self.bigImageView.frame.origin.x, 15);
                    self.cropAreaWidth = temp - self.cropAreaX;
                }
                [self setUpCropLayer];
                break;
            }
            case CROPVIEWRIGHT: {
                if (self.cropAreaWidth < 50) {
                    self.cropAreaWidth = 50;
                }
                if (self.cropAreaX + self.cropAreaWidth > MIN(self.bigImageView.frame.origin.x + self.bigImageView.frame.size.width, self.cropView.frame.origin.x + self.cropView.frame.size.width - 15)) {
                    self.cropAreaWidth = MIN(self.bigImageView.frame.origin.x + self.bigImageView.frame.size.width, self.cropView.frame.origin.x + self.cropView.frame.size.width - 15) - self.cropAreaX;
                }
                [self setUpCropLayer];
                break;
            }
            case CROPVIEWTOP: {
                if (self.cropAreaHeight < 50) {
                    self.cropAreaY -= 50 - self.cropAreaHeight;
                    self.cropAreaHeight = 50;
                }
                if (self.cropAreaY < MAX(self.bigImageView.frame.origin.y, 15)) {
                    CGFloat temp = self.cropAreaY + self.cropAreaHeight;
                    self.cropAreaY = MAX(self.bigImageView.frame.origin.y, 15);
                    self.cropAreaHeight = temp - self.cropAreaY;
                }
                [self setUpCropLayer];
                break;
            }
            case CROPVIEWBOTTOM: {
                if (self.cropAreaHeight < 50) {
                    self.cropAreaHeight = 50;
                }
                if (self.cropAreaY + self.cropAreaHeight > MIN(self.bigImageView.frame.origin.y + self.bigImageView.frame.size.height, self.cropView.frame.origin.y + self.cropView.frame.size.height - 15)) {
                    self.cropAreaHeight = MIN(self.bigImageView.frame.origin.y + self.bigImageView.frame.size.height, self.cropView.frame.origin.y + self.cropView.frame.size.height - 15) - self.cropAreaY;
                }
                [self setUpCropLayer];
                break;
            }
            case BIGIMAGEVIEW: {
                //旋转的角度 获取绕z轴 旋转的角度 -- 也就是当前平面旋转的角度
                float rotate = [[view.layer valueForKeyPath:@"transform.rotation.z"] floatValue];
                NSLog(@"旋转角度 == %f",rotate * 180/M_PI );
                //处理：当图片超出裁剪框的范围
                //任意角度的需要计算角度系数，后面有空再补充上去
                if (rotate == 0) {
                    CGRect currentFrame = view.frame;
                    if (currentFrame.origin.x >= self.cropAreaX) {
                        currentFrame.origin.x = self.cropAreaX;
                        
                    }
                    if (currentFrame.origin.y >= self.cropAreaY) {
                        currentFrame.origin.y = self.cropAreaY;
                    }
                    if (currentFrame.size.width + currentFrame.origin.x < self.cropAreaX + self.cropAreaWidth) {
                        CGFloat movedLeftX = fabs(currentFrame.size.width + currentFrame.origin.x - (self.cropAreaX + self.cropAreaWidth));
                        currentFrame.origin.x += movedLeftX;
                    }
                    if (currentFrame.size.height + currentFrame.origin.y < self.cropAreaY + self.cropAreaHeight) {
                        CGFloat moveUpY = fabs(currentFrame.size.height + currentFrame.origin.y - (self.cropAreaY + self.cropAreaHeight));
                        currentFrame.origin.y += moveUpY;
                    }
                    [UIView animateWithDuration:0.3 animations:^{
                        [view setFrame:currentFrame];
                    }];
                }
               
                break;
            }
            default:
                break;
        }
    }
}
// 捏合手势
-(void)handleCenterPinGesture:(UIPinchGestureRecognizer *)pinGesture
{
    CGFloat scaleRation = 3;
    UIView * view = self.bigImageView;
    
    // 缩放开始与缩放中
    if (pinGesture.state == UIGestureRecognizerStateBegan || pinGesture.state == UIGestureRecognizerStateChanged) {
        // 移动缩放中心到手指中心
        CGPoint pinchCenter = [pinGesture locationInView:view.superview];
        CGFloat distanceX = view.frame.origin.x - pinchCenter.x;
        CGFloat distanceY = view.frame.origin.y - pinchCenter.y;
        CGFloat scaledDistanceX = distanceX * pinGesture.scale;
        CGFloat scaledDistanceY = distanceY * pinGesture.scale;
        CGRect newFrame = CGRectMake(view.frame.origin.x + scaledDistanceX - distanceX, view.frame.origin.y + scaledDistanceY - distanceY, view.frame.size.width * pinGesture.scale, view.frame.size.height * pinGesture.scale);
        view.frame = newFrame;
        pinGesture.scale = 1;
    }
    
    // 缩放结束
    if (pinGesture.state == UIGestureRecognizerStateEnded) {
        CGFloat ration =  view.frame.size.width / self.originalFrame.size.width;
        
        // 缩放过大
        if (ration > 5) {
            CGRect newFrame = CGRectMake(0, 0, self.originalFrame.size.width * scaleRation, self.originalFrame.size.height * scaleRation);
            view.frame = newFrame;
        }
        
        // 缩放过小
        if (ration < 0.25) {
            view.frame = self.originalFrame;
        }
        // 对图片进行位置修正
        CGRect resetPosition = CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, view.frame.size.height);
        
        if (resetPosition.origin.x >= self.cropAreaX) {
            resetPosition.origin.x = self.cropAreaX;
        }
        if (resetPosition.origin.y >= self.cropAreaY) {
            resetPosition.origin.y = self.cropAreaY;
        }
        if (resetPosition.size.width + resetPosition.origin.x < self.cropAreaX + self.cropAreaWidth) {
            CGFloat movedLeftX = fabs(resetPosition.size.width + resetPosition.origin.x - (self.cropAreaX + self.cropAreaWidth));
            resetPosition.origin.x += movedLeftX;
        }
        if (resetPosition.size.height + resetPosition.origin.y < self.cropAreaY + self.cropAreaHeight) {
            CGFloat moveUpY = fabs(resetPosition.size.height + resetPosition.origin.y - (self.cropAreaY + self.cropAreaHeight));
            resetPosition.origin.y += moveUpY;
        }
        view.frame = resetPosition;
        
        // 对图片缩放进行比例修正，防止过小
        if (self.cropAreaX < self.bigImageView.frame.origin.x
            || ((self.cropAreaX + self.cropAreaWidth) > self.bigImageView.frame.origin.x + self.bigImageView.frame.size.width)
            || self.cropAreaY < self.bigImageView.frame.origin.y
            || ((self.cropAreaY + self.cropAreaHeight) > self.bigImageView.frame.origin.y + self.bigImageView.frame.size.height)) {
            view.frame = self.originalFrame;
        }
    }
}
//旋转手势
-(void)backGroundViewRotationAction:(UIRotationGestureRecognizer *)gesture{
    
    self.bigImageView.transform = CGAffineTransformRotate(self.bigImageView.transform, gesture.rotation);
    
    gesture.rotation = 0;
    
}

#pragma mark - gesture delegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if ([gestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]] && [otherGestureRecognizer isKindOfClass:[UIRotationGestureRecognizer class]]) {
        return YES;
    }else if ([gestureRecognizer isKindOfClass:[UIRotationGestureRecognizer class]] && [otherGestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]]){
        return YES;
    }else{
        return NO;
    }
    
}


- (void)setUpCropLayer
{
    self.cropView.layer.sublayers = nil;
    DBCropAreaLayer * layer = [[DBCropAreaLayer alloc] init];
    
    CGRect cropframe = CGRectMake(self.cropAreaX, self.cropAreaY, self.cropAreaWidth, self.cropAreaHeight);
    UIBezierPath * path = [UIBezierPath bezierPathWithRoundedRect:self.cropView.frame cornerRadius:0];
    UIBezierPath * cropPath = [UIBezierPath bezierPathWithRect:cropframe];
    [path appendPath:cropPath];
    layer.path = path.CGPath;
    
    layer.fillRule = kCAFillRuleEvenOdd;
    layer.fillColor = [[UIColor blackColor] CGColor];
    layer.opacity = 0.5;
    
    layer.frame = self.cropView.bounds;
    [layer setCropAreaLeft:self.cropAreaX CropAreaTop:self.cropAreaY CropAreaRight:self.cropAreaX + self.cropAreaWidth CropAreaBottom:self.cropAreaY + self.cropAreaHeight];
    [self.cropView.layer addSublayer:layer];
    [self.view bringSubviewToFront:self.cropView];
    
    
    UIButton* cropBtn = [[UIButton alloc]initWithFrame:CGRectMake(UIScreen.mainScreen.bounds.size.width - 80, UIApplication.sharedApplication.statusBarFrame.size.height + 10, 60, 40)];
    [cropBtn addTarget:self action:@selector(cropImage) forControlEvents:UIControlEventTouchUpInside];
    [cropBtn setTitle:@"截图" forState:UIControlStateNormal];
    cropBtn.backgroundColor = UIColor.greenColor;
    [cropBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    cropBtn.titleLabel.font = [UIFont systemFontOfSize:24];
    [self.view addSubview:cropBtn];
    [self.view  bringSubviewToFront:cropBtn];
    
    
    UIButton* backBtn = [[UIButton alloc]initWithFrame:CGRectMake(30, UIApplication.sharedApplication.statusBarFrame.size.height + 10, 60, 40)];
    [backBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [backBtn setTitle:@"返回" forState:UIControlStateNormal];
    backBtn.backgroundColor = UIColor.greenColor;
    [backBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    backBtn.titleLabel.font = [UIFont systemFontOfSize:24];
    [self.view addSubview:backBtn];

    [self.view  bringSubviewToFront:cropBtn];
}
-(void)back{
    [self dismissViewControllerAnimated:true completion:nil];
}


- (UIImageView *)bigImageView
{
    if (!_bigImageView) {
        _bigImageView = [[UIImageView alloc] init];
        _bigImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _bigImageView;
}

- (UIView *)cropView
{
    if (!_cropView) {
        _cropView = [[UIView alloc] init];
    }
    return _cropView;
}

// 裁剪图片并调用返回Block
- (void)cropImage
{
    //
    CGFloat imageScale = MIN(self.bigImageView.frame.size.width/self.targetImage.size.width, self.bigImageView.frame.size.height/self.targetImage.size.height)/self.bigImageView.image.scale;
    CGFloat cropX = (self.cropAreaX - self.bigImageView.frame.origin.x)/imageScale;
    CGFloat cropY = (self.cropAreaY - self.bigImageView.frame.origin.y)/imageScale;
    CGFloat cropWidth = self.cropAreaWidth/imageScale;
    CGFloat cropHeight = self.cropAreaHeight/imageScale;
    CGRect cropRect = CGRectMake(cropX, cropY, cropWidth, cropHeight);

    CGImageRef sourceImageRef = [self.targetImage CGImage];
    CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, cropRect);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
//    NSLog(@"newImage == %@",newImage);
    
//    //旋转的角度 获取绕z轴 旋转的角度 -- 也就是当前平面旋转的角度
//    float rotate = [[self.bigImageView.layer valueForKeyPath:@"transform.rotation.z"] floatValue];
//    //根据旋转的角度得到新的图片
//    UIImage *rotInputImage = [newImage imageRotatedByRadians:rotate];
//    CGImageRef tmp = CGImageCreateWithImageInRect([rotInputImage CGImage], cropRect);
//
//    UIImage *resultImage = [UIImage imageWithCGImage:tmp scale:imageScale orientation:newImage.imageOrientation];//newImage.imageOrientation
    
    if (self.clippedBlock) {
        [self dismissViewControllerAnimated:NO completion:nil];
        self.clippedBlock(newImage);
    }
    
}


@end
