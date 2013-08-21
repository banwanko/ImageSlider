//
//  ImageSliderModel.m
//  ImageSlider
//
//  Created by Ryuji Watanabe on 2013/08/07.
//  Copyright (c) 2013年 Excite Japan Co,. Ltd. All rights reserved.
//

#import "ImageSliderModel.h"

@implementation ImageSliderModel

static NSString *kResourcePath = nil;

- (id)init {
    self = [super init];
    if(self) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            kResourcePath = [[NSBundle mainBundle] resourcePath];
        });
    }
    return self;
}

/*
 * 画像読み込み
 */
- (UIImage*)imageAtIndex:(NSInteger)index {
    UIImage *result = nil;
    NSString *fileName = [NSString stringWithFormat:@"dummy%03d.jpg", index+1];
    NSString *path = [kResourcePath stringByAppendingPathComponent:fileName];
    result = [UIImage imageWithContentsOfFile:path];    
    return result;
}


@end
