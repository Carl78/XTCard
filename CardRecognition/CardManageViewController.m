//
//  CardManageViewController.m
//  CardRecognition
//  名片管理视图控制器
//  Created by bournejason on 15/5/5.
//  Copyright (c) 2015年 bournejason. All rights reserved.
//

#import "CardManageViewController.h"
#import "MFSideMenu.h"
#import "CardHttpRequestService.h"
#import "MJRefresh.h"
#import "CardListModel.h"
#import "CardListTableViewCell.h"
#import "CardDetailViewController.h"
#import "CardManageDetailViewController.h"
#import "MLKMenuPopover.h"
#import "SVProgressHUD.h"
#import "Base64Data.h"
#import "CardListCell.h"
#import "PopLoginViewController.h"

#define kScreenWidth [[UIScreen mainScreen] bounds].size.width
#define kPageSize 20
#define kSortName 1
#define kSortTime 2
#define KSortRelation 3
#define kAlertToLoginViewTag 1000

@interface CardManageViewController () <MLKMenuPopoverDelegate>{
    
    CardHttpRequestService *cardHttpRequestService;
    
    UITableView *_tableView;
    UISearchBar *bar;
    bool isPopup;
    int pageNumber;
    int sortField;
    NSString *searchContent;
    NSMutableArray *dataArray;
}
@property(nonatomic,strong) MLKMenuPopover *menuPopover;
@property(nonatomic, strong) NSArray *menuItems;
@property(nonatomic) int currentSortField;
@property(nonatomic) BOOL isNibRegistered;

@property(nonatomic, strong) NSArray *tempStockpileArr; //临时储存用, 搜索状态中
@property(nonatomic) BOOL isSearching;

@property(nonatomic, strong) NSNumber *userid;
@end

@implementation CardManageViewController
{
    int _tetnl;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetData:) name:@"DeleteCard" object:nil];
    
    //初始化主View
    UIView *mainView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    mainView.backgroundColor = [UIColor whiteColor];
    self.view = mainView;
    
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    pageNumber = 1;
    sortField = 1;
    self.currentSortField = 1;
    dataArray = [[NSMutableArray alloc]init];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //导航栏配置
    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
    self.navigationController.navigationBar.translucent = YES;
    
    //设置视图标题view
    //self.title = @"名片夹";
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(41, 0, 100, 30)];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setText:@"名片管理"];
    titleLabel.font = [UIFont boldSystemFontOfSize:20];
    self.navigationItem.titleView = titleLabel;
    
    [self setupMenuBarButtonItems];
    
    
    
    //搜索条
    bar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 64, width, 45)];
    bar.delegate = self;
    [bar setPlaceholder:@"请输入姓名或公司名称"];
    
    [self.view addSubview:bar];
    
    //数据表
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 45+64, width, height-64-45)];
    _tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];    //
    _tableView.dataSource = self;
    _tableView.delegate = self;
    //    _tableView.rowHeight = 100.0f;
    
    /*BOOL isUserLogin = [self isUserLogin];
    if (isUserLogin) {
        [self setupOriginData];
    }*/
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    BOOL isUserLogin = [self isUserLogin];
    if (isUserLogin) {
        [self setupOriginData];
    }
}

