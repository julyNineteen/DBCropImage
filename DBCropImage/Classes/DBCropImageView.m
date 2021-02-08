//
//  DBCropImageView.m
//  DDQP-Swift
//
//  Created by dy on 2021/1/27.
//  Copyright © 2021 9Tong. All rights reserved.
//

#import "DBCropImageView.h"
#import "UIImage+category.h"
#import "DBCropAreaLayer.h"

#define KScreenWidth  [UIScreen mainScreen].bounds.size.width
#define KScreenHeight [UIScreen mainScreen].bounds.size.height


#define ORIGINAL_MAX_WIDTH 640.0f

@interface DBCropImageView()

@property (nonatomic,assign) CGRect willCropRect;  //剪切区域

@property (nonatomic,strong) UIBezierPath *cropBezrPath;

@end

@implementation DBCropImageView

-(instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        [self configer];
        
    }
    return self;
}


//初始化
- (void)configer{
    self.backgroundColor = [UIColor clearColor];
    self.userInteractionEnabled = NO;
 
    //初始化参数
    self.cropAreaX = 15;
    self.cropAreaWidth = self.cropAreaWidth ?: KScreenWidth-self.cropAreaX*2;
    // 高/宽 = 0.2845 跟之前vin框比例一致
    self.cropAreaHeight = self.cropAreaHeight ?: self.cropAreaWidth * 0.2845;
   
    self.lineWidth = self.lineWidth ?: 3;
    self.lineColor = self.lineColor ?: UIColor.whiteColor;
    self.isShowShaw = self.isShowShaw ?: false;
    
    if (self.widthHeightRate>0) {
        self.cropAreaHeight = self.cropAreaWidth * self.widthHeightRate;
    }
    self.cropAreaY = self.cropAreaY ?: (KScreenHeight - self.cropAreaHeight)/2;
    
    self.willCropRect = CGRectMake(self.cropAreaX, self.cropAreaY, self.cropAreaWidth, self.cropAreaHeight);
}


//当视图在屏幕上出现的时候 -drawRect:方法就会被自动调用。-drawRect:方法里面的代码利用Core Graphics去绘制一个寄宿图，然后内容就会被缓存起来直到它需要被更新
//调用setNeedsDisplay会自动调用drawRect

- (void)drawRect:(CGRect)rect {
    ////修改
//    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height) cornerRadius:0];
//
//    self.cropBezrPath = [UIBezierPath bezierPathWithRect:self.willCropRect];
//
//    [path appendPath:_cropBezrPath];
//
//   // [path setUsesEvenOddFillRule:YES];
//
//    CAShapeLayer *fillLayer = [CAShapeLayer layer];
//
//    fillLayer.path = path.CGPath;
//
//    //中间透明
//    fillLayer.fillRule = kCAFillRuleEvenOdd;
//    //半透明效果
//    fillLayer.fillColor = [UIColor colorWithWhite:0.200 alpha:0.800].CGColor;
//
//    [self.layer addSublayer:fillLayer];
//
//    //绘制虚线边框
//    CAShapeLayer *vertulLineLayer = [CAShapeLayer layer];
//    vertulLineLayer.path = self.cropBezrPath.CGPath;
//    vertulLineLayer.strokeColor = [UIColor yellowColor].CGColor;
//    vertulLineLayer.fillColor = [UIColor clearColor].CGColor;
//    vertulLineLayer.lineCap = kCALineCapRound;
//    vertulLineLayer.lineWidth = 3;
//    vertulLineLayer.lineDashPattern = @[@8,@8];
//    [self.layer addSublayer:vertulLineLayer];
    

    CGContextRef context = UIGraphicsGetCurrentContext();
    if (context == nil) {
        return;
    }
    
    if (self.widthHeightRate>0) {
        self.cropAreaHeight = self.cropAreaWidth * self.widthHeightRate;
    }
    self.cropAreaY = self.cropAreaY ?: (KScreenHeight - self.cropAreaHeight)/2;
    self.willCropRect = CGRectMake(self.cropAreaX, self.cropAreaY, self.cropAreaWidth, self.cropAreaHeight);
    
    //设置蒙版背景
    [[[UIColor blackColor] colorWithAlphaComponent:0.5f] setFill];
    UIRectFill(rect);
    [[UIColor clearColor] setFill];

    //设置透明部分位置和圆角
    self.cropBezrPath = [UIBezierPath bezierPathWithRect: self.willCropRect];

//    self.cropBezrPath.lineWidth = self.lineWidth;
//    self.cropBezrPath.lineCapStyle = kCGLineCapRound;
//    self.cropBezrPath.lineJoinStyle = kCGLineJoinBevel;

    // 设置画笔颜色 -- 跟前一个页面的颜色一致
//    UIColor *strokeColor = self.lineColor;// colorWithRed:89/255.0 green:212/255.0 blue:209/255.0 alpha:1];
//    [strokeColor set];
//
//    // 根据我们设置的各个点连线
//    [self.cropBezrPath stroke];


    CGContextSetFillColorWithColor(UIGraphicsGetCurrentContext(), [[UIColor clearColor] CGColor]);

    CGContextAddPath(context, self.cropBezrPath.CGPath);
    CGContextSetBlendMode(context, kCGBlendModeClear);
    CGContextFillPath(context);
    
    //移除layer
    self.layer.sublayers = nil;
    
   
    
    self.willCropRect = CGRectMake(self.cropAreaX, self.cropAreaY, self.cropAreaWidth, self.cropAreaHeight);
    UIBezierPath * path = [UIBezierPath bezierPathWithRoundedRect:self.willCropRect cornerRadius:0];
    UIBezierPath * cropPath = [UIBezierPath bezierPathWithRect:self.willCropRect];
    [path appendPath:cropPath];
   
    DBCropAreaLayer * layer = [[DBCropAreaLayer alloc] init];
    layer.lineColor = self.lineColor;
    layer.cropLineWidth = self.lineWidth;
    layer.isShowShaw = self.isShowShaw;
    layer.widthHeightRate = self.widthHeightRate;
    
    layer.path = path.CGPath;
    //中间透明
    layer.fillRule = kCAFillRuleEvenOdd;
    layer.fillColor = [self.lineColor CGColor];
    //layer.opacity = 0.5;
    
    layer.frame = self.bounds;
    

    [layer setCropAreaLeft:self.cropAreaX CropAreaTop:self.cropAreaY CropAreaRight:self.cropAreaX + self.cropAreaWidth CropAreaBottom:self.cropAreaY + self.cropAreaHeight];
    
    [self.layer addSublayer:layer];
    
    
}

