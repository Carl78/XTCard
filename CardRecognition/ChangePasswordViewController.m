//
//  ChangePasswordViewController.m
//  CardRecognition
//
//  Created by admin on 15/11/24.
//  Copyright (c) 2015年 bournejason. All rights reserved.
//

#import "ChangePasswordViewController.h"
#import "SVProgressHUD.h"
#import "UserHttpRequestService.h"

#define kInputBackColor 0x707070

@interface ChangePasswordViewController (){

    NSString *username,*userid;
    UserHttpRequestService *userHttpRequestService;
}
@end

@implementation ChangePasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupNavigationView];
    
    //判断是否已经登陆
    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
    username = [defaults objectForKey:@"username"];//根据键值取出name
    userid = [defaults objectForKey:@"userid"];//根据键值取出id
    
    self.userNameTextField.text = username;
    
    self.userNameTextField.layer.cornerRadius = 7;
    //self.userNameTextField.borderStyle = UITextBorderStyleRoundedRect;
    //self.userNameTextField.keyboardType = UIKeyboardTypeASCIICapable;
    //self.userNameTextField.userInteractionEnabled = NO;
    
    self.userPasswordTextField.layer.cornerRadius = 7;
    //self.userPasswordTextField.borderStyle = UITextBorderStyleRoundedRect;
    //self.userPasswordTextField.secureTextEntry = YES;
    //self.userPasswordTextField.keyboardType = UIKeyboardTypeEmailAddress;

    self.userNewPasswordTextField.layer.cornerRadius = 7;
    //self.userNewPasswordTextField.borderStyle = UITextBorderStyleRoundedRect;
    //self.userNewPasswordTextField.secureTextEntry = YES;
    //self.userNewPasswordTextField.keyboardType = UIKeyboardTypeEmailAddress;
    
    self.userNewRepasswordTextField.layer.cornerRadius = 7;
    //self.userNewRepasswordTextField.borderStyle = UITextBorderStyleRoundedRect;
    //self.userNewRepasswordTextField.secureTextEntry = YES;
    //self.userNewRepasswordTextField.keyboardType = UIKeyboardTypeEmailAddress;
    
    [self.changeButton.layer setCornerRadius:7];
    [self.changeButton addTarget:self action:@selector(changePwd) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - Button

-(void)changePwd{
    NSString *oldPwd = self.userPasswordTextField.text;
    NSString *newPwd = self.userNewPasswordTextField.text;
    NSString *reNewPwd = self.userNewRepasswordTextField.text;
    
    if (oldPwd.length==0||newPwd.length==0||reNewPwd.length==0) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"输入错误" message:@"请输入相关密码信息" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        return;
    }
    if (![newPwd isEqualToString:reNewPwd]) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"输入错误" message:@"新密码和确认密码不一致" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    //显示加载动画
    [SVProgressHUD show];
    
    if(userHttpRequestService==nil)
        userHttpRequestService = [[UserHttpRequestService alloc]init];
    
    [userHttpRequestService updatePwdwithUserId:userid oldPwd:oldPwd newPwd:newPwd success:^(ExceptionInfo *info)
     {
         //清空登录信息
         NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
         
         [defaults setObject:nil forKey:@"username"];
         [defaults setObject:nil forKey:@"userid"];
         [SVProgressHUD dismiss];
         
         [self.navigationController popViewControllerAnimated:NO];
     }
                                          error:^(NSString *strFail) {
                                              [SVProgressHUD dismiss];
                                              UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"登陆失败" message:[NSString stringWithFormat:@"%@",strFail] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                                              [alert show];
                                          }];
    
}

#pragma mark - Navigate

-(void)setupNavigationView {
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(41, 0, 100, 30)];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setText:@"修改密码"];
    titleLabel.font = [UIFont boldSystemFontOfSize:20];
    self.navigationItem.titleView = titleLabel;
    
    [self setupMenuBarButtonItems];
}

- (void)setupMenuBarButtonItems {
    UIBarButtonItem *negativeLeftSpacer = [[UIBarButtonItem alloc]
                                           initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                           target:nil action:nil];
    negativeLeftSpacer.width = -15;
    self.navigationItem.leftBarButtonItems = @[negativeLeftSpacer, [self leftMenuBarButtonItem]];
    
}
- (UIBarButtonItem *)leftMenuBarButtonItem {
    
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0,0,30,30)];
    [button setImage:[UIImage imageNamed:@"return_back_normal"] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"return_back_pressed"] forState:UIControlStateSelected];
    [button addTarget:self action:@selector(leftSideMenuButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [button setTitleEdgeInsets:UIEdgeInsetsMake(-1, -55, 0, 0)];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithCustomView:button];
    item.style = UIBarButtonSystemItemAction;
    return item;
}

- (void)leftSideMenuButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Other

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
