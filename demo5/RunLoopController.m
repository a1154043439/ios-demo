//
//  RunLoopController.m
//  demo5
//
//  Created by test on 2017/7/26.
//  Copyright © 2017年 test. All rights reserved.
//
#import "RunLoopController.h"
#import "masonry.h"
@interface RunLoopController()
//这是一个RunLoopDemo,主要是测试RunLoop的用法
@property (strong,nonatomic)NSThread *thread; //使用Strong属性
@property (nonatomic , strong) UIButton * btn;
@property (nonatomic , strong) UIButton * btn1;
@end

@implementation RunLoopController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // 设置导航栏
    [self _setupNavigationItem];
    
    
    // 设置子控件
    [self _setupSubViews];
    
    //创建自定义的子线程
    //self.thread = [[NSThread alloc]initWithTarget:self selector:@selector(threadMethod) object:nil];
    //[self.thread start]; //启动子线程
}


#pragma mark - 设置导航栏
- (void)_setupNavigationItem
{
    self.title = @"RunLoopDemo";
}

#pragma mark - 设置子控件
- (void)_setupSubViews
{
    self.btn = [UIButton buttonWithType:UIButtonTypeSystem];
      self.btn1 = [UIButton buttonWithType:UIButtonTypeSystem];

    
   
    self.btn.backgroundColor = [UIColor redColor];
    self.btn1.backgroundColor = [UIColor blueColor];
    /*
     Type:
     UIButtonTypeCustom = 0, // 自定义类型
     UIButtonTypeSystem NS_ENUM_AVAILABLE_IOS(7_0),  // 系统类型
     UIButtonTypeDetailDisclosure,//详细描述样式，圆圈中间加个i
     UIButtonTypeInfoLight, //浅色的详细描述样式
     UIButtonTypeInfoDark,//深色的详细描述样式
     UIButtonTypeContactAdd,//加号样式
     UIButtonTypeRoundedRect = UIButtonTypeSystem,   // 圆角矩形
     */
    
    //设置按钮位置和尺寸
    self.btn.frame = CGRectMake(100, 100, 300, 50);
    //设置按钮文字颜色
    [self.btn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    
    //设置背景图片（需要注意按钮类型最好为自定义，系统类型的会使图片变暗）
    //    [self.btn setImage:[UIImage imageNamed:@"tupian"] forState:UIControlStateNormal];
    
    //设置按钮文字大小
    self.btn.titleLabel.font = [UIFont systemFontOfSize:20];
     self.btn1.titleLabel.font = [UIFont systemFontOfSize:20];
    
    //设置按钮文字标题
    [self.btn setTitle:@"为子线程runloop添加observer" forState:UIControlStateNormal];
    [self.btn1 setTitle:@"为子线程runloop添加timer" forState:UIControlStateNormal];
    
    [self.btn addTarget:self action:@selector(addRunLoopObserver) forControlEvents:UIControlEventTouchUpInside];
    [self.btn1 addTarget:self action:@selector(addTimer) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.btn];
    [self.view addSubview:self.btn1];
    //autolayout
    [self.btn  mas_makeConstraints:^(MASConstraintMaker *make) {
      make.centerX.mas_equalTo(self.view.mas_centerX);
      make.centerY.mas_equalTo(self.view.mas_centerY);
        
    } ];
    
    [self.btn1  mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.btn.mas_bottom).with.offset(20);
        make.centerX.equalTo(self.btn.mas_centerX);
        make.width.mas_equalTo(self.btn.mas_width);
        make.height.mas_equalTo(self.btn.mas_height);
        
    } ];
}


#pragma mark -- 测试一：子线程Selector源的启动


#pragma mark - NSRunLoop简介 -

