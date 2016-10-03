//
//  WTCity.m
//  weatherTest
//
//  Created by Vitaliy on 29.09.16.
//  Copyright © 2016 Vitaliy Shevtsov. All rights reserved.
//

#import "WTCity.h"
#import "WTWeather.h"

#import "NSDictionary+CheckOnNull.h"
#import "NSManagedObject+Helper.h"

NSString * const WTCityIdPath = @"_id";
NSString * const WTCityNamePath = @"name";
NSString * const WTCityCountryPath = @"country";
NSString * const WTCityLonPath = @"coord.lon";
NSString * const WTCityLatPath = @"coord.lat";

NSString * const WTCityWeatherPath = @"weather";
NSString * const WTCityTempPath = @"main.temp";
NSString * const WTCityPressurePath = @"main.pressure";
NSString * const WTCityHumidityPath = @"main.humidity";

NSTimeInterval const WTWeatherExpiryTime = 3600;
float const WTKelvinDelta = 273.15;

@implementation WTCity

@dynamic uid;
@dynamic name;
@dynamic country;
@dynamic longitude;
@dynamic latitude;
@dynamic temp;
@dynamic pressure;
@dynamic humidity;
@dynamic expiryDate;

@dynamic weather;

+ (WTCity *)cityFromJson:(NSDictionary *)json context:(NSManagedObjectContext *)context {
    WTCity *city = nil;
    NSNumber *cityId = [json wt_checkObjectOnNullForKeyPath:WTCityIdPath];
    if (cityId) {
        city = [WTCity findOrCreateWithContext:context
                                     predicate:[NSPredicate predicateWithFormat:@"uid == %@",cityId]];
        if (city) {
            city.uid = cityId;
            city.name = [json wt_checkObjectOnNullForKeyPath:WTCityNamePath];
            city.country = [json wt_checkObjectOnNullForKeyPath:WTCityCountryPath];
            city.longitude = [json wt_checkObjectOnNullForKeyPath:WTCityLonPath];
            city.latitude = [json wt_checkObjectOnNullForKeyPath:WTCityLatPath];
        }
    }
    return city;
}

- (void)updateWeatheInfoFromJson:(NSDictionary *)json context:(NSManagedObjectContext *)context {
    self.temp = [json wt_checkObjectOnNullForKeyPath:WTCityTempPath];
    self.pressure = [json wt_checkObjectOnNullForKeyPath:WTCityPressurePath];
    self.humidity = [json wt_checkObjectOnNullForKeyPath:WTCityHumidityPath];
    self.longitude = [json wt_checkObjectOnNullForKeyPath:WTCityLonPath];
    self.latitude = [json wt_checkObjectOnNullForKeyPath:WTCityLatPath];
    self.weather = [WTWeather weatherFromJson:[[json wt_checkObjectOnNullForKeyPath:WTCityWeatherPath] firstObject] context:context];
    self.expiryDate = [NSDate dateWithTimeIntervalSinceNow:WTWeatherExpiryTime];
}

#pragma mark - Accessory

- (BOOL)existWeatherData {
    return self.temp != nil && self.pressure != nil && self.humidity != nil && self.weather != nil && self.expiryDate;
}

- (BOOL)dateIsExpired {
    return [self.expiryDate compare:[NSDate date]] == NSOrderedAscending;
}

- (float)tempCelsius {
    return [self.temp floatValue] - WTKelvinDelta;
}

@end
