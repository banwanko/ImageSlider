//
//  ImageSliderViewController.m
//  ImageSlider
//
//  Created by Ryuji Watanabe on 2013/08/07.
//  Copyright (c) 2013年 Excite Japan Co,. Ltd. All rights reserved.
//

#import "ImageSliderViewController.h"
#import "ImageSliderTiledView.h"

@interface ImageSliderViewController ()
// InterfaceBuilder Outlet
@property (weak, nonatomic) IBOutlet UIImageView    *knobImageView;
@property (weak, nonatomic) IBOutlet UIScrollView   *scrollView;
@property (weak, nonatomic) IBOutlet UIView         *sliderBaseView;

// Private
@property (nonatomic, assign) BOOL                  isDrag;         // ドラッグ中か？
@property (nonatomic, assign) CGFloat               scrollWidth;    // スクロールビューの幅
@property (nonatomic, assign) CGFloat               moveDistance;   // 現在の移動距離
@property (nonatomic) NSTimer                       *scrollTimer;   // インターバルタイマー
@property (nonatomic) ImageSliderTiledView          *contentsView;  // 表示用View
@property (nonatomic, assign) NSInteger             nowIndex;       // 真ん中のIndex
@end


@implementation ImageSliderViewController
static const CGFloat    kTimerInterval          = 0.08f;    // タイマーインターバル値
static const NSInteger  kMaxImageCount          = 100;      // 画像数
static const CGFloat    kSliderBarPaddingSpace  = 20.0f;    // スライダーバーのパディングスペース
static const CGFloat    kAllowableRange         = 14.0f;    // 最低この値以上の移動距離じゃないと反応させない

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self _setup];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/****************************
 *
 * Touch Events
 *
 ****************************/
#pragma mark -
#pragma mark ===== Touch Events =====
/*
 * タッチ開始
 */
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if(![event touchesForView:_knobImageView]) {
        [super touchesBegan:touches withEvent:event];
        return;
    }
    // スクロール処理開始
    _isDrag = YES;
    _moveDistance = 0.0f;
}
/*
 * タッチ継続(移動)
 */
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if(![event touchesForView:_knobImageView] || !_isDrag) {
        [super touchesMoved:touches withEvent:event];
        return;
    }
    // 現在の位置を調整
    CGPoint point = [((UITouch*)[touches anyObject])locationInView:_sliderBaseView];
	CGFloat leftLimitPosX = _sliderBaseView.frame.origin.x + kSliderBarPaddingSpace;
	CGFloat rightLimitPosX = _sliderBaseView.frame.origin.x + _sliderBaseView.frame.size.width - kSliderBarPaddingSpace;
    if(point.x < leftLimitPosX) point.x = leftLimitPosX;
    if(point.x  > rightLimitPosX) point.x = rightLimitPosX;
    
    // ドラッグ中の座標を使って移動
    _knobImageView.center = CGPointMake(point.x, _sliderBaseView.frame.size.height / 2.0f);
    _moveDistance = point.x - _sliderBaseView.center.x ;
    if(fabsf(_moveDistance) < kAllowableRange) _moveDistance = 0.0f;   // 移動距離が足りない場合は無視する
    if(_moveDistance != 0.0f) _moveDistance = _moveDistance < 0 ? _moveDistance + kAllowableRange : _moveDistance - kAllowableRange;
    // もし移動距離が0ならば、位置補正してタイマーを止める。
    if(_moveDistance == 0.0f) {
        [self _stopScrollTimer];
        // 位置補正
        [self _adjustImagePotision];
    }
    else {
        // 位置移動用のタイマーが起動していない場合には起動させる。
        if(![_scrollTimer isValid]) [self _startScrollTimer];
    }
}

/*
 * タッチ終了
 */
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if(![event touchesForView:_knobImageView] || !_isDrag) {
        [super touchesEnded:touches withEvent:event];
        return;
    }
    // タイマー停止
    [self _stopScrollTimer];
    _isDrag = NO;
    
    // 後処理
    [UIView animateWithDuration:0.06f animations:^{
        _knobImageView.center = CGPointMake(_sliderBaseView.frame.size.width / 2.0f, _sliderBaseView.frame.size.height / 2.0f);
    }];
    // 位置補正
    [self _adjustImagePotision];
}

/****************************
 *
 * Privarte Methods
 *
 ****************************/
#pragma mark -
#pragma mark ===== Privarte Methods =====
/**
 * 初期化
 */
- (void)_setup {
    _isDrag = NO;
    _nowIndex = kMaxImageCount / 2;
    _knobImageView.userInteractionEnabled = YES;    // touchイベントを受けるため。
    _scrollWidth = _scrollView.frame.size.width;
    CGRect rect = CGRectMake(0.0f, 0.0f, kMaxImageCount * _scrollWidth, _scrollView.frame.size.height);
    
    _contentsView = [[ImageSliderTiledView alloc] initWithFrame:rect tileSize:_scrollView.frame.size];
    [_scrollView addSubview:_contentsView];
    _scrollView.contentSize = _contentsView.frame.size;
    _scrollView.contentOffset = CGPointMake(_nowIndex * _scrollWidth, 0.0f); // 真ん中に合わせる
    _scrollView.clipsToBounds = NO;             // スクロールビューを超えて子ビューを表示させる
    _scrollView.userInteractionEnabled = NO;    // スクロールビューは触れないようにする
}
/**
 * タイマー開始
 */
- (void)_startScrollTimer {
    if([_scrollTimer isValid]) [_scrollTimer invalidate];
    _scrollTimer = nil;
    // タイマー開始
    _scrollTimer = [NSTimer scheduledTimerWithTimeInterval:kTimerInterval target:self selector:@selector(_scrollTimerFire:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_scrollTimer forMode:NSRunLoopCommonModes];
}
/**
 * タイマー停止
 */
- (void)_stopScrollTimer {
    [_scrollTimer invalidate];
    _scrollTimer = nil;
}
/**
 * 画像位置の補正
 */
- (void)_adjustImagePotision {
    CGFloat pageX = _nowIndex * _scrollWidth;
    CGPoint offset = _scrollView.contentOffset;
    if(offset.x != pageX) [_scrollView setContentOffset:CGPointMake(pageX, 0.0f) animated:YES];
}
/**
 * x座標からページindexを取得する
 * @param offsetX 算出したいx座標
 * @return 算出したindex
 */
- (NSInteger)_calcPageIndexWithOffsetX:(CGFloat)offsetX {
    NSInteger result = floor((offsetX - _scrollWidth / 2) / _scrollWidth) + 1;
    return result;
}

/****************************
 *
 * Timer Methods
 *
 ****************************/
#pragma mark -
#pragma mark ===== Timer Methods =====
/*
 * スクロールタイマー処理
 */
- (void)_scrollTimerFire:(NSTimer*)timer {
    
    NSInteger move = (NSInteger)(_moveDistance);
    CGPoint offset = _scrollView.contentOffset;
    offset.x = offset.x + move;
    if(offset.x < 0) offset.x = 0;
    if(offset.x > (_scrollView.contentSize.width - _scrollWidth)) offset.x = (_scrollView.contentSize.width - _scrollWidth);
    [_scrollView setContentOffset:offset];
    // page
    NSInteger page = [self _calcPageIndexWithOffsetX:offset.x];
    _nowIndex = page;
}

@end