/**
 - CFRunLoopRef是在CoreFoundation框架中的，它的内部API以及实现，都是纯C语言编写，这些API都是
 线程安全的。
 - NSRunLoop是基于CFRunLoopRef的封装，它提供了面向对象的API，但是这些API不是线程安全的。
 
 NSRunloop和CFRunLoopRef都是RunLoop对象，它们的区别是：
 - 这两个对象的地址不同，因为他们的对象来自于完全不同的类。
 - CFRunLoop可以调用getCfRunLoop方法，将NSRunLoop转化为CFRunLoop。
 
 */
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    //
    NSRunLoop *curRunLoop = [NSRunLoop currentRunLoop];
    NSLog(@"1. 获取当前线程对应的currentRunLoop对象%@----%p", [NSThread currentThread], curRunLoop);
    //
    NSRunLoop *mainRunLoop = [NSRunLoop mainRunLoop];
    NSLog(@"2. 获取主线程对应的mainRunLoop对象%@----%p", [NSThread currentThread], mainRunLoop);
    
    /* Core Foundation */
    //
    CFRunLoopRef cfCurRunLoop = CFRunLoopGetCurrent();
    NSLog(@" 1. 获得当前线程的CFRunLoopGetCurrent对象%@----%p", [NSThread currentThread], cfCurRunLoop);
    //
    CFRunLoopRef cfMainRunLoop = CFRunLoopGetMain();
    NSLog(@"2. 获得主线程的CFRunLoopGetMain对象%@----%p", [NSThread currentThread], cfMainRunLoop);
    
    //
    NSLog(@"NSRunLoop转换为CFRunLoopRef%@----%p----%p", [NSThread currentThread], cfMainRunLoop, mainRunLoop.getCFRunLoop);
    
    // 开启子线程，执行task方法。
    [NSThread detachNewThreadSelector:@selector(task) toTarget:self withObject:nil];
}

- (void)task {
    
    /* 子线程和RunLoop
     1. 每一个子线程，都对应一个自己的RunLoop。
     2. 主线程的RunLoop在程序运行的时候就已经创建了，而子线程的RunLoop则需要手动开启。
     3. [NSRunLoop currentRunLoop]，此方法会开启一个新的RunLoop。
     4. RunLoop需要执行run方法来开启，但如果RunLoop中没有任何任务，就会关闭。
     */
    
    //
    NSLog(@"子线程当前RunLoop%@----%p----%p", [NSThread currentThread], [NSRunLoop currentRunLoop], [NSRunLoop mainRunLoop]);
    
    // 2. 开启一个新的RunLoop
    [[NSRunLoop currentRunLoop] run];
}

/**
 观察者可以观察到RunLoop不同的运行状态
 通过判断RunLoop的运行状态，可以执行一些操作。
 */
- (void)addRunLoopObserver {
    /**
     1. 创建监听者
     CFAllocatorRef allocator 分配存储空间
     CFOptionFlags activities 要监听哪个状态，kCFRunLoopAllActivities监听所有状态。
     Boolean repeats 是否持续监听RunLoop的状态
     CFIndex order 优先级，默认为0。
     Block activity RunLoop当前的状态
     */
    CFRunLoopObserverRef observer = CFRunLoopObserverCreateWithHandler(kCFAllocatorDefault, kCFRunLoopAllActivities, YES, 0, ^(CFRunLoopObserverRef observer, CFRunLoopActivity activity) {
        
        /**
         kCFRunLoopEntry = (1UL << 0),          进入工作
         kCFRunLoopBeforeTimers = (1UL << 1),   即将处理Timers事件
         kCFRunLoopBeforeSources = (1UL << 2),  即将处理Source事件
         kCFRunLoopBeforeWaiting = (1UL << 5),  即将休眠
         kCFRunLoopAfterWaiting = (1UL << 6),   被唤醒
         kCFRunLoopExit = (1UL << 7),           退出RunLoop
         kCFRunLoopAllActivities = 0x0FFFFFFFU  监听所有事件
         */
        // 当activity处于什么状态的时候，调用一次。
        switch (activity) {
            case kCFRunLoopEntry:
                NSLog(@"进入");
                break;
            case kCFRunLoopBeforeTimers:
                NSLog(@"即将处理Timer事件");
                break;
            case kCFRunLoopBeforeSources:
                NSLog(@"即将处理Source事件");
                break;
            case kCFRunLoopBeforeWaiting:
                NSLog(@"即将休眠");
                break;
            case kCFRunLoopAfterWaiting:
                NSLog(@"被唤醒");
                break;
            case kCFRunLoopExit:
                NSLog(@"退出RunLoop");
                break;
            default:
                break;
        }
    });
    
    /**
     2. 给对应的RunLoop添加一个监听者，并确定监听的是哪种运行模式。
     CFRunLoopRef rl 要添加监听者的RunLoop
     CFRunLoopObserverRef observer 要添加的监听者
     CFStringRef mode RunLoop的运行模式
     */
    CFRunLoopAddObserver(CFRunLoopGetCurrent(), observer, kCFRunLoopDefaultMode);
}


- (void)addTimer {

NSTimer *timer = [NSTimer timerWithTimeInterval:2.0 target:self selector:@selector(run) userInfo:nil repeats:YES];

// 将定时器添加到当前RunLoop的NSDefaultRunLoopMode下
[[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
}

- (void)run
{
    NSLog(@"---run");
}


@end


