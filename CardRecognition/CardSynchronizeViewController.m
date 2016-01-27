//
//  CardSynchronizeViewController.m
//  CardRecognition
//  名片同步视图控制器
//  Created by bournejason on 15/5/5.
//  Copyright (c) 2015年 bournejason. All rights reserved.
//

#import "CardSynchronizeViewController.h"
#import "MFSideMenu.h"
#import "MLKMenuPopover.h"
#import "CardListCell.h"
#import "DBOperation.h"
#import "DBCardListItem.h"
#import "CardModel.h"
#import "JSONKit.h"
#import "CardHttpRequestService.h"
#import "SyncHttpRequestService.h"
#import "ExceptionInfo.h"
#import "RMMapper.h"
#import "CardPackageTableViewCell.h"
#import "PopLoginViewController.h"
#import "Reachability.h"
#import "SVProgressHUD.h"
#define kAlertToLoginViewTag 1000



#define kScreenWidth [[UIScreen mainScreen] bounds].size.width


@interface CardSynchronizeViewController ()
<MLKMenuPopoverDelegate>
{
    bool isPopup;
    NSMutableArray *dataArray;
}
@property(nonatomic,strong) MLKMenuPopover *menuPopover;
@property(nonatomic, strong) NSArray *menuItems;
@property(nonatomic, strong) NSArray *dataArr;
@property(nonatomic, strong) NSMutableDictionary *isSelectedDic;
@property(nonatomic) BOOL isNibRegistered;

@property(nonatomic, strong) NSNumber *userid;
@end

@implementation CardSynchronizeViewController

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        DBOperation *dataBase = [[DBOperation alloc]init];
        self.dataArr = [dataBase getCardListByShard];
        self.isSelectedDic = [NSMutableDictionary dictionary];
        
        for (int i = 0; i< self.dataArr.count; i++) {
            [self.isSelectedDic setObject:@(NO) forKey:@(i)];
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(41, 0, 100, 30)];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setText:@"名片同步"];
    titleLabel.font = [UIFont boldSystemFontOfSize:20];
    self.navigationItem.titleView = titleLabel;
    [self setupMenuBarButtonItems];
}

#pragma pic 
- (BOOL) imageHasAlpha: (UIImage *) image
{
    CGImageAlphaInfo alpha = CGImageGetAlphaInfo(image.CGImage);
    return (alpha == kCGImageAlphaFirst ||
            alpha == kCGImageAlphaLast ||
            alpha == kCGImageAlphaPremultipliedFirst ||
            alpha == kCGImageAlphaPremultipliedLast);
}
- (NSString *) image2DataURL: (UIImage *) image
{
    NSData *imageData = nil;
    NSString *mimeType = nil;
    
    if ([self imageHasAlpha: image]) {
        imageData = UIImagePNGRepresentation(image);
        mimeType = @"image/png";
    } else {
        imageData = UIImageJPEGRepresentation(image, 1.0f);
        mimeType = @"image/jpeg";
    }
    
    return [NSString stringWithFormat:@"data\\:%@;base64,%@", mimeType,
            [imageData base64EncodedStringWithOptions: 0]];
    
}

#pragma mark MLKMenuPopoverDelegate

