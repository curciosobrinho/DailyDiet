//
//  FilterViewController.m
//  calorieApp
//
//  Created by Curcio Jamunda Sobrinho on 09/08/15.
//  Copyright (c) 2015 Curcio Jamunda. All rights reserved.
//

#import "FilterViewController.h"

@interface FilterViewController()

@property (nonatomic) UIView *containerView;
@property (nonatomic) UIView *fromDateRow;
@property (nonatomic) UIView *toDateRow;
@property (nonatomic) UILabel *titleLb;
@property (nonatomic) UILabel *fromLb;
@property (nonatomic) UILabel *toLb;
@property (nonatomic) UILabel *fromDateTimeLb;
@property (nonatomic) UILabel *toDateTimeLb;
@property (nonatomic) UIButton *cancelBt;
@property (nonatomic) UIButton *saveBt;
@property (nonatomic) NSString *startStrDate, *endStrDate;
@property (nonatomic) NSDate *startDate, *endDate;
@property (nonatomic) UIDatePicker *datePicker;
@property (nonatomic) UIView *bckViewDatePicker;
@property (nonatomic) BOOL isSelectingFromDate;
@end

@implementation FilterViewController

-(void)viewDidLoad {
    
    // this one we will create all in code
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    [timeFormatter setTimeStyle:NSDateFormatterShortStyle];
    
    // yesterday
    self.startDate = [NSDate dateWithTimeIntervalSinceNow:-86400];
    
    self.startStrDate = [NSString stringWithFormat:@"%@ %@",[dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:-86400]], [timeFormatter stringFromDate:[NSDate date]]];
    
    self.endDate = [NSDate date];
    self.endStrDate = [NSString stringWithFormat:@"%@ %@",[dateFormatter stringFromDate:[NSDate date]], [timeFormatter stringFromDate:[NSDate date]]];
    
    
    // the "almost transparent" background
    self.view.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.6];
    
    // first the containerView
    self.containerView = [self returnContainerView];
    
    // now lets add a title
    self.titleLb = [self returnTitleLb];
    [self.containerView addSubview:self.titleLb];
    
    // now lets add the from date row
    self.fromDateRow = [self returnRowWithPosition:CGPointMake(0, CGRectGetMaxY(self.titleLb.frame)+3)];
    self.fromLb = [self returnDateLabelWithFrame:CGRectMake(5.0, 12.5, self.fromDateRow.frame.size.width/2-30.0, 20.0) andText:@"Start"];
    [self.fromDateRow addSubview:self.fromLb];
    
    self.fromDateTimeLb = [self returnDateLabelWithFrame:CGRectMake(CGRectGetMaxX(self.fromLb.frame), 12.5, self.fromDateRow.frame.size.width/2+30.0, 20.0) andText:self.startStrDate];
    
    [self.fromDateRow addSubview:self.fromDateTimeLb];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapOnFromDate:)];
    [self.fromDateRow addGestureRecognizer:tap];
    
    [self.containerView addSubview:self.fromDateRow];
    
    // now lets add the to date row
    // notice that we remove 1 from position Y to be the same
    // and thus on the same as the last (fromDateRow)
    self.toDateRow = [self returnRowWithPosition:CGPointMake(0, CGRectGetMaxY(self.fromDateRow.frame)-1)];
    [self.containerView addSubview:self.toDateRow];
    
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapOnToDate:)];
    [self.toDateRow addGestureRecognizer:tap1];
    
    self.toLb = [self returnDateLabelWithFrame:CGRectMake(5.0, 12.5, self.toDateRow.frame.size.width/2-30.0, 20.0) andText:@"End"];
    [self.toDateRow addSubview:self.toLb];
    
    self.toDateTimeLb = [self returnDateLabelWithFrame:CGRectMake(CGRectGetMaxX(self.toLb.frame), 12.5, self.toDateRow.frame.size.width/2+30.0, 20.0) andText:self.endStrDate];
    
    [self.toDateRow addSubview:self.toDateTimeLb];
    
    // now the buttons
    self.cancelBt = [self returnButtonWithFrame:CGRectMake(0, CGRectGetMaxY(self.toDateRow.frame)-0.5, self.containerView.frame.size.width/2, self.containerView.frame.size.height+1-CGRectGetMaxY(self.toDateRow.frame)) title:@"Clear" triggerSelector:@selector(closeController)];
    [self.containerView addSubview:self.cancelBt];
    
    self.saveBt = [self returnButtonWithFrame:CGRectMake(CGRectGetMaxX(self.cancelBt.frame)-0.5, CGRectGetMaxY(self.toDateRow.frame)-0.5, self.containerView.frame.size.width/2+1, self.containerView.frame.size.height+1-CGRectGetMaxY(self.toDateRow.frame)) title:@"Filter" triggerSelector:@selector(pressedFilter:)];
    [self.containerView addSubview:self.saveBt];
    
    [self.view addSubview:self.containerView];
    
    // lets create the datepicker
    self.bckViewDatePicker = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-200.0, self.view.frame.size.width, 200.0)];
    self.bckViewDatePicker.backgroundColor = [UIColor whiteColor];
    self.datePicker = [self returnDatePickerWithFrame:CGRectMake(0, 0, self.bckViewDatePicker.frame.size.width, self.bckViewDatePicker.frame.size.height)];
    [self.bckViewDatePicker addSubview:self.datePicker];
    [self.view addSubview:self.bckViewDatePicker];
    
    [self showHideDatePicker];
}

