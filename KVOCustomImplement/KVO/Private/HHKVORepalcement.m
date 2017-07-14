//
//  HHKVORepalcement.m
//  KVOCustomImplement
//
//  Created by DoubleHH on 2017/7/14.
//  Copyright © 2017年 com.baidu.iwaimai. All rights reserved.
//

#import "HHKVORepalcement.h"
#import <objc/runtime.h>
#import "HHKVOInfo.h"
#import <CoreGraphics/CoreGraphics.h>

static NSString *const kReplacedClassPrefix = @"HHKVONotify_";

static NSString *keyFromSel(SEL sel) {
    NSString *selString = NSStringFromSelector(sel);
    NSRange colonRange = [selString rangeOfString:@":"];
    if (colonRange.length == 0 || ![selString hasPrefix:@"set"] || colonRange.location <= 3) {
        @throw [NSException exceptionWithName:@"Illegal setter" reason:@"非法的setter" userInfo:nil];
    }
    NSRange keyRange = NSMakeRange(3, colonRange.location - 3);
    NSString *key = [selString substringWithRange:keyRange];
    if (key.length == 1) {
        return key.lowercaseString;
    } else {
        return [[key substringToIndex:1].lowercaseString stringByAppendingString:[key substringFromIndex:1]];
    }
}

static void addAllInstanceMethod(Class fromClass, Class toClass) {
    unsigned int fromMethodCount = 0;
    Method *methods = class_copyMethodList(fromClass, &fromMethodCount);
    for (int i = 0; i < fromMethodCount; ++i) {
        Method method = methods[i];
        BOOL success = class_addMethod(toClass, method_getName(method), method_getImplementation(method), method_getTypeEncoding(method));
        NSLog(@"Add method %@ %@", NSStringFromSelector(method_getName(method)), success ? @"success" : @"failed");
    }
}

@interface HHKVOBase : NSObject
@end

@interface HHKVOSetter : NSObject
- (void)_hh_setterObject:(void *)obj;
- (void)_hh_setterInt:(unsigned int)value;
- (void)_hh_setterFloat:(float)value;
- (void)_hh_setterDouble:(float)value;
- (void)_hh_setterChar:(char *)value;
- (void)_hh_setterRect:(CGRect)value;
- (void)_hh_setterSize:(CGSize)value;
- (void)_hh_setterPoint:(CGPoint)value;
- (void)_hh_setterRange:(NSRange)value;
@end

@implementation HHKVORepalcement {
    Class _originalClass;
    Class _replacedClass;
}

- (instancetype)initWithOriginalClass:(Class)originalClass {
    self = [super init];
    if (self) {
        _originalClass = originalClass;
        [self initReplaceClass];
    }
    return self;
}

- (Class)replacedClass {
    return _replacedClass;
}

- (void)initReplaceClass {
    NSString *originalClassName = NSStringFromClass(_originalClass);
    NSString *replacedClassName = [kReplacedClassPrefix stringByAppendingString:originalClassName];
    
    // Alloc a new class whose super class is original class
    Class newClass = objc_allocateClassPair(_originalClass, [replacedClassName UTF8String], 0);
    // Add valueable methods from HHKVOBase class
    addAllInstanceMethod(HHKVOBase.class, newClass);
    objc_registerClassPair(newClass);
    
    _replacedClass = newClass;
}

- (void)overrideKey:(NSString *)key {
    NSString *upperKey = [key substringToIndex:1].uppercaseString;
    if (key.length > 1) {
        upperKey = [upperKey stringByAppendingString:[key substringFromIndex:1]];
    }
    NSString *methodName = [[@"set" stringByAppendingString:upperKey] stringByAppendingString:@":"];
    SEL methodSel = NSSelectorFromString(methodName);
    Method method = class_getInstanceMethod(_originalClass, methodSel);
    if (!method) {
        return;
    }
    IMP imp = [self replaceImpToOriginalSetterMethod:method];
    if (!imp) {
        return;
    }
    BOOL success = class_addMethod(_replacedClass, methodSel, imp, method_getTypeEncoding(method));
    NSLog(@"Update setter method %@ %@", NSStringFromSelector(methodSel), success ? @"success" : @"failed");
}

// Replace setter imp, insert monitor functions: willChangeValueForKey and didChangeValueForKey
- (IMP)replaceImpToOriginalSetterMethod:(Method)method {
    const int argLength = 256;
    char argName[argLength] = {};
    method_getArgumentType(method, 2, argName, argLength);
    IMP imp = 0;
    switch (*argName) {
        case _C_ID:
        case _C_CLASS:
        case _C_PTR: {
            imp = [HHKVOSetter instanceMethodForSelector:@selector(_hh_setterObject:)];
            break;
        }
        case _C_INT:
        case _C_UINT: {
            imp = [HHKVOSetter instanceMethodForSelector:@selector(_hh_setterInt:)];
            break;
        }
        case _C_FLT: {
            imp = [HHKVOSetter instanceMethodForSelector:@selector(_hh_setterFloat:)];
            break;
        }
        case _C_DBL: {
            imp = [HHKVOSetter instanceMethodForSelector:@selector(_hh_setterDouble:)];
            break;
        }
        case _C_CHR:
        case _C_UCHR:
        case _C_BOOL: {
            imp = [HHKVOSetter instanceMethodForSelector:@selector(_hh_setterChar:)];
            break;
        }
        case _C_STRUCT_B: {
            if (strstr(argName, "CGRect") != 0) { // "{CGRect={CGPoint=dd}{CGSize=dd}}"
                imp = [HHKVOSetter instanceMethodForSelector:@selector(_hh_setterRect:)];
            } else if (strstr(argName, "CGPoint") != 0) { // "{CGPoint=dd}"
                imp = [HHKVOSetter instanceMethodForSelector:@selector(_hh_setterPoint:)];
            } else if (strstr(argName, "CGSize") != 0) { // "{CGSize=dd}"
                imp = [HHKVOSetter instanceMethodForSelector:@selector(_hh_setterSize:)];
            } else if (strstr(argName, "NSRange") != 0) { // "{_NSRange=QQ}"
                imp = [HHKVOSetter instanceMethodForSelector:@selector(_hh_setterRange:)];
            }
            break;
        }
        default:
            break;
    }
    return imp;
}

