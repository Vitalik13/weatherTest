//
//  TWAPIController.h
//  weatherTest
//
//  Created by Vitaliy on 28.09.16.
//  Copyright © 2016 Vitaliy Shevtsov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

extern NSString *WTImageColdURL;
extern NSString *WTImageHotURL;

@class WTCity;
@interface WTNetworkManager : NSObject;

+ (WTNetworkManager *)sharedInstance;

- (void)downloadAndSaveAllCitiesWithSuccessBlock:(void(^)(NSManagedObjectContext *context))successBlock
                                    failureBlock:(void(^)(NSError *error))failureBlock;

- (void)getCityWeatherByCityId:(NSNumber *)cityId
                  successBlock:(void(^)(WTCity *city))successBlock
                  failureBlock:(void(^)(NSError *error))failureBlock;

@end
