//
//  CreateActivityViewController.h
//  CardRecognition
//
//  Created by sunshinek31 on 15/6/5.
//  Copyright (c) 2015年 bournejason. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Contactactivity.h"

@interface CreateActivityViewController : UIViewController
@property (weak, nonatomic) IBOutlet UINavigationBar *theNavigationBar;
@property (weak, nonatomic) IBOutlet UIButton *sendActivityButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *optionButton;
@property (weak, nonatomic) IBOutlet UITextView *contentTextView;
@property (weak, nonatomic) IBOutlet UILabel *currentActivityTypeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UIButton *updataButton;

@property(nonatomic,strong) Contactactivity *contactactivity;

- (IBAction)chooseActivityType:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)addContact:(id)sender;
- (IBAction)updataContact:(id)sender;

@end
