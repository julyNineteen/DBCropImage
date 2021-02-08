//
//  DBCropImageController.m
//  DDQP-Swift
//
//  Created by dy on 2021/1/27.
//  Copyright © 2021 9Tong. All rights reserved.
//

#import "DBCropImageController.h"
#import "DBCropImageView.h"
#import "DBCropAreaLayer.h"
#import "DBPanGestureRecognizer.h"

#define KScreenWidth   UIScreen.mainScreen.bounds.size.width
#define KScreenHeight  UIScreen.mainScreen.bounds.size.height
#define kIsPhoneX      (UIApplication.sharedApplication.statusBarFrame.size.height>20 ? true:false)
#define kBottomSafeAreaHeight (kIsPhoneX ? 34:0)

#define ORIGINAL_MAX_WIDTH 640.0f

//参考链接： https://github.com/yasic/DynamicClipImage
//简书链接： https://www.jianshu.com/p/73043c1d869a

typedef NS_ENUM(NSInteger, ACTIVEGESTUREVIEW) {
    CROPVIEWLEFT,
    CROPVIEWRIGHT,
    CROPVIEWTOP,
    CROPVIEWBOTTOM,
    imageView
};


@interface DBCropImageController ()<UIGestureRecognizerDelegate>{
    CGRect _foreCupRect;
}

@property(assign, nonatomic) ACTIVEGESTUREVIEW activeGestureView;

@property (nonatomic,strong) UIImageView *imageView;

//响应手势的view
@property (nonatomic,strong) UIView *backGroundView;

@property (nonatomic,strong) DBCropImageView *cropView;
@property (nonatomic, strong) UIToolbar *bottomBar;



@end

@implementation DBCropImageController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initConfig];
   
    //图片
    [self.view addSubview:self.imageView];
    //裁剪框
    [self.view addSubview:self.cropView];
    
    //添加手势
    [self addAllGestrues];
    
    //工具栏 --- 这个一定要放在最外层，否则图片可能遮挡
    [self.view addSubview:self.bottomBar];
}
-(void)initConfig{
    self.view.backgroundColor = [UIColor blackColor];
    
    //初始化参数
    self.cropAreaX =  self.cropAreaX ?: 15;
    self.cropAreaWidth = self.cropAreaWidth ?: KScreenWidth-self.cropAreaX*2;
    self.cropAreaHeight = self.cropAreaHeight ?: self.cropAreaHeight ?: self.cropAreaWidth * 0.2845;
    //设置了宽高比
    if (self.widthHeightRate>0) {
        self.cropAreaHeight = self.cropAreaWidth * self.widthHeightRate;
       
    }
    self.cropAreaY = self.cropAreaY ?: (KScreenHeight - self.cropAreaHeight)/2;
    
    self.lineWidth = self.lineWidth ?: 3;
    self.lineColor = self.lineColor ?: UIColor.whiteColor;
    self.isShowShaw = self.isShowShaw ?: false;
    self.minCropAreaHeight = self.minCropAreaHeight ?: 50;
    self.isFixCropArea = self.isFixCropArea ?: false;
}


//添加手势
-(void)addAllGestrues{
    UIView *backGroundView = [[UIView alloc] initWithFrame:self.view.bounds];
    //旋转手势
    UIRotationGestureRecognizer *rotationGes = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(backGroundViewRotationAction:)];
    rotationGes.delegate = self;
    [backGroundView addGestureRecognizer:rotationGes];
    //缩放手势
    UIPinchGestureRecognizer *pinchGes = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(backGroundViewPinchAction:)];
    pinchGes.delegate = self;
    [backGroundView addGestureRecognizer:pinchGes];
    //拖动手势
    //固定裁剪框 使用手势方法一
    if(self.isFixCropArea == true){
        UIPanGestureRecognizer *panGes = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(backGroundViewPanAction:)];
        [panGes setMinimumNumberOfTouches:1];
        [panGes setMaximumNumberOfTouches:1];
        panGes.delegate = self;
        [backGroundView addGestureRecognizer:panGes];
    }else{
        //可移动裁剪框 使用手势方法二
        DBPanGestureRecognizer *panGesture = [[DBPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleDynamicPanGesture:) inview:self.cropView];
        [panGesture setMinimumNumberOfTouches:1];
        [panGesture setMaximumNumberOfTouches:1];
        panGesture.delegate = self;
        [backGroundView addGestureRecognizer:panGesture];
    }
    self.backGroundView = backGroundView;
    
    [self.view addSubview:backGroundView];
    [self.view insertSubview:backGroundView atIndex:0];
    
}

