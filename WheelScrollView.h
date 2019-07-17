//
//  WheelScrollView.h
//  longchuang
//
//  Created by M on 2018/12/27.
//  Copyright © 2018 龙泽. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "WheelImageModel.h"
//#import "BannerListModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^EcologyTopCellBlock)(NSString *webUrl, NSString *title, NSInteger index);

@interface WheelScrollView : UIView

@property (nonatomic, strong) EcologyTopCellBlock bannerImgBlock;

- (instancetype)initWithHeight:(CGFloat)height;

- (void)setBannerList:(NSArray *)bannerList;

- (void)startTimer;

- (void)stopTimer;

@end

NS_ASSUME_NONNULL_END
