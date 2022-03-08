//
//  GetApiFakerFunction.h
//  EBankMPaas
//
//  Created by apple on 2021/6/18.
//  Copyright © 2021 Sinosun Technology Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "BrowserXFunctionHandler.h"
#import "BrowserHandler.h"
NS_ASSUME_NONNULL_BEGIN

@interface GetApiFakerFunction :  NSObject<BrowserHandler>
-(void)installWebView:(id)webView;
@end

NS_ASSUME_NONNULL_END
