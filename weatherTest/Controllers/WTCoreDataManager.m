//
//  MTDatabaseController.m
//  weatherTest
//
//  Created by Vitaliy on 29.09.16.
//  Copyright © 2016 Vitaliy Shevtsov. All rights reserved.
//

#import "WTCoreDataManager.h"
#import "WTCity.h"

static NSPersistentContainer *_persistentContainer;

@implementation WTCoreDataManager

+ (NSPersistentContainer *)persistentContainer { return _persistentContainer;}

+ (void)setPersistentContainer:(NSPersistentContainer *)persistentContainer { _persistentContainer = persistentContainer;}

+ (NSManagedObjectContext *)mainContext {
    return WTCoreDataManager.persistentContainer.viewContext;
}

#pragma mark - Base methods

+ (void)saveContext:(void(^)(NSManagedObjectContext *context))contextBlock
            success:(void(^)(NSManagedObjectContext *context))success
            failure:(void(^)(NSError *error))failure {
    if (contextBlock) {
        [WTCoreDataManager.persistentContainer performBackgroundTask:^(NSManagedObjectContext * _Nonnull context) {
            contextBlock(context);
            NSError *error = nil;
            [context save:&error];
            if (error) {
                failure(error);
            }
            else {
                success(context);
            }
        }];
    }
}


@end
