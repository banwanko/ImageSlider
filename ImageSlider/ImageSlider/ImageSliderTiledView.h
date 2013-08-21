//
//  ImageSliderTiledView.h
//  ImageSlider
//
//  Created by Ryuji Watanabe on 2013/08/07.
//  Copyright (c) 2013年 Excite Japan Co,. Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageSliderTiledView : UIView

@property (nonatomic, assign) CGSize        tileSize;
/**
 * タイルサイズを指定してViewを作成する
 */
- (id)initWithFrame:(CGRect)frame tileSize:(CGSize)tileSize;

@end
