//
//  SSRootApp+Config.m
//  Bizmate
//
//  Created by CT on 2020/11/25.
//  Copyright © 2020 Sinosun Technology Co., Ltd. All rights reserved.
//

#import "SSRootApp+Config.h"
#import "ProdcutionEnvConfig.h"
#import "ProductInterfaceUtil.h"
#import "IMProProvider.h"
#import "ProductBarData.h"
#import <objc/runtime.h>

@implementation SSRootApp(Config)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];

        SEL originalSelector = @selector(loadProjectEnvConfig);//application:didFinishLaunchingWithOptions:);//
        SEL swizzledSelector = @selector(swizzled_loadProjectEnvConfig);//application:didFinishLaunchingWithOptions:);//

        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);

        BOOL didAddMethod = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
        if (didAddMethod) {
            class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    });
}

-(void)swizzled_loadProjectEnvConfig {//application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{//
    int networkConfig = [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"ServerConfig"] intValue];
    int serverChange = [[[NSUserDefaults standardUserDefaults] objectForKey:@"ServerConfigChange"] intValue];
    if (networkConfig!=1) {
        if (serverChange) {
            networkConfig = serverChange%100;
        }
    }
//    [[ProductInterfaceUtil sharedManager] getProductApp]; test code
    [[ProdcutionEnvConfig sharedManager] getNetworkEnvConfigWithType:networkConfig];
    [[ProductInterfaceUtil sharedManager] setInnerSmti:@"itms-services://" forKey:SMTI_SER_KEY];
    
    // 自定义消息测试数据, test code
    [[ProductInterfaceUtil sharedManager] installProvider:[IMProProvider sharedManager]];
    //[[IMProProvider sharedManager] setCustomMessageCellHeight:100];//设定自定义消息高度统一为100，或者不设置，自定义消息通过msgContent动态计算
    //[[IMProProvider sharedManager] setPopMenuItem:@[@"11111",@"22222",@"转发",@"33333转发"]];
    ProductBarData *proData = [[ProductBarData alloc] init];
    [[ProductInterfaceUtil sharedManager] provideBarRightData:proData];
    /*
     Json格式为：
   [
       {"identifierStr": "menu_sms"," title": "伴正事"},
   {"identifierStr": "menu_news"," title": "资讯"},
        ……
   ]
     */
    // need to do
    [[ProductInterfaceUtil sharedManager] setMainConfig:@""];
    [[ProductInterfaceUtil sharedManager] setUpCustomMainUI:@1];
    
    [[ProductInterfaceUtil sharedManager] registFunction:[[NSClassFromString(@"GetApiFakerFunction") alloc] init]];
//    [[ProductInterfaceUtil sharedManager] setCommonApplets:@"19,245,58,37,90,92,91,223"];//员工 //打卡 会议 出差申请 请假申请
//    [[ProductInterfaceUtil sharedManager] setCommonApplets:@"245,265,270,29,90,92,91,223"];//老板 //会议 考勤统计 销售统计 通用设置
//    [[ProductInterfaceUtil sharedManager] setCommonApplets:@"90,92,91,223"];// 常用，可设置其他角色 //机票 酒店 火车 企业购

    [self swizzled_loadProjectEnvConfig];
//    [self swizzled_application:application didFinishLaunchingWithOptions:launchOptions];
    NSLog(@"root didFinishLaunchingWithOptions");
}

@end
