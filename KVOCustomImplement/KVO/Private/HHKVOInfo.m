//
//  HHKVOInfo.m
//  KVOCustomImplement
//
//  Created by DoubleHH on 2017/7/14.
//  Copyright © 2017年 com.baidu.iwaimai. All rights reserved.
//

#import "HHKVOInfo.h"
#import <objc/runtime.h>

@interface HHKVOKeyInfo : NSObject {
    NSString *_key;
    NSMutableDictionary *_change;
    NSPointerArray *_observations;
}

- (instancetype)initWithKey:(NSString *)key;
- (BOOL)containsObserver:(id)observer;
- (void)addObserver:(id)observer;
- (void)removeObserver:(id)observer;
- (void)notify;
- (void)updateNewValue:(id)newValue;
- (void)updateOldValue:(id)oldValue;

@end

@implementation HHKVOInfo {
    NSMutableDictionary *_keyMap;
    __weak NSObject *_instance;
}

- (instancetype)initWithInstance:(id)instance {
    self = [super init];
    if (self) {
        _instance = instance;
        _keyMap = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)addObserver:(NSObject *)anObserver
             forKey:(NSString *)key {
    HHKVOKeyInfo *keyInfo = [_keyMap objectForKey:key];
    if (!keyInfo) {
        keyInfo = [[HHKVOKeyInfo alloc] initWithKey:key];
        [_keyMap setObject:keyInfo forKey:key];
    }
    if ([keyInfo containsObserver:anObserver]) {
        return;
    }
    // unretain object
    [keyInfo addObserver:anObserver];
}

- (void)removeObserver:(NSObject *)anObserver
                forKey:(NSString *)key {
    HHKVOKeyInfo *keyInfo = [_keyMap objectForKey:key];
    if (!keyInfo) {
        return;
    }
    [keyInfo removeObserver:anObserver];
}

- (void)notifyKeyChanged:(NSString *)key {
    HHKVOKeyInfo *keyInfo = [_keyMap objectForKey:key];
    [keyInfo notify];
}

- (void)updateChangeWithNewValue:(id)newValue key:(NSString *)key {
    HHKVOKeyInfo *keyInfo = [_keyMap objectForKey:key];
    [keyInfo updateNewValue:newValue];
}

- (void)updateChangeWithOldValue:(id)oldValue key:(NSString *)key {
    HHKVOKeyInfo *keyInfo = [_keyMap objectForKey:key];
    [keyInfo updateOldValue:oldValue];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"KVOInfo, Instace:%@, Map:%@", _instance, _keyMap];
}

@end

@implementation HHKVOKeyInfo

- (instancetype)initWithKey:(NSString *)key {
    self = [super init];
    if (self) {
        _key = key;
        _change = [NSMutableDictionary dictionary];
        // store weak observers
        _observations = [NSPointerArray weakObjectsPointerArray];
    }
    return self;
}

- (BOOL)containsObserver:(id)observer {
    NSInteger index = [self indexOfObserver:observer];
    return index >= 0;
}

- (NSInteger)indexOfObserver:(id)observer {
    NSUInteger count = _observations.count;
    for (int i = 0; i < count; ++i) {
        id obj = [_observations pointerAtIndex:i];
        if (obj == observer) {
            return i;
        }
    }
    return -1;
}

- (void)addObserver:(id)observer {
    [_observations addPointer:(__bridge void * _Nullable)(observer)];
}

- (void)removeObserver:(id)observer {
    NSInteger index = [self indexOfObserver:observer];
    if (index >= 0) {
        [_observations removePointerAtIndex:index];
    }
}

- (void)notify {
    for (id obj in _observations) {
        [obj observeValueForKeyPath:_key ofObject:nil change:_change context:nil];
    }
}

- (void)updateNewValue:(id)newValue {
    [_change setObject:newValue forKey:@"new"];
}

- (void)updateOldValue:(id)oldValue {
    [_change setObject:oldValue forKey:@"old"];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"Key:%@, Observations(count:%d),%@:%@", _key, (int)_observations.allObjects.count, _observations, [self observationsDescription]];
}

- (NSString *)observationsDescription {
    NSMutableString *string = [NSMutableString stringWithString:@"["];
    NSUInteger count = _observations.count;
    for (int i = 0; i < count; ++i) {
        id obj = [_observations pointerAtIndex:i];
        [string appendString:[obj description] ?: @""];
        [string appendString:@","];
    }
    [string appendString:@"]"];
    return string;
}

@end


@implementation NSObject (HHKVOInfo)

- (HHKVOInfo *)hh_kvoInfo {
    return objc_getAssociatedObject(self, @selector(hh_kvoInfo));
}

- (void)setHh_kvoInfo:(HHKVOInfo *)info {
    objc_setAssociatedObject(self, @selector(hh_kvoInfo), info, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
