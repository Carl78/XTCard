//
//  CardGroupViewController.m
//  CardRecognition
//
//  Created by bournejason on 15/11/3.
//  Copyright © 2015年 bournejason. All rights reserved.
//

#import "CardGroupViewController.h"
#import "MLKMenuPopover.h"
#import "MFSideMenu.h"
#import "GroupHttpRequestService.h"
#import "Cardgroup.h"
#import "RMMapper.h"
#import "CardGroupListCell.h"
#import "CardGroupEditingViewController.h"
#import "ExceptionInfo.h"
#import "PopLoginViewController.h"



#define kScreenWidth [[UIScreen mainScreen] bounds].size.width
#define kScreenHeight [[UIScreen mainScreen] bounds].size.height

#define kAlertToLoginViewTag 1
#define kAlertAddGroupViewTag 2


@interface CardGroupViewController ()<MLKMenuPopoverDelegate>{
    bool isPopup;
    UITableView *tableView;


}
@property(nonatomic, strong) NSNumber *userid;

@property(nonatomic,strong) MLKMenuPopover *menuPopover;
@property(nonatomic,strong) NSArray *menuItems;

@property(nonatomic,strong) NSArray *dataArr;

@property(nonatomic) BOOL isNibRegistered;



@end

@implementation CardGroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //初始化主View
    UIView *mainView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    mainView.backgroundColor = [UIColor blackColor];
    self.view = mainView;
    
    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
    self.navigationController.navigationBar.translucent = YES;
    
    //设置视图标题view
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(41, 0, 100, 30)];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setText:@"分组管理"];
    titleLabel.font = [UIFont boldSystemFontOfSize:20];
    
    self.navigationItem.titleView = titleLabel;
    
    //创建左右导航按钮
    [self setupMenuBarButtonItems];
    
    //建立右排序列表内容
    self.menuItems = [NSArray arrayWithObjects:@"新建分组", nil];
    
    //创建table view
    CGRect frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.bounces = NO;
    [self.view addSubview:tableView];
    

}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    BOOL isUserLogin = [self isUserLogin];
    if (isUserLogin) {
        NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
        
        self.userid = [defaults objectForKey:@"userid"];
    }else{
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"友情提示"
                                                       message:@"用户未登录,请先前往登录页面"
                                                      delegate:self
                                             cancelButtonTitle:nil
                                             otherButtonTitles:@"前往",nil];
        alert.tag = kAlertToLoginViewTag;
        [alert show];
        return;
    }
    
    [self initGroupData];
}

#pragma mark - 用户登录判断

-(BOOL)isUserLogin{
    
    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
    
    id username = [defaults objectForKey:@"username"];
    id userid = [defaults objectForKey:@"userid"];
    
    self.userid = userid;
    
    if (username == nil || userid == nil) {
        return NO;
    }
    return YES;
}


