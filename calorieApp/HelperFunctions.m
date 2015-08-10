//
//  HelperViewController.m
//  calorieApp
//
//  Created by Curcio Jamunda Sobrinho on 04/08/15.
//  Copyright (c) 2015 Curcio Jamunda. All rights reserved.
//

#import "HelperFunctions.h"

@interface HelperFunctions ()

@end

@implementation HelperFunctions

+(void) showErrorWithMessage:(NSString *) msg title:(NSString *) title {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    
    [alert show];
}

@end
