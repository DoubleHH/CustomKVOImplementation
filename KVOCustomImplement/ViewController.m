//
//  ViewController.m
//  KVOCustomImplement
//
//  Created by DoubleHH on 2017/7/12.
//  Copyright © 2017年 com.baidu.iwaimai. All rights reserved.
//

#import "ViewController.h"
#import <objc/runtime.h>
#import "NSObject+HHKVO.h"
#import "HHFirstObj.h"

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.width

@interface ViewController () {
    HHFirstObj *_fObj;
    CGPoint _point;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    UIButton *testButon = [[UIButton alloc] initWithFrame:CGRectMake(0, 130, SCREEN_WIDTH, 50)];
    [testButon setTitle:@"Click and Test" forState:UIControlStateNormal];
    [testButon setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    testButon.titleLabel.font = [UIFont boldSystemFontOfSize:24];
    [testButon addTarget:self action:@selector(clickTest) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:testButon];
}

- (void)clickTest {
    [self testKVOExceptionObserverDealloc];
}

#pragma mark - Test type
- (void)testCustomKVO {
    _fObj = [[HHFirstObj alloc] init];
    _fObj.name = @"Xiao Ming";
    [_fObj hh_addObserver:self
                   forKey:@"name"];
    _fObj.name = @"Xiao Nan";
}

- (void)testCustomKVOInt {
    _fObj = [[HHFirstObj alloc] init];
    _fObj.year = -1;
    [_fObj hh_addObserver:self
                   forKey:@"year"];
    _fObj.year = -1000;
}

- (void)testCustomKVOCGPoint {
    _fObj = [[HHFirstObj alloc] init];
    _fObj.location = CGPointMake(116, 48);
    [_fObj hh_addObserver:self
                   forKey:@"location"];
    _fObj.location = CGPointMake(120, 120);
}

- (void)testCustomKVOCGRect {
    _fObj = [[HHFirstObj alloc] init];
    _fObj.rect = CGRectMake(0, 0, 1, 1);
    [_fObj hh_addObserver:self
                   forKey:@"rect"];
    _fObj.rect = CGRectMake(100, 100, 21, 21);
}

- (void)testCustomKVOSize {
    _fObj = [[HHFirstObj alloc] init];
    _fObj.size = CGSizeMake(1, 1);
    [_fObj hh_addObserver:self
                   forKey:@"size"];
    _fObj.size = CGSizeMake(100, 100);
}

- (void)testCustomKVORange {
    _fObj = [[HHFirstObj alloc] init];
    _fObj.range = NSMakeRange(1, 1);
    [_fObj hh_addObserver:self
                   forKey:@"range"];
    _fObj.range = NSMakeRange(100, 100);
}

#pragma mark - Test Remove
- (void)testKVORemove {
    _fObj = [[HHFirstObj alloc] init];
    _fObj.name = @"Remove1";
    [_fObj hh_addObserver:self
                   forKey:@"name"];
    _fObj.name = @"Remove2";
    
    [_fObj hh_removeObserver:self forKey:@"name"]; // hide/show this line for test
    _fObj.name = @"Removed";
}

#pragma mark - Test Exception
- (void)testKVOExceptionObserveredDealloc {
    HHFirstObj *fobj = [[HHFirstObj alloc] init];
    fobj.name = @"Exception1";
    [fobj hh_addObserver:self
                   forKey:@"name"];
    fobj.name = @"Exception2";
}

- (void)testKVOExceptionObserverDealloc {
    HHFirstObj *fobj = [[HHFirstObj alloc] init];
    self.title = @"VC1";
    [self hh_addObserver:fobj
                  forKey:@"title"];
    self.title = @"VC2";
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // print kvo info
        id obj = [self performSelector:@selector(hh_kvoInfo)];
        NSLog(@"%@", obj);
    });
}


#pragma mark - KVO Delegate
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    NSLog(@"%s, keypath:%@, change:%@", __func__, keyPath, change);
}

@end
