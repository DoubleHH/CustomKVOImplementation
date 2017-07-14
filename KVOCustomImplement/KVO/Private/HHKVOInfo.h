//
//  HHKVOInfo.h
//  KVOCustomImplement
//
//  Created by DoubleHH on 2017/7/14.
//  Copyright © 2017年 com.baidu.iwaimai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HHKVOInfo : NSObject

- (instancetype)initWithInstance:(id)instance;
- (void)addObserver:(NSObject *)anObserver
             forKey:(NSString *)key;
- (void)removeObserver:(NSObject *)anObserver
                forKey:(NSString *)key;
- (void)notifyKeyChanged:(NSString *)key;
- (void)updateChangeWithNewValue:(id)newValue key:(NSString *)key;
- (void)updateChangeWithOldValue:(id)newValue key:(NSString *)key;

@end

@interface NSObject (HHKVOInfo)
@property (nonatomic) HHKVOInfo *hh_kvoInfo;
@end
