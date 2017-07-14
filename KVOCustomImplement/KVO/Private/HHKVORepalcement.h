//
//  HHKVORepalcement.h
//  KVOCustomImplement
//
//  Created by DoubleHH on 2017/7/14.
//  Copyright © 2017年 com.baidu.iwaimai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HHKVORepalcement : NSObject

- (instancetype)initWithOriginalClass:(Class)originalClass;
- (void)overrideKey:(NSString *)key;
- (Class)replacedClass;

@end