@end

@implementation HHKVOBase

// Hide the new class when developer invokes [self class]
- (Class)class {
    return class_getSuperclass(object_getClass(self));
}

- (void)willChangeValueForKey:(NSString *)key {
    [super willChangeValueForKey:key];
    HHKVOInfo *kvoInfo = [self hh_kvoInfo];
    id oldValue = [self valueForKey:key];
    [kvoInfo updateChangeWithOldValue:oldValue key:key];
}

- (void)didChangeValueForKey:(NSString *)key {
    [super didChangeValueForKey:key];
    HHKVOInfo *kvoInfo = [self hh_kvoInfo];
    id newValue = [self valueForKey:key];
    [kvoInfo updateChangeWithNewValue:newValue key:key];
    // Notify observers of value changes
    [kvoInfo notifyKeyChanged:key];
}

@end

// This class is ugly. We can use generic to make it elegant if in swift
@implementation HHKVOSetter

- (void)_hh_setterObject:(void *)value {
    void (*imp)(id, SEL, void *) = (void (*)(id, SEL, void *))[self.class instanceMethodForSelector:_cmd];
    NSString *key = keyFromSel(_cmd);
    [self willChangeValueForKey:key];
    (*imp)(self, _cmd, value);
    [self didChangeValueForKey:key];
}

- (void)_hh_setterInt:(unsigned int)value {
    void (*imp)(id, SEL, unsigned int) = (void (*)(id, SEL, unsigned int))[self.class instanceMethodForSelector:_cmd];
    NSString *key = keyFromSel(_cmd);
    [self willChangeValueForKey:key];
    (*imp)(self, _cmd, value);
    [self didChangeValueForKey:key];
}

- (void)_hh_setterFloat:(float)value {
    void (*imp)(id, SEL, float) = (void (*)(id, SEL, float))[self.class instanceMethodForSelector:_cmd];
    NSString *key = keyFromSel(_cmd);
    [self willChangeValueForKey:key];
    (*imp)(self, _cmd, value);
    [self didChangeValueForKey:key];
}

- (void)_hh_setterDouble:(float)value {
    void (*imp)(id, SEL, double) = (void (*)(id, SEL, double))[self.class instanceMethodForSelector:_cmd];
    NSString *key = keyFromSel(_cmd);
    [self willChangeValueForKey:key];
    (*imp)(self, _cmd, value);
    [self didChangeValueForKey:key];
}

- (void)_hh_setterChar:(char *)value {
    void (*imp)(id, SEL, char *) = (void (*)(id, SEL, char *))[self.class instanceMethodForSelector:_cmd];
    NSString *key = keyFromSel(_cmd);
    [self willChangeValueForKey:key];
    (*imp)(self, _cmd, value);
    [self didChangeValueForKey:key];
}

- (void)_hh_setterRect:(CGRect)value {
    void (*imp)(id, SEL, CGRect) = (void (*)(id, SEL, CGRect))[self.class instanceMethodForSelector:_cmd];
    NSString *key = keyFromSel(_cmd);
    [self willChangeValueForKey:key];
    (*imp)(self, _cmd, value);
    [self didChangeValueForKey:key];
}

- (void)_hh_setterSize:(CGSize)value {
    void (*imp)(id, SEL, CGSize) = (void (*)(id, SEL, CGSize))[self.class instanceMethodForSelector:_cmd];
    NSString *key = keyFromSel(_cmd);
    [self willChangeValueForKey:key];
    (*imp)(self, _cmd, value);
    [self didChangeValueForKey:key];
}

- (void)_hh_setterPoint:(CGPoint)value {
    void (*imp)(id, SEL, CGPoint) = (void (*)(id, SEL, CGPoint))[self.class instanceMethodForSelector:_cmd];
    NSString *key = keyFromSel(_cmd);
    [self willChangeValueForKey:key];
    (*imp)(self, _cmd, value);
    [self didChangeValueForKey:key];
}

- (void)_hh_setterRange:(NSRange)value {
    void (*imp)(id, SEL, NSRange) = (void (*)(id, SEL, NSRange))[self.class instanceMethodForSelector:_cmd];
    NSString *key = keyFromSel(_cmd);
    [self willChangeValueForKey:key];
    (*imp)(self, _cmd, value);
    [self didChangeValueForKey:key];
}

@end