//重新设置裁剪框
-(void)resetCropViewLayer{
    self.cropView.cropAreaX = self.cropAreaX;
    self.cropView.cropAreaY = self.cropAreaY;
    self.cropView.cropAreaWidth = self.cropAreaWidth;
    self.cropView.cropAreaHeight = self.cropAreaHeight;

    [self.cropView setNeedsDisplay];
}

- (UIImage *)imageByScalingToMaxSize:(UIImage *)sourceImage {
    if (sourceImage.size.width < ORIGINAL_MAX_WIDTH) return sourceImage;
    CGFloat btWidth = 0.0f;
    CGFloat btHeight = 0.0f;
    if (sourceImage.size.width > sourceImage.size.height) {
        btHeight = ORIGINAL_MAX_WIDTH;
        btWidth = sourceImage.size.width * (ORIGINAL_MAX_WIDTH / sourceImage.size.height);
    } else {
        btWidth = ORIGINAL_MAX_WIDTH;
        btHeight = sourceImage.size.height * (ORIGINAL_MAX_WIDTH / sourceImage.size.width);
    }
    CGSize targetSize = CGSizeMake(btWidth, btHeight);
    
    return [self scaleToSize:sourceImage size:targetSize];
}

- (UIImage *)scaleToSize:(UIImage *)img size:(CGSize)size{
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(size);
    // 绘制改变大小的图片
    [img drawInRect:CGRectMake(0, 0, size.width, size.height)];
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    // 返回新的改变大小后的图片
    return scaledImage;
}


#pragma mark 手势触发事件
//缩放手势
-(void)backGroundViewPinchAction:(UIPinchGestureRecognizer *)gesture{
    
    UIView *view = self.imageView;
    
    if (gesture.state == UIGestureRecognizerStateBegan || gesture.state == UIGestureRecognizerStateChanged) {
        
        view.transform = CGAffineTransformScale(view.transform, gesture.scale, gesture.scale);
        gesture.scale = 1;
    }
}

//旋转手势
-(void)backGroundViewRotationAction:(UIRotationGestureRecognizer *)gesture{
    
    self.imageView.transform = CGAffineTransformRotate(self.imageView.transform, gesture.rotation);
    
    gesture.rotation = 0;
    
}
//拖动手势一 ----  固定边框
-(void)backGroundViewPanAction:(UIPanGestureRecognizer *)gesture{
    
    if (gesture.numberOfTouches == 1) {
        if (gesture.state == UIGestureRecognizerStateBegan || gesture.state == UIGestureRecognizerStateChanged) {
            CGPoint transLation = [gesture translationInView:self.backGroundView];
            self.imageView.center = CGPointMake(self.imageView.center.x + transLation.x, self.imageView.center.y + transLation.y);
            [gesture setTranslation:CGPointZero inView:self.backGroundView];
        }
    }
}

