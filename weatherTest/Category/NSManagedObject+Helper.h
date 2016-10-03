//
//  NSManagedObject+Helper.h
//  weatherTest
//
//  Created by Vitaliy on 29.09.16.
//  Copyright © 2016 Vitaliy Shevtsov. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (Helper)

+ (id)findOrCreateWithContext:(NSManagedObjectContext *)context
                    predicate:(NSPredicate *)predicate;

+ (id)findObjectWithContext:(NSManagedObjectContext *)context
                  predicate:(NSPredicate *)predicate
                      error:(NSError **)error;

+ (NSArray *)findObjectsWithContext:(NSManagedObjectContext *)context
                          predicate:(NSPredicate *)predicate
                              error:(NSError **)error;
@end
