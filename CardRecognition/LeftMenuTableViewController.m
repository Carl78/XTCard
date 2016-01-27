//
//  LeftMenuTableViewController.m
//  CardRecognition
//  左菜单视图控制器
//  Created by bournejason on 15/5/4.
//  Copyright (c) 2015年 bournejason. All rights reserved.
//

#import "LeftMenuTableViewController.h"
#import "MFSideMenu.h"
#import "LeftMenuTableViewCell.h"
#import "CardPackageViewController.h"
#import "CardAddViewController.h"
#import "CardManageViewController.h"
#import "CardOfMineViewController.h"
#import "CardSearchViewController.h"
#import "CardSynchronizeViewController.h"
#import "CardStatisticsViewController.h"
#import "SystemLoginViewController.h"
#import "SystemSettingViewController.h"
#import "CardGroupViewController.h"

#define kMenuOpenMainLeft 130 //主界面打开后在屏幕上留的宽度
#define kTitleColor 0x282828 //左菜单头背景颜色
#define kMenuFontColor 0xe1e4e3 //左菜单字体颜色
#define kMenuCellBGColor 0x403f3f //左菜单单元背景颜色

@interface LeftMenuTableViewController (){
    NSArray *menuCellTitles;
    NSArray *menuCellIcons;
}
@property (nonatomic) CGRect screen;
@end

