//
//  CardStatisticsViewController.m
//  CardRecognition
//  名片统计视图控制器
//  Created by bournejason on 15/5/5.
//  Copyright (c) 2015年 bournejason. All rights reserved.
//

#import "CardStatisticsViewController.h"
#import "MFSideMenu.h"
#import "MLKMenuPopover.h"
#import "OptionTableView.h"
#import "StatisticHttpRequestService.h"
#import "TimeUtil.h"
#import "CustomOptionView.h"
#import "SHLineGraphView.h"
#import "SHPlot.h"
#import "PopLoginViewController.h"

#define kButtonBGColor 0x403f3f //左菜单单元背景颜色
#define kButtonHighliftColor 0x282828 //左菜单头背景颜色
#define kButtonFontColor 0xe1e4e3 //左菜单字体颜色
#define kScreenWidth [[UIScreen mainScreen] bounds].size.width

#define kMyCardButtonTag 1
#define kSysCardButtonTag 2
#define kXpointNum 6

#define kTimeIntervalOneDay (60*60*24)
#define kAlertToLoginViewTag 1000

@interface CardStatisticsViewController ()<MLKMenuPopoverDelegate,UIAlertViewDelegate,UIWebViewDelegate,UIGestureRecognizerDelegate>
{
    bool isPopup;
}
@property(nonatomic,strong) MLKMenuPopover *menuPopover;
@property(nonatomic) BOOL isShowingLineChartView;
@property(nonatomic) BOOL isShowByDay;
@property(nonatomic) BOOL isShowByMonth;

@property(nonatomic) BOOL isShowByBusiness;
@property(nonatomic) BOOL isShowByRegion;

@property(nonatomic) BOOL isShowMyCard;
@property(nonatomic) BOOL isShowSysCard;
@property(nonatomic) BOOL isShowDefaultCard;

@property(nonatomic, strong) UIWindow *window;

@property(nonatomic, copy) NSString *startDate;
@property(nonatomic, copy) NSString *endDate;

@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer; //
@property (nonatomic) CGPoint panStartPoint;
@property (nonatomic) CGPoint panEndedPoint;

@property(nonatomic, strong) NSNumber *userid;
@end

@implementation CardStatisticsViewController

-(UIPanGestureRecognizer *)panGestureRecognizer{
    
    if (!_panGestureRecognizer) {
        _panGestureRecognizer = [[UIPanGestureRecognizer alloc]
                                 initWithTarget:self action:@selector(handlePan:)];
        [_panGestureRecognizer setMaximumNumberOfTouches:1];
        [_panGestureRecognizer setDelegate:self];
    }
    return _panGestureRecognizer;
}

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        
        self.isShowingLineChartView = YES;
        self.isShowByDay = YES;
        self.isShowByMonth = NO;
        
        self.isShowDefaultCard = YES;
        self.isShowMyCard = YES;
        self.isShowSysCard = NO;
        
        self.isShowByBusiness = YES;
        self.isShowByRegion = NO;
        
        self.startDate = @"";
        self.endDate = [TimeUtil getCurrentTime];
        
        
        
        self.myCardButton.highlighted = NO;
        self.sysCardButton.highlighted =NO;
        [self setupNavigationView];
        
        self.contentView.scrollView.scrollEnabled = NO;
        self.pieChartWebView.scrollView.scrollEnabled = NO;
        
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIColor *highlightColor =  [UIColor colorWithRed:((float)((kButtonBGColor & 0xFF0000) >> 16))/255.0 green:((float)((kButtonBGColor & 0xFF00) >> 8))/255.0 blue:((float)(kButtonBGColor & 0xFF))/255.0 alpha:1.0];
    UIColor *normalColor = [UIColor colorWithRed:((float)((kButtonHighliftColor & 0xFF0000) >> 16))/255.0 green:((float)((kButtonHighliftColor & 0xFF00) >> 8))/255.0 blue:((float)(kButtonHighliftColor & 0xFF))/255.0 alpha:1.0];
    self.myCardButton.backgroundColor = highlightColor;
    self.sysCardButton.backgroundColor = normalColor;
    
    self.myCardButton.tag = kMyCardButtonTag;
    self.sysCardButton.tag = kSysCardButtonTag;
    self.pieChartView.hidden = YES;
    
    
    
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
    
    [self getSourceData];
}

