//
//  ViewController.m
//  轮播图test
//
//  Created by 张俊平 on 2017/2/26.
//  Copyright © 2017年 ZHANGJUNPING. All rights reserved.
//

#import "ViewController.h"

#define KWIDTH [UIScreen mainScreen].bounds.size.width

@interface ViewController ()<UIScrollViewDelegate>

@property (nonatomic, strong)UIScrollView *scrollView;

@property (nonatomic, retain)NSTimer* rotateTimer;  //让视图自动切换

@property (nonatomic, strong)UIPageControl *pageControl;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //    创建滚动视图
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 100, KWIDTH, 250)];
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    //    将弹簧效果关闭
    self.scrollView.bounces = NO;
    [self.view addSubview:self.scrollView];
    
    //    在最前面添加冗余的最后一张图片
    UIImageView *firstImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, KWIDTH, 250)];
    firstImage.image = [UIImage imageNamed:@"4.jpg"];
    [self.scrollView addSubview:firstImage];
    //    添加四张图片
    for (int i = 1; i <= 4; i++) {
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(i* KWIDTH, 0, KWIDTH, 250)];
        imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%d.jpg", i]];
        [self.scrollView addSubview:imageView];
    }
    //    在最后的位置添加冗余的第一张图片
    UIImageView *lastImage = [[UIImageView alloc] initWithFrame:CGRectMake(5 * KWIDTH, 0, KWIDTH, 250)];
    lastImage.image = [UIImage imageNamed:@"1.jpg"];
    [self.scrollView addSubview:lastImage];
    
    self.scrollView.contentSize = CGSizeMake(KWIDTH * 6, 0);
    
    //   偏移到真正的第一页
    self.scrollView.contentOffset = CGPointMake(KWIDTH * 1, 0);
    
    
    self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, 300, KWIDTH, 50)];
    //    设置页数
    self.pageControl.numberOfPages = 4;
    //    设置当前页数
    self.pageControl.currentPage = 0;
    [self.view addSubview:self.pageControl];
    //    设置颜色
    //    未选中页数的颜色
    self.pageControl.pageIndicatorTintColor = [UIColor grayColor];
    //    选中页数的颜色
    self.pageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
    
    //    将pageControl于scrollView建立联系
    //    1.pageControl改变，通过pageControl的valueChanged事件处理scrollView
    //    添加事件
    [self.pageControl addTarget:self action:@selector(pageControlAction:) forControlEvents:UIControlEventValueChanged];
    
    //    2.scrollView改变偏移量时，pageControl需要跟着变动
    //    设置代理，根据代理方法处理偏移量的变化
    self.scrollView.delegate = self;
    
    
    //    开启定时器
    self.rotateTimer = [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
}

- (void)timerAction {
    //    得到当前的偏移量
    CGPoint offSet = self.scrollView.contentOffset;
    
    //    加一个单位的偏移量
    offSet.x = offSet.x + KWIDTH;
    //    加动画
    //    self.scrollView.contentOffset = offSet;
    [self.scrollView setContentOffset:offSet animated:YES];
    
}

- (void)pageControlAction:(UIPageControl *)sender {
    //    得到当前在第几页,
    //    由于第0位有一张冗余的图片，所以需要＋1
    NSInteger page = sender.currentPage + 1;
    
    //    让scrollView滚动到对应的页数
    self.scrollView.contentOffset = CGPointMake(page * KWIDTH, 0);
    
}
#pragma mark -- 滚动视图的代理方法
//开始拖拽的代理方法，在此方法中暂停定时器。

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    NSLog(@"正在拖拽视图，所以需要将自动播放暂停掉");
    [self.rotateTimer setFireDate:[NSDate distantFuture]];
    
}

//视图静止时（没有人在拖拽），开启定时器，让自动轮播
//停止减速时，计算当前页数
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    [self.rotateTimer setFireDate:[NSDate dateWithTimeInterval:1.5 sinceDate:[NSDate date]]];
    
    NSLog(@"contentOffSet %@", NSStringFromCGPoint(scrollView.contentOffset));
    //    计算当前页数
    NSInteger page = scrollView.contentOffset.x / KWIDTH;
    
    if (page == 5) {
        //        回到真正的第一页
        self.scrollView.contentOffset = CGPointMake(1 * KWIDTH, 0);
        self.pageControl.currentPage = 0;
    }
    else if (page == 0){
        //        回到真正的最后一页
        self.scrollView.contentOffset = CGPointMake(4 * KWIDTH, 0);
        self.pageControl.currentPage = 3;
    }
    
    else {
        //        由于第0位有一张冗余的图片，需要－1
        self.pageControl.currentPage = page - 1;
    }
    
}
//    动画完成后再处理pageControl
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    
    //告诉pageControl 计算当前的位置
    NSInteger page = self.scrollView.contentOffset.x / KWIDTH;
    if (page < 5) {
        self.pageControl.currentPage = page - 1;
    }
    else {
        //如果到了最后一个位置，需要回到第一张图片
        self.pageControl.currentPage = 0;
        self.scrollView.contentOffset = CGPointMake(KWIDTH * 1, 0);
    }
    
}

@end










