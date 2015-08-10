//
//  MealsTableViewController.h
//  calorieApp
//
//  Created by Curcio Jamunda Sobrinho on 04/08/15.
//  Copyright (c) 2015 Curcio Jamunda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ParseUI/ParseUI.h>

@interface MealsTableViewController : PFQueryTableViewController
@property (nonatomic) PFUser *externalUser;
@end