-(void)setupOriginData{
    [self.view addSubview:_tableView];
    self.menuItems = @[@"按姓名排序",@"按时间排序",@"亲密度排序"];
    cardHttpRequestService = [[CardHttpRequestService alloc]init];
    
    //显示加载动画
    [SVProgressHUD show];
    
    pageNumber = 1;
    
    [cardHttpRequestService getCardWithCompangOrName:@"" pageNumber:pageNumber pageSize:kPageSize sortField:1 userId:self.userid.intValue hasShare:NO success:^(NSString *strToken) {
        
        //移除加载动画
        [SVProgressHUD dismiss];
        
        if (dataArray.count>0) {
            [dataArray removeAllObjects];
        }
        
        
        CardListModel *cardListModel = [[CardListModel alloc]initWithString:strToken error:nil];
        for (CardModel *card in cardListModel.Items) {
            [dataArray addObject:card];
        }
        pageNumber ++;
        [_tableView reloadData];
        
        if((pageNumber-1)*kPageSize >= cardListModel.TotalItemCount){
            [_tableView.footer noticeNoMoreData];
        }
        
        
    } error:^(NSString *strFail) {
        
        //移除加载动画
        [SVProgressHUD dismiss];
        
        NSLog(@"fial");
    }];
    
    __block CardManageViewController *temp = self;
    
    // 添加传统的上拉刷新
    MJRefreshFooter *footer =
    [_tableView addLegendFooterWithRefreshingBlock:^{
        
        NSLog(@"当前pageNumber: %i", temp->pageNumber);
        
        // 进入刷新状态后会自动调用这个block
        [[[CardHttpRequestService alloc]init] getCardWithCompangOrName:temp->bar.text pageNumber:temp->pageNumber pageSize:kPageSize sortField:temp->sortField userId:temp->_userid.intValue hasShare:NO success:^(NSString *strToken) {
            [temp->_tableView.footer endRefreshing];
            //移除加载动画
            [SVProgressHUD dismiss];
            
            CardListModel *cardListModel = [[CardListModel alloc]initWithString:strToken error:nil];
            
            if (cardListModel.Items.count == 0) {
                [temp->_tableView.footer noticeNoMoreData];
                return ;
            }
            
            for (CardModel *card in cardListModel.Items) {
                [temp->dataArray addObject:card];
            }
            temp->pageNumber ++;
            
            if((temp->pageNumber-1)*kPageSize >= cardListModel.TotalItemCount){
                [temp->_tableView.footer noticeNoMoreData];
            }
            
            [temp->_tableView reloadData];
            
            
            
        } error:^(NSString *strFail) {
            [temp->_tableView.footer endRefreshing];
            //移除加载动画
            [SVProgressHUD dismiss];
            [footer endRefreshing];
            
            NSLog(@"fial");
        }];
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark- TableView Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    //    NSString *cellIdentifier = @"Cell";
    
    static NSString *CardListCellIdentifier = @"CardListCellIdentifier";
    if (!self.isNibRegistered) {
        UINib *nib = [UINib nibWithNibName:@"CardListCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:CardListCellIdentifier];
        self.isNibRegistered = YES;
    }
    
    CardListCell *cardListCell = [tableView dequeueReusableCellWithIdentifier:CardListCellIdentifier];
    
    if (indexPath.row == 0) {
    }
    
    if (!cardListCell) {
        cardListCell = [[CardListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CardListCellIdentifier];
    }
    
    CardModel *card = [dataArray objectAtIndex:indexPath.row];
    
    if (card.Position==nil||[card.Position isEqualToString:@"(null)"]) {
        cardListCell.nameLabel.text = card.Name;
    }else{
        NSString *nameAndTitle = [NSString stringWithFormat:@"%@    (%@)",card.Name,card.Position];
        cardListCell.nameLabel.text = nameAndTitle;
    }
    
    cardListCell.companyLabel.text = card.CompanyName;
    cardListCell.createTimeLabel.text = card.Createtime;
    cardListCell.closeValueLabel.text = [[NSString alloc]initWithFormat:@"亲密度:%@",card.CloseValue];
    
    return cardListCell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    CardModel *card = [dataArray objectAtIndex:indexPath.row];
    CardManageDetailViewController *nextViewController = [[CardManageDetailViewController alloc]initWithFrame:[UIScreen mainScreen].bounds andCardModel:card];
    
    [self.navigationController pushViewController:nextViewController animated:YES];
}

#pragma mark- UISearchBarDelegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    if (searchText.length==0) {
        return;
    }
    
    //    self.tempStockpileArr = self.menuItems;
    //    self.isSearching = YES;
    
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    pageNumber = 1;
    searchContent = searchBar.text;
    
    // 没有搜索内容
    //    if ([[searchContent stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""] || searchContent == nil){
    //        self.isSearching = NO;
    //        self.menuItems = [self.tempStockpileArr copy];
    //        self.tempStockpileArr = nil;
    //        [_tableView reloadData];
    //        return;
    //    }
    
    
    cardHttpRequestService = [[CardHttpRequestService alloc]init];
    [cardHttpRequestService getCardWithCompangOrName:searchContent pageNumber:pageNumber pageSize:kPageSize sortField:sortField userId:[self.userid intValue] hasShare:NO success:^(NSString *strToken) {
        dataArray = [NSMutableArray array];
        CardListModel *cardListModel = [[CardListModel alloc]initWithString:strToken error:nil];
        for (CardModel *card in cardListModel.Items) {
            [dataArray addObject:card];
        }
        pageNumber ++;
        [_tableView reloadData];
        [searchBar resignFirstResponder];
        
        
    } error:^(NSString *strFail) {
        
        NSLog(@"fial");
    }];
    
    
}
-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
}
-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
    
    UIView *topView = searchBar.subviews[0];
    
    for (UIView *subView in topView.subviews) {
        
        if ([subView isKindOfClass:NSClassFromString(@"UINavigationButton")]) {
            
            UIButton *cancelButton = (UIButton*)subView;
            //[cancelButton setTintColor:[UIColor blackColor]];
            [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
            
            
            
            //[cancelButton addTarget:self action:@selector(cancelBtn) forControlEvents:UIControlEventTouchUpInside];
        }
    }
}
-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    [searchBar setShowsCancelButton:NO animated:YES];
}


