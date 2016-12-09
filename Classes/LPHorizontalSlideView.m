// The MIT License (MIT)
//
// Copyright (c) 2015-2016 litt1e-p ( https://github.com/litt1e-p )
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

#import "LPHorizontalSlideView.h"

#define kKeyWindow [UIApplication sharedApplication].keyWindow
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define kSlideVieMaskMaxAlpha 0.6f
#define kSlideVieAnimateDuration 0.35f

typedef NS_ENUM(NSInteger, LPSlideViewState)
{
    LPSlideViewStateToLeft,
    LPSlideViewStateToRight
};

@interface LPHorizontalSlideView()<UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIView *mask;

@end

@implementation LPHorizontalSlideView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor       = [UIColor whiteColor];
        UIGestureRecognizer *panGr = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(viewPanEvent:)];
        panGr.delegate             = self;
        [self addGestureRecognizer:panGr];
    }
    return self;
}

- (void)setLeft:(CGFloat)x
{
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (CGFloat)minX
{
    return kScreenWidth - self.frame.size.width;
}

- (void)viewPanEvent:(UIPanGestureRecognizer *)gesture
{
    UIView *view = gesture.view;
    CGFloat finalX = view.frame.origin.x;
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:{
            break;
        }
            
        case UIGestureRecognizerStateChanged:{
            CGPoint tranlation = [gesture translationInView:self];
            CGFloat transX = view.frame.origin.x + tranlation.x;
            finalX = transX < [self minX] ? [self minX] : (transX > kScreenWidth ? kScreenWidth :transX);
            [self setLeft:finalX];
            [gesture setTranslation:CGPointMake(0, 0) inView:kKeyWindow];
            break;
        }
            
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:{
            [self slideView:LPSlideViewStateToRight];
            break;
        }
            
        case UIGestureRecognizerStateEnded:{
            if (self.frame.origin.x < (self.frame.size.width * 0.3 + [self minX])) {
                [UIView animateWithDuration:kSlideVieAnimateDuration animations:^{
                    [self setLeft:[self minX]];
                }];
            } else {
                [self dismiss];
            }
            break;
        }
            
        default:
            break;
    }
}

- (void)slideView:(LPSlideViewState)slideState
{
    CGFloat destinationX = slideState == LPSlideViewStateToLeft ? [self minX] : kScreenWidth;
    CGFloat destinationAlpha = slideState == LPSlideViewStateToLeft ? kSlideVieMaskMaxAlpha : 0.f;
    [UIView animateWithDuration:kSlideVieAnimateDuration animations:^{
        self.userInteractionEnabled = NO;
        [self setLeft:destinationX];
        self.mask.backgroundColor = [UIColor colorWithWhite:0.f alpha:destinationAlpha];
    } completion:^(BOOL finished) {
        self.userInteractionEnabled = YES;
    }];
}

- (void)showOnView:(UIView *)view
{
    [view addSubview:self.mask];
    [view addSubview:self];
    [self setLeft:kScreenWidth];
    [self slideView:LPSlideViewStateToLeft];
}

- (void)dismiss
{
    [self slideView:LPSlideViewStateToRight];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kSlideVieAnimateDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.mask removeFromSuperview];
        [self removeFromSuperview];
    });
}

- (UIView *)mask
{
    if (!_mask) {
        _mask                       = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
        _mask.backgroundColor       = [UIColor colorWithWhite:0 alpha:0.01];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
        tap.delegate                = self;
        tap.numberOfTapsRequired    = 1;
        [tap addTarget:self action:@selector(dismiss)];
        [_mask addGestureRecognizer:tap];
    }
    return _mask;
}
@end
