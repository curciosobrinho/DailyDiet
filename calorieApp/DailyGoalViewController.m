//
//  FirstViewController.m
//  calorieApp
//
//  Created by Curcio Jamunda Sobrinho on 02/08/15.
//  Copyright (c) 2015 Curcio Jamunda. All rights reserved.
//

#import "DailyGoalViewController.h"
#import "HelperFunctions.h"
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import "NewMealTableViewController.h"

@interface DailyGoalViewController () <NewMealTableViewControllerDelegate> {
    
    int caloriesLeft, caloriesGoal;
}

@property (atomic) NSMutableArray *mealsArray;
@end

@implementation DailyGoalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // just to avoid not having a goal
    caloriesGoal=1500;
    
    self.mealsArray = [NSMutableArray array];
    
    // lets create the tableview programmatically - the 292 is 224(y) + 10(from roundView) + 48
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 224.0, self.view.frame.size.width, self.view.frame.size.height-292) style:UITableViewStylePlain];
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    [self.tableView registerNib:[UINib nibWithNibName:@"FirstCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"FirstCell"];
    [self.view addSubview:self.tableView];
    
    // lets create the roundView programmatically
    self.roundView = [[UIView alloc] initWithFrame:CGRectMake(self.view.center.x-100.0, 10.0, 200.0, 200.0)];
    [self.roundView setClipsToBounds:YES];
    [self.roundView.layer setCornerRadius:100.0];
    self.roundView.backgroundColor = [UIColor greenColor];
    [self.view addSubview:self.roundView];
    
    // now the label inside the roundView
    self.insideRoundLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 90.0, 180.0, 20)];
    self.insideRoundLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    [self.roundView addSubview:self.insideRoundLabel];
    self.insideRoundLabel.text = [NSString stringWithFormat:@"%d cal left", caloriesGoal];
    self.insideRoundLabel.textAlignment = NSTextAlignmentCenter;
    self.insideRoundLabel.translatesAutoresizingMaskIntoConstraints=NO;
    
    // important to set the size to grow accordingly
    self.insideRoundLabel.minimumScaleFactor=0.4;
    self.insideRoundLabel.adjustsFontSizeToFitWidth=YES;
    
    // lets add constraits programatticaly too
    [self setConstraitsForLabel];
    
    [self addNotificationObserver];
}

-(void) addNotificationObserver {
    
    // to avoid multiples observers, the easiest way is to remove first, then add
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NEW_MEAL_ADDED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSaveMeal) name:NEW_MEAL_ADDED object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DATA_REFRESHED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRefresh) name:DATA_REFRESHED object:nil];
}

-(void)checkIfGoalWasChanged {
    
    NSUserDefaults *ud =[NSUserDefaults standardUserDefaults];
    
    if ([ud objectForKey:@"goal"]) {
        
        caloriesGoal=[[ud objectForKey:@"goal"] intValue];
    }
}

// constraits programmatically
-(void) setConstraitsForLabel {
    
    // lets add center Y constrait
    [self.roundView addConstraint:[NSLayoutConstraint constraintWithItem:self.insideRoundLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.roundView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    
    // lets add center X constrait
    [self.roundView addConstraint:[NSLayoutConstraint constraintWithItem:self.insideRoundLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.roundView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    
    // lets add width constrait
    [self.roundView addConstraint:[NSLayoutConstraint constraintWithItem:self.insideRoundLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.roundView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0]];
    
}

// here lets pratice to resize things according to orientation (actually size of orientation)
-(void) viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    
    // lets animate to look cool
    [UIView animateWithDuration:0.25 animations:^{
        
        // we get the frame from roudView
        CGRect frameRound = self.roundView.frame;
        
        // we always want the smallest size from width or height
        // as it is a round, both must be the sale
        frameRound.size.height = MIN(size.width*0.625,size.height*0.3);
        frameRound.size.width = MIN(size.width*0.625,size.height*0.3);
        
        // the center X we use the width/2 minus half of its width
        frameRound.origin.x = size.width/2-frameRound.size.width/2;
        self.roundView.frame = frameRound;
        
        // remake the round by using cornerRadius of half size of the width (that is the same as height)
        [self.roundView.layer setCornerRadius:frameRound.size.width/2];
        
        // now lets resize the tableview
        CGRect frameTable = self.tableView.frame;
        frameTable.size = size;
        
        // we need to remove from the height of the tabbar (I used 48 to have 1 point free)
        CGFloat tabBarHeight = 48.0;
        if (size.width > self.view.frame.size.width) {
            
            tabBarHeight=18.0;
        }
        
        frameTable.size.height -=CGRectGetMaxY(frameRound)+tabBarHeight;
        
        // and reposition the Y axis from the round ball
        frameTable.origin.y = CGRectGetMaxY(self.roundView.frame)+10;
        
        self.tableView.frame = frameTable;
        
    } completion:^(BOOL finished) {
        
        // we have to reload to "repaint" the tableview (section headers and cells)
        [self.tableView reloadData];
    }];
}

-(void) fillRoundView {
    
    // here we change the colors according to the calories left
    UIColor *roundColor = [UIColor greenColor];
    
    caloriesLeft = caloriesGoal - [self totalCaloriesDay];
    
    if (caloriesLeft<500) {
        
        roundColor = [UIColor yellowColor];
    }
    
    if (caloriesLeft<300) {
        
        roundColor = [UIColor orangeColor];
    }
    
    if (caloriesLeft<1) {
        
        roundColor = [UIColor redColor];
    }
    
    [UIView animateWithDuration:1 animations:^{
        
        self.roundView.backgroundColor = roundColor;
        self.insideRoundLabel.text=[NSString stringWithFormat:@"%d calories left", caloriesLeft];
    }];
    
}

#pragma mark - Total Calories
-(int) totalCaloriesDay {
    
    int total = [[self.mealsArray valueForKeyPath:@"@sum.calories"] intValue];
    return total;
}

#pragma mark - data source - reload
-(void) reloadAllData {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    NSString *dateToSearch = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:[NSDate date]]];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Meals"];
    [query whereKey:@"relUser" equalTo:[PFUser currentUser]];
    [query whereKey:@"dateAndTime" hasPrefix:dateToSearch];
    [query orderByDescending:@"dateAndTime"];
    [query findObjectsInBackgroundWithTarget:self selector:@selector(callbackWithResult:error:)];
    
}

-(void)callbackWithResult:(NSArray *)result error:(NSError *)error {
    
    self.mealsArray = [NSMutableArray arrayWithArray:result];
    [self.tableView reloadData];
    [self fillRoundView];
}

-(UILabel *) createLogoLabelWithText:(NSString *) text frame:(CGRect )frame {
    
    UILabel *lb = [[UILabel alloc] initWithFrame:frame];
    lb.text=text;
    lb.font = [UIFont fontWithName:@"GillSans-Light" size:42];
    lb.textColor = [UIColor darkGrayColor];
    return lb;
}

#pragma mark - tableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.mealsArray.count;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 100.0;
}

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
    lb.text=[NSString stringWithFormat:@"Total Calories consumed today = %d", [self totalCaloriesDay]];
    lb.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2];
    lb.textAlignment=NSTextAlignmentCenter;
    [backView addSubview:lb];
    return backView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"FirstCell";
    PFTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    PFObject *object = [self.mealsArray objectAtIndex:indexPath.row];
    
    // for this one, we use the FirstCell.xib
    // we use the viewWithTag to find the views
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
        
        obj = [self.mealsArray objectAtIndex:indexPath.row];
        
    }
    
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    NewMealTableViewController *vcMeal = [story instantiateViewControllerWithIdentifier:@"addNewMeal"];
    vcMeal.objectToUse = obj;
    vcMeal.delegate=self;
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vcMeal];
    [nc.navigationBar setTranslucent:NO];
    
    [self presentViewController:nc animated:YES completion:nil];
}

