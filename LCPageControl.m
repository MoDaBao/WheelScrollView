//
//  LCPageControl.m
//  YouMi
//
//  Created by M on 2019/7/15.
//  Copyright © 2019 啧啧. All rights reserved.
//

#import "LCPageControl.h"

#define dotW (kScreen_Width - (magrin * self.numberOfPages - 1) - 20) * 1.0 / self.numberOfPages // 圆点宽
#define dotH 7  // 圆点高
#define magrin   20  // 圆点间距

@implementation LCPageControl


- (void)layoutSubviews {
    [super layoutSubviews];
    //计算圆点间距
    CGFloat marginX = dotW + magrin;
    
    
    
    //计算整个pageControll的宽度
    CGFloat newW = (self.subviews.count - 1 ) * marginX;
    
    //设置新frame
    CGRect frame = (CGRect)self.frame;
    frame = CGRectMake(kScreen_Width/2-(newW + dotW)/2, frame.origin.y, newW + dotW, frame.size.height);
    self.frame = frame;
    
    //遍历subview,设置圆点frame
    for (int i=0; i<[self.subviews count]; i++) {
        UIImageView* dot = [self.subviews objectAtIndex:i];
        dot.layer.cornerRadius = 0;
        
        if (i == self.currentPage) {
            [dot setFrame:CGRectMake(i * marginX, dot.frame.origin.y, dotW, dotH)];
        }else {
            [dot setFrame:CGRectMake(i * marginX, dot.frame.origin.y, dotW, dotH)];
        }
    }
}

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
    }
    return self;
}

- (void)setNumberOfPages:(NSInteger)numberOfPages {
    [super setNumberOfPages:numberOfPages];
    
    [self layoutSubviews];
    
}



@end
