//
//  WTWeather.m
//  weatherTest
//
//  Created by Vitaliy on 29.09.16.
//  Copyright © 2016 Vitaliy Shevtsov. All rights reserved.
//

#import "WTWeather.h"

#import "NSDictionary+CheckOnNull.h"
#import "NSManagedObject+Helper.h"

NSString * const WTWeatherIdPath = @"id";
NSString * const WTWeatherMainPath = @"main";
NSString * const WTWeatherDescriptionPath = @"description";

@implementation WTWeather

@dynamic uid;
@dynamic main;
@dynamic detailedDescription;

@dynamic cities;

+ (WTWeather *)weatherFromJson:(NSDictionary *)json context:(NSManagedObjectContext *)context {
    WTWeather *weather = nil;
    NSNumber *weatherId = [json wt_checkObjectOnNullForKeyPath:WTWeatherIdPath];
    if (weatherId) {
        weather = [WTWeather findOrCreateWithContext:context
                                           predicate:[NSPredicate predicateWithFormat:@"uid == %@",weatherId]];
        if (weather) {
            weather.uid = weatherId;
            weather.main = [json wt_checkObjectOnNullForKeyPath:WTWeatherMainPath];
            weather.detailedDescription = [json wt_checkObjectOnNullForKeyPath:WTWeatherDescriptionPath];
        }
    }
    return weather;
}

@end
