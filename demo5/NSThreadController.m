//
//  NSThreadController.m
//  demo5
//
//  Created by test on 2017/7/27.
//  Copyright © 2017年 test. All rights reserved.
//

#import "NSThreadController.h"
#import <pthread.h>

@interface NSThreadController ()

@property (nonatomic, strong) NSThread *thread;

@property (nonatomic) NSUInteger ticketCount;

@property (nonatomic, strong) NSThread *window1;

@property (nonatomic, strong) NSThread *window2;

@end

@implementation NSThreadController

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - iOS多线程：-

/**
 pthread_create(&thread, NULL, run, NULL); 中各项参数含义：
 第一个参数&thread是线程对象
 第二个和第四个是线程属性，可赋值NULL
 第三个run表示指向函数的指针（run对应函数里是需要在新线程中执行的任务）
 
 */
- (void)pthread {
    pthread_t thread;
    pthread_create(&thread, NULL, run, NULL);
}

// 新线程调用方法，里边为需要执行的任务
void* run(void *param) {
    NSLog(@"%@", [NSThread currentThread]);
    return NULL;
}

/**
 先创建线程，再启动线程
 */
- (void)createThread1 {
    NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(task) object:nil];
    [thread start];
}

/**
 创建线程后自动启动线程
 */
- (void)createThread2 {
    [NSThread detachNewThreadSelector:@selector(task) toTarget:self withObject:nil];
}

/**
 隐式创建并启动线程
 */
- (void)createThread3 {
    [self performSelectorInBackground:@selector(task) withObject:nil];
}

- (void)task {
    for (int i = 0; i < 100; ++i){
        NSLog(@"%d----%@", i, [NSThread currentThread]);
    }
}


/**
 设置线程的优先级，qualityOfService属性必须在线程启动之前设置，启动之后将无法再设置。
 */
- (void)createThread4 {
    self.thread = [[NSThread alloc] initWithTarget:self selector:@selector(threadMain) object:nil];
    self.thread.qualityOfService = NSQualityOfServiceDefault;
    [self.thread start];
}

/**
 由于线程的创建和销毁非常消耗性能，大多情况下，我们需要复用一个长期运行的线程来执行任务。
 
 在线程启动之后会首先执行-threadMain，正常情况下threadMain方法执行结束之后，线程就会退出。为了
 线程可以长期复用接收消息，我们需要在threadMain中给thread添加runloop。
 
 */
- (void)threadMain {
    [[NSThread currentThread] setName:@"MyThread"];
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    [runLoop addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
    while (![[NSThread currentThread] isCancelled]) {
        [runLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
    }
}

- (void)threadTask1 {
    for (int i = 0; i < 10000; ++i){
        NSLog(@"任务1 %d----%@", i, [NSThread currentThread]);
        if (100 == i) {
            [self cancelThread];
        }
    }
}

- (void)threadTask2 {
    for (int i = 0; i < 10000; ++i){
        NSLog(@"任务2 %d----%@", i, [NSThread currentThread]);
    }
}

/**
 当我们想要结束线程的时候，我们可以使用CFRunLoopStop()配合-cancel来结束线程。
 不过这个方法必须在self.thread线程下调用。如果当前是主线程。可以perform到self.thread下调用这
 个方法结束线程。
 */
- (void)cancelThread {
    [[NSThread currentThread] cancel];
    CFRunLoopStop(CFRunLoopGetCurrent());
}

/**
 添加两个任务来测试取消线程的效果，并且要等到第一个任务完成后，才进行下一个任务，如果用两个线程测
 试，就不需要这样，具体可以参考下一个例子。
 */
- (void)runTasks {
    [self performSelector:@selector(threadTask1) onThread:self.thread withObject:nil waitUntilDone:YES];
    [self performSelector:@selector(threadTask2) onThread:self.thread withObject:nil waitUntilDone:NO];
}

#pragma mark - iOS多线程篇：NSThread -

/**
 情景：某演唱会门票发售，在广州和北京均开设窗口进行销售。
 */
- (void)createSaleTicketWindow {
    
    // 先监听线程退出的通知，以便知道线程什么时候退出
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(threadExitNotice) name:NSThreadWillExitNotification object:nil];
    
    // 设置演唱会的门票数量
    _ticketCount = 50;
    
    // 新建两个子线程（代表两个窗口同时销售门票）
    self.window1 = [[NSThread alloc]initWithTarget:self selector:@selector(createRunLoop1) object:nil];
    [self.window1 start];
    
    self.window2 = [[NSThread alloc]initWithTarget:self selector:@selector(createRunLoop2) object:nil];
    [self.window2 start];
}

/**
 线程的持续运行和退出
 我们注意到，线程启动后，执行saleTicket完毕后就马上退出了，怎样能让线程一直运行呢（窗口一直开放，
 可以随时指派其卖演唱会的门票的任务），答案就是给线程加上runLoop。

 */
- (void)createRunLoop1 {
    [[NSThread currentThread] setName:@"北京售票窗口"];
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    [runLoop addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
    while (![[NSThread currentThread] isCancelled]) {
        [runLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
    }
}

- (void)createRunLoop2 {
    [[NSThread currentThread] setName:@"广州售票窗口"];
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    [runLoop addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
    while (![[NSThread currentThread] isCancelled]) {
        [runLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
    }
}

- (void)threadExitNotice {
    NSLog(@"%@ will exit", [NSThread currentThread]);
}

/**
 - 线程启动后，执行saleTicket，执行完毕后就会退出，为了模拟持续售票的过程，我们需要给它加一个循环。
 
 - 让线程完成任务（售票）后自行退出

 */
- (void)saleTicket {
    while (1) {
        @synchronized(self) {
            // 如果还有票，继续售卖
            if (_ticketCount > 0) {
                _ticketCount --;
                NSLog(@"%@", [NSString stringWithFormat:@"剩余票数：%ld 窗口：%@", _ticketCount, [NSThread currentThread].name]);
                [NSThread sleepForTimeInterval:0.2];
            }
            // 如果已卖完，关闭售票窗口
            else {
                if ([NSThread currentThread].isCancelled) {
                    break;
                } else {
                    NSLog(@"%@ 票已售完", [NSThread currentThread].name);
                    // 给当前线程标记为取消状态
                    [[NSThread currentThread] cancel];
                    // 停止当前线程的runLoop
                    CFRunLoopStop(CFRunLoopGetCurrent());
                }
            }
        }
    }
}

- (void)startSaleTicket {
    [self performSelector:@selector(saleTicket) onThread:self.window1 withObject:nil waitUntilDone:NO];
    [self performSelector:@selector(saleTicket) onThread:self.window2 withObject:nil waitUntilDone:NO];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self createSaleTicketWindow];
    [self startSaleTicket];
}

@end
