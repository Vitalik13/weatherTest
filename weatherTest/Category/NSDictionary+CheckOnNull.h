//
//  NSDictionary+CheckOnNull.h
//  weatherTest
//
//  Created by Vitaliy on 29.09.16.
//  Copyright © 2016 Vitaliy Shevtsov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (CheckOnNull)

- (id)wt_checkObjectOnNullForKeyPath:(NSString *)keyPath;

@end
