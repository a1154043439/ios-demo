//
//  ScrollViewController.m
//  demo4
//
//  Created by test on 2017/7/18.
//  Copyright © 2017年 test. All rights reserved.
//

#import "RunLoopModelViewController.h"
#import "masonry.h"
@interface RunLoopModelViewController()<UIScrollViewDelegate>
//声明对象
@property (nonatomic,strong) UIScrollView *scrollView;
@end

@implementation RunLoopModelViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // 设置导航栏
    [self _setupNavigationItem];
    
    
    // 设置子控件
    [self _setupSubViews];
}


#pragma mark - 设置导航栏
- (void)_setupNavigationItem
{
    self.title = @"RunLoopModelViewController";
}

#pragma mark - 设置子控件
- (void)_setupSubViews
{
        
        // 1.创建UIScrollView
        UIScrollView *scrollView = [[UIScrollView alloc] init];
        scrollView.frame = CGRectMake(0, 0, 250, 250); // frame中的size指UIScrollView的可视范围
        scrollView.backgroundColor = [UIColor grayColor];
        [self.view addSubview:scrollView];
        
        // 2.创建UIImageView（图片）
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.image = [UIImage imageNamed:@"2.jpg"];
        CGFloat imgW = imageView.image.size.width; // 图片的宽度
        CGFloat imgH = imageView.image.size.height; // 图片的高度
        imageView.frame = CGRectMake(0, 0, imgW, imgH);
        [scrollView addSubview:imageView];
        
        // 3.设置scrollView的属性
        
        // 设置UIScrollView的滚动范围（内容大小）
        scrollView.contentSize = imageView.image.size;
        
        // 隐藏水平滚动条
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.showsVerticalScrollIndicator = NO;
        
        // 用来记录scrollview滚动的位置
        //    scrollView.contentOffset = ;
        
        // 去掉弹簧效果
        //    scrollView.bounces = NO;
        
        // 增加额外的滚动区域（逆时针，上、左、下、右）
        // top  left  bottom  right
        scrollView.contentInset = UIEdgeInsetsMake(20, 20, 20, 20);
        
        _scrollView = scrollView;
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    btn.frame = CGRectMake(250, 250, 100, 100);
    [btn setTitle:@"添加定时器" forState:UIControlStateNormal];
     [self.view addSubview:btn];
    
    
    [btn addTarget:self action:@selector(task) forControlEvents:UIControlEventTouchUpInside];


    
    }

- (void)task{
    //先运行此行代码显示mode不同
//    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timeTask) userInfo:nil repeats:YES];
    NSTimer *countDownTimer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(timeTask) userInfo:nil repeats:YES];
    NSRunLoop *currentRunLoop = [NSRunLoop currentRunLoop];
    [currentRunLoop addTimer:countDownTimer forMode:NSRunLoopCommonModes];
}


-(void)timeTask{
    
    
    NSLog(@"定时执行任务");
}
#pragma mark -代理方法
/*
 // 返回一个放大或者缩小的视图
 - (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
 {
 
 }
 // 开始放大或者缩小
 - (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:
 (UIView *)view
 {
 
 }
 
 // 缩放结束时
 - (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale
 {
 
 }
 
 // 视图已经放大或缩小
 - (void)scrollViewDidZoom:(UIScrollView *)scrollView
 {
 NSLog(@"scrollViewDidScrollToTop");
 }
 */
/*普通滑动
 scrollViewWillBeginDragging
 2017-07-18 17:09:29.125 demo4[18400:967160] scrollViewDidScroll
 2017-07-18 17:09:29.531 demo4[18400:967160] scrollViewDidEndDragging
 快速滑动
 2017-07-18 17:11:38.371 demo4[18400:967160] scrollViewWillBeginDecelerating
 2017-07-18 17:11:38.449 demo4[18400:967160] scrollViewDidScroll
 2017-07-18 17:11:39.310 demo4[18400:967160] scrollViewDidEndDecelerating
 
 
 */

// 是否支持滑动至顶部
- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView
{
    return YES;
}

// 滑动到顶部时调用该方法
- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView
{
    NSLog(@"scrollViewDidScrollToTop");
}

// scrollView 已经滑动
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSLog(@"scrollViewDidScroll");
}

// scrollView 开始拖动
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    NSLog(@"scrollViewWillBeginDragging");
}

// scrollView 结束拖动
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    NSLog(@"scrollViewDidEndDragging");
}

// scrollView 开始减速（以下两个方法注意与以上两个方法加以区别）
- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    NSLog(@"scrollViewWillBeginDecelerating");
}

// scrollview 减速停止
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSLog(@"scrollViewDidEndDecelerating");
    
}
@end