- (void)setupMenuBarButtonItems {
    UIBarButtonItem *negativeLeftSpacer = [[UIBarButtonItem alloc]
                                           initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                           target:nil action:nil];
    negativeLeftSpacer.width = -15;
    self.navigationItem.leftBarButtonItems = @[negativeLeftSpacer, [self leftMenuBarButtonItem]];
    //self.navigationItem.leftBarButtonItem = [self leftMenuBarButtonItem];
    
    UIBarButtonItem *negativeRightSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeRightSpacer.width = -10;
    self.navigationItem.rightBarButtonItems = @[negativeRightSpacer,[self rightMenuBarButtonItem]];
    
    //self.navigationItem.rightBarButtonItem = [self rightMenuBarButtonItem];
}
#pragma mark - 左菜单创建函数
- (UIBarButtonItem *)leftMenuBarButtonItem {
    
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0,0,30,30)];
    [button setImage:[UIImage imageNamed:@"icon_menu.png"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(leftSideMenuButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [button setTitleEdgeInsets:UIEdgeInsetsMake(-1, -55, 0, 0)];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithCustomView:button];
    
    return item;
}
#pragma mark - 右菜单创建函数
- (UIBarButtonItem *)rightMenuBarButtonItem {
    
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0,0,30,30)];
    [button setImage:[UIImage imageNamed:@"icon_sort.png"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(rightSideMenuButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithCustomView:button];
    
    return item;
}

#pragma mark - 左菜单处理函数
- (void)leftSideMenuButtonPressed:(id)sender {
    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{
        [self setupMenuBarButtonItems];
    }];
}
#pragma mark - 右菜单处理函数
- (void)rightSideMenuButtonPressed:(id)sender {
    if (isPopup) {
        [self.menuPopover dismissMenuPopover];
        isPopup = NO;
    }else{
        
        NSArray *imageNames = @[@"name_order"];
        
        self.menuPopover = [[MLKMenuPopover alloc] initWithFrame:CGRectMake(kScreenWidth-140-60, 50, 120+60, 44) menuItems:self.menuItems andImages:imageNames];
        self.menuPopover.menuPopoverDelegate = self;
        [self.menuPopover showInView:self.view];
        isPopup = YES;
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - alert view delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == kAlertAddGroupViewTag  && buttonIndex == 0) {
        UITextField *textField=[alertView textFieldAtIndex:0];
        NSString *name = textField.text;
        if (name.length==0||[name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length==0) {
            return;
        }
        [self addGroupWithGName:name];
    }
    if (alertView.tag == kAlertToLoginViewTag && buttonIndex == 0) {
        PopLoginViewController *viewController = [[PopLoginViewController alloc]init];
        [viewController didLoginSuccess:^{
            [viewController dismissViewControllerAnimated:YES completion:nil];
            NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
            self.userid = [defaults objectForKey:@"userid"];
            [self initGroupData];

        }];
        [self presentViewController:viewController animated:YES completion:^{
            
        }];
    }
}

#pragma mark UITableview delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArr.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
}
- (UITableViewCell *)tableView:(UITableView *)table cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CardShareListCellIdentifier = @"CardGroupListCellIdentifier";
    if (!self.isNibRegistered) {
        UINib *nib = [UINib nibWithNibName:@"CardGroupListCell" bundle:nil];
        [table registerNib:nib forCellReuseIdentifier:CardShareListCellIdentifier];
        self.isNibRegistered = YES;
    }
    
    CardGroupListCell *cardGroupListCell = [table dequeueReusableCellWithIdentifier:CardShareListCellIdentifier];
    
    cardGroupListCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    
    if (!cardGroupListCell) {
        cardGroupListCell = [[CardGroupListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CardShareListCellIdentifier];
    }
    
    Cardgroup *card = [self.dataArr objectAtIndex:indexPath.row];
    if (![card.Name isKindOfClass:[NSNull class]]) {
        cardGroupListCell.NameLabel.text = card.Name;
    }
    //cardGroupListCell.NameLabel.text = card.Name;
    cardGroupListCell.createTimeLabel.text = card.Createtime;
    
    return cardGroupListCell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    Cardgroup *group = self.dataArr[indexPath.row];
    
    CardGroupEditingViewController *nextViewController = [[CardGroupEditingViewController alloc]initWithName:group.Name andTargetValue:group.Id.description];
    [nextViewController setCompleteOpertion:^(NSString *newValue){
        
        NSLog(@"id=%@,uid=%@,name=%@",group.Id.description,group.Userid.description,newValue);
        
        [self modifyGroupWithName:newValue andId:group.Id.description userId:group.Userid.description];
        
    }];
    [nextViewController didDeleteOpertion:^(NSString *newValue) {
        
        NSLog(@"id=%@",group.Id.description);
        
        [self deleteGroupByID:group.Id.description];
        [nextViewController.navigationController popViewControllerAnimated:YES];

    }];
    
    [self.navigationController pushViewController:nextViewController animated:YES];
}

#pragma mark MLKMenuPopoverDelegate

