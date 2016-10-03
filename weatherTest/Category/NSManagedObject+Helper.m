//
//  NSManagedObject+Helper.m
//  weatherTest
//
//  Created by Vitaliy on 29.09.16.
//  Copyright © 2016 Vitaliy Shevtsov. All rights reserved.
//

#import "NSManagedObject+Helper.h"
#import "WTCoreDataManager.h"

@implementation NSManagedObject (Helper)

#pragma mark - Public Methods

+ (id)findOrCreateWithContext:(NSManagedObjectContext *)context
                    predicate:(NSPredicate *)predicate {
    NSManagedObject *object = nil;
    object = [self findObjectWithContext:context
                               predicate:predicate
                                   error:nil];;
    if (!object) {
        object = [[self alloc] initWithContext:context];
    }
    return object;
}


+ (id)findObjectWithContext:(NSManagedObjectContext *)context
                  predicate:(NSPredicate *)predicate
                      error:(NSError **)error {
    NSFetchRequest *fetchRequest = [self fetchRequest];
    fetchRequest.predicate = predicate;
    fetchRequest.fetchLimit = 1;
    __block id object = nil;
    [context performBlockAndWait:^{
        object = [[context executeFetchRequest:fetchRequest error:error] firstObject];
    }];
    return object;
}

+ (NSArray *)findObjectsWithContext:(NSManagedObjectContext *)context
                          predicate:(NSPredicate *)predicate
                              error:(NSError **)error {
    NSFetchRequest *fetchRequest = [self fetchRequest];
    fetchRequest.predicate = predicate;
    
    __block NSArray *objects = nil;
    [context performBlockAndWait:^{
        objects = [context executeFetchRequest:fetchRequest error:error];
    }];
    return objects;
}

@end
