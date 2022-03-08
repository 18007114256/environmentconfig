//
//  MockApiManager.m
//  MockCommunication
//
//  Created by apple on 2021/6/18.
//

#import "MockApiManager.h"
#import "AFNetworking.h"

@interface MockApiManager ()

@property (nonatomic ,strong) NSDictionary *mockConfigDic;
@property (nonatomic, weak) CALayer *watermarkLayer;

@end

@implementation MockApiManager

+ (instancetype)sharedManager{
    static MockApiManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[MockApiManager alloc] init];
    });
    return _sharedManager;
}

-(id)init{
    self = [super init];
    if (self) {
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"MockBundle" ofType:@"bundle"];
        self.mockConfigDic = [NSMutableDictionary dictionaryWithContentsOfFile:[[NSBundle bundleWithPath:bundlePath] pathForResource:@"MockConfig" ofType:@"plist"]];
        if (self.mockConfigDic.allKeys.count > 0) {
            // 添加水印
            NSArray *mockApis = [self.mockConfigDic objectForKey:@"MockCMDList"];
            if (mockApis.count>0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self setUpWaterMark];
                });
            }
        }
    }
    return self;
}

- (void)setUpWaterMark {
    if (self.watermarkLayer == nil) {
        CALayer *watermarkLayer = [[CALayer alloc] init];
        self.watermarkLayer = watermarkLayer;
        self.watermarkLayer.frame = [UIScreen mainScreen].bounds;
        UIImage *image = [UIImage imageNamed:@"img_demo_watermark.png" inBundle:[NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"MockBundle" ofType:@"bundle"]] compatibleWithTraitCollection:[UITraitCollection traitCollectionWithUserInterfaceIdiom:UIUserInterfaceIdiomPhone]];
        self.watermarkLayer.contents = (__bridge id _Nullable)(image.CGImage);
        self.watermarkLayer.contentsScale = image.scale;
        self.watermarkLayer.contentsGravity = kCAGravityResizeAspectFill;
        self.watermarkLayer.opacity = 0.5;
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        [window.layer addSublayer:self.watermarkLayer];
        self.watermarkLayer.zPosition = 9999;
    }
}

- (void)showWatermarkLayer {
    self.watermarkLayer.hidden = NO;
}

- (void)hiddenWatermarkLayer {
    self.watermarkLayer.hidden = YES;
}

-(BOOL)checkMockApi:(NSString *)cmd{
    NSMutableArray *array = self.mockConfigDic[@"MockCMDList"];
    if ([array containsObject:cmd]) {
        return YES;
    }
    return NO;
}

- (void)mockApi:(NSString *)cmd host:(NSString *__nullable)host parameters:(id)parameters success:(void (^)(id  responseObject))success failure:(void (^)( NSError * error))failure{
    NSURL *baseUrl;
    if (host.length < 1) {
        baseUrl = [NSURL URLWithString: self.mockConfigDic[@"MockHostPath"]];
    }else{
        baseUrl = [NSURL URLWithString:host];
    }
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    configuration.timeoutIntervalForRequest = 30;
    AFHTTPSessionManager * tempManager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseUrl sessionConfiguration:configuration];
    tempManager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    [tempManager POST:cmd parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"MOCK_success,%@==%@",cmd,parameters);
        if (success) {
            success(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"MOCK_error,%@==%@",cmd,error);
        if (failure) {
            failure(error);
        }
    }];
}


@end