- (void)menuPopover:(MLKMenuPopover *)menuPopover didSelectMenuItemAtIndex:(NSInteger)selectedIndex
{
    
    [self.menuPopover dismissMenuPopover];
    if (selectedIndex == 0) {
        
        [self.isSelectedDic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [self.isSelectedDic setObject:@(YES) forKey:key];
        }];
        [self.tableView reloadData];
        
    }else if (selectedIndex == 1){
        
        BOOL isUserLogin = [self isUserLogin];
        if (!isUserLogin) {
            return;
        }
        
        //获取用户WIFI环境传输的设置
        NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
        NSString * isWifi = [defaults objectForKey:@"wifi"];
        
        //判断是否关闭在非WIFI环境下传输
        Reachability *r = [Reachability reachabilityWithHostName:@"www.baidu.com"];
        if ([r currentReachabilityStatus]!=ReachableViaWiFi) {
            if ([isWifi isEqualToString:@"1"]) { //打开只在WIFI下同步，当前状态是非WIFI状态
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您设置只在WIFI环境下进行数据同步" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                return;
            }
        }
        
        // 同步
        NSMutableArray *arr = [NSMutableArray array];
        
        [self.isSelectedDic enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, id obj, BOOL *stop) {
            BOOL isSelect = [obj boolValue];
            
            
            
            if (isSelect) {
                DBCardListItem *item = [self.dataArr objectAtIndex:[key integerValue]];
                DBCard *card = [[[DBOperation alloc]init] getCardInfoById:[item.Id integerValue]];
                
                UIImage *img = [[UIImage alloc]initWithContentsOfFile:[NSString stringWithFormat:@"%@/Documents/%@.jpg",NSHomeDirectory(),item.pic_name]];
                
                //NSData *imgData = UIImagePNGRepresentation(img);
                NSData *imgData = UIImageJPEGRepresentation(img, 1.0);
                //NSString *base64ImageString = [imgData base64Encoding];
                NSString *base64ImageString = [imgData base64EncodedStringWithOptions:0];
                
                
                CardModel *tempCard = [[CardModel alloc]init];
                
                
                tempCard.Id = card.Id;
                tempCard.Gourpid = @0;
                tempCard.Telephone = card.job_tel;
                if (card.job_tel == nil) tempCard.Telephone = @"";
                tempCard.Base64Image = base64ImageString;
                tempCard.syncState = @0;
                tempCard.Companyid = @0;
                tempCard.State = @"1";
                tempCard.Areaid = @0;
                tempCard.Maintenanceuser = [NSString stringWithFormat:@"%@",self.userid]; //本地登录用户id
                tempCard.Mobilphone = card.mobile;
                
                tempCard.GroupName = [[[DBOperation alloc]init] QueryGroupById:card.gid.description];
                
                if (tempCard.GroupName == nil) {
                    tempCard.GroupName = @"未分组";
                }
                
                //tempCard.GroupName = @"";
                tempCard.Createuser = [NSString stringWithFormat:@"%@",self.userid];  //本地的用户id
                tempCard.Industryid = @0;
                tempCard.Fax = card.fax;
                if (card.fax == nil) tempCard.Fax = @"";
                tempCard.CompanyName = card.company;
                tempCard.Name = card.name;
                tempCard.Email = card.mail;
                if (card.mail == nil) tempCard.Email = @"";
                tempCard.Address = card.address;
                tempCard.Position = @"";
                tempCard.Remark = card.note;
                tempCard.Position = card.title;
                
                [arr addObject:tempCard];
            }
            
        }];
        
        
        NSString *json = [arr JSONString];
        SyncHttpRequestService *request = [[SyncHttpRequestService alloc]init];
        [SVProgressHUD show];
        [request sysnCardInfo:arr success:^(NSString *strToken) {
            NSLog(@"%@",strToken);
            [SVProgressHUD dismiss];
            NSData *data = [strToken dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            ExceptionInfo *info = [RMMapper objectWithClass:[ExceptionInfo class] fromDictionary:dict];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                            message:[NSString stringWithFormat:@"%@",info.Info]
                                                           delegate:self
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil];
            
            if ([info.Result intValue] > 0) {
                alert.tag = 22;
                NSMutableArray *array = [[NSMutableArray alloc]init];
                // 成功
                [self.isSelectedDic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                    int i = [key intValue];
                    if ([obj boolValue]) {
                        DBCardListItem *item = [self.dataArr objectAtIndex:i];
                        [array addObject:item.Id];
                    }
                    
                }];
                /*for (DBCardListItem *item in self.dataArr) {
                    //DBCard *card = [[[DBOperation alloc]init] getCardInfoById:[item.Id integerValue]];
                    [array addObject:item.Id];
                }*/
                [[[DBOperation alloc]init] UpdateCardShard:array];

            }
            [alert show];
        } failBlock:^(NSString *strFail) {
            [SVProgressHUD dismiss];
        }];
        
    }
    
}

