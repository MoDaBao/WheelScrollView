//
//  WheelScrollView.m
//  longchuang
//
//  Created by M on 2018/12/27.
//  Copyright © 2018 龙泽. All rights reserved.
//

#import "WheelScrollView.h"
#import "LCPageControl.h"

#define IMAGEVIEW_COUNT 3

@interface WheelScrollView ()<UIScrollViewDelegate> {
    NSInteger _currentImageIndex; //当前索引
    NSInteger _imageCount; //图片总数
    NSArray *_bannerList;
    NSTimer *bannerTimer;
}

@property (nonatomic, strong) UIScrollView *ShufflingHeadView;
@property (nonatomic, strong) UIImageView *leftImageView;
@property (nonatomic, strong) UIImageView *centerImageView;
@property (nonatomic, strong) UIImageView *rightImageView;
@property (nonatomic, strong) LCPageControl *pageControl;
@property (nonatomic, assign) CGFloat shufflingHeight;

@end

@implementation WheelScrollView

- (instancetype)initWithHeight:(CGFloat)height {
    if (self = [super init]) {
        
        self.shufflingHeight = height;
        [self createShufflingView];
    }
    return self;
}



/*******************************顶部轮播图start************************************/
# pragma mark - Shuffling（轮播图）
- (void)createShufflingView {
//    self.backgroundColor = MainBgColor;
    
    _bannerList = [[NSArray alloc]init];
    _imageCount = _bannerList.count;
    
    self.ShufflingHeadView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    self.ShufflingHeadView.backgroundColor = [UIColor whiteColor];
    self.ShufflingHeadView.delegate = self;
    self.ShufflingHeadView.bounces = NO;
    self.ShufflingHeadView.pagingEnabled = YES;
    self.ShufflingHeadView.showsHorizontalScrollIndicator = NO;
    self.ShufflingHeadView.contentSize = CGSizeMake(kScreen_Width*IMAGEVIEW_COUNT,0);
    //设置当前显示的位置为中间图片
    [self.ShufflingHeadView setContentOffset:CGPointMake(kScreen_Width, 0) animated:NO];
    [self addSubview:self.ShufflingHeadView];
    [self.ShufflingHeadView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    self.pageControl = [[LCPageControl alloc] initWithFrame:CGRectMake(0, self.shufflingHeight - 10, kScreen_Width, 10)];
    self.pageControl.numberOfPages = 1;
    self.pageControl.hidesForSinglePage = YES;
    self.pageControl.userInteractionEnabled = YES;
    self.pageControl.currentPageIndicatorTintColor = UIColorFromRGB(0xea4141);
    self.pageControl.pageIndicatorTintColor = [UIColor whiteColor];
    [self addSubview:self.pageControl];
    [self.pageControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.ShufflingHeadView);
        make.height.equalTo(@10);
        make.width.equalTo(@(kScreen_Width));
        make.bottom.equalTo(self.ShufflingHeadView.mas_bottom).offset(-8);
    }];
    [self addImageViews];
    [self setBannerDefaultImage];
}

#pragma mark 添加图片控件
- (void)addImageViews {
    self.leftImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, kScreen_Width, self.shufflingHeight)];
    self.leftImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.leftImageView.clipsToBounds = YES;
    [self.ShufflingHeadView addSubview:self.leftImageView];
    
    self.centerImageView = [[UIImageView alloc]initWithFrame:CGRectMake(kScreen_Width, 0, kScreen_Width, self.shufflingHeight)];
    self.centerImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.centerImageView.clipsToBounds = YES;
    UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesClick:)];
    self.centerImageView.userInteractionEnabled = YES;
    [self.centerImageView addGestureRecognizer:singleTap];
    [self.ShufflingHeadView addSubview:self.centerImageView];
    
    self.rightImageView = [[UIImageView alloc]initWithFrame:CGRectMake(2*kScreen_Width, 0, kScreen_Width, self.shufflingHeight)];
    self.rightImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.rightImageView.clipsToBounds = YES;
    [self.ShufflingHeadView addSubview:self.rightImageView];
}


#pragma mark 设置默认显示图片

- (void)setBannerDefaultImage {
    if (_imageCount == 0) {
        self.ShufflingHeadView.scrollEnabled = NO;
        return;
    }
    if (_imageCount < 2) {
        [bannerTimer setFireDate:[NSDate distantFuture]];//关闭
        self.ShufflingHeadView.scrollEnabled = NO;
        NSString *imagePath = _bannerList[0];
        [self.leftImageView sd_setImageWithURL:[NSURL URLWithString:imagePath] placeholderImage:nil options:SDWebImageRetryFailed|SDWebImageRefreshCached];
        [self.centerImageView sd_setImageWithURL:[NSURL URLWithString:imagePath] placeholderImage:nil options:SDWebImageRetryFailed|SDWebImageRefreshCached];
        [self.rightImageView sd_setImageWithURL:[NSURL URLWithString:imagePath] placeholderImage:nil options:SDWebImageRetryFailed|SDWebImageRefreshCached];
    } else {
        self.ShufflingHeadView.scrollEnabled = YES;
        NSString *imagePathLeft = _bannerList[_imageCount-1];
//        BannerModel *modelLeft = _bannerList[_imageCount-1];
        [self.leftImageView sd_setImageWithURL:[NSURL URLWithString:imagePathLeft] placeholderImage:nil options:SDWebImageRetryFailed|SDWebImageRefreshCached];
        
        NSString *imagePathCenter = _bannerList[0];
//        BannerModel *modelCenter = _bannerList[0];
        [self.centerImageView sd_setImageWithURL:[NSURL URLWithString:imagePathCenter] placeholderImage:nil options:SDWebImageRetryFailed|SDWebImageRefreshCached];
        
        NSString *imagePathRight = _bannerList[1];
//        BannerModel *modelRight = _bannerList[1];
        [self.rightImageView sd_setImageWithURL:[NSURL URLWithString:imagePathRight] placeholderImage:nil options:SDWebImageRetryFailed|SDWebImageRefreshCached];
    }
    _currentImageIndex = 0;
    //设置当前页
    self.pageControl.currentPage = _currentImageIndex;
}


