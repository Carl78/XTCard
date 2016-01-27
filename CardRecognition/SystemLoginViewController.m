//
//  SystemLoginViewController.m
//  CardRecognition
//  系统登陆视图控制器
//  Created by bournejason on 15/5/5.
//  Copyright (c) 2015年 bournejason. All rights reserved.
//

#import "SystemLoginViewController.h"
#import "MFSideMenu.h"
#import <QuartzCore/QuartzCore.h>
#import "UserHttpRequestService.h"
#import "SVProgressHUD.h"
#import "ChangePwdViewController.h"
#import "CardManageViewController.h"
#import "ChangePasswordViewController.h"


#define kInputBackColor 0x707070
@interface SystemLoginViewController (){
    NSString *username;
    NSString *userid;
    UserHttpRequestService *userHttpRequestService;
    UIView *inputBackView,*whiteBackView;
    NSArray *controllers;
}
@property (nonatomic,strong) UITextField *userNameTextField,*userPasswordTextField;
@end

@implementation SystemLoginViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // Do any additional setup after loading the view.
    
    int width = [UIScreen mainScreen].bounds.size.width;
    int height = [UIScreen mainScreen].bounds.size.height;
    
    //初始化主View
    UIView *mainView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    mainView.backgroundColor = [UIColor blackColor];
    self.view = mainView;
    
    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
    self.navigationController.navigationBar.translucent = YES;
    
    //设置视图标题view
    //self.title = @"名片夹";
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(41, 0, 100, 30)];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setText:@"用户登录"];
    titleLabel.font = [UIFont boldSystemFontOfSize:20];
    self.navigationItem.titleView = titleLabel;
    
    
    whiteBackView = [[UIView alloc]initWithFrame:CGRectMake(0, 60, width, height-60)];
    whiteBackView.backgroundColor = [UIColor whiteColor];
    
    
    inputBackView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, width, 230)];
    inputBackView.backgroundColor = [UIColor colorWithRed:((float)((kInputBackColor & 0xFF0000) >> 16))/255.0 green:((float)((kInputBackColor & 0xFF00) >> 8))/255.0 blue:((float)(kInputBackColor & 0xFF))/255.0 alpha:1.0];
    
    
    UIBarButtonItem *negativeLeftSpacer = [[UIBarButtonItem alloc]
                                           initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                           target:nil action:nil];
    negativeLeftSpacer.width = -15;
    
    self.navigationItem.leftBarButtonItems = @[negativeLeftSpacer, [self leftMenuBarButtonItem]];
    
    //判断是否已经登陆
    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
    username = [defaults objectForKey:@"username"];//根据键值取出name
    userid = [defaults objectForKey:@"userid"];//根据键值取出id
    

    if (userid==nil || [userid isEqualToString:@""]) {
        
    
        //未登陆
        UILabel *userNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 20, 100, 40)];
        self.userNameTextField = [[UITextField alloc]initWithFrame:CGRectMake(110, 20, width-110-10, 40)];
        userNameLabel.text = @"用户账号：";
        userNameLabel.font = [UIFont boldSystemFontOfSize:18];
        userNameLabel.textColor = [UIColor whiteColor];
    
        self.userNameTextField.layer.cornerRadius = 7;
        self.userNameTextField.borderStyle = UITextBorderStyleRoundedRect;
        self.userNameTextField.keyboardType = UIKeyboardTypeASCIICapable;
    
        UILabel *userPasswordLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 70, 100, 40)];
        self.userPasswordTextField = [[UITextField alloc]initWithFrame:CGRectMake(110, 70, width-110-10, 40)];
        userPasswordLabel.text = @"登陆密码：";
        userPasswordLabel.font = [UIFont boldSystemFontOfSize:18];
        userPasswordLabel.textColor = [UIColor whiteColor];

        self.userPasswordTextField.layer.cornerRadius = 7;
        self.userPasswordTextField.borderStyle = UITextBorderStyleRoundedRect;
        self.userPasswordTextField.secureTextEntry = YES;
        self.userPasswordTextField.keyboardType = UIKeyboardTypeEmailAddress;
        
        UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(10, 140, width-10-10, 50)];
        [button setTitle:@"登录" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        button.backgroundColor = [UIColor blackColor];
        [button.layer setCornerRadius:7];
        [button addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];

        
        [inputBackView addSubview:userNameLabel];
        [inputBackView addSubview:self.userNameTextField];
        [inputBackView addSubview:userPasswordLabel];
        [inputBackView addSubview:self.userPasswordTextField];
        [inputBackView addSubview:button];
    }else{
        //已登陆
        UILabel *hintLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 40, width-10, 40)];
        
        NSString *string =[NSString stringWithFormat:@"尊敬的%@,您已登录！",username];
        hintLabel.text = string;
        hintLabel.font = [UIFont boldSystemFontOfSize:16];
        hintLabel.textColor = [UIColor whiteColor];
        
        hintLabel.textAlignment = NSTextAlignmentCenter;
        
        //退出按钮
        UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(10, 140, width/2-10-5, 50)];
        [button setTitle:@"退出" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        button.backgroundColor = [UIColor blackColor];
        [button.layer setCornerRadius:7];
        
        [button addTarget:self action:@selector(logout) forControlEvents:UIControlEventTouchUpInside];
        
        //修改密码
        UIButton *changePwdButton = [[UIButton alloc]initWithFrame:CGRectMake(width/2+5,140, width/2-10-5, 50)];
        [changePwdButton setTitle:@"修改密码" forState:UIControlStateNormal];
        [changePwdButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        changePwdButton.backgroundColor = [UIColor blackColor];
        [changePwdButton.layer setCornerRadius:7];
        
        [changePwdButton addTarget:self action:@selector(changePwd) forControlEvents:UIControlEventTouchUpInside];

        
        [inputBackView addSubview:hintLabel];
        [inputBackView addSubview:button];
        [inputBackView addSubview:changePwdButton];
    }
    
    [whiteBackView addSubview:inputBackView];
    [self.view addSubview:whiteBackView];
    
    

}
- (void)changePwd{
    //ChangePwdViewController *changePwdController = [[ChangePwdViewController alloc]init];
    ChangePasswordViewController *changePwdController = [[ChangePasswordViewController alloc]init];
    
    [self.navigationController pushViewController:changePwdController animated:NO];
}
- (void)login{
    
    //显示加载动画
    [SVProgressHUD show];
        
        
        if(userHttpRequestService==nil)
            userHttpRequestService = [[UserHttpRequestService alloc]init];
        
        [userHttpRequestService loginWithName:self.userNameTextField.text andPassword:self.userPasswordTextField.text success:^(User *user) {
            
            [SVProgressHUD dismiss];
            
            int result = [user.exceptionInfo.Result intValue];
            
            if (result > 0) {
                username = [user.loginInfo valueForKey:@"LoginName"];
                userid = [NSString stringWithFormat:@"%@",[user.loginInfo valueForKey:@"UserID"]];
                
                //存储登录信息
                NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
                [defaults setObject:username forKey:@"username"];
                [defaults setObject:userid forKey:@"userid"];
                
                //修改页面信息
                [inputBackView removeFromSuperview];
                NSArray *arr = [inputBackView subviews];
                for (UIView *view in arr) {
                    [view removeFromSuperview];
                }
                //已登陆
                int width = [UIScreen mainScreen].bounds.size.width;
                int height = [UIScreen mainScreen].bounds.size.height;
                UILabel *hintLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 40, width-10, 40)];
                
                NSString *string =[NSString stringWithFormat:@"尊敬的%@,您已登录！",username];
                hintLabel.text = string;
                hintLabel.font = [UIFont boldSystemFontOfSize:16];
                hintLabel.textColor = [UIColor whiteColor];
                
                hintLabel.textAlignment = NSTextAlignmentCenter;
                
                //退出按钮
                UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(10, 140, width/2-10-5, 50)];
                [button setTitle:@"退出" forState:UIControlStateNormal];
                [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                button.backgroundColor = [UIColor blackColor];
                [button.layer setCornerRadius:7];
                
                [button addTarget:self action:@selector(logout) forControlEvents:UIControlEventTouchUpInside];
                
                //修改密码
                UIButton *changePwdButton = [[UIButton alloc]initWithFrame:CGRectMake(width/2+5,140, width/2-10-5, 50)];
                [changePwdButton setTitle:@"修改密码" forState:UIControlStateNormal];
                [changePwdButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                changePwdButton.backgroundColor = [UIColor blackColor];
                [changePwdButton.layer setCornerRadius:7];
                [changePwdButton addTarget:self action:@selector(changePwd) forControlEvents:UIControlEventTouchUpInside];


                
                
                [inputBackView addSubview:hintLabel];
                [inputBackView addSubview:button];
                [inputBackView addSubview:changePwdButton];

                
                [whiteBackView addSubview:inputBackView];
                [self.view addSubview:whiteBackView];
                
                CardManageViewController *cardManageViewController;
                cardManageViewController = [[CardManageViewController alloc]init];
                controllers = [NSArray arrayWithObject:cardManageViewController];

                UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
                navigationController.viewControllers = controllers;
                
            }else{
                
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"登陆失败" message:[NSString stringWithFormat:@"%@",user.exceptionInfo.Info] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [SVProgressHUD dismiss];
                [alert show];
            }
            
        } error:^(NSString *strFail) {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"登陆失败" message:[NSString stringWithFormat:@"%@",strFail] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alert show];
        }];
    
}