#pragma mark - 右菜单创建函数
- (UIBarButtonItem *)rightMenuBarButtonItem {
    
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0,0,35,30)];
    [button setImage:[UIImage imageNamed:@"icon_sort"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(rightSideMenuButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithCustomView:button];
    
    return item;
}
#pragma mark - 菜单创建函数
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

#pragma mark - 左菜单处理函数
- (void)leftSideMenuButtonPressed:(id)sender {
    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{
        [self setupMenuBarButtonItems];
    }];
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
#pragma mark - 右菜单处理函数
- (void)rightSideMenuButtonPressed:(id)sender {
    
    if (isPopup) {
        [self.menuPopover dismissMenuPopover];
        isPopup = NO;
    }else{
        
        NSArray *menuItems = @[@"全选",@"同步"];
        NSArray *imageNames = @[@"select_all",@"sync_menu"];
        
        self.menuPopover = [[MLKMenuPopover alloc] initWithFrame:CGRectMake(kScreenWidth-140-60, 50, 120+60, 44*2) menuItems:menuItems andImages:imageNames];
        
        self.menuPopover.menuPopoverDelegate = self;
        [self.menuPopover showInView:self.view];
        isPopup = YES;
    }
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

#pragma mark - UITableView delegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    //    NSString *cellIdentifier = @"Cell";
    
    /*static NSString *CardListCellIdentifier = @"CardListCellIdentifier";
    if (!self.isNibRegistered) {
        UINib *nib = [UINib nibWithNibName:@"CardListCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:CardListCellIdentifier];
        self.isNibRegistered = YES;
    }
    
    CardListCell *cardListCell = [tableView dequeueReusableCellWithIdentifier:CardListCellIdentifier];*/
    
    DBCardListItem *items = self.dataArr[indexPath.row];
    
    
    
    
    /*if (!cardListCell) {
        cardListCell = [[CardListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CardListCellIdentifier];
        cardListCell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }
    UIImage* image = [[UIImage alloc]initWithContentsOfFile:[NSString stringWithFormat:@"%@/Documents/%@.jpg",NSHomeDirectory(),items.pic_name]];
    //    CardModel *card = [dataArray objectAtIndex:indexPath.row];
    //
    cardListCell.cardImage.image = image;
    cardListCell.nameLabel.text = items.name;
    cardListCell.companyLabel.text = items.company;
    cardListCell.createTimeLabel.text = items.create_time;
    
    BOOL isSelected = [[self.isSelectedDic objectForKey:@(indexPath.row)] boolValue];
    if (isSelected) {
        cardListCell.accessoryType = UITableViewCellAccessoryCheckmark;
    }else{
        cardListCell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    
    return cardListCell;*/
    
    NSString *cellIdentifier = @"Cell";
    
    CardPackageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(cell == nil) {
        cell = [[CardPackageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    
    
    UIImage* image = [[UIImage alloc]initWithContentsOfFile:[NSString stringWithFormat:@"%@/Documents/%@.jpg",NSHomeDirectory(),items.pic_name]];
    cell.cardImageView.image = image;
    cell.nameLabel.text = items.name;
    cell.titleLabel.text = items.title;
    cell.companyLabel.text = items.company;
    
    BOOL isSelected = [[self.isSelectedDic objectForKey:@(indexPath.row)] boolValue];
    if (isSelected) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    BOOL isSelected = [[self.isSelectedDic objectForKey:@(indexPath.row)] boolValue];
    BOOL newS = !isSelected;
    //    [self.isSelectedDic setObject:@(newS) forKey:@(indexPath.row)];
    self.isSelectedDic[@(indexPath.row)] = @(newS);
    
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
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
            
            [viewController dismissViewControllerAnimated:YES completion:nil];
        }];
        [self presentViewController:viewController animated:YES completion:^{
            
        }];
    }else if(alertView.tag == 22){
        DBOperation *dataBase = [[DBOperation alloc]init];
        self.dataArr = [dataBase getCardListByShard];
        if(self.isSelectedDic==nil)
            self.isSelectedDic = [NSMutableDictionary dictionary];
        else{
            [self.isSelectedDic removeAllObjects];
        }
        
        for (int i = 0; i< self.dataArr.count; i++) {
            [self.isSelectedDic setObject:@(NO) forKey:@(i)];
        }
        
        [self.tableView reloadData];
        
    }
}
@end
