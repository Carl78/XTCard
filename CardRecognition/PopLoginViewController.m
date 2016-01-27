//
//  PopLoginViewController.m
//  CardRecognition
//
//  Created by bournejason on 15/6/11.
//  Copyright (c) 2015年 bournejason. All rights reserved.
//

#import "PopLoginViewController.h"
#import "MFSideMenu.h"
#import <QuartzCore/QuartzCore.h>
#import "UserHttpRequestService.h"
#import "SVProgressHUD.h"


#define kInputBackColor 0x707070
@interface PopLoginViewController (){
    NSString *username;
    NSString *userid;
    UserHttpRequestService *userHttpRequestService;
    UIView *inputBackView,*whiteBackView;
}
@property (nonatomic,strong) UITextField *userNameTextField,*userPasswordTextField;
@property(nonatomic, strong) UIToolbar *toolbar;
@property(nonatomic, copy) UserLoginSuccessBlock successBlock;
@end
@implementation PopLoginViewController
- (void)viewDidLoad {
    [super viewDidLoad];
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
    //    self.navigationItem.titleView = titleLabel;
    self.toolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44+20)];
    UIView *theBackView = [[UIView alloc]initWithFrame:self.toolbar.bounds];
    theBackView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    theBackView.backgroundColor = [UIColor blackColor];
    [_toolbar addSubview:theBackView];
    [self.view addSubview:_toolbar];
    titleLabel.center = CGPointMake(_toolbar.center.x, _toolbar.frame.size.height/2+10);
    [self.toolbar addSubview:titleLabel];
    
    
    whiteBackView = [[UIView alloc]initWithFrame:CGRectMake(0, 60, width, height-60)];
    whiteBackView.backgroundColor = [UIColor whiteColor];
    
    
    inputBackView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, width, 230)];
    inputBackView.backgroundColor = [UIColor colorWithRed:((float)((kInputBackColor & 0xFF0000) >> 16))/255.0 green:((float)((kInputBackColor & 0xFF00) >> 8))/255.0 blue:((float)(kInputBackColor & 0xFF))/255.0 alpha:1.0];
    
    
    UIBarButtonItem *negativeLeftSpacer = [[UIBarButtonItem alloc]
                                           initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                           target:nil action:nil];
    negativeLeftSpacer.width = -15;
    
    //    self.navigationItem.leftBarButtonItems = @[negativeLeftSpacer, [self leftMenuBarButtonItem]];
    self.toolbar.items = @[negativeLeftSpacer, [self leftMenuBarButtonItem]];
    
    //判断是否已经登陆
    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
    username = [defaults objectForKey:@"username"];//根据键值取出name
    userid = [defaults objectForKey:@"userid"];//根据键值取出id
    
    
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
    
    
    
    
    
    [whiteBackView addSubview:inputBackView];
    [self.view addSubview:whiteBackView];
    
    
    
}

- (void)login{
    
    //显示加载动画
    [SVProgressHUD show];
    
    if(userHttpRequestService==nil)
        userHttpRequestService = [[UserHttpRequestService alloc]init];
    
    [userHttpRequestService loginWithName:self.userNameTextField.text andPassword:self.userPasswordTextField.text success:^(User *user) {
        
        [SVProgressHUD dismiss];
        
        NSNumber *result = [user.exceptionInfo valueForKey:@"Result"];
        if ([result intValue] > 0) {
            username = [user.loginInfo valueForKey:@"LoginName"];
            userid = [NSString stringWithFormat:@"%@",[user.loginInfo valueForKey:@"UserID"]];
            
            //存储登录信息
            NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
            [defaults setObject:username forKey:@"username"];
            [defaults setObject:userid forKey:@"userid"];
            
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"登陆成功"
                                                           message:nil
                                                          delegate:self
                                                 cancelButtonTitle:@"确定"
                                                 otherButtonTitles:nil];
            [alert show];
            
            if (self.successBlock) {
                self.successBlock();
            }
            
        }else{
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"登陆失败"
                                                           message:nil
                                                          delegate:self
                                                 cancelButtonTitle:@"确定"
                                                 otherButtonTitles:nil];
            [alert show];
        }
        
    } error:^(NSString *strFail) {
        
    }];
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 左菜单创建函数
- (UIBarButtonItem *)leftMenuBarButtonItem {
    
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0,0,30,30)];
    [button setImage:[UIImage imageNamed:@"return_back_normal"] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"return_back_pressed"] forState:UIControlStateSelected];
    [button addTarget:self action:@selector(leftSideMenuButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [button setTitleEdgeInsets:UIEdgeInsetsMake(-1, -55, 0, 0)];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithCustomView:button];
    item.style = UIBarButtonSystemItemAction;
    return item;
    
    return item;
}

#pragma mark - 左菜单处理函数
- (void)leftSideMenuButtonPressed:(id)sender {
//        [self.menuContainerViewController toggleLeftSideMenuCompletion:^{
//            UIBarButtonItem *negativeLeftSpacer = [[UIBarButtonItem alloc]
//                                                   initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
//                                                   target:nil action:nil];
//            negativeLeftSpacer.width = -15;
//            self.navigationItem.leftBarButtonItems = @[negativeLeftSpacer,[self leftMenuBarButtonItem]];
//        }];
    [self dismissViewControllerAnimated:YES completion:nil];
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

-(void)didLoginSuccess:(UserLoginSuccessBlock)successBlock{
    self.successBlock = successBlock;
}
@end