#pragma mark - 菜单相关
// 菜单创建函数
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

// 左菜单创建函数
- (UIBarButtonItem *)leftMenuBarButtonItem {
    
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0,0,30,30)];
    [button setImage:[UIImage imageNamed:@"icon_menu.png"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(leftSideMenuButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [button setTitleEdgeInsets:UIEdgeInsetsMake(-1, -55, 0, 0)];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithCustomView:button];
    
    return item;
}

// 右菜单创建
- (UIBarButtonItem *)rightMenuBarButtonItem {
    
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0,0,35,30)];
    [button setImage:[UIImage imageNamed:@"icon_sort"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(rightSideMenuButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithCustomView:button];
    
    return item;
}

// 左菜单处理函数
- (void)leftSideMenuButtonPressed:(id)sender {
    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{
        [self setupMenuBarButtonItems];
    }];
}

// 右菜单处理函数
- (void)rightSideMenuButtonPressed:(id)sender {
    if ([self isUserLogin]) {
        if (isPopup) {
            [self.menuPopover dismissMenuPopover];
            isPopup = NO;
        }else{
            
            NSArray *imageNames = @[@"name_order",@"time_order",@"close_order"];
            
            self.menuPopover = [[MLKMenuPopover alloc] initWithFrame:CGRectMake(kScreenWidth-140-60, 50, 120+60, 44*3) menuItems:self.menuItems andImages:imageNames];
            
            self.menuPopover.menuPopoverDelegate = self;
            [self.menuPopover showInView:self.view];
            isPopup = YES;
        }
    }
}

#pragma mark MLKMenuPopoverDelegate

- (void)menuPopover:(MLKMenuPopover *)menuPopover didSelectMenuItemAtIndex:(NSInteger)selectedIndex
{
    
    [self.menuPopover dismissMenuPopover];
    pageNumber = 1;
    searchContent =  bar.text;
    
    sortField = (int)selectedIndex+1;
    
    cardHttpRequestService = [[CardHttpRequestService alloc]init];
    [cardHttpRequestService getCardWithCompangOrName:bar.text pageNumber:pageNumber pageSize:kPageSize sortField:sortField userId:self.userid.intValue hasShare:NO success:^(NSString *strToken) {
        
        dataArray = [NSMutableArray array];
        
        CardListModel *cardListModel = [[CardListModel alloc]initWithString:strToken error:nil];
        for (CardModel *card in cardListModel.Items) {
            [dataArray addObject:card];
        }
        pageNumber ++;
        [_tableView reloadData];
        
        
    } error:^(NSString *strFail) {
        
        NSLog(@"fial");
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
-(void)resetData:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    
    //    CardModel *card = [userInfo objectForKey:@"Card"];
    [cardHttpRequestService getCardWithCompangOrName:bar.text pageNumber:pageNumber pageSize:kPageSize sortField:sortField userId:self.userid.intValue hasShare:NO success:^(NSString *strToken) {
        
        //移除加载动画
        [SVProgressHUD dismiss];
        
        CardListModel *cardListModel = [[CardListModel alloc]initWithString:strToken error:nil];
        for (CardModel *card in cardListModel.Items) {
            [dataArray addObject:card];
        }
        pageNumber ++;
        [_tableView reloadData];
        
        
    } error:^(NSString *strFail) {
        
        //移除加载动画
        [SVProgressHUD dismiss];
        
        NSLog(@"fial");
    }];
    
}

#pragma mark - 用户登录判断

-(BOOL)isUserLogin{
    
    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
    
    NSString * username = [defaults objectForKey:@"username"];
    NSString * userid = [defaults objectForKey:@"userid"];
    
    if (username == nil || userid == nil) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"友情提示"
                                                       message:@"用户未登录,请先前往登录页面"
                                                      delegate:self
                                             cancelButtonTitle:nil
                                             otherButtonTitles:@"前往",nil];
        alert.tag = kAlertToLoginViewTag;
        [alert show];
        return NO;
    }
    
    self.userid = @([userid intValue]);
    return YES;
}

#pragma mark - UIAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == kAlertToLoginViewTag && buttonIndex == 0) {
        PopLoginViewController *viewController = [[PopLoginViewController alloc]init];
        [viewController didLoginSuccess:^{
            [self setupOriginData];
            [viewController dismissViewControllerAnimated:YES completion:nil];
        }];
        [self presentViewController:viewController animated:YES completion:^{
            
        }];
    }
}
@end