- (void)menuPopover:(MLKMenuPopover *)menuPopover didSelectMenuItemAtIndex:(NSInteger)selectedIndex
{
    [self.menuPopover dismissMenuPopover];
    isPopup = NO;
    
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"添加分组"
                          message:nil
                          delegate:self
                          cancelButtonTitle:@"确定"
                          otherButtonTitles:@"取消",nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    alert.tag = kAlertAddGroupViewTag;
    [alert show];

    
    //[tableView reloadData];
    
}


- (void)initGroupData{
    GroupHttpRequestService *groupHttpRequestService = [[GroupHttpRequestService alloc]init];
    
    [groupHttpRequestService getGroupByUserID:self.userid.description success:^(NSString *strToken) {
        
        NSLog(@"%@",strToken);
        
        NSData *data = [strToken dataUsingEncoding:NSUTF8StringEncoding];
        
        id responseJSON = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        
        
        NSMutableArray* rooms = [RMMapper mutableArrayOfClass:[Cardgroup class]
                                        fromArrayOfDictionary:responseJSON];
        
        self.dataArr = rooms;
        
        [tableView reloadData];
    } error:^(NSString *strFail) {
        
    }];
}

-(void)addGroupWithGName:(NSString*)gName{
    GroupHttpRequestService *groupHttpRequestService = [[GroupHttpRequestService alloc]init];
    
    [groupHttpRequestService addGroupWithUserID:self.userid.description groupName:gName success:^(NSString *strToken) {
        NSLog(@"%@",strToken);
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"添加分组成功"
                              message:nil
                              delegate:nil
                              cancelButtonTitle:@"确定"
                              otherButtonTitles:nil,nil];
        [alert show];
        
        [self initGroupData];
        
    } error:^(NSString *strFail) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"添加分组失败"
                              message:nil
                              delegate:nil
                              cancelButtonTitle:@"确定"
                              otherButtonTitles:nil,nil];
        [alert show];
    }];
}

-(void)modifyGroupWithName:(NSString *)name andId:(NSString *)idstr userId:(NSString *)uid{
    GroupHttpRequestService *groupHttpRequestService = [[GroupHttpRequestService alloc]init];
    [groupHttpRequestService modifyGroupByID:idstr groupName:name userID:uid success:^(NSString *strToken) {
        
        NSData *data = [strToken dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        
        ExceptionInfo* info = [RMMapper objectWithClass:[ExceptionInfo class] fromDictionary:dict];
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"修改操作"
                              message:info.Info
                              delegate:nil
                              cancelButtonTitle:@"确定"
                              otherButtonTitles:nil,nil];
        [alert show];
        
        [self initGroupData];

    } error:^(NSString *strFail) {
        NSData *data = [strFail dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        
        ExceptionInfo* info = [RMMapper objectWithClass:[ExceptionInfo class] fromDictionary:dict];
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"修改失败"
                              message:info.Info
                              delegate:nil
                              cancelButtonTitle:@"确定"
                              otherButtonTitles:nil,nil];
        [alert show];
    }];

}

-(void)deleteGroupByID:(NSString *)idstr{
    GroupHttpRequestService *groupHttpRequestService = [[GroupHttpRequestService alloc]init];
    [groupHttpRequestService deleteGroupByID:idstr success:^(NSString *strToken) {
        NSData *data = [strToken dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        
        ExceptionInfo* info = [RMMapper objectWithClass:[ExceptionInfo class] fromDictionary:dict];
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"删除操作"
                              message:info.Info
                              delegate:nil
                              cancelButtonTitle:@"确定"
                              otherButtonTitles:nil,nil];
        [alert show];
        [self initGroupData];
    } error:^(NSString *strFail) {
        NSData *data = [strFail dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        
        ExceptionInfo* info = [RMMapper objectWithClass:[ExceptionInfo class] fromDictionary:dict];
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"删除失败"
                              message:info.Info
                              delegate:nil
                              cancelButtonTitle:@"确定"
                              otherButtonTitles:nil,nil];
        [alert show];
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
