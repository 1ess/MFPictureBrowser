
//  Copyright © 2018年 GodzzZZZ. All rights reserved.

#import "MFRunLoopDistribution.h"
#import <objc/runtime.h>

@interface MFRunLoopDistribution ()
@property (nonatomic, strong) NSMutableArray *tasks;
@property (nonatomic, strong) NSMutableArray *tasksKeys;
@property (nonatomic, strong) NSTimer *timer;
@end

@implementation MFRunLoopDistribution
- (void)removeAllTasks {
    [self.tasks removeAllObjects];
    [self.tasksKeys removeAllObjects];
}

- (void)addTask:(MFRunLoopDistributionUnit)unit withKey:(id)key{
    [self.tasks addObject:unit];
    [self.tasksKeys addObject:key];
}

- (void)_timerFiredMethod:(NSTimer *)timer {
    //We do nothing here
}

- (instancetype)init {
    if ((self = [super init])) {
        _tasks = [NSMutableArray array];
        _tasksKeys = [NSMutableArray array];
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(_timerFiredMethod:) userInfo:nil repeats:YES];
    }
    return self;
}

+ (instancetype)sharedRunLoopDistribution {
    static MFRunLoopDistribution *singleton;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        singleton = [[self alloc] init];
        [self _registerRunLoopDistributionAsMainRunloopObserver:singleton];
    });
    return singleton;
}

+ (void)_registerRunLoopDistributionAsMainRunloopObserver:(MFRunLoopDistribution *)runLoopDistribution {
    static CFRunLoopObserverRef defaultModeObserver;
    _registerObserver(kCFRunLoopBeforeWaiting, defaultModeObserver, NSIntegerMax - 999, kCFRunLoopDefaultMode, (__bridge void *)runLoopDistribution, &_defaultModeRunLoopWorkDistributionCallback);
}

static void _registerObserver(CFOptionFlags activities, CFRunLoopObserverRef observer, CFIndex order, CFStringRef mode, void *info, CFRunLoopObserverCallBack callback) {
    CFRunLoopRef runLoop = CFRunLoopGetCurrent();
    CFRunLoopObserverContext context = {
        0,
        info,
        &CFRetain,
        &CFRelease,
        NULL
    };
    observer = CFRunLoopObserverCreate(NULL,
                                       activities,
                                       YES,
                                       order,
                                       callback,
                                       &context);
    CFRunLoopAddObserver(runLoop, observer, mode);
    CFRelease(observer);
}

static void _runLoopWorkDistributionCallback(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info) {
    MFRunLoopDistribution *runLoopWorkDistribution = (__bridge MFRunLoopDistribution *)info;
    if (runLoopWorkDistribution.tasks.count == 0) {
        return;
    }
    BOOL result = NO;
    while (result == NO && runLoopWorkDistribution.tasks.count) {
        MFRunLoopDistributionUnit unit  = runLoopWorkDistribution.tasks.firstObject;
        result = unit();
        [runLoopWorkDistribution.tasks removeObjectAtIndex:0];
        [runLoopWorkDistribution.tasksKeys removeObjectAtIndex:0];
    }
}

static void _defaultModeRunLoopWorkDistributionCallback(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info) {
    _runLoopWorkDistributionCallback(observer, activity, info);
}
@end
