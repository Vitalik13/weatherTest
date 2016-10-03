//
//  UIViewController+Alert.m
//  weatherTest
//
//  Created by Vitaliy on 01.10.16.
//  Copyright © 2016 Vitaliy Shevtsov. All rights reserved.
//

#import "UIViewController+Alert.h"

@implementation UIViewController (Alert)

#pragma mark - Error methods

- (void)wt_showErrorAlertViewWithError:(NSError *)error okHandler:(void (^)(UIAlertAction *action))handler {
    [self wt_showAlertWithTitle:@"Error"
                        message:error.localizedDescription
             titleSuccessButton:nil
           handlerSuccessButton:nil
              titleCancelButton:@"Ok"
            handlerCancelButton:handler];
}

#pragma mark - Base methods

- (void)wt_showAlertWithTitle:(NSString *)title
                      message:(NSString *)message
           titleSuccessButton:(NSString *)successButton
         handlerSuccessButton:(void (^)(UIAlertAction *))successBlock
            titleCancelButton:(NSString *)cancelButton
          handlerCancelButton:(void (^)(UIAlertAction *))cancelBlock {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    if (successButton != nil) {
        UIAlertAction *actionSuccess = [UIAlertAction actionWithTitle:successButton
                                                                style:UIAlertActionStyleDefault
                                                              handler:successBlock];
        [alertController addAction:actionSuccess];    }
    
    
    if (cancelButton != nil) {
        UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:cancelButton
                                                               style:UIAlertActionStyleCancel
                                                             handler:cancelBlock];
        [alertController addAction:actionCancel];
    }
    
    [self presentViewController:alertController animated:YES completion:NULL];
    
    alertController.view.tintColor = [UIColor darkGrayColor];
    
    if (successButton == nil && cancelButton == nil) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [alertController dismissViewControllerAnimated:YES completion:^{}];
        });
    }
}

@end
