//
//  FilterViewController.h
//  calorieApp
//
//  Created by Curcio Jamunda Sobrinho on 09/08/15.
//  Copyright (c) 2015 Curcio Jamunda. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FilterViewControllerDelegate <NSObject>

-(void) didPickedFromDate:(NSDate *)fromDate andToDate:(NSDate *)toDate;
-(void) didPressCancel;
@end

@interface FilterViewController : UIViewController
@property (nonatomic, weak) id <FilterViewControllerDelegate> delegate;
@end
