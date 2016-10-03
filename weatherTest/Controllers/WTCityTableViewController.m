//
//  WTCityTableViewController.m
//  weatherTest
//
//  Created by Vitaliy on 28.09.16.
//  Copyright © 2016 Vitaliy Shevtsov. All rights reserved.
//

#import "WTCityTableViewController.h"
#import "WTWeatherDetailsViewController.h"

#import "WTNetworkManager.h"
#import "WTCoreDataManager.h"

#import "WTCity.h"

@interface WTCityTableViewController () <NSFetchedResultsControllerDelegate,UISearchBarDelegate>

@property (nonatomic,strong) NSFetchedResultsController *fetchedResultsController;

@property (strong, nonatomic) IBOutlet UIButton *toTopButton;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end

@implementation WTCityTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupToTopButton];
    [[self fetchedResultsControllerWithContext:[WTCoreDataManager mainContext]] performFetch:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self scrollViewDidScroll:self.tableView];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.toTopButton.hidden = YES;
}

#pragma mark - Handler

- (IBAction)toTopScrollTableView:(UIButton *)sender {
    [self.tableView setContentOffset:CGPointZero animated:YES];
    sender.hidden = YES;
}

- (IBAction)reload:(UIBarButtonItem *)sender {
    [self showLoadIndicator];
    __weak typeof(self) weakSelf = self;
    [[WTNetworkManager sharedInstance] downloadAndSaveAllCitiesWithSuccessBlock:^(NSManagedObjectContext *context) {
        [weakSelf hidLoadIndicator];
        [[weakSelf fetchedResultsControllerWithContext:context] performFetch:nil];
        [weakSelf searchBar:weakSelf.searchBar textDidChange:weakSelf.searchBar.text];
        [weakSelf.tableView reloadData];
    } failureBlock:^(NSError *error) {
        [weakSelf hidLoadIndicator];
    }];
}

#pragma mark - UI

- (void)setupToTopButton {
    self.toTopButton.layer.cornerRadius = CGRectGetWidth(self.toTopButton.frame) / 2;
    self.toTopButton.layer.borderWidth = 1.f;
    self.toTopButton.layer.borderColor = [UIColor blackColor].CGColor;
    CGFloat yPosition = self.navigationController.view.frame.size.height - (CGRectGetHeight(self.toTopButton.frame) + 10.f);
    CGFloat xPosition = CGRectGetWidth(self.navigationController.view.frame) - (CGRectGetWidth(self.toTopButton.frame) + 10.f);
    
    [self.toTopButton setFrame:CGRectMake(xPosition, yPosition, CGRectGetWidth(self.toTopButton.frame), CGRectGetHeight(self.toTopButton.frame))];
    [self.navigationController.view addSubview:self.toTopButton];
}

- (void)showLoadIndicator {
    UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    indicatorView.color = [UIColor blackColor];
    indicatorView.hidesWhenStopped = NO;
    [indicatorView startAnimating];
    UIBarButtonItem *loadBarButton = [[UIBarButtonItem alloc] initWithCustomView:indicatorView];
    [self.navigationItem setRightBarButtonItem:loadBarButton animated:NO];
}

- (void)hidLoadIndicator {
    UIBarButtonItem *refreshBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                                      target:self
                                                                                      action:@selector(reload:)];
    [self.navigationItem setRightBarButtonItem:refreshBarButton animated:NO];
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (![searchText isEqualToString:@""]) {
        NSPredicate *predicate =[NSPredicate predicateWithFormat:@"name BEGINSWITH[cd] %@", searchText];
        [self.fetchedResultsController.fetchRequest setPredicate:predicate];
    }
    else {
        [self.fetchedResultsController.fetchRequest setPredicate:nil];
    }
    NSError *error = nil;
    [[self fetchedResultsController] performFetch:&error];
    [self.tableView reloadData];
}

#pragma mark - NSFetchedResults

- (NSFetchedResultsController *)fetchedResultsControllerWithContext:(NSManagedObjectContext *)context {
    NSFetchRequest *fetchRequest = [WTCity fetchRequest];
    NSSortDescriptor *nameSort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:nameSort]];
    [fetchRequest setFetchBatchSize:20];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                    managedObjectContext:context
                                                                      sectionNameKeyPath:@"country"
                                                                               cacheName:nil];
    self.fetchedResultsController.delegate = self;
    
    return self.fetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type {
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        default:
            return;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(nullable NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(nullable NSIndexPath *)newIndexPath {
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] withCity:anObject];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView moveRowAtIndexPath:indexPath toIndexPath:newIndexPath];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

#pragma mark - UIScrollViewDelegate 

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    self.toTopButton.hidden = scrollView.contentOffset.y < self.tableView.bounds.size.height;
}

#pragma mark - Table View

- (void)configureCell:(UITableViewCell *)cell withCity:(WTCity *)city {
    cell.textLabel.text = city.name;
}

#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.fetchedResultsController sections] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return sectionInfo.name;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"CityCellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    WTCity *city = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    [self configureCell:cell withCity:city];
    return cell;
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [self.view endEditing:YES];
    if ([segue.destinationViewController isKindOfClass:[WTWeatherDetailsViewController class]]) {
        WTWeatherDetailsViewController *weatherDetailsViewController = (WTWeatherDetailsViewController*)segue.destinationViewController;
        weatherDetailsViewController.city = [[self fetchedResultsController] objectAtIndexPath:[self.tableView indexPathForCell:sender]];
    }
}


@end
