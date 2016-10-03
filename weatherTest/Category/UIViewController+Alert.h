//
//  UIViewController+Alert.h
//  weatherTest
//
//  Created by Vitaliy on 01.10.16.
//  Copyright © 2016 Vitaliy Shevtsov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (Alert)

- (void)wt_showErrorAlertViewWithError:(NSError *)error okHandler:(void (^)(UIAlertAction *action))handler;

- (void)wt_showAlertWithTitle:(NSString *)title
                      message:(NSString *)message
           titleSuccessButton:(NSString *)successButton
         handlerSuccessButton:(void (^)(UIAlertAction *))successBlock
            titleCancelButton:(NSString *)cancelButton
          handlerCancelButton:(void (^)(UIAlertAction *))cancelBlock;

@end
