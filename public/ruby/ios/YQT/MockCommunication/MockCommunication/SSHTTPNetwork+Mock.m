//
//  SSHTTPNetwork+Mock.m
//  MockCommunication
//
//  Created by apple on 2021/6/15.
//

#import "SSHTTPNetwork+Mock.h"
#import <objc/runtime.h>
#import "SSError+NetWork.h"
#import "AFNetworking.h"
#import "SSOriginDataProcess.h"
#import "NSString+Expand.h"
#import "MockApiManager.h"
#import "TBaseTSRespond.h"
#import "ShowCustomToastView.h"

void __swipe_swizzle1(Class cls, SEL originalSelector) {
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

@interface SSHTTPNetwork ()

- (AFHTTPSessionManager *)getSesstionManager:(SSBaseTSRequest *)request;
- (void)httpRequestFailed:(SSBaseTSRequest*)tsRequest operation:(NSURLSessionDataTask*)operation;
- (void)addRequest:(id<SSMessageProcessData>)packet operation:(NSURLSessionDataTask*)operation;
- (void)removeRequest:(id<SSMessageProcessData>)packet operation:(NSURLSessionDataTask*)operation;

@end


@implementation SSHTTPNetwork (Mock)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __swipe_swizzle1(self, @selector(sendMessage:));
    });
}

- (void)swizzled_sendMessage:(id<SSMessageProcessData>)data{
//    NSString *sss = data.identify;
    SSBaseTSRequest *request = (SSBaseTSRequest *)data;
    if ([[MockApiManager sharedManager] checkMockApi:request.cmd]) {
        NSDictionary *tempDic = [[[SSOriginDataProcess alloc] init] processRequestData:request error:NULL];

        [[MockApiManager sharedManager] mockApi:request.cmd host:nil parameters:tempDic success:^(id  _Nonnull responseObject) {
            NSDictionary *result = (NSDictionary *)responseObject;
            TBaseTSRespond *respond = [[TBaseTSRespond alloc] init];
            respond.code = 0;
            respond.extInfo = request.extInfo;
            respond.cmd = request.cmd;
            respond.requestKey = request.requestKey;
            respond.session = request.session;
            SSError *err = [SSError serverError:request respond:respond];
            if ([result[@"result"] isKindOfClass:NSDictionary.class]) {
                respond.responseParams =result[@"result"];
            } else {
                [ShowCustomToastView showToast:@"必传返回参数格式错误" time:1.0];
                [self.callBack onFailed:err];
                return;
            }
            
            int code = [result[@"resultCode"] intValue];
            if (code != 0) {
                [ShowCustomToastView showToast:[result[@"resultMessage"] length] > 0 ? result[@"resultMessage"] : @"暂无错误信息" time:1.0];
                [self.callBack onFailed:err];
                return;
            }
            if (request != nil) {
                [self removeRequest:request operation:nil];
            }
            [self.callBack onSuccess:respond];
        } failure:^(NSError * _Nonnull error) {
            [ShowCustomToastView showToast:error.userInfo[NSLocalizedDescriptionKey] time:1.0];
            if (request != nil) {
                [self removeRequest:request operation:nil];
            }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
            SSError *err = [[SSError alloc] init];
            if ([SSError respondsToSelector:@selector(httpError2:)]) {
                err = [SSError performSelector:@selector(httpError2:) withObject:request];
            } else if ([SSError respondsToSelector:@selector(httpError:)]) {
                err = [SSError performSelector:@selector(httpError:) withObject:request];
            }
#pragma clang diagnostic pop
            [self.callBack onFailed:err];
        }];
//        [self addRequest:request operation:nil];
    }else{
        [self swizzled_sendMessage:data];
    }
}


@end
