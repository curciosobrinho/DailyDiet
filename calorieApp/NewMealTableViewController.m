//
//  NewMealTableViewController.m
//  calorieApp
//
//  Created by Curcio Jamunda Sobrinho on 03/08/15.
//  Copyright (c) 2015 Curcio Jamunda. All rights reserved.
//

#import "NewMealTableViewController.h"
#import "HelperFunctions.h"

@interface NewMealTableViewController () {
    
    BOOL isAddingNewFile;
}
@property (nonatomic) PFFile *imageFile;
@property (nonatomic) PFObject *objectPFOImage;
@property (nonatomic) UIDatePicker *datePicker;
@end

@implementation NewMealTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    isAddingNewFile=NO;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    [timeFormatter setTimeStyle:NSDateFormatterShortStyle];
    
    self.entryDate.text = [NSString stringWithFormat:@"%@ %@",[dateFormatter stringFromDate:[NSDate date]], [timeFormatter stringFromDate:[NSDate date]]];
    
    if (self.objectToUse) {
        
        PFFile *file =self.objectToUse[@"image"];
        if (file) {
            self.image.image =[UIImage imageWithData:[file getData]];
        }
        self.mealText.text=[self.objectToUse[@"text"] description];
        self.calorieText.text=[self.objectToUse[@"calories"] description];
        self.entryDate.text = [self.objectToUse[@"dateAndTime"] description];
        self.title =[self.objectToUse[@"text"] description];
    }

    self.datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 310.0, self.view.frame.size.width, 100.0)];
    [self.datePicker addTarget:self action:@selector(didChooseDate:) forControlEvents:UIControlEventValueChanged];
    [self.datePicker setHidden:YES];
    [self.datePicker setDatePickerMode:UIDatePickerModeDateAndTime];
    [self.datePicker setDate:[NSDate date]];
    [self.tableView addSubview:self.datePicker];
}

-(IBAction)closeAdd:(id)sender {
    
    [self dismissKeyboardAndHidePicker];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Save pressed

-(IBAction)saveNew:(id)sender {
    
    [self dismissKeyboardAndHidePicker];
    
    if (!self.mealText.text.length) {
        
        [HelperFunctions showErrorWithMessage:@"Missing field"  title:@"Please fill meal field"];
        return;
    }
    
    if (![self.datePicker isHidden]) {
        
        [self didChooseDate:@"k"];
    }

    // if we have new image, first we have to upload, otherwise, just save the Meal
    if (isAddingNewFile) {
        
        UIImage *imageFromView = self.image.image;
        self.imageFile = [PFFile fileWithName:@"image.jpg" data:UIImageJPEGRepresentation(imageFromView, 0.5)];
        
        // Request a background execution task to allow us to finish uploading
        // the photo even if the app is sent to the background
        self.photoPostBackgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
            [[UIApplication sharedApplication] endBackgroundTask:self.photoPostBackgroundTaskId];
        }];
        
        // Save the Photo PFObject
        [self.imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
            if (succeeded) {
                
                [self saveAndPostTheMeal];
                
            } else {
                
                [[UIApplication sharedApplication] endBackgroundTask:self.photoPostBackgroundTaskId];
                [self.imageFile save];
                [HelperFunctions showErrorWithMessage:@"Problems to upload"  title:@"Upload could not be done. Try again later."];
            }
            
        } progressBlock:^(int percentDone) {
            
            if ([self.delegate respondsToSelector:@selector(uploadImageCompletedInPercent:)]) {
                
                [self.delegate uploadImageCompletedInPercent:percentDone];
            }
        }];
   
        // no changes to the pic, just save the meal
    } else {
        
        [self saveAndPostTheMeal];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void) saveAndPostTheMeal {
    
    PFObject *objMeal = [PFObject objectWithClassName:@"Meals"];
    
    if (self.objectToUse) {
        
        objMeal = self.objectToUse;
    }
    
    objMeal[@"text"] = self.mealText.text;
    
    // if from "Show all users" show the meals from that user
    if (self.externalUser){
        
        objMeal[@"relUser"] = self.externalUser;
        
    } else {
        
        objMeal[@"relUser"] = [PFUser currentUser];
    }
    
    if (isAddingNewFile) {
        
        objMeal[@"image"] = self.imageFile;
    }
    
    objMeal[@"calories"] = @([self.calorieText.text intValue]);
    objMeal[@"dateAndTime"] = self.entryDate.text;
    objMeal[@"dateAndTimeDate"] = [self.datePicker date];
    
    [objMeal saveEventually:^(BOOL succeeded, NSError *error) {
        
        if (succeeded) {
            
            // lets tell everyone interested
            [self postNotificationForNewMeal];
            
            // and trigger the delegates
            if ([self.delegate respondsToSelector:@selector(didSaveMeal)]) {
                
                [self.delegate didSaveMeal];
            }
            
        } else {
            
            [HelperFunctions showErrorWithMessage:@"Problems to upload"  title:@"Upload could not be done. Try again."];
            NSLog(@"error=%@",error);
        }
        
        self.objectToUse=nil;
        
        if (self.photoPostBackgroundTaskId) {
            
            [[UIApplication sharedApplication] endBackgroundTask:self.photoPostBackgroundTaskId];
            
        }
        
    }];

    
}

