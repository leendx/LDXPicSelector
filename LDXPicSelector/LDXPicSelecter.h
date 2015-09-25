//
//  LDXPhotoSelecteer.h
//  just4Test
//
//  Created by Leen on 15/8/10.
//  Copyright (c) 2015年 Leen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void(^ImageSelectBlock)(UIImage *selImage);
@interface LDXPicSelecter : NSObject



@property (nonatomic, assign) CGSize overlaySize;
@property (nonatomic, strong) UIView *overlayView;

//- (void)start:(UIViewController*)vc withBlock:(ImageSelectBlock)block;


+ (void)start:(UIViewController*)vc withBlock:(ImageSelectBlock)block;
@end
