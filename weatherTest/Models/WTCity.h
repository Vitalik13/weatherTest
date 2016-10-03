//
//  WTCity.h
//  weatherTest
//
//  Created by Vitaliy on 29.09.16.
//  Copyright © 2016 Vitaliy Shevtsov. All rights reserved.
//

#import <CoreData/CoreData.h>

@class WTWeather;
@interface WTCity : NSManagedObject

@property (nonatomic,strong) NSNumber *uid;
@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSString *country;
@property (nonatomic,strong) NSNumber *longitude;
@property (nonatomic,strong) NSNumber *latitude;
@property (nonatomic,strong) NSNumber *temp;
@property (nonatomic,strong) NSNumber *pressure;
@property (nonatomic,strong) NSNumber *humidity;

@property (nonatomic,strong) NSDate *expiryDate;

@property (nonatomic,assign,readonly) float tempCelsius;
@property (nonatomic,assign,readonly) BOOL existWeatherData;
@property (nonatomic,assign,readonly) BOOL dateIsExpired;

@property (nonatomic,strong) WTWeather *weather;

+ (WTCity *)cityFromJson:(NSDictionary *)json context:(NSManagedObjectContext *)context;

- (void)updateWeatheInfoFromJson:(NSDictionary *)json context:(NSManagedObjectContext *)context;

@end
