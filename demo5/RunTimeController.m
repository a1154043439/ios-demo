////
////  RunTimeController.m
////  demo5
////
////  Created by test on 2017/7/27.
////  Copyright © 2017年 test. All rights reserved.
////
//
//#import "ViewController.h"
//#import <objc/runtime.h>
//
/////-----------------------------------------------------------------------------
///// http://nshipster.com/associated-objects
/////-----------------------------------------------------------------------------
//#pragma mark - Associated Objects -
//
///**
// Associated Objects—or Associative References, as they were originally known—are a feature of the Objective-C 2.0 runtime, introduced in OS X Snow Leopard (available in iOS 4). The term refers to the following three C functions declared in <objc/runtime.h>, which allow objects to associate arbitrary values for keys at runtime:
// 
// objc_setAssociatedObject
// objc_getAssociatedObject
// objc_removeAssociatedObjects
// Why is this useful? It allows developers to add custom properties to existing classes in categories, which is an otherwise notable shortcoming for Objective-C.
// 
// http://nshipster.com/associated-objects
// */
//@interface NSObject (AssociatedObject)
//@property (nonatomic, strong) id associatedObject;
//@end
//
//
//@implementation NSObject (AssociatedObject)
//@dynamic associatedObject;
//
///**
// It is often recommended that they key be a static char—or better yet, the
// pointer to one. Basically, an arbitrary value that is guaranteed to be constant,
// unique, and scoped for use within getters and setters:
// 
// static char kAssociatedObjectKey;
// 
// objc_getAssociatedObject(self, &kAssociatedObjectKey);
// 
// http://nshipster.com/associated-objects
// */
//- (void)setAssociatedObject:(id)object {
//    objc_setAssociatedObject(self, @selector(associatedObject), object, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//}
//
//- (id)associatedObject {
//    return objc_getAssociatedObject(self, @selector(associatedObject));
//}
//
//@end
//
//#pragma mark - Method Swizzling 和 AOP 实践 -
//@interface UIViewController (MethodSwizzling)
//
//@end
//
//
//@implementation UIViewController (MethodSwizzling)
//
///**
// 一般情况下，类别里的方法会重写掉主类里相同命名的方法。如果有两个类别实现了相同命名的方法，只有一个
// 方法会被调用。但 +load: 是个特例，当一个类被读到内存的时候， runtime 会给这个类及它的每一个类
// */
//+ (void)load
//{
//    swizzleMethod([self class], @selector(viewDidAppear:), @selector(swizzled_viewDidAppear:));
//}
//
///**
// 代码看起来可能有点奇怪，像递归不是么。当然不会是递归，因为在 runtime 的时候，函数实现已经被交换
// 了。调用 viewDidAppear: 会调用你实现的 swizzled_viewDidAppear:，而在 swizzled_viewDidAppear: 里
// 调用 swizzled_viewDidAppear: 实际上调用的是原来的 viewDidAppear:
// 
// */
//- (void)swizzled_viewDidAppear:(BOOL)animated
//{
//    NSLog(@"---- swizzled_viewDidAppear 位置1 ----");
//    
//    // call original implementation
//    [self swizzled_viewDidAppear:animated];
//    
//    NSLog(@"---- swizzled_viewDidAppear 位置2 ----");
//}
//
///**
// 要先尝试添加原 selector 是为了做一层保护，因为如果这个类没有实现 originalSelector ，但其父
// 类实现了，那 class_getInstanceMethod 会返回父类的方法。这样 method_exchangeImplementations 替
// 换的是父类的那个方法，这当然不是你想要的。所以我们先尝试添加 orginalSelector ，如果已经存在，再
// 用 method_exchangeImplementations 把原方法的实现跟新的方法实现给交换掉。
//
// */
//void swizzleMethod(Class class, SEL originalSelector, SEL swizzledSelector)
//{
//    // the method might not exist in the class, but in its superclass
//    Method originalMethod = class_getInstanceMethod(class, originalSelector);
//    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
//    
//    // class_addMethod will fail if original method already exists
//    BOOL didAddMethod = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
//    
//    // the method doesn’t exist and we just added one
//    if (didAddMethod) {
//        class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
//    }
//    else {
//        method_exchangeImplementations(originalMethod, swizzledMethod);
//    }
//}
//
//
///**
// 其实，这里还可以更简化点：直接用新的 IMP 取代原 IMP ，而不是替换。只需要有全局的函数指针指向
// 原 IMP 就可以。
//
// */
////void (gOriginalViewDidAppear)(id, SEL, BOOL);
////
////void newViewDidAppear(UIViewController *self, SEL _cmd, BOOL animated)
////{
////    // call original implementation
////    gOriginalViewDidAppear(self, _cmd, animated);
////
////    // Logging
////    [Logging logWithEventName:NSStringFromClass([self class])];
////}
////
////+ (void)load
////{
////    Method originalMethod = class_getInstanceMethod(self, @selector(viewDidAppear:));
////    gOriginalViewDidAppear = (void *)method_getImplementation(originalMethod);
////
////    if(!class_addMethod(self, @selector(viewDidAppear:), (IMP) newViewDidAppear, method_getTypeEncoding(originalMethod))) {
////        method_setImplementation(originalMethod, (IMP) newViewDidAppear);
////    }
////}
//
//@end
//
//#pragma mark - 如何自己动手实现 KVO -
//
///**
// 打印一个类的全部方法
// */
//static NSArray *ClassMethodNames(Class c)
//{
//    NSMutableArray *array = [NSMutableArray array];
//    
//    unsigned int methodCount = 0;
//    Method *methodList = class_copyMethodList(c, &methodCount);
//    unsigned int i;
//    for(i = 0; i < methodCount; i++) {
//        [array addObject: NSStringFromSelector(method_getName(methodList[i]))];
//    }
//    free(methodList);
//    
//    return array;
//}
//
//
//@interface ViewController ()
//
//@end
//
//@implementation ViewController
//
//- (void)viewDidLoad {
//    
//    [super viewDidLoad];
//    
//    //    self.associatedObject = @"Hello, AssociatedObject!";
//    //    NSLog(@"%@", self.associatedObject);
//    
//    //    NSArray *array = ClassMethodNames([UIViewController class]);
//    //    for (NSString *method in array) {
//    //        NSLog(@"----%@", method);
//    //    }
//    
//    if ([self hasSelector:@selector(viewDidLoad)]) {
//        NSLog(@"true");
//    } else {
//        NSLog(@"false");
//    }
//}
//
//- (void)viewDidAppear:(BOOL)animated {
//    
//    NSLog(@"---- viewDidAppear 位置1 ----");
//    
//    // 父类的方法被替换了
//    [super viewDidAppear:animated];
//    
//    NSLog(@"---- viewDidAppear 位置1 ----");
//}
//
//#pragma mark - 实现 KVO -
//
///**
// 判断一个类是否实现了某个方法
//
// */
//- (BOOL)hasSelector:(SEL)selector
//{
//    Class clazz = object_getClass(self);
//    unsigned int methodCount = 0;
//    Method* methodList = class_copyMethodList(clazz, &methodCount);
//    for (unsigned int i = 0; i < methodCount; i++) {
//        SEL thisSelector = method_getName(methodList[i]);
//        if (thisSelector == selector) {
//            free(methodList);
//            return YES;
//        }
//    }
//    
//    free(methodList);
//    return NO;
//}
//
//@end
