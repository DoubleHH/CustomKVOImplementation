//
//  HHFirstObj.h
//  KVOCustomImplement
//
//  Created by DoubleHH on 2017/7/12.
//  Copyright © 2017年 com.baidu.iwaimai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@interface HHFirstObj : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) int year;
@property (nonatomic, assign) CGPoint location;
@property (nonatomic, assign) CGRect rect;
@property (nonatomic, assign) CGSize size;
@property (nonatomic, assign) NSRange range;

@end
