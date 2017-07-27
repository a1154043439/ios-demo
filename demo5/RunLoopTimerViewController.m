//
//  RunLoopTimerViewController.m
//  demo5
//
//  Created by test on 2017/7/27.
//  Copyright © 2017年 test. All rights reserved.
//
#import "RunLoopTimerViewController.h"
@interface RunLoopTimerViewController()

@end

@implementation RunLoopTimerViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    //设置按钮文字标题
    [[super btn] setTitle:@"异步scheduled添加定时任务" forState:UIControlStateNormal];
    [super.btn1 setTitle:@"主线程scheduled添加定时任务" forState:UIControlStateNormal];

}


#pragma mark - 设置导航栏
- (void)_setupNavigationItem
{
    self.title = @"RunLoopTimerViewController";
}



- (void)task1 {
    
//
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      
    NSTimer *myTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timeTask) userInfo:nil repeats:YES];
        NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
        [runLoop run];
        [myTimer fire];
        
    });
    
    
}
- (void)task2 {
    
   [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(timeTask) userInfo:nil repeats:YES];
    
}


-(void)timeTask{
    
  
    NSLog(@"定时执行任务");
}






@end