@implementation LeftMenuTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    //初始化菜单标题及图标
    menuCellTitles = [NSArray arrayWithObjects:@"本机名片",@"新增名片",@"名片同步",@"名片管理",@"分组管理",@"我的名片",@"全名片检索",@"名片统计",@"系统登陆",@"系统设置", nil];
    menuCellIcons = [NSArray arrayWithObjects:@"package_menu",@"add_menu",@"sync_menu",@"manage_menu",@"my_menu",@"my_menu",@"search_menu",@"statistics_menu",@"my_menu",@"setting_menu",nil];
    
    //设置tableview背景颜色
    
    self.tableView.backgroundColor = [UIColor colorWithRed:((float)((kMenuCellBGColor & 0xFF0000) >> 16))/255.0 green:((float)((kMenuCellBGColor & 0xFF00) >> 8))/255.0 blue:((float)(kMenuCellBGColor & 0xFF))/255.0 alpha:1.0];;
    //去掉tableview多余的分隔线
    UIView *view =[ [UIView alloc]init];
    view.backgroundColor = [UIColor clearColor];
    [self.tableView setTableFooterView:view];
    
    
    //去分隔线前面的多余空白
    UIEdgeInsets edgeInset = self.tableView.separatorInset;
    self.tableView.separatorInset = UIEdgeInsetsMake(edgeInset.top, 0, edgeInset.bottom, edgeInset.right);//修改分隔线长度
    
    //获取屏幕宽度
    self.screen = [[UIScreen mainScreen] bounds];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return menuCellTitles.count;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UILabel *label = [[UILabel alloc] init];
    
    NSString *menuTitle = @"功能列表";
    
    
    if (self.screen.size.width == 320) {
        label.frame = CGRectMake((self.screen.size.width-kMenuOpenMainLeft)/2, 10, kMenuOpenMainLeft, 22);
    }else if(self.screen.size.width == 375){
        label.frame = CGRectMake((self.screen.size.width-kMenuOpenMainLeft-50)/2, 10, kMenuOpenMainLeft, 22);
    }
    label.backgroundColor = [UIColor colorWithRed:((float)((kTitleColor & 0xFF0000) >> 16))/255.0 green:((float)((kTitleColor & 0xFF00) >> 8))/255.0 blue:((float)(kTitleColor & 0xFF))/255.0 alpha:1.0];
    label.textColor = [UIColor colorWithRed:((float)((kMenuFontColor & 0xFF0000) >> 16))/255.0 green:((float)((kMenuFontColor & 0xFF00) >> 8))/255.0 blue:((float)(kMenuFontColor & 0xFF))/255.0 alpha:1.0];
    label.font = [UIFont fontWithName:@"Helvetica-Bold" size:22];
    label.text = menuTitle;
    
    
    // Create header view and add label as a subview
    UIView *sectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 20, tableView.bounds.size.width, 22)];
    [sectionView setBackgroundColor:[UIColor colorWithRed:((float)((kTitleColor & 0xFF0000) >> 16))/255.0 green:((float)((kTitleColor & 0xFF00) >> 8))/255.0 blue:((float)(kTitleColor & 0xFF))/255.0 alpha:1.0]];
    [sectionView addSubview:label];
    return sectionView;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"LeftMenuCell";
    
    LeftMenuTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
 
    if (cell == nil) {
        cell = [[LeftMenuTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    //cell.textLabel.text = [NSString stringWithFormat:@"%s", array[indexPath.row]];
    //cell.textLabel.text = array[indexPath.row];
    cell.titleLabel.text = menuCellTitles[indexPath.row];
    cell.titleLabel.textColor = [UIColor colorWithRed:((float)((kMenuFontColor & 0xFF0000) >> 16))/255.0 green:((float)((kMenuFontColor & 0xFF00) >> 8))/255.0 blue:((float)(kMenuFontColor & 0xFF))/255.0 alpha:1.0];
    cell.iconImageView.image = [UIImage imageNamed:menuCellIcons[indexPath.row]];
    cell.backgroundColor = [UIColor colorWithRed:((float)((kMenuCellBGColor & 0xFF0000) >> 16))/255.0 green:((float)((kMenuCellBGColor & 0xFF00) >> 8))/255.0 blue:((float)(kMenuCellBGColor & 0xFF))/255.0 alpha:1.0];
    //cell.textLabel.textColor = [UIColor whiteColor];
    
    return cell;
}

//控制section的长度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section ==0)
        return 45.0f;
    else
        return 30.0f;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
    NSArray *controllers;
    CardPackageViewController *cardPackageViewController;
    CardAddViewController *cardAddViewController;
    CardManageViewController *cardManageViewController;
    CardOfMineViewController *cardOfMineViewController;
    CardSearchViewController *cardSearchViewController;
    CardSynchronizeViewController *cardSynchronizeViewController;
    CardStatisticsViewController *cardStatisticsViewController;
    SystemLoginViewController *systemLoginViewController;
    SystemSettingViewController *systemSettingViewController;
    CardGroupViewController *cardGroupViewController;
    

    
    switch (indexPath.row) {
        case 0:
            cardPackageViewController = [[CardPackageViewController alloc] init];
            controllers = [NSArray arrayWithObject:cardPackageViewController];
            break;
        case 1:
            cardAddViewController = [[CardAddViewController alloc]init];
            cardAddViewController.navigation = navigationController;
            controllers = [NSArray arrayWithObject:cardAddViewController];
            break;
        case 2:
            cardSynchronizeViewController = [[CardSynchronizeViewController alloc]init];
            controllers = [NSArray arrayWithObject:cardSynchronizeViewController];
            break;
        case 3:
            cardManageViewController = [[CardManageViewController alloc]init];
            controllers = [NSArray arrayWithObject:cardManageViewController];
            break;
            
        case 4:
            cardGroupViewController = [[CardGroupViewController alloc]init];
            controllers = [NSArray arrayWithObject:cardGroupViewController];
            break;
        case 5:
            cardOfMineViewController = [[CardOfMineViewController alloc]init];
            controllers = [NSArray arrayWithObject:cardOfMineViewController];
            break;
        case 6:
            cardSearchViewController = [[CardSearchViewController alloc]init];
            controllers = [NSArray arrayWithObject:cardSearchViewController];
            break;
        case 7:
            cardStatisticsViewController = [[CardStatisticsViewController alloc]initWithNibName:@"CardStatisticsViewController" bundle:nil];
            controllers = [NSArray arrayWithObject:cardStatisticsViewController];
            break;
        
        case 8:
            systemLoginViewController = [[SystemLoginViewController alloc]init];
            controllers = [NSArray arrayWithObject:systemLoginViewController];
            break;
        case 9:
            systemSettingViewController = [[SystemSettingViewController alloc]init];
            controllers = [NSArray arrayWithObject:systemSettingViewController];
            break;
            
        default:
            break;
    }
    
    navigationController.viewControllers = controllers;
    
    [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];//关闭menu
    
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];//取消选中项
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
