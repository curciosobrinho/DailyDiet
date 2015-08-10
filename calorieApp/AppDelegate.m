//
//  AppDelegate.m
//  calorieApp
//
//  Created by Curcio Jamunda Sobrinho on 02/08/15.
//  Copyright (c) 2015 Curcio Jamunda. All rights reserved.
//

#import "AppDelegate.h"
#import <Parse/Parse.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    // [Optional] Power your app with Local Datastore. For more info, go to
    // https://parse.com/docs/ios_guide#localdatastore/iOS
    [Parse enableLocalDatastore];
    
    // Initialize Parse.
    [Parse setApplicationId:@"AMfdHXN52kx1pwMe2KmOWVO1JR7hV0Gusj3Zker5"
                  clientKey:@"XGCoNTvdvjvjlBXHAAeHeQMoH30B3kzM6cTCMbjj"];
    
    // [Optional] Track statistics around application opens.
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    
    
    return YES;
}

@end