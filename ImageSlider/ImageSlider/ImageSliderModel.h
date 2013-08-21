//
//  ImageSliderModel.h
//  ImageSlider
//
//  Created by Ryuji Watanabe on 2013/08/07.
//  Copyright (c) 2013年 Excite Japan Co,. Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageSliderModel : NSObject

/**
 * 画像を読み込み返す
 *
 * @param index 画像インデックス
 * @return UIImageインスタンス
 */
- (UIImage*)imageAtIndex:(NSInteger)index;
@end