// 拖动手势二  -----  可移动边框
-(void)handleDynamicPanGesture:(DBPanGestureRecognizer *)panGesture
{
    UIView * view = self.imageView;
    //NSLog(@"view.superview == %@",view.superview);
    CGPoint translation = [panGesture translationInView:view.superview];
    
    CGPoint beginPoint = panGesture.beginPoint;
    CGPoint movePoint = panGesture.movePoint;
    CGFloat judgeWidth = 15;
    
    // 开始滑动时判断滑动对象是 ImageView 还是 Layer 上的 Line
    if (panGesture.state == UIGestureRecognizerStateBegan) {
        //左边线
        if (beginPoint.x >= self.cropAreaX - judgeWidth && beginPoint.x <= self.cropAreaX + judgeWidth && beginPoint.y >= self.cropAreaY && beginPoint.y <= self.cropAreaY + self.cropAreaHeight && self.cropAreaWidth >= self.minCropAreaHeight) {
            self.activeGestureView = CROPVIEWLEFT;
            NSLog(@"操作左边线");
        } else if (beginPoint.x >= self.cropAreaX + self.cropAreaWidth - judgeWidth && beginPoint.x <= self.cropAreaX + self.cropAreaWidth + judgeWidth && beginPoint.y >= self.cropAreaY && beginPoint.y <= self.cropAreaY + self.cropAreaHeight &&  self.cropAreaWidth >= self.minCropAreaHeight) {
            self.activeGestureView = CROPVIEWRIGHT;
            NSLog(@"操作右边线");
        } else if (beginPoint.y >= self.cropAreaY - judgeWidth && beginPoint.y <= self.cropAreaY + judgeWidth && beginPoint.x >= self.cropAreaX && beginPoint.x <= self.cropAreaX + self.cropAreaWidth && self.cropAreaHeight >= self.minCropAreaHeight) {
            self.activeGestureView = CROPVIEWTOP;
            NSLog(@"操作上边线");
        } else if (beginPoint.y >= self.cropAreaY + self.cropAreaHeight - judgeWidth && beginPoint.y <= self.cropAreaY + self.cropAreaHeight + judgeWidth && beginPoint.x >= self.cropAreaX && beginPoint.x <= self.cropAreaX + self.cropAreaWidth && self.cropAreaHeight >= self.minCropAreaHeight) {
            self.activeGestureView = CROPVIEWBOTTOM;
            NSLog(@"操作下边线");
        } else {
            NSLog(@"操作图片");
            self.activeGestureView = imageView;
            [view setCenter:CGPointMake(view.center.x + translation.x, view.center.y + translation.y)];
            [panGesture setTranslation:CGPointZero inView:view.superview];
//            CGPoint transLation = [panGesture translationInView:self.backGroundView];
//            self.imageView.center = CGPointMake(self.imageView.center.x + transLation.x, self.imageView.center.y + transLation.y);
//            [panGesture setTranslation:CGPointZero inView:self.backGroundView];
        }
    }
    
    // 滑动过程中进行位置改变
    if (panGesture.state == UIGestureRecognizerStateChanged) {
        CGFloat diff = 0;
        switch (self.activeGestureView) {
            case CROPVIEWLEFT: {
                diff = movePoint.x - self.cropAreaX;
                if (diff >= 0 && self.cropAreaWidth > self.minCropAreaHeight) {
                    self.cropAreaWidth -= diff;
                    self.cropAreaX += diff;
                } else if (diff < 0 && self.cropAreaX > self.imageView.frame.origin.x && self.cropAreaX >= 15) {
                    self.cropAreaWidth -= diff;
                    self.cropAreaX += diff;
                }
                [self resetCropViewLayer];
                break;
            }
            case CROPVIEWRIGHT: {
                diff = movePoint.x - self.cropAreaX - self.cropAreaWidth;
                if (diff >= 0 && (self.cropAreaX + self.cropAreaWidth) < MIN(self.imageView.frame.origin.x + self.imageView.frame.size.width, self.cropView.frame.origin.x + self.cropView.frame.size.width - 15)){
                    self.cropAreaWidth += diff;
                } else if (diff < 0 && self.cropAreaWidth >= self.minCropAreaHeight) {
                    self.cropAreaWidth += diff;
                }
                [self resetCropViewLayer];
                break;
            }
            case CROPVIEWTOP: {
                diff = movePoint.y - self.cropAreaY;
                if (diff >= 0 && self.cropAreaHeight > self.minCropAreaHeight) {
                    self.cropAreaHeight -= diff;
                    self.cropAreaY += diff;
                } else if (diff < 0 && self.cropAreaY > self.imageView.frame.origin.y && self.cropAreaY >= 15) {
                    self.cropAreaHeight -= diff;
                    self.cropAreaY += diff;
                }
                [self resetCropViewLayer];
                break;
            }
            case CROPVIEWBOTTOM: {
                diff = movePoint.y - self.cropAreaY - self.cropAreaHeight;
                if (diff >= 0 && (self.cropAreaY + self.cropAreaHeight) < MIN(self.imageView.frame.origin.y + self.imageView.frame.size.height, self.cropView.frame.origin.y + self.cropView.frame.size.height - 15)){
                    self.cropAreaHeight += diff;
                } else if (diff < 0 && self.cropAreaHeight >= self.minCropAreaHeight) {
                    self.cropAreaHeight += diff;
                }
                [self resetCropViewLayer];
                break;
            }
            case imageView: {
                [view setCenter:CGPointMake(view.center.x + translation.x, view.center.y + translation.y)];
                [panGesture setTranslation:CGPointZero inView:view.superview];
//                CGPoint transLation = [panGesture translationInView:self.backGroundView];
//                self.imageView.center = CGPointMake(self.imageView.center.x + transLation.x, self.imageView.center.y + transLation.y);
//                [panGesture setTranslation:CGPointZero inView:self.backGroundView];
                break;
            }
            default:
                break;
        }
    }
    
    // 滑动结束后进行位置修正
    //  如果是裁剪区域边线，则要判断左右、上下边线之间的距离是否过短，边线是否超出 UIImageView 的范围等。如果左右边线距离过短则设置最小裁剪宽度，如果上线边线距离过短则设置最小裁剪高度，如果左边线超出了 UIImageView 左/右/上/下边线，则需要紧贴 UIImageView 的左/右/上/下边线，并更新裁剪区域宽度，以此类推。然后更新 CAShapeLayer 上的空心蒙层
    if (panGesture.state == UIGestureRecognizerStateEnded) {
        switch (self.activeGestureView) {
            case CROPVIEWLEFT: {
                if (self.cropAreaWidth < self.minCropAreaHeight) {
                    self.cropAreaX -= self.minCropAreaHeight - self.cropAreaWidth;
                    self.cropAreaWidth = self.minCropAreaHeight;
                }
                if (self.cropAreaX < MAX(self.imageView.frame.origin.x, 15)) {
                    CGFloat temp = self.cropAreaX + self.cropAreaWidth;
                    self.cropAreaX = MAX(self.imageView.frame.origin.x, 15);
                    self.cropAreaWidth = temp - self.cropAreaX;
                }
                [self resetCropViewLayer];
                break;
            }
            case CROPVIEWRIGHT: {
                if (self.cropAreaWidth < self.minCropAreaHeight) {
                    self.cropAreaWidth = self.minCropAreaHeight;
                }
                if (self.cropAreaX + self.cropAreaWidth > MIN(self.imageView.frame.origin.x + self.imageView.frame.size.width, self.cropView.frame.origin.x + self.cropView.frame.size.width - 15)) {
                    self.cropAreaWidth = MIN(self.imageView.frame.origin.x + self.imageView.frame.size.width, self.cropView.frame.origin.x + self.cropView.frame.size.width - 15) - self.cropAreaX;
                }
                [self resetCropViewLayer];
                break;
            }
            case CROPVIEWTOP: {
                if (self.cropAreaHeight < self.minCropAreaHeight) {
                    self.cropAreaY -= self.minCropAreaHeight - self.cropAreaHeight;
                    self.cropAreaHeight = self.minCropAreaHeight;
                }
                if (self.cropAreaY < MAX(self.imageView.frame.origin.y, 15)) {
                    CGFloat temp = self.cropAreaY + self.cropAreaHeight;
                    self.cropAreaY = MAX(self.imageView.frame.origin.y, 15);
                    self.cropAreaHeight = temp - self.cropAreaY;
                }
                [self resetCropViewLayer];
                break;
            }
            case CROPVIEWBOTTOM: {
                if (self.cropAreaHeight < self.minCropAreaHeight) {
                    self.cropAreaHeight = self.minCropAreaHeight;
                }
                if (self.cropAreaY + self.cropAreaHeight > MIN(self.imageView.frame.origin.y + self.imageView.frame.size.height, self.cropView.frame.origin.y + self.cropView.frame.size.height - 15)) {
                    self.cropAreaHeight = MIN(self.imageView.frame.origin.y + self.imageView.frame.size.height, self.cropView.frame.origin.y + self.cropView.frame.size.height - 15) - self.cropAreaY;
                }
                [self resetCropViewLayer];
                break;
            }
            //处理图片超出裁剪框边线的情况，则需要紧贴 UIImageView 的左/右/上/下边线；
            //目前只处理未旋转的情况，旋转任意角度计算边线位置暂不处理
            case imageView: {
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

#pragma mark property getter
- (UIImageView *)imageView{
    if (!_imageView) {
        UIImage *soucreImage = [self imageByScalingToMaxSize:_image];
        if (soucreImage) {
            float _imageScale = KScreenWidth / soucreImage.size.width;
            _imageView = [[UIImageView alloc] initWithImage:soucreImage];
            _imageView.frame = CGRectMake(0, (KScreenHeight - soucreImage.size.height*_imageScale)/2, soucreImage.size.width*_imageScale, soucreImage.size.height*_imageScale);
        }else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"图片读取失败！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alert show];
        }
        _imageView.userInteractionEnabled = NO;
    }
    return _imageView;
}

-(DBCropImageView *)cropView{
    if (!_cropView) {
        _cropView = [[DBCropImageView alloc] initWithFrame:self.view.bounds];
        _cropView.cropAreaHeight = self.cropAreaHeight;
        _cropView.cropAreaY = self.cropAreaY;
        _cropView.cropAreaX = self.cropAreaX;
        _cropView.cropAreaWidth = self.cropAreaWidth;
        
        _cropView.lineColor = self.lineColor;
        _cropView.lineWidth = self.lineWidth;
        _cropView.isShowShaw = self.isShowShaw;
        
    }
    return _cropView;
}

//工具栏
- (UIToolbar *)bottomBar {
    if (_bottomBar == nil) {
        _bottomBar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, [UIScreen  mainScreen].bounds.size.height - 64 - kBottomSafeAreaHeight, [UIScreen mainScreen].bounds.size.width, 64)];
        _bottomBar.barStyle = UIBarStyleBlackTranslucent;
        
        UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        UIButton *cancleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [cancleButton setTitle:@"取消" forState:UIControlStateNormal];
        cancleButton.titleLabel.font = [UIFont systemFontOfSize:18];
        cancleButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [cancleButton sizeToFit];
        [cancleButton addTarget:self action:@selector(cancelClip) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc]initWithCustomView:cancleButton];

        
        UIButton *enterButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [enterButton setTitle:@"确认" forState:UIControlStateNormal];
        enterButton.titleLabel.font = [UIFont systemFontOfSize:18];
        enterButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [enterButton sizeToFit];
        [enterButton addTarget:self action:@selector(finishedBtnAction) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *enterItem = [[UIBarButtonItem alloc]initWithCustomView:enterButton];

        _bottomBar.items = @[cancelItem,flexibleSpace,enterItem];
    }
    return _bottomBar;
}

#pragma mark 按钮点击事件
//取消
- (void)cancelClip {
    
    [self dismissViewControllerAnimated:NO completion:nil];
    if (self.cancelClipBlock) {
        self.cancelClipBlock();
    }
}
//完成
-(void)finishedBtnAction {
    
    UIImage *cropedImage = [self.cropView clipImageWithSoucreImageView:self.imageView];
    if (!cropedImage) {
      
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"图片裁剪失败！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        return;
    }
    //NSLog(@"cropedImage == %@",cropedImage);
    // 测试保存图片到相册
    //[self saveImageToPhotoAlbum:cropedImage];
    
    if (self.clippedBlock) {
        [self dismissViewControllerAnimated:NO completion:nil];
        self.clippedBlock(cropedImage);
    }
}

///MARK: 保存至相册
- (void)saveImageToPhotoAlbum:(UIImage*)savedImage {
    UIImageWriteToSavedPhotosAlbum(savedImage, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
}

// 指定回调方法
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo: (void *)contextInfo {
    if(error){
        NSLog(@"保存图片失败");
    }else{
        NSLog(@"保存图片成功");
    }
}

@end