#pragma mark --加载轮播图数据
- (void)setBannerList:(NSArray *)bannerList {
    
    NSMutableArray *temp = [NSMutableArray new];
    [bannerList enumerateObjectsUsingBlock:^(NSString * obj, NSUInteger idx, BOOL * stop) {
        NSString *urlString;
        if ([obj isKindOfClass:[NSString class]]) {
            urlString = obj;
        } else if ([obj isKindOfClass:[NSURL class]]) {
            NSURL *url = (NSURL *)obj;
            urlString = [url absoluteString];
        }
        if (urlString) {
            [temp addObject:urlString];
        }
    }];
    
    _bannerList = [temp copy];
    _imageCount = _bannerList.count;
    self.pageControl.numberOfPages = _bannerList.count;
    [self setBannerDefaultImage];
    
    if (bannerList.count > 1) {
        [self startTimer];
    } else {
        [self stopTimer];
    }
}


#pragma mark --点击轮播图
- (void)tapGesClick:(id)send {
    if (_bannerList.count>0) {
        if (_bannerImgBlock) {
//            BannerModel *model = _bannerList[_currentImageIndex];
            _bannerImgBlock(@"",@"",_currentImageIndex);
        }
    }
}

#pragma mark 滚动停止事件
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGPoint offset=scrollView.contentOffset;
    if (scrollView == _ShufflingHeadView) {
        if (_imageCount == 0) {
            return;
        }
        
        if (offset.x>kScreen_Width) { //you hua
            _currentImageIndex=(_currentImageIndex+1)%_imageCount;
        }else if (offset.x<kScreen_Width){  //zuo hua
            _currentImageIndex=(_currentImageIndex+_imageCount-1)%_imageCount;
            
        }
        //重新加载图片
        [self reloadImage];
        //移动到中间
        [self.ShufflingHeadView setContentOffset:CGPointMake(kScreen_Width, 0) animated:NO];
        //设置分页
        self.pageControl.currentPage=_currentImageIndex;
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if (scrollView == _ShufflingHeadView) {
        //重新加载图片
        [self reloadImage];
        [_ShufflingHeadView setContentOffset:CGPointMake(kScreen_Width, 0) animated:NO];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (scrollView == _ShufflingHeadView) {
        //取消定时器
        [self stopTimer];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (scrollView == _ShufflingHeadView && (_bannerList.count > 1)) {
        [self startTimer];
    }
}

#pragma mark 重新加载图片
- (void)reloadImage {
    if (_bannerList.count==0) {
        return;
    }
    static NSInteger leftImageIndex,rightImageIndex;
    NSString *imagepathCenter = _bannerList[_currentImageIndex];
//    BannerModel *modelCenter = _bannerList[_currentImageIndex];
    [_centerImageView sd_setImageWithURL:[NSURL URLWithString:imagepathCenter] placeholderImage:nil options:SDWebImageRetryFailed|SDWebImageRefreshCached];
    //重新设置左右图片
    leftImageIndex=(_currentImageIndex+_imageCount-1)%_imageCount;
    NSString *imagepathLeft = _bannerList[leftImageIndex];
//    BannerModel *modelLeft = _bannerList[leftImageIndex];
    [_leftImageView sd_setImageWithURL:[NSURL URLWithString:imagepathLeft] placeholderImage:nil options:SDWebImageRetryFailed|SDWebImageRefreshCached];
    
    rightImageIndex=(_currentImageIndex+1)%_imageCount;
    NSString *imagepathRight = _bannerList[rightImageIndex];
//    BannerModel *modelRight = _bannerList[rightImageIndex];
    [_rightImageView sd_setImageWithURL:[NSURL URLWithString:imagepathRight] placeholderImage:nil options:SDWebImageRetryFailed|SDWebImageRefreshCached];
    
}

- (void)bannerTimer {
    _currentImageIndex =  _pageControl.currentPage;
    _currentImageIndex ++;
    _currentImageIndex = _currentImageIndex > _imageCount - 1 ? 0 : _currentImageIndex;
    
    [_ShufflingHeadView setContentOffset:CGPointMake(kScreen_Width * 2, 0) animated:YES];
    
    _pageControl.currentPage = _currentImageIndex;
    
}

- (void)startTimer {
    if (!bannerTimer) {
        bannerTimer =  [NSTimer scheduledTimerWithTimeInterval:5.f target:self selector:@selector(bannerTimer) userInfo:nil repeats:YES];
    }
}

- (void)stopTimer {
    if (bannerTimer) {
        //取消定时器
        [bannerTimer invalidate];
        bannerTimer = nil;
    }
}

- (void)dealloc {
    [self stopTimer];
}



@end
