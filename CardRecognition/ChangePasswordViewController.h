//
//  ChangePasswordViewController.h
//  CardRecognition
//
//  Created by admin on 15/11/24.
//  Copyright (c) 2015年 bournejason. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChangePasswordViewController : UIViewController

//@property (weak, nonatomic) IBOutlet UINavigationItem *navigateItem;
//@property (weak, nonatomic) IBOutlet UINavigationBar *navigateBar;
@property (strong, nonatomic) IBOutlet UITextField *userNameTextField;
@property (strong, nonatomic) IBOutlet UITextField *userPasswordTextField;
@property (strong, nonatomic) IBOutlet UITextField *userNewPasswordTextField;
@property (strong, nonatomic) IBOutlet UITextField *userNewRepasswordTextField;
@property (strong, nonatomic) IBOutlet UIButton *changeButton;

//@property (strong, nonatomic) IBOutlet UIView *changeView;
//@property (weak, nonatomic) IBOutlet UITextField *accountTextField;

@end