-(void)handlePan:(UIPanGestureRecognizer *)recognizer {
    
    //    if (!self.isGettingDate) {
    CGPoint translatedPoint = [recognizer translationInView:self.contentView.scrollView];
    if (recognizer.state == UIGestureRecognizerStateBegan){
        NSLog(@"begin x: %f, y: %f",translatedPoint.x,translatedPoint.y);
        NSLog(@"do something");
        self.panStartPoint = translatedPoint;
    }
    if (recognizer.state == UIGestureRecognizerStateChanged) {
        NSLog(@"do something");
    }
    
    if (recognizer.state == UIGestureRecognizerStateEnded){
        NSLog(@"do something");
        NSLog(@"ended x: %f, y: %f",translatedPoint.x,translatedPoint.y);
        self.panEndedPoint = translatedPoint;
        
        [self wheatherGetNewData];
    }
    //    }
}


-(void)wheatherGetNewData {
    
    CGFloat width = self.panEndedPoint.x - self.panStartPoint.x;
    
    if (ABS(width) > 30.0f) {
        [self.contentView.scrollView removeGestureRecognizer:_panGestureRecognizer];
        
        // 换新数据
        
        if (width > 0.0f){
            // 往前
            
            NSDate *oldStartDate = [TimeUtil getTargetDate:self.startDate];
            self.endDate = [TimeUtil getTargetTime:oldStartDate];
            
        }else{
            // 往后
            
            if (self.isShowByDay){
                NSDate *endDay = [TimeUtil getTargetDate:self.endDate];
                NSDate *endD = [NSDate dateWithTimeInterval:kXpointNum* kTimeIntervalOneDay sinceDate:endDay];
                self.endDate = [TimeUtil getTargetTime:endD];
            }
            
            if (self.isShowByMonth) {
                NSDate *endDay = [TimeUtil getTargetDate:self.endDate];
                self.endDate = [TimeUtil newDate:-kXpointNum from:endDay];
            }
            
        }
        
        [self getSourceData];
    }
    
}

#pragma mark - navigation config

-(void)setupNavigationView {
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(41, 0, 100, 30)];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setText:@"名片统计"];
    titleLabel.font = [UIFont boldSystemFontOfSize:20];
    self.navigationItem.titleView = titleLabel;
    
    [self setupMenuBarButtonItems];
}

- (UIBarButtonItem *)rightMenuBarButtonItem {
    
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0,0,35,30)];
    [button setImage:[UIImage imageNamed:@"icon_sort"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(rightSideMenuButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithCustomView:button];
    
    return item;
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

- (void)leftSideMenuButtonPressed:(id)sender {
    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{
        [self setupMenuBarButtonItems];
    }];
}

- (UIBarButtonItem *)leftMenuBarButtonItem {
    
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0,0,30,30)];
    [button setImage:[UIImage imageNamed:@"icon_menu.png"] forState:UIControlStateNormal];
    //    [button setImage:[UIImage imageNamed:@"return_back_pressed"] forState:UIControlStateSelected];
    [button addTarget:self action:@selector(leftSideMenuButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [button setTitleEdgeInsets:UIEdgeInsetsMake(-1, -55, 0, 0)];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithCustomView:button];
    item.style = UIBarButtonSystemItemAction;
    return item;
}

- (void)rightSideMenuButtonPressed:(id)sender {
    
    NSArray *imageNames;
    int count = 0;
    NSArray *menuItems;
    if (self.isShowingLineChartView) {
        menuItems = @[@"饼状图"];
        imageNames = @[@"bingzhuang"];
    }else{
        menuItems = @[@"折线图"];
        imageNames = @[@"zhexian"];
    }
    
    
    count = (int)menuItems.count ;
    
    if (isPopup) {
        [self.menuPopover dismissMenuPopover];
        isPopup = NO;
    }else{
        self.menuPopover = [[MLKMenuPopover alloc] initWithFrame:CGRectMake(kScreenWidth-140-60, 50, 120+60, 44*count) menuItems:menuItems andImages:imageNames];
        self.menuPopover.menuPopoverDelegate = (id)self;
        [self.menuPopover showInView:self.view];
        isPopup = YES;
    }
}


#pragma mark -

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

