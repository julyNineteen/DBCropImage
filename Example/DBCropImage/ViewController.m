//
//  ViewController.m
//  图片剪裁Test2
//
//  Created by change009 on 16/2/19.
//  Copyright © 2016年 change009. All rights reserved.
//

#import "ViewController.h"
#import "DBCropImageController.h"
#import "CupedResultVC.h"
#import "YasicClipPage.h"

@interface ViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property(nonatomic,assign)BOOL isNewCropImage;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isNewCropImage = false;
}

- (IBAction)camerBtnAction:(id)sender {
    self.isNewCropImage = false;

    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    picker.modalPresentationStyle = 0;
    picker.modalPresentationStyle = 0;
    [self presentViewController:picker animated:YES completion:nil];
    
}


- (IBAction)photoBtnAction:(id)sender {
    self.isNewCropImage = true;
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    picker.modalPresentationStyle = 0;
    picker.modalPresentationStyle = 0;
    [self presentViewController:picker animated:YES completion:nil];
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    [self dismissViewControllerAnimated:false completion:nil];
    
    if(self.isNewCropImage == true){
        DBCropImageController *vc = [[DBCropImageController alloc] init];
        vc.lineColor = UIColor.whiteColor;
        vc.isShowShaw = true;
        vc.lineWidth = 2;
        vc.isFixCropArea = false;
        //vc.widthHeightRate = 3/4.0;
        //vc.cropAreaHeight = 50;
        vc.image = image;
        vc.clippedBlock = ^(UIImage * _Nonnull clippedImage) {
            CupedResultVC *ResultVC = [[CupedResultVC alloc] init];
            ResultVC.resultImage = clippedImage;
            ResultVC.modalPresentationStyle = 0;
            [self presentViewController:ResultVC animated:YES completion:nil];
            
        };
        vc.cancelClipBlock = ^{
            [self dismissViewControllerAnimated:YES completion:nil];
        };
        vc.modalPresentationStyle = 0;
        [self presentViewController:vc animated:YES completion:nil];
    }else{
        YasicClipPage *picker = [[YasicClipPage alloc] init];
        picker.targetImage = image;
        picker.clippedBlock = ^(UIImage * _Nonnull clippedImage) {
            CupedResultVC *ResultVC = [[CupedResultVC alloc] init];
            ResultVC.resultImage = clippedImage;
            ResultVC.modalPresentationStyle = 0;
            [self presentViewController:ResultVC animated:YES completion:nil];
            
        };
        picker.cancelClipBlock = ^{
            [self dismissViewControllerAnimated:YES completion:nil];
        };
        picker.modalPresentationStyle = 0;
        [self presentViewController:picker animated:YES completion:nil];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (BOOL) isSourceTypeAvailable{
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}

- (BOOL) isCameraDeviceAvailable{
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront];
}

@end