-(void) didTapOnFromDate:(id) sender {
    self.isSelectingFromDate=YES;
    [self showHideDatePicker];
}

-(void) didTapOnToDate:(id) sender {
    self.isSelectingFromDate=NO;
    [self showHideDatePicker];
}

-(UIView *) returnContainerView {
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(20.0, 20.0, 210.0, 180.0)];
    view.backgroundColor=[UIColor whiteColor];
    CGPoint center = self.view.center;
    center.y-=50.0;
    view.center =center;
    view.layer.cornerRadius=5.0;
    [view setClipsToBounds:YES];
    return view;
}

-(UIView *) returnRowWithPosition:(CGPoint) position{
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(position.x, position.y, self.containerView.frame.size.width, 45.0)];
    view.backgroundColor=[UIColor whiteColor];
    view.layer.borderWidth=0.5;
    view.layer.borderColor = [UIColor lightGrayColor].CGColor;
    return view;
}

-(UILabel *) returnTitleLb {
    
    UILabel *lb = [[UILabel alloc] initWithFrame:CGRectMake(0, 10.0, self.containerView.frame.size.width, 30.0)];
    lb.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    lb.textAlignment = NSTextAlignmentCenter;
    lb.text=NSLocalizedString(@"Select a Period", nil);
    return lb;
}

-(UILabel *) returnDateLabelWithFrame:(CGRect) frame andText:(NSString *)textToWrite {
    
    UILabel *lb = [[UILabel alloc] initWithFrame:frame];
    lb.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
    lb.textAlignment = NSTextAlignmentNatural;
    lb.text=textToWrite;
    return lb;
}

-(UIButton *) returnButtonWithFrame:(CGRect) frame title:(NSString *)btTitle triggerSelector:(SEL) selector {
    
    UIButton *bt = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    bt.frame=frame;
    [bt setTitle:btTitle forState:UIControlStateNormal];
    bt.layer.borderColor=[UIColor lightGrayColor].CGColor;
    bt.layer.borderWidth=0.5;
    [bt addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    return bt;
}

-(UIDatePicker *) returnDatePickerWithFrame:(CGRect) frame {
    
    UIDatePicker *picker = [[UIDatePicker alloc] initWithFrame:frame];
    [picker addTarget:self action:@selector(didChooseDate:) forControlEvents:UIControlEventValueChanged];
    [picker setDatePickerMode:UIDatePickerModeDateAndTime];
    [picker setDate:[NSDate date]];
    return picker;
}

-(void) closeController {
    
    // if delegate handles it, it has to dismiss this VC
    if ([self.delegate respondsToSelector:@selector(didPressCancel)]){
        
        [self.delegate didPressCancel];
        return;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void) pressedFilter:(id) sender {
    
    if ([self.delegate respondsToSelector:@selector(didPickedFromDate:andToDate:)]){
        
        [self.delegate didPickedFromDate:self.startDate andToDate:self.endDate];
    }
}

#pragma mark - DatePicker

-(void) didChooseDate:(id) sender {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    [timeFormatter setTimeStyle:NSDateFormatterShortStyle];
    
    NSString *resultDate = [NSString stringWithFormat:@"%@ %@",[dateFormatter stringFromDate:[self.datePicker date]], [timeFormatter stringFromDate:[self.datePicker date]]];
    
    if (self.isSelectingFromDate) {
        
        self.startDate = [self.datePicker date];
        self.startStrDate = resultDate;
        self.fromDateTimeLb.text = self.startStrDate;
        
    } else {
        
        self.endDate = [self.datePicker date];
        self.endStrDate = resultDate;
        self.toDateTimeLb.text = self.endStrDate;
    }
    
    [self showHideDatePicker];
}

-(void) showHideDatePicker {
    
    [self.bckViewDatePicker setHidden:![self.bckViewDatePicker isHidden]];
}

// here lets reposition things according to orientation
-(void) viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    
    [UIView animateWithDuration:0.25 animations:^{
        self.containerView.center = CGPointMake(size.width/2, size.height/2);
        self.bckViewDatePicker.frame = CGRectMake(0.0, size.height-200, size.width, 200.0);
        self.datePicker.center = CGPointMake(self.bckViewDatePicker.center.x, self.datePicker.center.y);
    }];
}
@end