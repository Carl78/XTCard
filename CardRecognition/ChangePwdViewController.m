//
//  ChangePwdViewController.m
//  CardRecognition
//
//  Created by bournejason on 15/10/19.
//  Copyright © 2015年 bournejason. All rights reserved.
//

#import "ChangePwdViewController.h"
#import "SVProgressHUD.h"
#import "UserHttpRequestService.h"
#define kInputBackColor 0x707070

@interface ChangePwdViewController (){
    UIView *inputBackView,*whiteBackView;
    NSString *username,*userid;
    UserHttpRequestService *userHttpRequestService;
}
@property (nonatomic,strong) UITextField *userNameTextField,*userPasswordTextField,*userNewPasswordTextField,*userNewRepasswordTextField;
@end

@implementation ChangePwdViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    
    [self setupNavigationView];
    
    
    //判断是否已经登陆
    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
    username = [defaults objectForKey:@"username"];//根据键值取出name
    userid = [defaults objectForKey:@"userid"];//根据键值取出id
    
    whiteBackView = [[UIView alloc]initWithFrame:CGRectMake(0, 60, width, height-60)];
    whiteBackView.backgroundColor = [UIColor whiteColor];
    
    
    inputBackView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, width, 300)];
    inputBackView.backgroundColor = [UIColor colorWithRed:((float)((kInputBackColor & 0xFF0000) >> 16))/255.0 green:((float)((kInputBackColor & 0xFF00) >> 8))/255.0 blue:((float)(kInputBackColor & 0xFF))/255.0 alpha:1.0];
    
    
    //未登陆
    UILabel *userNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 20, 100, 40)];
    self.userNameTextField = [[UITextField alloc]initWithFrame:CGRectMake(110, 20, width-110-10, 40)];
    userNameLabel.text = @"用户账号：";
    userNameLabel.font = [UIFont boldSystemFontOfSize:18];
    userNameLabel.textColor = [UIColor whiteColor];
    
    self.userNameTextField.text = username;
    
    self.userNameTextField.layer.cornerRadius = 7;
    self.userNameTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.userNameTextField.keyboardType = UIKeyboardTypeASCIICapable;
    self.userNameTextField.userInteractionEnabled = NO;
    
    
    
    UILabel *userPasswordLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 70, 100, 40)];
    self.userPasswordTextField = [[UITextField alloc]initWithFrame:CGRectMake(110, 70, width-110-10, 40)];
    userPasswordLabel.text = @"旧密码：";
    userPasswordLabel.font = [UIFont boldSystemFontOfSize:18];
    userPasswordLabel.textColor = [UIColor whiteColor];
    
    self.userPasswordTextField.layer.cornerRadius = 7;
    self.userPasswordTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.userPasswordTextField.secureTextEntry = YES;
    self.userPasswordTextField.keyboardType = UIKeyboardTypeEmailAddress;
    
    
    UILabel *userNewPasswordLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 120, 100, 40)];
    self.userNewPasswordTextField = [[UITextField alloc]initWithFrame:CGRectMake(110, 120, width-110-10, 40)];
    userNewPasswordLabel.text = @"新密码：";
    userNewPasswordLabel.font = [UIFont boldSystemFontOfSize:18];
    userNewPasswordLabel.textColor = [UIColor whiteColor];
    
    self.userNewPasswordTextField.layer.cornerRadius = 7;
    self.userNewPasswordTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.userNewPasswordTextField.secureTextEntry = YES;
    self.userNewPasswordTextField.keyboardType = UIKeyboardTypeEmailAddress;
    
    
    UILabel *userNewRepasswordLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 170, 110, 40)];
    self.userNewRepasswordTextField = [[UITextField alloc]initWithFrame:CGRectMake(110, 170, width-110-10, 40)];
    userNewRepasswordLabel.text = @"密码确认：";
    userNewRepasswordLabel.font = [UIFont boldSystemFontOfSize:18];
    userNewRepasswordLabel.textColor = [UIColor whiteColor];
    
    self.userNewRepasswordTextField.layer.cornerRadius = 7;
    self.userNewRepasswordTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.userNewRepasswordTextField.secureTextEntry = YES;
    self.userNewRepasswordTextField.keyboardType = UIKeyboardTypeEmailAddress;
    
    
    
    
    
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(10, 240, width-10-10, 50)];
    [button setTitle:@"修改密码" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    button.backgroundColor = [UIColor blackColor];
    [button.layer setCornerRadius:7];
    [button addTarget:self action:@selector(changePwd) forControlEvents:UIControlEventTouchUpInside];
    
    
    [inputBackView addSubview:userNameLabel];
    [inputBackView addSubview:self.userNameTextField];
    [inputBackView addSubview:userPasswordLabel];
    [inputBackView addSubview:self.userPasswordTextField];
    [inputBackView addSubview:userNewPasswordLabel];
    [inputBackView addSubview:self.userNewPasswordTextField];
    [inputBackView addSubview:userNewRepasswordLabel];
    [inputBackView addSubview:self.userNewRepasswordTextField];
    [inputBackView addSubview:button];
    
    [whiteBackView addSubview:inputBackView];
    [self.view addSubview:whiteBackView];
    
    
    // Do any additional setup after loading the view.
}

-(void)changePwd{
    NSString *oldPwd = self.userPasswordTextField.text;
    NSString *newPwd = self.userNewPasswordTextField.text;
    NSString *reNewPwd = self.userNewRepasswordTextField.text;
    
    if (oldPwd.length==0||newPwd.length==0||reNewPwd.length==0) {
        return;
    }
    if (![newPwd isEqualToString:reNewPwd]) {
        return;
    }
    
    //显示加载动画
    [SVProgressHUD show];
    
    
    if(userHttpRequestService==nil)
        userHttpRequestService = [[UserHttpRequestService alloc]init];
    
    [userHttpRequestService updatePwdwithUserId:userid oldPwd:oldPwd newPwd:newPwd success:^(ExceptionInfo *info){
        
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
    //self.navigationItem.leftBarButtonItem = [self leftMenuBarButtonItem];
    
    
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
