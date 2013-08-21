//
//  ImageSliderTiledView.m
//  ImageSlider
//
//

#import "ImageSliderTiledView.h"
#import "ImageSliderTiledLayer.h"

@interface ImageSliderTiledView ()
@property (nonatomic, strong) ImageSliderTiledLayer               *tiledLayer;
@end

@implementation ImageSliderTiledView {
}

+(Class)layerClass
{
    return [CATiledLayer class];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}
- (id)initWithFrame:(CGRect)frame tileSize:(CGSize)tileSize {
    self = [self initWithFrame:frame];
    if(self) {
        [self _setupDrawLayerWithTileSize:tileSize];
    }
    return self;
}

- (void)setTileSize:(CGSize)tileSize {
    _tileSize = tileSize;
    if(_tiledLayer) {
        [_tiledLayer removeFromSuperlayer];
        _tiledLayer = nil;
    }
    [self _setupDrawLayerWithTileSize:tileSize];
}


/**
 * 指定されたタイルサイズで初期化する
 * @param tileSize  一つの画像を表示するタイルサイズ
 */
- (void)_setupDrawLayerWithTileSize:(CGSize)tileSize {
    _tileSize = tileSize;
    _tiledLayer = [ImageSliderTiledLayer new];
	CGFloat contentsScale = [UIScreen mainScreen].scale;
    CGSize scaleTileSize = CGSizeMake(_tileSize.width * contentsScale, _tileSize.height * contentsScale);
    CGRect contentsRect = self.frame;
    _tiledLayer.contentsScale = contentsScale;
	_tiledLayer.frame = contentsRect;
	_tiledLayer.delegate = _tiledLayer;
	_tiledLayer.levelsOfDetail = 1;
	_tiledLayer.levelsOfDetailBias = 0;
    _tiledLayer.tileSize = scaleTileSize;
	[self.layer addSublayer:_tiledLayer];
}

@end
