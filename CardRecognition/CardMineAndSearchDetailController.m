//
//  CardMineAndSearchDetailController.m
//  CardRecognition
//
//  Created by bournejason on 15/6/7.
//  Copyright (c) 2015年 bournejason. All rights reserved.
//

#import "CardMineAndSearchDetailController.h"
#import "CardMineAndSearchDetailView.h"
@interface CardMineAndSearchDetailController ()
{
    bool isPopup;
}
@property (nonatomic, strong) CardModel *cardDetail;
@property (nonatomic, strong) UIView *contentView;  // 主内容页面


@property (nonatomic, strong) CardMineAndSearchDetailView *cardDetailView;

@property(nonatomic) BOOL isEdittingCard;
@end

@implementation CardMineAndSearchDetailController{
    
}
-(UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc]initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height-64)];
        _contentView.backgroundColor = [UIColor lightGrayColor];
        [self.view addSubview:_contentView];
    }
    return _contentView;
}

-(CardMineAndSearchDetailView *)cardDetailView{
    if (!_cardDetailView) {
        //        _cardDetailView = [[CardDetailView alloc]initWithFrame:self.contentView.bounds];
        _cardDetailView = [[CardMineAndSearchDetailView alloc]initWithFrame:self.contentView.bounds andCardModel:self.cardDetail];
        _cardDetailView.backgroundColor = [UIColor whiteColor];
        _cardDetailView.parentViewController = self;
        [self.contentView addSubview:_cardDetailView];
    }
    return _cardDetailView;
}

#pragma mark -
-(id)initWithFrame:(CGRect)frame andCardModel:(CardModel *)cardModel{
    self = [super init];
    if (self) {
        self.view.frame = frame;
        self.cardDetail = cardModel;
        
        [self setupNavigationView];
        
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



- (void)setupMenuBarButtonItems {
    UIBarButtonItem *negativeLeftSpacer = [[UIBarButtonItem alloc]
                                           initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                           target:nil action:nil];
    negativeLeftSpacer.width = -15;
    self.navigationItem.leftBarButtonItems = @[negativeLeftSpacer, [self leftMenuBarButtonItem]];
    //self.navigationItem.leftBarButtonItem = [self leftMenuBarButtonItem];
        //self.navigationItem.rightBarButtonItem = [self rightMenuBarButtonItem];
}

- (void)leftSideMenuButtonPressed:(id)sender {
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

@end
