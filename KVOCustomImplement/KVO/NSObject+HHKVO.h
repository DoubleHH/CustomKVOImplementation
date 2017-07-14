//
//  NSObject+HHKVO.h
//  KVOCustomImplement
//
//  Created by DoubleHH on 2017/7/14.
//  Copyright © 2017年 com.baidu.iwaimai. All rights reserved.
//

/**
 A custom simple KVO for learning internal implementation about KVO.
 
 When we meet the three sutiations, app will crash:
 1. Mutiple - invoke remove observer method;
 2. Observer is delloced, but observed object still send message to it;
 3. Observered object is delloced, but forget remove observer;
 
 But you need't worry about Apple's KVO exceptions if use this.
 
 Refered to KVO open source of GNU.
 */
#import <Foundation/Foundation.h>

@interface NSObject (HHKVO)

/**
 Add an observer for key. Observer is holded for weak.
 */
- (void)hh_addObserver:(NSObject*)anObserver
                forKey:(NSString*)key;

/**
 Remove an observer for key. Mutiple-invoke is ok.
 */
- (void)hh_removeObserver:(NSObject *)anObserver
                   forKey:(NSString *)key;

@end
