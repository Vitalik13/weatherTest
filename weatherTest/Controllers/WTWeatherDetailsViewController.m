//
//  WTWeatherDetailsViewController.m
//  weatherTest
//
//  Created by Vitaliy on 28.09.16.
//  Copyright © 2016 Vitaliy Shevtsov. All rights reserved.
//

#import "WTWeatherDetailsViewController.h"
#import "WTNetworkManager.h"
#import <SDWebImage/UIImageView+WebCache.h>

#import "WTCity.h"
#import "WTWeather.h"

#import "UIViewController+Alert.h"

@interface WTWeatherDetailsViewController ()

@property (weak, nonatomic) IBOutlet UILabel *tempLabel;
@property (weak, nonatomic) IBOutlet UILabel *pressureLabel;
@property (weak, nonatomic) IBOutlet UILabel *humidityLabel;
@property (weak, nonatomic) IBOutlet UILabel *mainLabel;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *imageActivityIndicatorView;

@end

@implementation WTWeatherDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNavigationBar];
    if (!self.city.existWeatherData || self.city.dateIsExpired) {
        [self loadWeatherData];
    }
    else {
       [self setupWeatherCity:self.city];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Load

- (void)loadWeatherData {
    __weak typeof(self) weakSelf = self;
    [[WTNetworkManager sharedInstance] getCityWeatherByCityId:self.city.uid
                                                 successBlock:^(WTCity *city) {
                                                     [weakSelf setupWeatherCity:city];
                                                 }
                                                 failureBlock:^(NSError *error) {
                                                     [weakSelf wt_showErrorAlertViewWithError:error okHandler:^(UIAlertAction *action) {
                                                         [weakSelf.navigationController popViewControllerAnimated:YES];
                                                     }];
                                                 }];
}

#pragma mark - UI

- (void)setupNavigationBar {
    self.title = self.city.name;
}

- (void)setupWeatherCity:(WTCity *)city {
    self.mainLabel.text = city.weather.main;
    self.tempLabel.text = [NSString stringWithFormat:@"%@%.1lf°, %@",city.tempCelsius > 0 ? @"+" : @"",city.tempCelsius,city.weather.detailedDescription];
    self.pressureLabel.text = [NSString stringWithFormat:@"Pressure : %ld P",[city.pressure integerValue]];
    self.humidityLabel.text = [NSString stringWithFormat:@"Humidity : %ld %%",[city.humidity integerValue]];
    NSString *imageUrl = city.tempCelsius > 0 ? WTImageHotURL : WTImageColdURL;
    __weak typeof(self) weakSelf = self;
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:imageUrl]
                             completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                 weakSelf.imageView.image = image;
                                 [weakSelf.imageActivityIndicatorView stopAnimating];
                             }];
}

@end
