//
//  CardManageDetailViewController.m
//  CardRecognition
//
//  Created by sunshinek31 on 15/6/4.
//  Copyright (c) 2015年 bournejason. All rights reserved.
//

#import "CardManageDetailViewController.h"
#import "CardModel.h"
#import "CardDetailView.h"
#import "ActivityManageView.h"
#import "MLKMenuPopover.h"
#import "CreateActivityViewController.h"
#import "CardShareViewController.h"
#import "CardUnshareViewController.h"
#import "ShareHttpRequestService.h"
#import "Contactactivity.h"
#import "CardHttpRequestService.h"
#import "ExceptionInfo.h"
#import "RMMapper.h"
#import "SVProgressHUD.h"

#define kButtonBGColor 0x403f3f //左菜单单元背景颜色
#define kButtonHighliftColor 0x282828 //左菜单头背景颜色
#define kButtonFontColor 0xe1e4e3 //左菜单字体颜色

#define kSectionViewHeight 40.0f
#define kScreenWidth [[UIScreen mainScreen] bounds].size.width

#define kDetailButtonTag 1
#define kManageButtonTag 2

#define kDeleteCardAlertTag 1001
#define kDeleteCardAlert_success_tag 1002

@interface CardManageDetailViewController ()<MLKMenuPopoverDelegate,UIAlertViewDelegate>
{
    bool isPopup;
}
@property (nonatomic, strong) CardModel *cardDetail;
@property (nonatomic, strong) UIView *sectionView;  // 页面分区功能view
@property (nonatomic, strong) UIView *contentView;  // 主内容页面

@property (nonatomic, strong) UIButton *detailButton;
@property (nonatomic, strong) UIButton *manageButton;

@property (nonatomic, strong) CardDetailView *cardDetailView;
@property (nonatomic, strong) ActivityManageView *activityMangeView;

@property (nonatomic) BOOL isShowCardDetail;
@property (nonatomic) BOOL isShowActivityManage;
@property (nonatomic) BOOL isShowDefaultContentView;

@property(nonatomic,strong) MLKMenuPopover *menuPopover;
@property(nonatomic, strong) NSArray *menuItems;


@end

@implementation CardManageDetailViewController

#pragma mark - getter

-(UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc]initWithFrame:CGRectMake(0, kSectionViewHeight+64, self.view.frame.size.width, self.view.frame.size.height - kSectionViewHeight-64)];
        _contentView.backgroundColor = [UIColor lightGrayColor];
        [self.view addSubview:_contentView];
    }
    return _contentView;
}

-(CardDetailView *)cardDetailView{
    if (!_cardDetailView) {
        //        _cardDetailView = [[CardDetailView alloc]initWithFrame:self.contentView.bounds];
        _cardDetailView = [[CardDetailView alloc]initWithFrame:self.contentView.bounds andCardModel:self.cardDetail];
        _cardDetailView.backgroundColor = [UIColor whiteColor];
        _cardDetailView.parentViewController = self;
        [self.contentView addSubview:_cardDetailView];
    }
    return _cardDetailView;
}
-(ActivityManageView *)activityMangeView{
    if (!_activityMangeView) {
        _activityMangeView = [[ActivityManageView alloc]initWithFrame:self.contentView.bounds];
        _activityMangeView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        _activityMangeView.parentViewController = self;
        [_activityMangeView configSourceDataWithCardId:[NSString stringWithFormat:@"%@",self.cardDetail.Id]];
        [self.contentView addSubview:self.activityMangeView];
    }
    return _activityMangeView;
}


