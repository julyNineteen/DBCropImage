# DBCropImage

## Requirements

## Installation

DBCropImage is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'DBCropImage'
```
不多说，先上图：
![裁剪图片.gif](https://upload-images.jianshu.io/upload_images/3067622-e9448ba0ffc7f24b.gif?imageMogr2/auto-orient/strip)
源代码仓库
https://github.com/julyNineteen/DBCropImage

一个专门裁剪图片轻量级的轮子，简单易用，功能丰富（高自由度的参数设定、支持旋转和缩放、拖动），能满足绝大部分裁剪的需求。源代码公开，具体详细实现逻辑参数都在里面。非常支持自定义。
目前功能：
    ✅ 支持任意角度360度的旋转；
    ✅ 高自由度的参数设定，包括裁剪区域颜色大小、裁剪宽高比等；
    ✅支持固定或者可移动的裁剪框
    ✅ 支持固定或者可移动的裁剪框
    ✅ 裁剪算法公开，轻量级，非常适合自定义为适合自己的项目

   使用非常简单，一个初始化方法搞定
```
       DBCropImageController *vc = [[DBCropImageController alloc] init];
        vc.lineColor = UIColor.whiteColor;//裁剪框线条眼色
        vc.isShowShaw = true;               //裁剪框线条是否显示阴影
        vc.lineWidth = 2;                        //裁剪框线条的宽度
        vc.isFixCropArea = false;       //是否固定裁剪框
        vc.widthHeightRate = 3/4.0;//设置宽高比例
        vc.cropAreaHeight = 50;      //设置最小裁剪高度
        vc.image = image;                 //传入裁剪图片
       //裁剪图片回调
        vc.clippedBlock = ^(UIImage * _Nonnull clippedImage) {
            CupedResultVC *ResultVC = [[CupedResultVC alloc] init];
            ResultVC.resultImage = clippedImage;
            ResultVC.modalPresentationStyle = 0;
            [self presentViewController:ResultVC animated:YES completion:nil];
        };
       //取消裁剪
        vc.cancelClipBlock = ^{
            [self dismissViewControllerAnimated:YES completion:nil];
        };
        vc.modalPresentationStyle = 0;
        [self presentViewController:vc animated:YES completion:nil];
```
核心裁剪逻辑实现在这里，代码注释非常详细，适合对图片裁剪领域的学习。
```
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
```


简书链接：https://www.jianshu.com/p/1298428f5848

## Author

julylions@163.com

## License

DBCropImage is available under the MIT license. See the LICENSE file for more info.
