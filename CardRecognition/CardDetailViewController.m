//
//  CardDetailViewController.m
//  CardRecognition
//
//  Created by bournejason on 15/5/28.
//  Copyright (c) 2015年 bournejason. All rights reserved.
//

#import "CardDetailViewController.h"
#import "RecognitionResultTableViewCell.h"
#import "DBOperation.h"
#import "DBCard.h"
#import "MLKMenuPopover.h"
#import "CardModel.h"
#import "CardPackageDetailView.h"
#import "DBCard.h"

#define kButtonHighliftColor 0x282828 //左菜单头背景颜色
#define kScreenWidth [[UIScreen mainScreen] bounds].size.width
#define kScreenHeight [[UIScreen mainScreen] bounds].size.height

#define kEditCard 0   //编辑名片
#define kDeleteCard 1    //删除名片

@interface CardDetailViewController ()<MLKMenuPopoverDelegate,UIAlertViewDelegate>{
    
    bool isPopup;
    //数据库操作类
    DBOperation *db;
    

}
@property (nonatomic, strong) DBCard *cardDetail;
@property (nonatomic, strong) UIView *contentView;  // 主内容页面


@property (nonatomic, strong) CardPackageDetailView *cardDetailView;

@property(nonatomic,strong) MLKMenuPopover *menuPopover;
@property(nonatomic, strong) NSArray *menuItems;



@end

@implementation CardDetailViewController

-(UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc]initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height-64)];
        _contentView.backgroundColor = [UIColor lightGrayColor];
        [self.view addSubview:_contentView];
    }
    return _contentView;
}

-(CardPackageDetailView *)cardDetailView{
    if (!_cardDetailView) {
        //        _cardDetailView = [[CardDetailView alloc]initWithFrame:self.contentView.bounds];
        _cardDetailView = [[CardPackageDetailView alloc]initWithFrame:self.contentView.bounds andCardModel:self.cardDetail];
        _cardDetailView.backgroundColor = [UIColor whiteColor];
        _cardDetailView.parentViewController = self;
        [self.contentView addSubview:_cardDetailView];
    }
    return _cardDetailView;
}

#pragma mark -
-(id)initWithFrame:(CGRect)frame andCardModel:(NSInteger *)cardID{
    
    
    self = [super init];
    if (self) {
        self.view.frame = frame;
        
        db = [[DBOperation alloc]init];
        self.cardDetail = [db getCardInfoById:cardID];
        
        isPopup = NO;
        
        [self setupNavigationView];
        
        [self.contentView addSubview:self.cardDetailView];
        
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    return self;
}

-(void)setupNavigationView {
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(41, 0, 100, 30)];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setText:@"名片详情"];
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
    //self.navigationItem.rightBarButtonItem = [self rightMenuBarButtonItem];
    
    
    UIBarButtonItem *negativeRightSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeRightSpacer.width = -10;
    self.navigationItem.rightBarButtonItems = @[negativeRightSpacer,[self rightMenuBarButtonItem]];
    
    //self.navigationItem.rightBarButtonItem = [self rightMenuBarButtonItem];
}
- (UIBarButtonItem *)rightMenuBarButtonItem {
    
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0,0,35,30)];
    [button setImage:[UIImage imageNamed:@"icon_sort"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(rightSideMenuButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithCustomView:button];
    
    return item;
}

- (void)rightSideMenuButtonPressed:(id)sender{
    NSArray *imageNames;
    int count = 0;
    
    self.menuItems = @[@"编辑名片",@"删除名片"];
    imageNames = @[@"edit",@"card_info_delete"];
        
    if (isPopup) {
        [self.menuPopover dismissMenuPopover];
        isPopup = NO;
    }else{
        self.menuPopover = [[MLKMenuPopover alloc] initWithFrame:CGRectMake(kScreenWidth-140-60, 50, 120+60, 44*2) menuItems:self.menuItems andImages:imageNames];
        self.menuPopover.menuPopoverDelegate = (id)self;
        [self.menuPopover showInView:self.view];
        isPopup = YES;
    }
}

- (void)leftSideMenuButtonPressed:(id)sender {
//    if ([self.cardDetailView checkCard]) {
//        [self.navigationController popViewControllerAnimated:YES];
//    }
    
    [self.navigationController popViewControllerAnimated:YES];
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

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}

#pragma mark - MLKMenuPopover delegate

-(void)menuPopover:(MLKMenuPopover *)menuPopover didSelectMenuItemAtIndex:(NSInteger)selectedIndex{
    if (selectedIndex == 0) {
        NSLog(@"编辑名片");
        if (!self.isEdittingCard) {
            //                [self detailViewChangeMenuName:menuPopover];
            [self.cardDetailView setCardEditting:YES];
            self.isEdittingCard = YES;
        }else{
            
            [self.cardDetailView setCardEditting:NO];
            self.isEdittingCard = NO;
        }
    }else if(selectedIndex == 1){
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"确认删除"
                                                       message:@"确认删除此名片吗？"
                                                      delegate:self
                                             cancelButtonTitle:@"取消"
                                             otherButtonTitles:@"确认",nil];
        alert.tag = 1;
        [alert show];
        
        
        
        
    }
}
#pragma mark - UIAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 1 && buttonIndex== 1) {
        [self deleteCard];
    }
}

-(void)deleteCard{

    [db DeleteCard:[NSString stringWithFormat:@"%@",self.cardDetail.Id]];
    [self.navigationController popViewControllerAnimated:YES];
}


@end