- (IBAction)showTypeList:(id)sender {
    
    NSArray *titleNameArr = @[@"按天显示",@"按月显示"];
    int selectIndex;
    if (self.isShowByDay && !self.isShowByMonth) {
        selectIndex = 0;
    }else if (!self.isShowByDay && self.isShowByMonth){
        selectIndex = 1;
    }
    
    //    selectIndex = -1;  // < 0 不显示markCheck图标
    
    CustomOptionView *view = [[CustomOptionView alloc]initWithParams:titleNameArr defaultSelectIndex:selectIndex];
    [view didSelectIndexPath:^(NSIndexPath *indexPath, NSString *context, NSInteger tag) {
        if (indexPath.row == 0) {
            self.isShowByDay = YES;
            self.isShowByMonth = NO;
            self.showTypeLabel.text = @"  按天显示";
        }else if (indexPath.row == 1){
            self.isShowByDay = NO;
            self.isShowByMonth = YES;
            self.showTypeLabel.text = @"  按月显示";
        }
        self.startDate = @"";
        self.endDate = [TimeUtil getCurrentTime];
        [self getSourceData];
    }];
    
}

- (IBAction)switchMyCardAndSysCard:(UIButton *)sender {
    UIColor *highlightColor =  [UIColor colorWithRed:((float)((kButtonBGColor & 0xFF0000) >> 16))/255.0 green:((float)((kButtonBGColor & 0xFF00) >> 8))/255.0 blue:((float)(kButtonBGColor & 0xFF))/255.0 alpha:1.0];
    UIColor *normalColor = [UIColor colorWithRed:((float)((kButtonHighliftColor & 0xFF0000) >> 16))/255.0 green:((float)((kButtonHighliftColor & 0xFF00) >> 8))/255.0 blue:((float)(kButtonHighliftColor & 0xFF))/255.0 alpha:1.0];
    
    if (sender.tag == kMyCardButtonTag) {
        
        if (self.isShowMyCard) {
            return;
        }
        
        self.myCardButton.backgroundColor = highlightColor;
        self.sysCardButton.backgroundColor = normalColor;
        
        self.isShowMyCard = YES;
        self.isShowSysCard = NO;
        self.isShowDefaultCard = YES;
        
    }else if (sender.tag == kSysCardButtonTag){
        
        if (self.isShowSysCard) {
            return;
        }
        
        self.myCardButton.backgroundColor = normalColor;
        self.sysCardButton.backgroundColor = highlightColor;
        
        self.isShowMyCard = NO;
        self.isShowSysCard = YES;
        self.isShowDefaultCard = NO;
    }
    
    if (self.isShowingLineChartView) {
        [self getSourceData];
    }else{
        [self getDataSourceOfPieChart];
    }
}

#pragma mark - MLK delegate

- (void)menuPopover:(MLKMenuPopover *)menuPopover didSelectMenuItemAtIndex:(NSInteger)selectedIndex
{
    
    [self.menuPopover dismissMenuPopover];
    if (self.isShowingLineChartView){
        // 显示分布图
        self.LineChartView.hidden = YES;
        self.pieChartView.hidden = NO;
        self.isShowingLineChartView = NO;
        
        if ([self isUserLogin]) {
            [self getDataSourceOfPieChart];
        }
        
    }else{
        // 显示折线图
        self.LineChartView.hidden = NO;
        self.pieChartView.hidden = YES;
        self.isShowingLineChartView = YES;
    }
}

-(void)removeCurrentWindow:(id)sender {
    
    [UIView animateWithDuration:0.2 animations:^{
        self.window.alpha = 0.0f;
    } completion:^(BOOL finished) {
        self.window.hidden = YES;
        [self.window removeFromSuperview];
        self.window = nil;
    }];
    
}

#pragma mark - data request

