//
//  NewMealTableViewController.h
//  calorieApp
//
//  Created by Curcio Jamunda Sobrinho on 03/08/15.
//  Copyright (c) 2015 Curcio Jamunda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@protocol NewMealTableViewControllerDelegate <NSObject>

@optional
-(void) uploadImageCompletedInPercent:(NSInteger) percentDone;
-(void) didSaveMeal;

@end

@interface NewMealTableViewController : UITableViewController <UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate>
@property (nonatomic, weak) IBOutlet UIImageView *image;
@property (nonatomic, weak) IBOutlet UITextField *mealText;
@property (nonatomic, weak) IBOutlet UITextField *calorieText;
@property (nonatomic, weak) IBOutlet UILabel *entryDate;
@property (nonatomic) NSUInteger photoPostBackgroundTaskId;
@property (nonatomic) PFObject *objectToUse;
@property (nonatomic) PFUser *externalUser;
@property (nonatomic, weak) id <NewMealTableViewControllerDelegate> delegate;
@end
