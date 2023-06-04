//
//  RunLoopMonitor.m
//  RunLoopDemo
//
//  Created by 阿炮 on 2023/6/4.
//

#import "RunLoopMonitor.h"

@interface RunLoopMonitor()

@property (nonatomic, assign) NSInteger checkCount;

@property (nonatomic, assign) BOOL isMonitoring;

@property (nonatomic, assign) CFRunLoopActivity currentActivity;
@property (nonatomic, assign) CFRunLoopObserverRef observer;

@property (nonatomic, strong) dispatch_semaphore_t semphore;
@property (nonatomic, strong) dispatch_semaphore_t eventSemphore;

@end

static NSTimeInterval lxd_restore_interval = 5;
static NSTimeInterval lxd_time_out_interval = 1;
static int64_t lxd_wait_interval = 200 * NSEC_PER_MSEC;

@implementation RunLoopMonitor

-(void)dealloc{
    NSLog(@"%s", __func__);
    [self stopMonitoring];
}

static RunLoopMonitor *_instance = nil;

+(instancetype)sharedInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[super allocWithZone:NULL] init];
        //不是使用alloc方法，而是调用[[super allocWithZone:NULL] init]
        //已经重载allocWithZone基本的对象分配方法，所以要借用父类（NSObject）的功能来帮助出处理底层内存分配的杂物
        [_instance commonInit];
    });
    return _instance;
}
/*
 当static关键字修饰局部变量时，只会初始化一次且在程序中只有一份内存
 allocWithZone mutablecopyWithZone 这个类遵守<NSCopying,NSMutableCopying>协议
 如果_instance = [self alloc] init];创建的话，
 将会和-(id) allocWithZone:(struct _NSZone *)zone产生死锁。
 dispatch_once中的onceToken线程被阻塞，等待onceToken值改变。
 当用alloc创建对象、以及对对象进行copy mutableCopy也是返回唯一实例
 */

+ (instancetype)allocWithZone: (struct _NSZone *)zone {
    return [self sharedInstance];
}

//  对对象使用copy也是返回唯一实例
-(id)copyWithZone:(NSZone *)zone {
    return [RunLoopMonitor sharedInstance];
}

//  对对象使用mutablecopy也是返回唯一实例
-(id)mutableCopyWithZone:(NSZone *)zone {
    return [RunLoopMonitor sharedInstance];;
}

//  监听runloop状态after waiting 和 before sources之间
static inline dispatch_queue_t monitor_queue(void){
    static dispatch_queue_t monitor_queue;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        monitor_queue = dispatch_queue_create("com.sindrilin.monitor_queue", NULL);
    });
    return monitor_queue;
}

- (void)commonInit{
    _isMonitoring = true;
//    [self semaphoreaTest];
}

- (void)semaphoreaTest {
    NSLog(@"semaphore---begin");
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
   
    dispatch_async(queue, ^{
        [NSThread sleepForTimeInterval:2];
        NSLog(@"测试测试测试测试测试测试");
        dispatch_semaphore_signal(semaphore);
    });
//    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
//    NSLog(@"semaphore---end");
}

- (void)stopMonitoring{
    if (_isMonitoring) _isMonitoring = YES;
    
    // 释放对象
    CFRunLoopRemoveObserver(CFRunLoopGetMain(), _observer, kCFRunLoopCommonModes);
    CFRelease(_observer);
    _observer = nil;
}

//  启动RunLoop监控
- (void)startMonitoring{

    // 创建一个RunLoop观察者，并设置回调函数和观察者上下文
    CFRunLoopObserverContext context ={0, (__bridge void *)(self), NULL, NULL, NULL};
    _observer = CFRunLoopObserverCreate(kCFAllocatorDefault, kCFRunLoopAllActivities, YES, 0, &runLoopObserverCallback, &context);

    // 将观察者添加到主线程的RunLoop
    CFRunLoopAddObserver(CFRunLoopGetMain(), _observer, kCFRunLoopCommonModes);
    
    // 在子线程中国呢启动一个定时器，每隔0.5秒检查一次主线程的RunLoop状态
//    NSTimer *timer = [NSTimer timerWithTimeInterval:0.5 target:self selector:@selector(checkMainThreadRunLoopStatus)  userInfo:nil repeats:YES];
//    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
//    [[NSRunLoop currentRunLoop] run];
    
    dispatch_async(monitor_queue(), ^{
        while (_isMonitoring) {
//            if (self.lastActivity == kCFRunLoopBeforeWaiting){
//
//            }else{
//
//            }
        }
    });
}


// RunLoop观察者的回调函数，用于记录RunLoop的活动状态
void runLoopObserverCallback(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info){
    RunLoopMonitor *object = (__bridge  RunLoopMonitor *)info;
//#if LOG_RUNLOOP_ACTIVITY
//    switch (activity) {
//        case kCFRunLoopEntry:
//            //  进入Runloop
//            NSLog(@"runloop entry");
//            break;
//
//        case kCFRunLoopExit:
//            //  退出Runloop
//            NSLog(@"runloop exit");
//            break;
//
//        case kCFRunLoopAfterWaiting:
//            //  唤醒
//            NSLog(@"runloop after waiting");
//            break;
//
//        case kCFRunLoopBeforeTimers:
//            //  处理Timer事件
//            NSLog(@"runloop before timers");
//            break;
//
//        case kCFRunLoopBeforeSources:
//            //  处理Source事件
//            NSLog(@"runloop before sources");
//            break;
//
//        case kCFRunLoopBeforeWaiting:
//            //  进入休眠
//            NSLog(@"runloop before waiting");
//            break;
//
//        default:
//            break;
//    }
//#endif
    object.currentActivity = activity;
}

// 在定时器回调方法中， 检查主线程的RunLoop状态
-(void)checkMainThreadRunLoopStatus{
    // 如果RunLoop的活动状态为kCFRunLoopBeforeSources或kCFRunLoopAfterWaiting，则增加检查计数
    if (self.currentActivity == kCFRunLoopBeforeSources || self.currentActivity == kCFRunLoopAfterWaiting){
        self.checkCount += 1;
        //如果连续5次检查都没有发生状态变化，认为发生了卡顿
        if(self.checkCount > 5){
            NSLog(@"主线程出现卡顿");
            self.checkCount= 0;
        }
    }else{
        self.checkCount = 0;
    }
}


@end