//https://www.jb51.cc/iOS/329231.html
//操作UIKit上下文的操作方式是线程安全的,但你似乎无法在一个线程之外创建一个除了主程序,因为UIGraphicsBeginImageContextWithOptions“应该只在主程序中调用线程“,但仍然这样做的工作是完美的
- (UIImage *)clipImageWithSoucreImageView:(UIImageView *)imageView{
    
    CGRect foreCropRect = self.willCropRect;
    
    CGRect soucreRect = imageView.frame;
    
    UIImage *soucreImage = imageView.image;
    
    //缩放比例
    float zoomScale = [[imageView.layer valueForKeyPath:@"transform.scale.x"] floatValue];
   
    //计算 要裁剪图片的大小
    CGSize cropSize = CGSizeMake((foreCropRect.size.width)/zoomScale, (foreCropRect.size.height)/zoomScale);
    //计算 裁剪图片的原点
    CGPoint cropViewOrigin = CGPointMake((foreCropRect.origin.x - soucreRect.origin.x)/zoomScale,
                                            (foreCropRect.origin.y - soucreRect.origin.y)/zoomScale);
    
    //向上取整
    if((NSInteger)cropSize.width % 2 == 1)
    {
        cropSize.width = ceil(cropSize.width);
    }
    if((NSInteger)cropSize.height % 2 == 1)
    {
        cropSize.height = ceil(cropSize.height);
    }
    
    float _imageScale = soucreImage.size.width / self.cropAreaWidth;
    CGFloat imgRate = KScreenWidth/self.cropAreaWidth;
    //修正偏移量 得到最终的
    CGRect CropImageRect = CGRectMake((NSInteger)(cropViewOrigin.x)*_imageScale/imgRate ,(NSInteger)( cropViewOrigin.y)*_imageScale/imgRate, (NSInteger)(cropSize.width)*_imageScale/imgRate,(NSInteger)(cropSize.height)*_imageScale/imgRate);
   
    //旋转的角度 获取绕z轴 旋转的角度 -- 也就是当前平面旋转的角度
    float rotate = [[imageView.layer valueForKeyPath:@"transform.rotation.z"] floatValue];
    NSLog(@"旋转角度 == %f",rotate * 180/M_PI );
    //根据旋转的角度得到新的图片
    UIImage *rotInputImage = [soucreImage imageRotatedByRadians:rotate];
    
    CGImageRef tmp = CGImageCreateWithImageInRect([rotInputImage CGImage], CropImageRect);
    
    UIImage *resultImage = [UIImage imageWithCGImage:tmp scale:soucreImage.scale orientation:soucreImage.imageOrientation];
    
    if (!resultImage) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"您剪切的区域无效，请重新剪切" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        return nil;
    }
    
    CGRect imageRect = CGRectZero;
    imageRect.size = resultImage.size;
    
    UIBezierPath *cropedPath;
    //设置为YES 不透明，节省性能
    UIGraphicsBeginImageContextWithOptions(imageRect.size, YES,1);
    {
        //[[UIColor blackColor] setFill];
        UIRectFill(imageRect);
        [[UIColor whiteColor] setFill];
        //修改
        cropedPath = [UIBezierPath bezierPathWithRect:imageRect];
        [cropedPath fill];
    }
    UIImage *maskImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //设置为YES 不透明，节省性能
    //1 裁剪尺寸原比例 设置为0或者UIScreen.mainScreen.scale 或随屏幕分辨率放大尺寸
    UIGraphicsBeginImageContextWithOptions(imageRect.size,YES,1);
    {
        CGContextClipToMask(UIGraphicsGetCurrentContext(), imageRect, maskImage.CGImage);
        [resultImage drawAtPoint:CGPointZero];
    }
    UIImage *maskResultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return maskResultImage;
    
}


/* 图片规定大小 */
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

/*  去除图片本身自带方向 */
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

@end