-(void)logout{
    
    //清空登录信息
    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
    
    [defaults setObject:nil forKey:@"username"];
    [defaults setObject:nil forKey:@"userid"];
    
    //修改页面信息
    [inputBackView removeFromSuperview];
    NSArray *arr = [inputBackView subviews];
    for (UIView *view in arr) {
        [view removeFromSuperview];
    }
    //未登陆
    int width = [UIScreen mainScreen].bounds.size.width;
    int height = [UIScreen mainScreen].bounds.size.height;
    UILabel *userNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 20, 100, 40)];
    self.userNameTextField = [[UITextField alloc]initWithFrame:CGRectMake(110, 20, width-110-10, 40)];
    userNameLabel.text = @"用户账号：";
    userNameLabel.font = [UIFont boldSystemFontOfSize:18];
    userNameLabel.textColor = [UIColor whiteColor];
    
    self.userNameTextField.layer.cornerRadius = 7;
    self.userNameTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.userNameTextField.keyboardType = UIKeyboardTypeASCIICapable;

    
    UILabel *userPasswordLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 70, 100, 40)];
    self.userPasswordTextField = [[UITextField alloc]initWithFrame:CGRectMake(110, 70, width-110-10, 40)];
    userPasswordLabel.text = @"登陆密码：";
    userPasswordLabel.font = [UIFont boldSystemFontOfSize:18];
    userPasswordLabel.textColor = [UIColor whiteColor];
    self.userPasswordTextField.layer.cornerRadius = 7;
    self.userPasswordTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.userPasswordTextField.secureTextEntry = YES;
    self.userPasswordTextField.keyboardType = UIKeyboardTypeEmailAddress;
    
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(10, 140, width-10-10, 50)];
    [button setTitle:@"登录" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    button.backgroundColor = [UIColor blackColor];
    [button.layer setCornerRadius:7];
    [button addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
    
    
    [inputBackView addSubview:userNameLabel];
    [inputBackView addSubview:self.userNameTextField];
    [inputBackView addSubview:userPasswordLabel];
    [inputBackView addSubview:self.userPasswordTextField];
    [inputBackView addSubview:button];
    
    [whiteBackView addSubview:inputBackView];
    [self.view addSubview:whiteBackView];

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 左菜单创建函数
- (UIBarButtonItem *)leftMenuBarButtonItem {
    
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0,0,30,30)];
    [button setImage:[UIImage imageNamed:@"icon_menu.png"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(leftSideMenuButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithCustomView:button];
    
    return item;
}

#pragma mark - 左菜单处理函数
- (void)leftSideMenuButtonPressed:(id)sender {
    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{
        UIBarButtonItem *negativeLeftSpacer = [[UIBarButtonItem alloc]
                                               initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                               target:nil action:nil];
        negativeLeftSpacer.width = -15;
        self.navigationItem.leftBarButtonItems = @[negativeLeftSpacer,[self leftMenuBarButtonItem]];
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size {
    
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}


@end