#pragma mark -
-(id)initWithFrame:(CGRect)frame andCardModel:(CardModel *)cardModel{
    self = [super init];
    if (self) {
        self.view.frame = frame;
        self.cardDetail = cardModel;
        
        
        self.isShowCardDetail = YES;
        self.isShowActivityManage = NO;
        self.isShowDefaultContentView = YES;    // 默认显示名片详情view;
        [self setupNavigationView];
        [self setupSectionView];
        
        [self.contentView addSubview:self.cardDetailView];
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
    [self.navigationController popViewControllerAnimated:YES];
    [SVProgressHUD dismiss];
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

- (void)rightSideMenuButtonPressed:(id)sender {
    
    NSArray *imageNames;
    int count = 0;
    if (self.isShowDefaultContentView) {
        self.menuItems = self.isEdittingCard ? @[@"取消编辑",@"删除名片",@"分享名片",@"取消分享"] : @[@"编辑名片",@"删除名片",@"分享名片",@"取消分享"] ;
        imageNames = @[@"edit",@"card_info_delete",@"share_select",@"cancel_share"];
    }else{
        self.menuItems = @[@"新建活动"];
        imageNames = @[@"edit"];
    }
    count = (int)self.menuItems.count ;
    
    if (isPopup) {
        [self.menuPopover dismissMenuPopover];
        isPopup = NO;
    }else{
        self.menuPopover = [[MLKMenuPopover alloc] initWithFrame:CGRectMake(kScreenWidth-140-60, 50, 120+60, 44*count) menuItems:self.menuItems andImages:imageNames];
        self.menuPopover.menuPopoverDelegate = (id)self;
        [self.menuPopover showInView:self.view];
        isPopup = YES;
    }
}

#pragma mark -

-(void)setupSectionView {
    self.sectionView = [[UIView alloc]initWithFrame:CGRectMake(0, 64, [[UIScreen mainScreen] bounds].size.width, kSectionViewHeight)];
    [self.view addSubview:self.sectionView];
    //上按钮条
    self.detailButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width/2, kSectionViewHeight)];
    self.detailButton.backgroundColor = [UIColor colorWithRed:((float)((kButtonBGColor & 0xFF0000) >> 16))/255.0 green:((float)((kButtonBGColor & 0xFF00) >> 8))/255.0 blue:((float)(kButtonBGColor & 0xFF))/255.0 alpha:1.0];
    [self.detailButton setTitle:@"名片详情" forState:UIControlStateNormal];
    [self.detailButton setTitleColor:[UIColor colorWithRed:((float)((kButtonFontColor & 0xFF0000) >> 16))/255.0 green:((float)((kButtonFontColor & 0xFF00) >> 8))/255.0 blue:((float)(kButtonFontColor & 0xFF))/255.0 alpha:1.0] forState:UIControlStateNormal];
    self.detailButton.titleLabel.font = [UIFont systemFontOfSize: 14.0];
    self.detailButton.tag = kDetailButtonTag;
    [self.sectionView addSubview:self.detailButton];
    
    self.manageButton = [[UIButton alloc] initWithFrame:CGRectMake([[UIScreen mainScreen] bounds].size.width/2,0, [[UIScreen mainScreen] bounds].size.width/2, kSectionViewHeight)];
    self.manageButton.backgroundColor = [UIColor colorWithRed:((float)((kButtonHighliftColor & 0xFF0000) >> 16))/255.0 green:((float)((kButtonHighliftColor & 0xFF00) >> 8))/255.0 blue:((float)(kButtonHighliftColor & 0xFF))/255.0 alpha:1.0];
    [self.manageButton setTitle:@"活动管理" forState:UIControlStateNormal];
    [self.manageButton setTitleColor:[UIColor colorWithRed:((float)((kButtonFontColor & 0xFF0000) >> 16))/255.0 green:((float)((kButtonFontColor & 0xFF00) >> 8))/255.0 blue:((float)(kButtonFontColor & 0xFF))/255.0 alpha:1.0] forState:UIControlStateNormal];
    self.manageButton.titleLabel.font = [UIFont systemFontOfSize: 14.0];
    self.manageButton.tag = kManageButtonTag;
    [self.sectionView addSubview:self.manageButton];
    
    [self.detailButton addTarget:self action:@selector(switchContentView:) forControlEvents:UIControlEventTouchUpInside];
    [self.manageButton addTarget:self action:@selector(switchContentView:) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - 内部页面切换

-(void)switchContentView:(UIButton *)sender {
    
    if (sender.tag == kDetailButtonTag) {
        if (self.isShowCardDetail) {
            return;
        }
    }else if(sender.tag == kManageButtonTag){
        if (self.isShowActivityManage) {
            return;
        }
    }
    
    if (self.isShowDefaultContentView) {
        // 从详情页面切换至活动管理页面
        
        [UIView animateWithDuration:0.2 animations:^{
            
            self.detailButton.backgroundColor = [UIColor colorWithRed:((float)((kButtonHighliftColor & 0xFF0000) >> 16))/255.0 green:((float)((kButtonHighliftColor & 0xFF00) >> 8))/255.0 blue:((float)(kButtonHighliftColor & 0xFF))/255.0 alpha:1.0];
            self.manageButton.backgroundColor = [UIColor colorWithRed:((float)((kButtonBGColor & 0xFF0000) >> 16))/255.0 green:((float)((kButtonBGColor & 0xFF00) >> 8))/255.0 blue:((float)(kButtonBGColor & 0xFF))/255.0 alpha:1.0];
            
            [self.cardDetailView removeFromSuperview];
            [self.contentView addSubview:self.activityMangeView];
            
            self.isShowActivityManage = YES;
            self.isShowCardDetail = NO;
        } completion:nil];
        
    }else{
        // 从活动管理页面切换至名片详情页面
        [UIView animateWithDuration:0.2 animations:^{
            self.detailButton.backgroundColor = [UIColor colorWithRed:((float)((kButtonBGColor & 0xFF0000) >> 16))/255.0 green:((float)((kButtonBGColor & 0xFF00) >> 8))/255.0 blue:((float)(kButtonBGColor & 0xFF))/255.0 alpha:1.0];
            self.manageButton.backgroundColor = [UIColor colorWithRed:((float)((kButtonHighliftColor & 0xFF0000) >> 16))/255.0 green:((float)((kButtonHighliftColor & 0xFF00) >> 8))/255.0 blue:((float)(kButtonHighliftColor & 0xFF))/255.0 alpha:1.0];
            
            [self.activityMangeView removeFromSuperview];
            [self.contentView addSubview:self.cardDetailView];
            
            self.isShowActivityManage = NO;
            self.isShowCardDetail = YES;
        } completion:nil];
        
    }
    
    self.isShowDefaultContentView = !self.isShowDefaultContentView;
}

#pragma mark - MLKMenuPopover delegate

-(void)menuPopover:(MLKMenuPopover *)menuPopover didSelectMenuItemAtIndex:(NSInteger)selectedIndex{
    
    if (self.isShowDefaultContentView) {
        //  详情页面状态
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
            
            [self deleteCard];
            
        }else if(selectedIndex == 2){
            //分享名片
            
            CardShareViewController *nextViewController = [[CardShareViewController alloc]initWithNibName:@"CardShareViewController" bundle:nil];
            nextViewController.cardId = self.cardDetail.Id;
            [self.navigationController pushViewController:nextViewController animated:YES];
            
        }else if(selectedIndex == 3){
            //取消分享
            
            CardUnshareViewController *nextViewController = [[CardUnshareViewController alloc]initWithNibName:@"CardUnshareViewController" bundle:nil];
            nextViewController.cardId = self.cardDetail.Id;
            [self.navigationController pushViewController:nextViewController animated:YES];
            
            
            /*ShareHttpRequestService *request = [[ShareHttpRequestService alloc]init];
            //            self.cardDetail.Id
            [request cancelCardShareByCardIds:@[self.cardDetail.Id] success:^(NSString *strToken) {
                NSData *data = [strToken dataUsingEncoding:NSUTF8StringEncoding];
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                
                NSString *info = @"";
                if ([dict.allKeys containsObject:@"Info"]) {
                    info = [dict objectForKey:@"Info"];
                }
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                                message:info
                                                               delegate:nil
                                                      cancelButtonTitle:@"确定"
                                                      otherButtonTitles:nil];
                [alert show];
            } error:^(NSString *strFail) {
                
            }];*/
            
            
        }
        
        
        /////////////////////
    }else{
        //  活动页面状态
        
        CreateActivityViewController *nextViewController = [[CreateActivityViewController alloc]initWithNibName:@"CreateActivityViewController" bundle:nil];
        Contactactivity *newC = [[Contactactivity alloc]init];
        newC.Id = @(0);
        newC.Cardid = self.cardDetail.Id;
        nextViewController.contactactivity = newC;
        [self.navigationController pushViewController:nextViewController animated:YES];
        
    }
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if (self.isShowActivityManage) {
        [self.activityMangeView configSourceDataWithCardId:[NSString stringWithFormat:@"%@",self.cardDetail.Id]];
    }
    
}

#pragma mark -
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == kDeleteCardAlertTag && buttonIndex == 1) {
        
        NSLog(@"删除名片");
        CardHttpRequestService *request = [[CardHttpRequestService alloc]init];
        
        [request deleteCardByID:[NSString stringWithFormat:@"%@",self.cardDetail.Id ] success:^(NSString *strToken) {
            
            NSData *data = [strToken dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            ExceptionInfo *info = [RMMapper objectWithClass:[ExceptionInfo class] fromDictionary:dict];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                            message:[NSString stringWithFormat:@"%@",info.Info]
                                                           delegate:self
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil];
            if ([info.Result intValue] > 0) {
                alert.tag = kDeleteCardAlert_success_tag;
            }
            [alert show];
            
            
        } error:^(NSString *strFail) {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"删除失败"
                                                            message:strFail
                                                           delegate:nil
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil];
            
            [alert show];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"DeleteCard" object:nil userInfo:@{@"Card":self.cardDetail}];
        }];
    }else if (alertView.tag == kDeleteCardAlert_success_tag){
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - 删除名片

-(void)deleteCard{
    //删除名片
    NSString *name = self.cardDetail.Name;
    NSString *messgae = [NSString stringWithFormat:@"您确定要删除%@吗?",name];
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"删除操作"
                                                   message:messgae
                                                  delegate:self
                                         cancelButtonTitle:@"取消"
                                         otherButtonTitles:@"确认", nil];
    alert.tag = kDeleteCardAlertTag;
    [alert show];
}

@end
