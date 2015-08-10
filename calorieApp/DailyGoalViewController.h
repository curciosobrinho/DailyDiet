//
//  FirstViewController.h
//  calorieApp
//
//  Created by Curcio Jamunda Sobrinho on 02/08/15.
//  Copyright (c) 2015 Curcio Jamunda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ParseUI/ParseUI.h>

@interface DailyGoalViewController : UIViewController <PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate, UITableViewDataSource, UITableViewDelegate>
@property (nonatomic) UITableView *tableView;
@property (nonatomic) UIView *roundView;
@property (nonatomic) UILabel *insideRoundLabel;
@end