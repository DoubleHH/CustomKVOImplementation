//
//  NSObject+HHKVO.m
//  KVOCustomImplement
//
//  Created by DoubleHH on 2017/7/14.
//  Copyright © 2017年 com.baidu.iwaimai. All rights reserved.
//

#import "NSObject+HHKVO.h"
#import <objc/runtime.h>
#import "HHKVOInfo.h"
#import "HHKVORepalcement.h"

static HHKVORepalcement *replacementClassForOriginalClass(Class originalClass) {
    static NSMutableDictionary *sReplacementClassMap;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sReplacementClassMap = [NSMutableDictionary dictionary];
    });
    NSString *key = NSStringFromClass(originalClass);
    HHKVORepalcement *replacement = [sReplacementClassMap objectForKey:key];
    if (!replacement) {
        replacement = [[HHKVORepalcement alloc] initWithOriginalClass:originalClass];
        [sReplacementClassMap setObject:replacement forKey:key];
    }
    return replacement;
}

@implementation NSObject (HHKVO)

- (void)hh_addObserver:(NSObject *)anObserver
                forKey:(NSString *)key {
    if (!key.length ||
        ![anObserver respondsToSelector:@selector(observeValueForKeyPath:ofObject:change:context:)]) {
        return;
    }
    HHKVORepalcement *replacement = replacementClassForOriginalClass(self.class);
    HHKVOInfo *kvoInfo = self.hh_kvoInfo;
    if (!kvoInfo) {
        kvoInfo = [[HHKVOInfo alloc] initWithInstance:self];
        self.hh_kvoInfo = kvoInfo;
        // Replace self's isa, then objc_msgsend will search method(setter) in 'replacedClass'
        object_setClass(self, replacement.replacedClass);
    }
    [replacement overrideKey:key];
    [kvoInfo addObserver:anObserver forKey:key];
}

- (void)hh_removeObserver:(NSObject *)anObserver
                   forKey:(NSString *)key {
    if (!key.length ||
        ![anObserver respondsToSelector:@selector(observeValueForKeyPath:ofObject:change:context:)]) {
        return;
    }
    HHKVOInfo *kvoInfo = self.hh_kvoInfo;
    if (!kvoInfo) {
        return;
    }
    [kvoInfo removeObserver:anObserver forKey:key];
}

@end
