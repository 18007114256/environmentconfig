//
//  MockApiManager.h
//  MockCommunication
//
//  Created by apple on 2021/6/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MockApiManager : NSObject

+ (instancetype)sharedManager;

- (void)mockApi:(NSString *)cmd host:(NSString *__nullable)host parameters:(id)parameters success:(void (^)(id  responseObject))success failure:(void (^)( NSError * error))failure;

-(BOOL)checkMockApi:(NSString *)cmd;

@end

NS_ASSUME_NONNULL_END
