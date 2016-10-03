//
//  NSDictionary+CheckOnNull.m
//  weatherTest
//
//  Created by Vitaliy on 29.09.16.
//  Copyright © 2016 Vitaliy Shevtsov. All rights reserved.
//

#import "NSDictionary+CheckOnNull.h"

@implementation NSDictionary (CheckOnNull)

- (id)wt_checkObjectOnNullForKeyPath:(NSString *)keyPath {
    return ([self valueForKeyPath:keyPath] == [NSNull null]) ? nil : [self valueForKeyPath:keyPath];
}

@end
