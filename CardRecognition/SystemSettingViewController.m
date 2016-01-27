//
//  SystemSettingViewController.m
//  CardRecognition
//  系统设置视图控制器
//  Created by bournejason on 15/5/5.
//  Copyright (c) 2015年 bournejason. All rights reserved.
//

#import "SystemSettingViewController.h"
#import "MFSideMenu.h"

#define kBGColor 0x707070 //背景颜色
#define kItemBGColor 0x403f3f //item颜色

@interface SystemSettingViewController ()

@end

@implementation SystemSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //初始化主View
    UIView *mainView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    mainView.backgroundColor = [UIColor colorWithRed:((float)((kBGColor & 0xFF0000) >> 16))/255.0 green:((float)((kBGColor & 0xFF00) >> 8))/255.0 blue:((float)(kBGColor & 0xFF))/255.0 alpha:1.0];
    self.view = mainView;
    
    //item view
    UIView *itemView = [[UIView alloc]initWithFrame:CGRectMake(0, 60, [[UIScreen mainScreen]bounds].size.width, 80)];
    itemView.backgroundColor = [UIColor colorWithRed:((float)((kItemBGColor & 0xFF0000) >> 16))/255.0 green:((float)((kItemBGColor & 0xFF00) >> 8))/255.0 blue:((float)(kItemBGColor & 0xFF))/255.0 alpha:1.0];
    [self.view addSubview:itemView];
    
    //title
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 15, 100, 20)];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.text = @"Wifi同步";
    titleLabel.font = [UIFont fontWithName:@"Helvetica" size:18];
    [itemView addSubview:titleLabel];
    
    //content
    UILabel *contentLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 45, 300, 20)];
    contentLabel.textColor = [UIColor whiteColor];
    contentLabel.text = @"只有在Wifi状态下才能进行数据同步";
    contentLabel.font = [UIFont fontWithName:@"Helvetica" size:14];
    [itemView addSubview:contentLabel];
    
    
    //switch
    UISwitch *wifi = [[UISwitch alloc]initWithFrame:CGRectMake([[UIScreen mainScreen] bounds].size.width-60, 10, 40, 20)];
    wifi.onTintColor = [UIColor whiteColor];
    //获取用户WIFI环境传输的设置
    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
    NSString * isWifi = [defaults objectForKey:@"wifi"];
    if([isWifi isEqualToString:@"1"]){
        [wifi setOn:YES];
    }else{
        [wifi setOn:NO];
    }
    
    [wifi addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];

    [itemView addSubview:wifi];
    
    
    //item view
    UIView *versionView = [[UIView alloc]initWithFrame:CGRectMake(0, 142, [[UIScreen mainScreen]bounds].size.width, 80)];
    versionView.backgroundColor = [UIColor colorWithRed:((float)((kItemBGColor & 0xFF0000) >> 16))/255.0 green:((float)((kItemBGColor & 0xFF00) >> 8))/255.0 blue:((float)(kItemBGColor & 0xFF))/255.0 alpha:1.0];
    //title
    
    NSString *ndic = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *strVersion = [NSString stringWithFormat:@"当前版本是：%@",ndic];
    
    UILabel *versionLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 30, [[UIScreen mainScreen]bounds].size.width-20, 20)];
    versionLabel.textColor = [UIColor whiteColor];
    versionLabel.text = strVersion;
    versionLabel.font = [UIFont fontWithName:@"Helvetica" size:18];
    [versionView addSubview:versionLabel];
    
    [self.view addSubview:versionView];
    
    
    self.navigationItem.leftBarButtonItem = [self leftMenuBarButtonItem];

}

-(void)switchAction:(id)sender
{
    UISwitch *switchButton = (UISwitch*)sender;

    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
    
    BOOL isButtonOn = [switchButton isOn];
    if (isButtonOn) {//开
        [defaults setObject:@"1" forKey:@"wifi"];
    }else {//关
        [defaults setObject:@"0" forKey:@"wifi"];
    }
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
        self.navigationItem.leftBarButtonItem = [self leftMenuBarButtonItem];
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

@end
