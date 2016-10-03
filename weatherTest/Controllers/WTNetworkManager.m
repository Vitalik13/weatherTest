//
//  TWAPIController.m
//  weatherTest
//
//  Created by Vitaliy on 28.09.16.
//  Copyright © 2016 Vitaliy Shevtsov. All rights reserved.
//

#import "WTNetworkManager.h"
#import "WTCoreDataManager.h"
#import <UIKit/UIKit.h>

#import "WTCity.h"

#import "NSManagedObject+Helper.h"
#import "NSDictionary+CheckOnNull.h"

static NSString *WTErrorMessagePath = @"message";
static NSString *WTCodPath = @"cod";

static NSString *WTApiKey = @"00714f07efa71fce379d69af2773db31";
static NSString *WTWeatherURL = @"http://api.openweathermap.org/data/2.5/weather";

static NSString *WTCitiesURL = @"http://s05657b7d.fastvps-server.com/DocumentsCitiesRU.json";

NSString *WTImageColdURL = @"http://hikingartist.files.wordpress.com/2012/05/1-christmas-tree.jpg";
NSString *WTImageHotURL = @"http://www.webcity.su/images/img/summer-sun-sea-beach-4.jpg";

@interface WTNetworkManager ()

@property (nonatomic,strong) NSURLSession *session;

@end

@implementation WTNetworkManager

#pragma mark - Singleton init

+ (WTNetworkManager *)sharedInstance {
    static WTNetworkManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[WTNetworkManager alloc] init];
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        instance.session = [NSURLSession sessionWithConfiguration:configuration];
    });
    return instance;
}

#pragma mark - API methods

- (void)downloadAndSaveAllCitiesWithSuccessBlock:(void(^)(NSManagedObjectContext *context))successBlock
                                    failureBlock:(void(^)(NSError *error))failureBlock {
    [self sendGETRequest:WTCitiesURL
              parameters:nil
             cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                 success:^(NSHTTPURLResponse *response, id responseObject) {
                     [WTCoreDataManager saveContext:^(NSManagedObjectContext *context) {
                         for (NSDictionary *cityJson in (NSArray*)responseObject) {
                             [WTCity cityFromJson:cityJson context:context];
                         }
                     } success:^(NSManagedObjectContext *context) {
                         if (successBlock) {
                             successBlock(context);
                         }
                     } failure:failureBlock];
                 }
                 failure:^(NSHTTPURLResponse *response, NSError *error) {
                     if (failureBlock) {
                         failureBlock(error);
                     }
                 }];
}

- (void)getCityWeatherByCityId:(NSNumber *)cityId
                  successBlock:(void(^)(WTCity *city))successBlock
                  failureBlock:(void(^)(NSError *error))failureBlock  {
    NSDictionary *parameters = @{
                                 @"id" : [cityId  stringValue],
                                 @"APPID" : WTApiKey
                                 };
    [self sendGETRequest:WTWeatherURL
              parameters:parameters
             cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                 success:^(NSHTTPURLResponse *response, id responseObject) {
                     NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uid == %@",cityId];
                     [WTCoreDataManager saveContext:^(NSManagedObjectContext *context) {
                         WTCity *city = [WTCity findOrCreateWithContext:context
                                                              predicate:predicate];
                         [city updateWeatheInfoFromJson:(NSDictionary *)responseObject context:context];
                     } success:^(NSManagedObjectContext *context) {
                         if (successBlock) {
                             WTCity *city = [WTCity findObjectWithContext:context
                                                                predicate:predicate
                                                                    error:nil];
                             successBlock(city);
                         }
                     } failure:failureBlock];
                 }
                 failure:^(NSHTTPURLResponse *response, NSError *error) {
                     if (failureBlock) {
                         failureBlock(error);
                     }
                 }];
}

#pragma mark - REST methods

- (void)sendGETRequest:(NSString *)path
            parameters:(id)parameters
           cachePolicy:(NSURLRequestCachePolicy)cachePolicy
               success:(void (^)(NSHTTPURLResponse *response, id responseObject))success
               failure:(void (^)(NSHTTPURLResponse *response, NSError *error))failure {
    NSURLRequest *getRequest = [self createRequest:path
                                            method:@"GET"
                                    withParameters:parameters
                                       cachePolicy:cachePolicy];
    [self sendRequest:getRequest
              success:success
              failure:failure];
}

#pragma mark - Base methods

- (nullable NSError *)findErrorInResponse:(id)responseObject forUrlHost:(NSString *)host {
    NSError *error = nil;
    if ([responseObject isKindOfClass:[NSDictionary class]]) {
        if ([responseObject wt_checkObjectOnNullForKeyPath:WTErrorMessagePath]) {
            NSString *code = [responseObject wt_checkObjectOnNullForKeyPath:WTCodPath];
            NSString *errorMessage = [responseObject wt_checkObjectOnNullForKeyPath:WTErrorMessagePath];
            NSDictionary *userInfo = @{
                                       NSLocalizedDescriptionKey : errorMessage
                                       };
            error = [NSError errorWithDomain:host
                                        code:[code integerValue]
                                    userInfo:userInfo];
            
        }
    }
    return error;
}

- (NSURLRequest *)createRequest:(NSString *)path
                         method:(NSString *)method
                 withParameters:(NSDictionary *)parameters
                    cachePolicy:(NSURLRequestCachePolicy)cachePolicy {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:path] cachePolicy:cachePolicy timeoutInterval:0];
    [request setHTTPMethod:method];
#warning if you use another methods example :"POST","PUD","DELETE" etc. Then you should add methods setHTTPBody
    NSURLComponents *url = [[NSURLComponents alloc] initWithURL:request.URL resolvingAgainstBaseURL:YES];
    NSMutableArray *queryItems = NSMutableArray.new;
    [parameters enumerateKeysAndObjectsUsingBlock:^(NSString *name, NSString *value, BOOL *stop) {
        [queryItems addObject:[NSURLQueryItem queryItemWithName:name
                                                          value:[value stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet]]];
    }];
    url.queryItems = queryItems;
    request.URL = url.URL;
    return [request copy];
}

- (NSURLSessionDataTask *)sendRequest:(NSURLRequest *)request
                              success:(void (^)(NSHTTPURLResponse *, id))success
                              failure:(void (^)(NSHTTPURLResponse *, NSError *))failure {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSURLSessionDataTask *dataTask = [self.session dataTaskWithRequest:request
                                                     completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                                         [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                                                         NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                                                         id responseObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
                                                         error = [self findErrorInResponse:responseObject forUrlHost:request.URL.host];
                                                         if (error) {
                                                             if (failure) {
                                                                 failure(httpResponse,error);
                                                             }
                                                         }
                                                         else {
                                                             if (success) {
                                                                 success(httpResponse,responseObject);
                                                             }
                                                         }
                                                     }];
    [dataTask resume];
    return dataTask;
}


@end