-(void)getSourceData {
    
    StatisticHttpRequestService *request = [[StatisticHttpRequestService alloc]init];
    
    NSNumber *analyType = @(0);
    if (self.isShowByDay) {
        NSDate *endDay = [TimeUtil getTargetDate:self.endDate];
        NSDate *beforeDate =[NSDate dateWithTimeInterval:-kXpointNum* kTimeIntervalOneDay sinceDate:endDay];
        self.startDate = [TimeUtil getTargetTime:beforeDate];
        analyType = @(2);
    }
    
    if (self.isShowByMonth) {
        NSDate *endDay = [TimeUtil getTargetDate:self.endDate];
        self.startDate = [TimeUtil newDate:kXpointNum from:endDay];
        analyType = @(1);
    }
    
    [request getCardGrowthByUserID:[self getSourceByUserOrSystem] analyType:analyType startDate:self.startDate endDate:self.endDate
                           success:^(NSString *strToken) {
                               
                               NSLog(@"%@",strToken);
                               NSData *data = [strToken dataUsingEncoding:NSUTF8StringEncoding];
                               NSArray *dataArr = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                               
                               NSMutableArray *xArr = [NSMutableArray array];
                               NSMutableArray *yArr = [NSMutableArray array];
                               
                               for (int i = 0; i< dataArr.count; i++) {
                                   NSDictionary *dataDic = dataArr[i];
                                   NSString *xText = [NSString stringWithFormat:@"\'%@\'",[dataDic objectForKey:@"time"]];
                                   NSString *yValue = [NSString stringWithFormat:@"%@",[dataDic objectForKey:@"value"]];
                                   
                                   
                                   [xArr addObject:xText];
                                   [yArr addObject:yValue];
                               }
                               
                               NSString *htmlFile = [[NSBundle mainBundle] pathForResource:@"Lines" ofType:@"html"];
                               NSString* htmlString = [NSString stringWithContentsOfFile:htmlFile encoding:NSUTF8StringEncoding error:nil];
                               
                               NSURL *baseURL = [NSURL fileURLWithPath:htmlFile];
                               NSString *strWidth;
                               strWidth = [NSString stringWithFormat:@"%f",self.contentView.bounds.size.width];
                               NSString *strHeight;
                               strHeight = [NSString stringWithFormat:@"%f",self.contentView.bounds.size.height];
                               
                               NSArray *xAxises = @[@"'a'",@"'b'",@"'c'",@"'d'",@"'e'"];
                               xAxises = xArr;
                               NSArray *dataSeries = @[@"7.0",@"6.9",@"5.1",@"4.2",@"4.4"];
                               dataSeries = yArr;
                               
                               NSString *strXAxises = [xAxises componentsJoinedByString:@","];
                               NSString *strData = [dataSeries componentsJoinedByString:@","];
                               NSString *strDataLabel = @"名片数量";
                               NSString *strYLabel = @"";
                               
                               htmlString = [htmlString stringByReplacingOccurrencesOfString:@"##title##" withString:@""];
                               htmlString = [htmlString stringByReplacingOccurrencesOfString:@"##width##" withString:strWidth];
                               htmlString = [htmlString stringByReplacingOccurrencesOfString:@"##height##" withString:strHeight];
                               htmlString = [htmlString stringByReplacingOccurrencesOfString:@"##xAxis##" withString:strXAxises];
                               htmlString = [htmlString stringByReplacingOccurrencesOfString:@"##data##" withString:strData];
                               htmlString = [htmlString stringByReplacingOccurrencesOfString:@"##dataLabel##" withString:strDataLabel];
                               htmlString = [htmlString stringByReplacingOccurrencesOfString:@"##yAxisTitle##" withString:strYLabel];
                               
                               [self.contentView loadHTMLString:htmlString baseURL:baseURL];
                               [self.contentView.scrollView addGestureRecognizer:self.panGestureRecognizer];
                               
                           } error:^(NSString *strFail) {
                               
                           }];
}

-(void)webViewDidStartLoad:(UIWebView *)webView{
    
}
-(void)webViewDidFinishLoad:(UIWebView *)webView{
    
}
-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    
}

- (IBAction)pieChartChooseOtherType:(id)sender {
    
    NSArray *titleNameArr = @[@"按行业统计",@"按地区统计"];
    int selectIndex;
    selectIndex = -1;  // < 0 不显示markCheck图标
    
    if (self.isShowByBusiness) {
        selectIndex = 0;
    }
    if (self.isShowByRegion) {
        selectIndex = 1;
    }
    
    
    
    CustomOptionView *view = [[CustomOptionView alloc]initWithParams:titleNameArr defaultSelectIndex:selectIndex];
    [view didSelectIndexPath:^(NSIndexPath *indexPath, NSString *context, NSInteger tag) {
        if (indexPath.row == 0) {
            
            self.pieChartInfoLabel.text = @"  按行业统计";
            self.isShowByBusiness = YES;
            self.isShowByRegion = NO;
            
            
        }else if (indexPath.row == 1){
            
            self.isShowByBusiness = NO;
            self.isShowByRegion = YES;
            self.pieChartInfoLabel.text = @"  按地区统计";
            
        }
        
        [self getDataSourceOfPieChart];
    }];
}

