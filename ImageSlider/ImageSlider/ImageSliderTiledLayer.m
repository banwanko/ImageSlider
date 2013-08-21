//
//  ImageSliderTiledLayer.m
//  ImageSlider
//
//  Created by Ryuji Watanabe on 2013/08/07.
//  Copyright (c) 2013年 Excite Japan Co,. Ltd. All rights reserved.
//

#import "ImageSliderTiledLayer.h"
#import "ImageSliderModel.h"

@interface ImageSliderTiledLayer ()
@property (nonatomic) ImageSliderModel          *sliderImageModel;
@end

@implementation ImageSliderTiledLayer {
    
}

static const CGFloat    kMarginSpace = 2.0f;    // マージン

+ (CFTimeInterval)fadeDuration {
	CFTimeInterval result = 0.1f;   // フェードインする時間
	return result;
}

- (id)init {
    self = [super init];
    if(self) {
        _sliderImageModel = [ImageSliderModel new];
    }
    return self;
}

/*
 * 描画
 */
- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx{
	if([layer class] != [ImageSliderTiledLayer class]) return;

    CGRect rect =CGContextGetClipBoundingBox(ctx);
    CGFloat x = rect.origin.x * self.contentsScale;
	NSInteger index = [self _calcPageIndexWithOffsetX:x];
    if(index < 0) return;

	// 表示画像取得
    UIImage *orgImage = [_sliderImageModel imageAtIndex:index];
    
    // 描画
	CGContextSaveGState(ctx);
	CGContextTranslateCTM(ctx, 0.0f, 0.0f);
	CGContextScaleCTM(ctx, 1.0f, -1.0f);
	rect = CGContextGetClipBoundingBox(ctx);
    
    // 描画位置・サイズを合わせる
    CGImageRef imageRef = [orgImage CGImage];
    size_t width = CGImageGetWidth(imageRef) - (kMarginSpace*2);
    size_t height = CGImageGetHeight(imageRef) - (kMarginSpace*2);
    CGFloat widthRatio  = (rect.size.width - (kMarginSpace*2))  / width;
    CGFloat heightRatio = (rect.size.height - (kMarginSpace*2)) / height;
    CGFloat ratio = (widthRatio < heightRatio) ? widthRatio : heightRatio;
    CGFloat targetWidth, targetHeight;
    targetHeight = height * ratio;
    targetWidth = width * ratio;
    
    rect.origin.x += (rect.size.width - targetWidth) / 2 + kMarginSpace;
    rect.origin.y += (rect.size.height - targetHeight) / 2 + kMarginSpace;
    if (ratio < 1.0) {
        rect.size.width = targetWidth;
        rect.size.height = targetHeight;        
    }
    // 描画
	CGContextDrawImage(ctx, rect, [orgImage CGImage]);
    CGContextFillPath(ctx);    
	CGContextRestoreGState(ctx);    
}

/**
 * 指定したx座標からindexを算出する
 * @param offsetX   算出対象となるX座標
 * @return 算出したindex
 */
- (NSInteger)_calcPageIndexWithOffsetX:(CGFloat)offsetX {
    CGSize size = self.tileSize;
    NSInteger result = floor((offsetX - size.width / 2) / size.width) + 1;
    return result;
}
@end
