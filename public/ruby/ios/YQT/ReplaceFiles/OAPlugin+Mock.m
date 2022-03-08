//
//  OAPlugin+Custom.m
//  TChat
//
//  Created by apple on 2022/1/12.
//  Copyright © 2022 Sinosun Technology Co., Ltd. All rights reserved.
//

#import "OAPlugin+Mock.h"
void __swipe_swizzle_oa(Class cls, SEL originalSelector) {
    NSString *originalName = NSStringFromSelector(originalSelector);
    NSString *alternativeName = [NSString stringWithFormat:@"swizzled_%@", originalName];

    SEL alternativeSelector = NSSelectorFromString(alternativeName);

    Method originalMethod = class_getInstanceMethod(cls, originalSelector);
    Method alternativeMethod = class_getInstanceMethod(cls, alternativeSelector);

    class_addMethod(cls,
                    originalSelector,
                    class_getMethodImplementation(cls, originalSelector),
                    method_getTypeEncoding(originalMethod));
    class_addMethod(cls,
                    alternativeSelector,
                    class_getMethodImplementation(cls, alternativeSelector),
                    method_getTypeEncoding(alternativeMethod));

    method_exchangeImplementations(class_getInstanceMethod(cls, originalSelector),
                                   class_getInstanceMethod(cls, alternativeSelector));
}
@interface  OAPlugin()
@property (nonatomic, strong) NSMutableArray *dataArray;
- (id)getWebView;
@end

@implementation OAPlugin (Mock)
+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __swipe_swizzle_oa(self, @selector(initialize));
    });
}

- (void)swizzled_initialize{
    [self swizzled_initialize];
    
    if (self.dataArray) {
        id obj = [[NSClassFromString(@"GetApiFakerFunction") alloc] init];
        if (obj) {
            if ([obj respondsToSelector:@selector(installWebView:)]) {
                [obj performSelector:@selector(installWebView:) withObject:[self getWebView]];
            }
            [self.dataArray addObject:obj];
        }
    }
}
@end
