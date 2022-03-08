//
//  GetApiFakerFunction.m
//  EBankMPaas
//
//  Created by apple on 2021/6/18.
//  Copyright © 2021 Sinosun Technology Co., Ltd. All rights reserved.
//

#import "GetApiFakerFunction.h"
//#import "AppDelegate+EBank.h"
#import <MockCommunication/MockApiManager.h>
#import "NSString+Expand.h"

//@interface SSNetworkProcess ()
//
//@end
@interface GetApiFakerFunction()
@property (nonatomic,copy) void(^ callBack)(JSMessage * data, void(^back)(id jsData));
@property (nonatomic, weak) id webView;
@property (nonatomic, strong) id<BaseH5FunctionObjProtocol> obj;
@end

@implementation GetApiFakerFunction

-(void)installWebView:(id)webView{
    self.webView = webView;
    [self installCallBack];
}

-(id)getWebView{
    return self.webView;
}


- (void)installCallBack {
//    __weak typeof(self) weakSelf = self;
    _callBack = ^(JSMessage * data, void(^back)(id jsData)) {
        
        NSDictionary *mockData =data.data;

        
        NSString *cmd =mockData[@"url"][@"cmd"];
        NSString *host =mockData[@"url"][@"urlApi"];

        id requestData =mockData[@"params"];
    

        [[MockApiManager sharedManager] mockApi:cmd host:host parameters:requestData success:^(id  _Nonnull responseObject) {
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            [dic setObject:@(0) forKey:@"retCode"];
            [dic setObject:[NSString jsonStringFromData:responseObject] forKey:@"data"];
            
            if (back) {
                back([NSString jsonStringFromData:dic]);
            }

//            back(@"0",@"",[NSString jsonStringFromData:responseObject]);

        } failure:^(NSError * _Nonnull error) {
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            [dic setObject:@(-1) forKey:@"retCode"];
            [dic setObject:error.description forKey:@"msg"];
            if (back) {
                back([NSString jsonStringFromData:dic]);
            }

        }];
//        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
//        if (data) {
//            [dic setObject:data forKey:@"params"];
//        }
//
//        if (back) {
//            [dic setObject:back forKey:@"callBack"];
//        }
//
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if ([weakSelf.obj respondsToSelector:@selector(excuteByDic:)]) {
//                [weakSelf.obj excuteByDic:dic];
//            }
//        });
    };
}

- (NSNumber *)registerType {
    return @(HandlerTypeRegister);
}


- (NSString *)getHandlerName {
    return @"GetApiFakerFunction";
}

- (void(^)(JSMessage * data, void(^back)(id jsData)))jsCallBack {
    return _callBack;
}
//- (NSString *)getFunctionName{
//    return @"GetApiFakerFunction";
//
//}

// 插件浏览器丢出来的事件
//- (void)handlerXFunction:(NSString *)data callBack:(void(^)(NSString *retCode,NSString *msg, NSString *data))callBack{
//
//    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
//    NSData *jsonData = [data dataUsingEncoding:NSUTF8StringEncoding];
//    dic = [NSJSONSerialization JSONObjectWithData:jsonData
//                                              options:NSJSONReadingMutableContainers
//                                                error:nil];
//    if (dic==nil ) {
//        return ;
//    }
//    NSDictionary *mockData =dic[@"data"];
//
//
//    NSString *cmd =mockData[@"url"][@"cmd"];
//    NSString *host =mockData[@"url"][@"urlApi"];
//
//    id requestData =mockData[@"params"];
//
//    [[MockApiManager sharedManager] mockApi:cmd host:host parameters:requestData success:^(id  _Nonnull responseObject) {
//        callBack(@"0",@"",[NSString jsonStringFromData:responseObject]);
//
//    } failure:^(NSError * _Nonnull error) {
//        callBack(@"1",error.description,@"");
//
//    }];
//
//}

@end
