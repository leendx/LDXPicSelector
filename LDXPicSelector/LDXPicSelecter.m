//
//  LDXPhotoSelecteer.m
//  just4Test
//
//  Created by Leen on 15/8/10.
//  Copyright (c) 2015年 Leen. All rights reserved.
//

#import "LDXPicSelecter.h"
#import <MobileCoreServices/MobileCoreServices.h>


@interface LDXPicSelecter() <UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate>
{
    UIViewController *parentVC;
    UIView *bgView;
    
    UIImageView *selectorImg;
    CGAffineTransform transform;
    ImageSelectBlock imageblock;
}

@end

@implementation LDXPicSelecter


#define COLOR_BUTTON_GAY [UIColor colorWithRed:165.0f/255.0f green:165.0f/255.0f blue:165.0f/255.0f alpha:1.0f]

+ (void)start:(UIViewController*)vc withBlock:(ImageSelectBlock)block
{
    LDXPicSelecter *ps = [[LDXPicSelecter alloc] init];
    [ps start:vc withBlock:block];
}

- (void)start:(UIViewController*)vc withBlock:(ImageSelectBlock)block
{
    parentVC = vc;
    // 修改照片   相机/相册
    UIActionSheet *choiceSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"取消"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"拍照", @"从相册中选取", nil];
    
    [choiceSheet showInView:vc.view];
    imageblock = block;
}


#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        // 拍照
        if ([self isCameraAvailable] && [self doesCameraSupportTakingPhotos]) {
            UIImagePickerController *controller = [[UIImagePickerController alloc] init];
            controller.sourceType = UIImagePickerControllerSourceTypeCamera;
            if ([self isFrontCameraAvailable]) {
                controller.cameraDevice = UIImagePickerControllerCameraDeviceRear;
            }
            NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
            [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
            controller.mediaTypes = mediaTypes;
            controller.delegate = self;
            //            controller.allowsEditing = YES;
            [parentVC presentViewController:controller
                               animated:YES
                             completion:^(void){
                                 NSLog(@"Picker View Controller is presented");
                             }];
        }
        
    } else if (buttonIndex == 1) {
        // 从相册中选取
        if ([self isPhotoLibraryAvailable]) {
            UIImagePickerController *controller = [[UIImagePickerController alloc] init];
            controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
            [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
            controller.mediaTypes = mediaTypes;
            controller.delegate = self;
            //            controller.allowsEditing = YES;
            
            [parentVC presentViewController:controller
                               animated:YES
                             completion:^(void){
                                 NSLog(@"Picker View Controller is presented");
                             }];
        }
    } else if (buttonIndex == 2) {
        // 取消
        imageblock = nil;
    }
}


#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:^() {
        
        UIImage *chooseImg = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            bgView = [[UIView alloc] initWithFrame:parentVC.view.bounds];
            bgView.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.5];
            
            selectorImg = [[UIImageView alloc] initWithImage:chooseImg];
            selectorImg.userInteractionEnabled = YES;
            
            UIPanGestureRecognizer *panGR = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(imagePanAction:)];
            [selectorImg addGestureRecognizer:panGR];
            
            UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(imagepinchAction:)];
            [selectorImg addGestureRecognizer:pinchGestureRecognizer];
            
            [bgView addSubview:selectorImg];
            
            
            self.overlayView = [[UIView alloc] init];
            self.overlayView.layer.borderColor = [[UIColor orangeColor] CGColor];
            self.overlayView.layer.borderWidth = 2;
            self.overlayView.userInteractionEnabled = NO;
            if (CGSizeEqualToSize(_overlaySize, CGSizeZero)) {
                _overlaySize = CGSizeMake(250, 250);
            }
            self.overlayView.frame = CGRectMake(0, 0, _overlaySize.width, _overlaySize.height);
            self.overlayView.center = parentVC.view.center;
            [bgView addSubview:self.overlayView];
            
            [self initControlBtn];
            
            [parentVC.view addSubview:bgView];
        });
        
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^(){
        
    }];
}

- (void)imagePanAction:(UIPanGestureRecognizer*)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        transform = selectorImg.transform;
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        // 获取手势在视图上偏移的坐标
        CGPoint translation = [recognizer translationInView:selectorImg];
        selectorImg.transform = CGAffineTransformTranslate(transform, translation.x, translation.y);
    } else if (recognizer.state == UIGestureRecognizerStateEnded) {
        
        transform = selectorImg.transform;
        CGFloat disX = 0, disY = 0;
        if (CGRectGetMinX(selectorImg.frame)>CGRectGetMinX(_overlayView.frame)) {
            disX = CGRectGetMinX(_overlayView.frame) - CGRectGetMinX(selectorImg.frame);
            
        }
        else if (CGRectGetMaxX(selectorImg.frame)<CGRectGetMaxX(_overlayView.frame)) {
            disX = CGRectGetMaxX(_overlayView.frame) - CGRectGetMaxX(selectorImg.frame);
            
        }
        
        if (CGRectGetMinY(selectorImg.frame)>CGRectGetMinY(_overlayView.frame)) {
            disY = CGRectGetMinY(_overlayView.frame) - CGRectGetMinY(selectorImg.frame);
            
        }
        else if (CGRectGetMaxY(selectorImg.frame)<CGRectGetMaxY(_overlayView.frame)) {
            disY = CGRectGetMaxY(_overlayView.frame) - CGRectGetMaxY(selectorImg.frame);
            
        }
        
        if (disX!=0 || disY!=0) {
            
            [UIView animateWithDuration:0.2f animations:^{
                selectorImg.transform = CGAffineTransformTranslate(transform, disX/transform.a, disY/transform.a);
            } completion:^(BOOL finished) {
                transform = selectorImg.transform;
            }];
        }
    }
}

