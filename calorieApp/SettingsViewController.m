//
//  SettingsViewController.m
//  calorieApp
//
//  Created by Curcio Jamunda Sobrinho on 06/08/15.
//  Copyright (c) 2015 Curcio Jamunda. All rights reserved.
//

#import "SettingsViewController.h"
#import "PFPrimaryButton.h"
#import <ParseUI/ParseUI.h>
#import "PFColor.h"
#import "UsersTableViewController.h"
#import "Constants.h"

@interface SettingsViewController()

@property (nonatomic) PFPrimaryButton *logOutBt;
@property (nonatomic) PFPrimaryButton *showUsers;
@property (nonatomic) PFTextField *goalField;
@property (nonatomic) PFObject *goalObject;
@end
@implementation SettingsViewController

-(void)logOUT:(id)sender {
    
    [PFUser logOutInBackgroundWithBlock:^(NSError *error){
        self.goalObject=nil;
        [self.tabBarController setSelectedIndex:0];
    }];
}

-(void)viewDidLoad {
    
    [super viewDidLoad];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignResponderForField)];
    self.view.userInteractionEnabled=YES;
    [self.view addGestureRecognizer:tap];
    
    self.view.backgroundColor = [PFColor commonBackgroundColor];
    
    self.goalField = [[PFTextField alloc] initWithFrame:CGRectMake(0, 80, self.view.frame.size.width, 60.0)
                                      separatorStyle:PFTextFieldSeparatorStyleBottom];
    self.goalField.keyboardType = UIKeyboardTypeNumberPad;
    self.goalField.placeholder = NSLocalizedString(@"Your Daily Goal", nil);
    [self.view addSubview:self.goalField];
    
    // Only admins
    self.showUsers = [[PFPrimaryButton alloc] initWithBackgroundImageColor:[PFColor signupButtonBackgroundColor]];
    [self.showUsers setTitle:NSLocalizedString(@"Show all users", nil) forState:UIControlStateNormal];
    self.showUsers.frame=CGRectMake(0, CGRectGetMaxY(self.goalField.frame)+10.0, self.view.frame.size.width, 60.0);
    [self.showUsers addTarget:self action:@selector(showAllUsers:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.showUsers];
    [self.showUsers setHidden:YES];
    
    self.logOutBt = [[PFPrimaryButton alloc] initWithBackgroundImageColor:[PFColor loginButtonBackgroundColor]];
    [self.logOutBt setTitle:NSLocalizedString(@"Log Out", nil) forState:UIControlStateNormal];
    self.logOutBt.frame=CGRectMake(0, self.view.frame.size.height-140, self.view.frame.size.width, 60.0);
    [self.logOutBt addTarget:self action:@selector(logOUT:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.logOutBt];
}

-(void) showAllUsers:(id) sender {
    
    UsersTableViewController *userVC = [[UsersTableViewController alloc] initWithClassName:@"_User"];
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:userVC];
    [self presentViewController:nc animated:YES completion:nil];
    
}

-(void) resignResponderForField {
    
    [self.goalField resignFirstResponder];
}

-(void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    // Only admins
    if ([[[[PFUser currentUser] objectForKey:@"role"] description] isEqualToString:@"A"]) {
        
        [self.showUsers setHidden:NO];
        
    } else {
        
        [self.showUsers setHidden:YES];
    }

    // lets user local storage
    NSUserDefaults *ud =[NSUserDefaults standardUserDefaults];
    if ([ud objectForKey:@"goal"]) {
        
        self.goalField.text=[[ud objectForKey:@"goal"] description];
        
    }
    
    // and now lets see if we have info on parse
    PFQuery *query = [PFQuery queryWithClassName:@"Goal"];
    [query whereKey:@"relUser" equalTo:[PFUser currentUser]];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error){
        
        if (object) {
            self.goalObject = object;
            self.goalField.text=[object[@"dailyGoal"] description];
        }
    }];
}

-(void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    if (self.goalField.text.length) {
        
        // lets save locally with NSUserDefaults
        [[NSUserDefaults standardUserDefaults] setInteger:[self.goalField.text integerValue] forKey:@"goal"];
        
        // and on Parse
        if (!self.goalObject) {
            PFQuery *query = [PFQuery queryWithClassName:@"Goal"];
            [query whereKey:@"relUser" equalTo:[PFUser currentUser]];
            
            [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error){
                
                if (object) {
                    self.goalObject=object;
                    
                } else {
                    self.goalObject = [PFObject objectWithClassName:@"Goal"];
                    [self.goalObject setObject:[PFUser currentUser] forKey:@"relUser"];
                }
                [self.goalObject setObject:self.goalField.text forKey:@"dailyGoal"];
                [self.goalObject saveEventually];
            }];

        } else {
            
            [self.goalObject setObject:self.goalField.text forKey:@"dailyGoal"];
            [self.goalObject saveEventually];
        }
        
    }

    [self.goalField resignFirstResponder];
}

-(void)viewDidAppear:(BOOL)animated {
    
    // *** Tweak ***
    // I had to force to recalculate otherwise the logout got lost on landscape
    // because in ViewDidLoad the size is not set (the landscape size)
    CGSize size = self.view.frame.size;
    if (size.height<size.width) {
        
        // lets animate to look cool
        [UIView animateWithDuration:0.25 animations:^{
            self.logOutBt.frame=CGRectMake(0, size.height-140, size.width, 60.0);
            self.goalField.frame = CGRectMake(0, 40.0, size.width, 60.0);
            self.showUsers.frame=CGRectMake(0, CGRectGetMaxY(self.goalField.frame)+10.0, size.width, 60.0);
            
        } completion:^(BOOL finished) {
            [self.goalField setNeedsLayout];
            [self.goalField setNeedsDisplay];
        }];
    }
}
// here lets pratice to resize things according to orientation (actually size of orientation)
-(void) viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    
    [self resignResponderForField];
    
    // lets animate to look cool
    [UIView animateWithDuration:0.25 animations:^{
        
        self.logOutBt.frame=CGRectMake(0, size.height-140, size.width, 60.0);
        
        // it will be landscape
        if (size.width>size.height) {
            
            self.goalField.frame = CGRectMake(0, 40.0, size.width, 60.0);
            
        } else {
            
            self.goalField.frame = CGRectMake(0, 80.0, size.width, 60.0);
        }
        
        self.showUsers.frame=CGRectMake(0, CGRectGetMaxY(self.goalField.frame)+10.0, size.width, 60.0);
        
    } completion:^(BOOL finished) {
        [self.goalField setNeedsLayout];
        [self.goalField setNeedsDisplay];
    }];
}

@end