-(void)getDataSourceOfPieChart {
    StatisticHttpRequestService *request = [[StatisticHttpRequestService alloc]init];
    
    NSNumber *section;
    if (self.isShowByBusiness) {
        section = @(1);
    }
    if (self.isShowByRegion) {
        section = @(2);
    }
    
    [request getCardPieByUserID:[self getSourceByUserOrSystem] section:section success:^(NSString *strToken) {
        
        NSLog(@"%@",strToken);
        
        NSData *data = [strToken dataUsingEncoding:NSUTF8StringEncoding];
        NSArray *dataArr = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        
        NSMutableArray *arr = [NSMutableArray array];
        
        for (int i = 0; i< dataArr.count; i++) {
            NSDictionary *dataDic = dataArr[i];
            
            NSString *yValue = [NSString stringWithFormat:@"%@",[dataDic objectForKey:@"value"]];
            NSString *xText = [NSString stringWithFormat:@"\'%@ %@\'",[dataDic objectForKey:@"time"],[dataDic objectForKey:@"value"]];
            
            
            NSString *param = [NSString stringWithFormat:@"[%@,%@]",xText,yValue];
            [arr addObject:param];
        }
        
        //                                pie chart
        NSString *htmlFile = [[NSBundle mainBundle] pathForResource:@"Pie" ofType:@"html"];
        NSString* htmlString = [NSString stringWithContentsOfFile:htmlFile encoding:NSUTF8StringEncoding error:nil];
        
        NSURL *baseURL = [NSURL fileURLWithPath:htmlFile];
        NSString *strMinWidth = @"310";
        NSString *strMaxWidth = @"600";
        
        
        NSString *strHeight = @"1600";
        
        if ([UIScreen mainScreen].bounds.size.height==320) {
            strHeight = @"300";
        }
        
        
        strMaxWidth = [NSString stringWithFormat:@"%f",self.pieChartWebView.bounds.size.width];
        strHeight = [NSString stringWithFormat:@"%f",self.pieChartWebView.bounds.size.height];
        strHeight = @"300";
        //strMaxWidth = @"310";
        
        
        NSArray *dataSeries = @[@"['a',25.0]",@"['b',25.0]",@"['c',25.0]",@"['d',25.0]"];
        dataSeries = arr;
        
        NSString *strData = [dataSeries componentsJoinedByString:@","];
        NSString *strDataLabel = @"百分比";
        
        htmlString = [htmlString stringByReplacingOccurrencesOfString:@"##title##" withString:@""];
        htmlString = [htmlString stringByReplacingOccurrencesOfString:@"##minWidth##" withString:strMinWidth];
        htmlString = [htmlString stringByReplacingOccurrencesOfString:@"##maxWidth##" withString:strMaxWidth];
        htmlString = [htmlString stringByReplacingOccurrencesOfString:@"##height##" withString:strHeight];
        htmlString = [htmlString stringByReplacingOccurrencesOfString:@"##data##" withString:strData];
        htmlString = [htmlString stringByReplacingOccurrencesOfString:@"##dataLabel##" withString:strDataLabel];
        NSLog(@"%@",htmlString);
        
        [self.pieChartWebView loadHTMLString:htmlString baseURL:baseURL];
        
    } error:^(NSString *strFail) {
        
    }];
}

-(NSNumber *)getSourceByUserOrSystem {
    
    if (self.isShowMyCard) {
        return self.userid;
    }
    
    if (self.isShowSysCard) {
        return @(0);
    }
    
    return @(0);
    
}

#pragma mark - 用户登录判断

-(BOOL)isUserLogin{
    
    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
    
    id username = [defaults objectForKey:@"username"];
    id userid = [defaults objectForKey:@"userid"];
    
    if (username == nil || userid == nil) {
        self.chooseShowTypeButton.enabled = NO;
        self.pieChartShowTypeButton.enabled = NO;
        return NO;
    }
    self.chooseShowTypeButton.enabled = YES;
    self.pieChartShowTypeButton.enabled = YES;
    return YES;
}

#pragma mark - UIAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == kAlertToLoginViewTag && buttonIndex == 0) {
        PopLoginViewController *viewController = [[PopLoginViewController alloc]init];
        [viewController didLoginSuccess:^{
            
            [viewController dismissViewControllerAnimated:YES completion:nil];
        }];
        [self presentViewController:viewController animated:YES completion:^{
            
        }];
    }
}
@end