#pragma mark - Table view data source
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.calorieText resignFirstResponder];
    [self.mealText resignFirstResponder];
    [self.datePicker setHidden:YES];
    
    if (indexPath.row == 0) {

        [self showActionSheet];
        
    } else if (indexPath.row == 1) {
        
        [self.calorieText becomeFirstResponder];
    
    } else if (indexPath.row == 2) {
        
        [self.mealText becomeFirstResponder];
        
    } else if (indexPath.row == 3) {
        
        [self.datePicker setHidden:NO];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    
    [self.datePicker setHidden:YES];
}

-(void) showActionSheet {
    
    UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:@"Choose" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Picture",@"Existing Foto", nil];
    [action showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    // cancel button
     if (buttonIndex==2) {
         return;
     }
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate=self;
    
    if (buttonIndex==0) {
        
        // first we check if there a camera available (simulator does not have one)
        if (![UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront|UIImagePickerControllerCameraDeviceRear]) {
            
            [HelperFunctions showErrorWithMessage:@"No Camera" title:@"No camera available"];
            return;
        }
        
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.showsCameraControls=YES;
        
    } else if (buttonIndex==1) {
        
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;

    }

    [self presentViewController:picker animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {

    isAddingNewFile=YES;
    
    [picker dismissViewControllerAnimated:YES completion:^{
        
        [self setImageWithAnimation:[info objectForKey:UIImagePickerControllerOriginalImage]];

    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(void) setImageWithAnimation:(UIImage *) imageFromPicker {
    
    [self.image setHidden:YES];
    
    UIImageView *iv = [[UIImageView alloc] initWithImage:imageFromPicker];
    [self.tableView addSubview:iv];
    
    [UIView animateWithDuration:0.4 animations:^{
        
        iv.frame = CGRectMake(100.0, 8.0, 80.0, 100.0);
        
    } completion:^(BOOL finished) {
        
        [self.image setHidden:NO];
        self.image.image = imageFromPicker;
        
        [iv removeFromSuperview];
    }];
    
}

#pragma mark - DatePicker
-(void) didChooseDate:(id) sender {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    [timeFormatter setTimeStyle:NSDateFormatterShortStyle];
    
    self.entryDate.text = [NSString stringWithFormat:@"%@ %@",[dateFormatter stringFromDate:[self.datePicker date]], [timeFormatter stringFromDate:[self.datePicker date]]];
    [self.datePicker setHidden:YES];
}

#pragma mark - postNotification
-(void) postNotificationForNewMeal {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NEW_MEAL_ADDED object:nil];
}

#pragma mark - helper function
-(void) dismissKeyboardAndHidePicker {
    
    [self.mealText resignFirstResponder];
    [self.calorieText resignFirstResponder];
    [self.datePicker setHidden:YES];
}
@end