- (void)imagepinchAction:(UIPinchGestureRecognizer*)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        transform = selectorImg.transform;
        if (selectorImg.transform.a<0.5f) {
            [UIView animateWithDuration:0.2f animations:^{
                transform.a = 0.5f;
                transform.d = 0.5f;
                
                selectorImg.transform = transform;
            } completion:^(BOOL finished) {
                transform = selectorImg.transform;
            }];
        }
        
    }else if(recognizer.state == UIGestureRecognizerStateBegan){
        transform = selectorImg.transform;
    }
    else if (recognizer.state == UIGestureRecognizerStateChanged)
    {
        selectorImg.transform = CGAffineTransformScale(transform,recognizer.scale, recognizer.scale);
        
    }
}
#pragma mark - 摄像头和相册相关公用方法
/**
 * 判断设备是否有摄像头
 */
- (BOOL) isCameraAvailable{
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}

/**
 * 前面的摄像头是否可用
 */
- (BOOL) isFrontCameraAvailable{
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront];
}

/**
 * 后面的摄像头是否可用
 */
- (BOOL) isRearCameraAvailable{
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
}

/**
 * 检查摄像头是否支持拍照
 */
- (BOOL) doesCameraSupportTakingPhotos {
    return [self cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypeCamera];
}

/**
 * 相册是否可用
 */
- (BOOL) isPhotoLibraryAvailable{
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary];
}

/**
 * 是否可以在相册中选择视频
 */
- (BOOL) canUserPickVideosFromPhotoLibrary{
    return [self cameraSupportsMedia:(__bridge NSString *)kUTTypeMovie sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}

/**
 * 是否可以在相册中选择相片
 */
- (BOOL) canUserPickPhotosFromPhotoLibrary{
    return [self cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}

/**
 * 判断是否支持某种多媒体类型：拍照，视频
 */
- (BOOL) cameraSupportsMedia:(NSString *)paramMediaType sourceType:(UIImagePickerControllerSourceType)paramSourceType{
    __block BOOL result = NO;
    if ([paramMediaType length] == 0) {
        return NO;
    }
    NSArray *availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:paramSourceType];
    [availableMediaTypes enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *mediaType = (NSString *)obj;
        if ([mediaType isEqualToString:paramMediaType]){
            result = YES;
            *stop= YES;
        }
    }];
    return result;
}


#define FooterHeight 50.0f
#define ButtonWidth 100.0f
/**
 * 初始化button
 */
- (void)initControlBtn {
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, parentVC.view.frame.size.height - FooterHeight, parentVC.view.frame.size.width, FooterHeight)];
    footerView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
    [bgView addSubview:footerView];
    
    UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, ButtonWidth, FooterHeight)];
    cancelBtn.backgroundColor = [UIColor clearColor];
    cancelBtn.titleLabel.textColor = [UIColor whiteColor];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:18.0f]];
    [cancelBtn.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [cancelBtn.titleLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [cancelBtn.titleLabel setNumberOfLines:0];
    [cancelBtn setTitleEdgeInsets:UIEdgeInsetsMake(5.0f, 5.0f, 5.0f, 5.0f)];
    [cancelBtn addTarget:self action:@selector(cancelCropping) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:cancelBtn];
    
    UIButton *confirmBtn = [[UIButton alloc] initWithFrame:CGRectMake(footerView.frame.size.width-ButtonWidth, 0, ButtonWidth, FooterHeight)];
    confirmBtn.backgroundColor = [UIColor clearColor];
    confirmBtn.titleLabel.textColor = [UIColor whiteColor];
    [confirmBtn setTitle:@"确定" forState:UIControlStateNormal];
    [confirmBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:18.0f]];
    [confirmBtn.titleLabel setTextAlignment:NSTextAlignmentCenter];
    confirmBtn.titleLabel.textColor = [UIColor whiteColor];
    [confirmBtn.titleLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [confirmBtn.titleLabel setNumberOfLines:0];
    [confirmBtn setTitleEdgeInsets:UIEdgeInsetsMake(5.0f, 5.0f, 5.0f, 5.0f)];
    [confirmBtn addTarget:self action:@selector(finishCropping) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:confirmBtn];
}


- (void)cancelCropping {
    [bgView removeFromSuperview];
    imageblock = nil;
}

- (void)finishCropping {
    
    CGRect rect = [_overlayView convertRect:_overlayView.frame toView:selectorImg];
    CGRect imgrect = (CGRect){
        .origin.x = (_overlayView.frame.origin.x - selectorImg.frame.origin.x)/selectorImg.transform.a,
        .origin.y = (_overlayView.frame.origin.y - selectorImg.frame.origin.y)/selectorImg.transform.a,
        .size.width  = CGRectGetWidth(rect),
        .size.height = CGRectGetHeight(rect)
    };
    CGImageRef cr = CGImageCreateWithImageInRect([selectorImg.image CGImage], imgrect);
    
    UIImage *cropped = [UIImage imageWithCGImage:cr];
    
    CGImageRelease(cr);
    
    UIImage *scaleImage = [self scaleImage:cropped size:imgrect.size];
    imageblock(scaleImage);
    [self cancelCropping];
}


-(UIImage*)scaleImage:(UIImage*)image size:(CGSize)newSize
{
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(newSize);
    
    // 绘制改变大小的图片
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    
    // 返回新的改变大小后的图片
    return scaledImage;
}
@end