#pragma mark NewMealTableViewControllerDelegate
// while uploading we just change the title, here we could show some view
-(void) uploadImageCompletedInPercent:(NSInteger) percentDone {
    
    self.title = [NSString stringWithFormat:@"Uploading %ld%%", percentDone];
}

// once done, we return to standard title and reload the data
-(void) didSaveMeal {
    
    self.title = @"Daily Goal";
    [self reloadAllData];
}

// once done, we return to standard title and reload the data
-(void) didRefresh {
    
    [self reloadAllData];
}

-(void)viewWillAppear:(BOOL)animated {
    
    // if logged, lets reload - we could optimize to avoid
    // reloading everytime
    if ([PFUser currentUser]) {
        
        [self reloadAllData];
    }
}

#pragma mark - Login
-(void) viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    // if not logged, show login controller
    if (![PFUser currentUser]) {
        
        PFLogInViewController *loginVC = [PFLogInViewController new];
        loginVC.logInView.logo = [self createLogoLabelWithText:@"Daily Diet" frame:loginVC.logInView.logo.frame];
        loginVC.signUpController.signUpView.logo=[self createLogoLabelWithText:@"Daily Diet" frame:loginVC.signUpController.signUpView.logo.frame];
        loginVC.delegate = self;
        loginVC.signUpController.delegate=self;
        [loginVC.logInView.dismissButton setHidden:YES];
        [self presentViewController:loginVC animated:YES completion:nil];
        return;
    }
    
    [self checkIfGoalWasChanged];
    [self fillRoundView];
}

- (BOOL)logInViewController:(PFLogInViewController *)logInController
shouldBeginLogInWithUsername:(NSString *)username
                   password:(NSString *)password {
    
    if (!username.length || !password.length) {
        
        [HelperFunctions showErrorWithMessage:@"Please fill all fields"  title:@"Missing field(s)"];
        
        return NO;
    }
    
    return YES;
}

- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    
    // lets post notification to update all lists
    [[NSNotificationCenter defaultCenter] postNotificationName:NEW_MEAL_ADDED object:nil];
    
    [logInController dismissViewControllerAnimated:YES completion:nil];
}

- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController {
    // here we could do something when the user cancels
    return;
}

#pragma mark - Signup
- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user {
    
    // we have to send the info to update the ROLE to USE
    [user setObject:@"U" forKey:@"role"];
    [user saveEventually];
    
    // now lets dismiss both view, the signup and the login
    [signUpController dismissViewControllerAnimated:YES completion:^{
        
        // lets post notification to update all lists
        [[NSNotificationCenter defaultCenter] postNotificationName:NEW_MEAL_ADDED object:nil];
    
        // and we have to dismiss the login that was being s
        [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
    }];
}

- (BOOL)signUpViewController:(PFSignUpViewController *)signUpController shouldBeginSignUp:(NSDictionary *)info {
    
    if (!signUpController.signUpView.usernameField.text.length || !signUpController.signUpView.passwordField.text.length || !signUpController.signUpView.emailField.text.length) {
        
        [HelperFunctions showErrorWithMessage:@"Please fill all fields"  title:@"Missing field(s)"];
        
        return NO;
    }
    
    return YES;
}

@end
