//
//  MealsTableViewController.m
//  calorieApp
//
//  Created by Curcio Jamunda Sobrinho on 04/08/15.
//  Copyright (c) 2015 Curcio Jamunda. All rights reserved.
//

#import "MealsTableViewController.h"
#import <Parse/PFObject.h>
#import <Parse/PFQuery.h>
#import <ParseUI/PFTableViewCell.h>
#import "NewMealTableViewController.h"
#import "Constants.h"
#import "FilterViewController.h"

@interface MealsTableViewController () <NewMealTableViewControllerDelegate, FilterViewControllerDelegate>

@property (nonatomic) NSString *filterTitleForSection;
@property (nonatomic) NSDate *startDate;
@property (nonatomic) NSDate *endDate;

@end

@implementation MealsTableViewController

- (instancetype)initWithClassName:(NSString *)className {
    
    self = [super initWithClassName:className];
    if (self) {
        self.pullToRefreshEnabled = YES;
        self.objectsPerPage = 15;
        self.paginationEnabled = YES;
        self.loadingViewEnabled=YES;
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
    
    // by default, you can set only one right barButtonItem on storyBoard
    // lets add our second here
    UIBarButtonItem *filterBT = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(showFilter:)];
    NSMutableArray *btArray = [NSMutableArray arrayWithArray:self.navigationItem.rightBarButtonItems];
    
    [btArray addObject:filterBT];
    
    // if we are pushed from "Show all users" lets change the buttons order
    // to leave the back button alone :D
    if (self.externalUser){
        
        [btArray addObject:self.editButtonItem];
        
    } else {
        
        self.navigationItem.leftBarButtonItem = self.editButtonItem;
    }
    
    self.navigationItem.rightBarButtonItems= btArray;
    [self addNotificationObserver];
    self.filterTitleForSection =@"All meals";
}

-(void) addNotificationObserver {
    
    // to avoid multiples observers, the easiest way is to remove first, then add
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NEW_MEAL_ADDED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSaveMeal) name:NEW_MEAL_ADDED object:nil];
}

- (void)deleteSelectedItems:(id)sender {
    
    [self removeObjectsAtIndexPaths:self.tableView.indexPathsForSelectedRows];
    [self performSelector:@selector(postNotificationForRefresh) withObject:nil afterDelay:3];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self removeObjectAtIndexPath:indexPath];
    }
}

#pragma mark Data

- (PFQuery *)queryForTable {
    
    PFQuery *query = [PFQuery queryWithClassName:@"Meals"];
    
    // if from "Show all users" show the meals from that user
    if (self.externalUser){
        
        [query whereKey:@"relUser" equalTo:self.externalUser];
        
    } else {
        
        [query whereKey:@"relUser" equalTo:[PFUser currentUser]];
    }
    
    if (self.startDate) {
        [query whereKey:@"dateAndTimeDate" greaterThanOrEqualTo:self.startDate];
        [query whereKey:@"dateAndTimeDate" lessThanOrEqualTo:self.endDate];
    }
    
    [query orderByDescending:@"dateAndTimeDate"];
    return query;
}

#pragma mark TableView

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 30.0;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 25.0)];
    backView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    UILabel *lb = [[UILabel alloc] initWithFrame:CGRectMake(0, 5.0, self.view.frame.size.width, 20.0)];
    lb.text=[NSString stringWithFormat:@"Showing: %@",self.filterTitleForSection];
    if (!self.objects.count) {
        
        lb.text=@"No meals found. Add above";
    }
    lb.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2];
    lb.textAlignment=NSTextAlignmentCenter;
    [backView addSubview:lb];
    
    return backView;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
                        object:(PFObject *)object {
    
    
    static NSString *cellIdentifier = @"Cell";
    PFTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    // for this one we use the cell view from the storyboard
    // we use viewWithTag to find the views
    
    PFImageView *imageView =(PFImageView *)[cell viewWithTag:1];
    imageView.image = [UIImage imageNamed:@"empty-image"];
    imageView.file = object[@"image"];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    [imageView loadInBackground];
    [imageView setClipsToBounds:YES];
    [imageView.layer setCornerRadius:5.0];
    
    UILabel *mealLb = (UILabel *)[cell viewWithTag:2];
    UILabel *caloriesLb = (UILabel *)[cell viewWithTag:3];
    UILabel *dateTimeLb = (UILabel *)[cell viewWithTag:4];
    
    mealLb.text = object[@"text"];
    caloriesLb.text = [NSString stringWithFormat:@"Calories: %@", object[@"calories"]];
    dateTimeLb.text =[object[@"dateAndTime"] description];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self showAddControllerForIndexPath:indexPath];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Navigation

-(void) showAddControllerForIndexPath:(NSIndexPath *) indexPath {
    
    PFObject *obj = nil;
    
    if (indexPath) {
        
        obj = [self objectAtIndexPath:indexPath];
        
    }
    // here we load the VC (ViewController) from storyboard, note that the I have set the
    // storyboard ID "addNewMeal" to be able to use it this way
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    NewMealTableViewController *vcMeal = [story instantiateViewControllerWithIdentifier:@"addNewMeal"];
    vcMeal.objectToUse = obj;
    vcMeal.delegate=self;
    
    if (self.externalUser) {
        
        vcMeal.externalUser=self.externalUser;
    }
    
    // we add a NavigationController to inheritance the navbar, to be able to push, etc
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vcMeal];
    [nc.navigationBar setTranslucent:NO];
    
    [self presentViewController:nc animated:YES completion:nil];
}

-(IBAction)addNew:(id)sender {
    
    [self showAddControllerForIndexPath:nil];
}

#pragma mark - NewMealTableViewControllerDelegate

-(void)didSaveMeal {
    
    self.title = @"Meals";
    [self loadObjects];
}

-(void) uploadImageCompletedInPercent:(NSInteger)percentDone {
    
    self.title = [NSString stringWithFormat:@"Uploading %ld%%", percentDone];
}

- (void)objectsDidLoad:(NSError *)error{
    
    [super objectsDidLoad:error];
    
    if (!error) {
        
        [self postNotificationForRefresh];
        
    }
}
-(void) postNotificationForRefresh {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:DATA_REFRESHED object:nil];
}

#pragma mark - Show Filter
-(void)showFilter:(id)sender {
    
    FilterViewController *filter = [FilterViewController new];
    filter.delegate = self;
    
    // here we do the trick to be able to show almost transparent
    // view controller
    filter.modalPresentationStyle= UIModalPresentationOverFullScreen;
    
    [self presentViewController:filter animated:YES completion:nil];
}

#pragma mark Filter Delegate
-(void) didPickedFromDate:(NSDate *)fromDate andToDate:(NSDate *)toDate {
    
    self.startDate = fromDate;
    self.endDate = toDate;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    [timeFormatter setTimeStyle:NSDateFormatterShortStyle];
    
    NSString *start = [NSString stringWithFormat:@"%@ %@",[dateFormatter stringFromDate:self.startDate], [timeFormatter stringFromDate:self.startDate]];
    
    NSString *end = [NSString stringWithFormat:@"%@ %@",[dateFormatter stringFromDate:self.endDate], [timeFormatter stringFromDate:self.endDate]];
    
    self.filterTitleForSection =[NSString stringWithFormat:@"From %@ to %@",start, end];
    [self loadObjects];
    
    [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
}

-(void) didPressCancel {
    
    self.startDate=nil;
    self.endDate=nil;
    self.filterTitleForSection =@"All meals";
    [self loadObjects];
    [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
}

// when rotate just reload the TableView to be have the section header view and labels repositioned
-(void) viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    
    [self.tableView reloadData];
}

@end