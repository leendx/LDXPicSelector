//
//  ViewController.m
//  LDXPicSelector
//
//  Created by Leen on 15/9/25.
//  Copyright (c) 2015年 leen. All rights reserved.
//

#import "ViewController.h"
#import "LDXPicSelecter.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)ActionTouchUpInside:(id)sender
{
    [LDXPicSelecter start:self withBlock:^(UIImage *selImage) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            _iv_pic.image = selImage;
            _iv_pic.frame = CGRectMake(_iv_pic.frame.origin.x, _iv_pic.frame.origin.y, selImage.size.width, selImage.size.height);
        });
    }];
}
@end
