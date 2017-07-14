//
//  HHFirstObj.m
//  KVOCustomImplement
//
//  Created by DoubleHH on 2017/7/12.
//  Copyright © 2017年 com.baidu.iwaimai. All rights reserved.
//

#import "HHFirstObj.h"

@implementation HHFirstObj

- (void)dealloc {
    NSLog(@"%s", __func__);
}

- (void)willChangeValueForKey:(NSString *)key {
    [super willChangeValueForKey:key];
    NSLog(@"%s", __func__);
}

- (void)didChangeValueForKey:(NSString *)key {
    [super didChangeValueForKey:key];
    NSLog(@"%s", __func__);
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    NSLog(@"%s, keypath:%@, change:%@", __func__, keyPath, change);
}

@end
