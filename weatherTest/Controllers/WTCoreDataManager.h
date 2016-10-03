//
//  MTDatabaseController.h
//  weatherTest
//
//  Created by Vitaliy on 29.09.16.
//  Copyright © 2016 Vitaliy Shevtsov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@class WTCity;
@interface WTCoreDataManager : NSObject

@property (class) NSPersistentContainer *persistentContainer;

+ (NSManagedObjectContext *)mainContext;

+ (void)saveContext:(void(^)(NSManagedObjectContext *context))contextBlock
            success:(void(^)(NSManagedObjectContext *context))success
            failure:(void(^)(NSError *error))failure;

@end
