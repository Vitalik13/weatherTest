//
//  WTWeather.h
//  weatherTest
//
//  Created by Vitaliy on 29.09.16.
//  Copyright © 2016 Vitaliy Shevtsov. All rights reserved.
//

#import <CoreData/CoreData.h>

@class WTCity;
@interface WTWeather : NSManagedObject

@property (nonatomic,strong) NSNumber *uid;
@property (nonatomic,strong) NSString *main;
@property (nonatomic,strong) NSString *detailedDescription;

@property (nonatomic,strong) NSSet<WTCity *> *cities;

+ (WTWeather *)weatherFromJson:(NSDictionary *)json context:(NSManagedObjectContext *)context;

@end
