# CustomKVOImplementation


A custom simple KVO for learning internal implementation about KVO.
 
As we all known, when we use KVO and meet the three sutiations, app will crash:
 
1. The times of invoking remove observer method more than add observer method;
2. Observer is delloced, but observed object still send message to it. EXC_BAD_ACCESS;
3. Observered object is delloced, but forget remove observer;
 
But you need't worry about Apple's KVO exceptions if use this.
 
Refered to KVO open source of GNU.


## 中文翻译一下

代码是一个KVO的简单自定义实现版本，用于学习&理解底层KVO是的实现原理。

众所周知，当我们使用KVO并遇到以下三种情形时，App会崩溃：

1. `removeObserver`调用次数比`addObserver`次数多;
2. 观察者释放了，但没有移除观察，那么当KVO触发时，会发生野指针异常访问；
3. 被观察者释放了，但没有移除观察者；

但使用这个版本的KVO不会发生以上的异常。

参考：GNU对于KVO的开放源码。
