//
//  RunLoopMonitor.h
//  RunLoopDemo
//
//  Created by 阿炮 on 2023/6/4.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RunLoopMonitor : NSObject

+ (instancetype)sharedInstance;
- (void)startMonitoring;

@end

NS_ASSUME_NONNULL_END
