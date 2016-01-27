//
//  CardUnshareViewController.m
//  CardRecognition
//
//  Created by bournejason on 15/11/2.
//  Copyright © 2015年 bournejason. All rights reserved.
//

#import "CardUnshareViewController.h"
#import "MLKMenuPopover.h"
#import "CardShareListCell.h"
#import "ShareHttpRequestService.h"
#import "SharedCard.h"
#import "RMMapper.h"
#import "NSArray+ParseArray.h"

#define kScreenWidth [[UIScreen mainScreen] bounds].size.width


@interface CardUnshareViewController ()<MLKMenuPopoverDelegate>
{
    bool isPopup;
    bool isAllSelect;
}

@property(nonatomic,strong) MLKMenuPopover *menuPopover;
@property(nonatomic) BOOL isNibRegistered;
@property(nonatomic, strong) NSArray *cellInfoArr;
@property(nonatomic, strong) NSMutableDictionary *selectedCell;



@end

@implementation CardUnshareViewController

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    isAllSelect = NO;
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(41, 0, 100, 30)];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setText:@"已分享名片"];
    titleLabel.font = [UIFont boldSystemFontOfSize:20];
    self.navigationItem.titleView = titleLabel;
    [self setupMenuBarButtonItems];
    
    ShareHttpRequestService *request = [[ShareHttpRequestService alloc]init];
    
    [request getSharedUserByCardId:self.cardId.description username:@"" success:^(NSString *strToken) {
        NSLog(@"%@",strToken);
        
        NSData *data = [strToken dataUsingEncoding:NSUTF8StringEncoding];
        
        id responseJSON = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        
        
        
        NSMutableArray* rooms = [RMMapper mutableArrayOfClass:[SharedCard class]
                                        fromArrayOfDictionary:responseJSON];
        
        self.selectedCell = [NSMutableDictionary dictionary];
        for (int i = 0; i < rooms.count; i++) {
            [self.selectedCell setObject:[NSNumber numberWithBool:NO] forKey:@(i)];
            //                [self.selectedCell setValue:@NO forKey:@(i)];
        }
        
        self.cellInfoArr = rooms;
        [self.tableView reloadData];
        
    } error:^(NSString *strFail) {
        
    }];
    
    self.searchBar.delegate = self;
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
    NSArray *menuItems;
    
    if (isAllSelect) {
        menuItems = @[@"取消全选",@"取消选中分享"];
        imageNames = @[@"manage_menu",@"manage_menu"];
    }else{
        menuItems = @[@"全选",@"取消选中分享"];
        imageNames = @[@"manage_menu",@"manage_menu"];
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

#pragma mark - MLK delegate
-(void)menuPopover:(MLKMenuPopover *)menuPopover didSelectMenuItemAtIndex:(NSInteger)selectedIndex{
    if (selectedIndex==0){
        if (isAllSelect) {
            isAllSelect = NO;
            for (int i = 0; i < self.selectedCell.count; i++) {
                [self.selectedCell setObject:[NSNumber numberWithBool:NO] forKey:@(i)];
            }
            
        }else{
            isAllSelect = YES;
            for (int i = 0; i < self.selectedCell.count; i++) {
                [self.selectedCell setObject:[NSNumber numberWithBool:YES] forKey:@(i)];
            }
        }
        [self.tableView reloadData];
        
    }
    if (selectedIndex == 1) {
        
        if (self.cellInfoArr.count == 0||[self selectCellCount]==0) {
            // 没有数据
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                            message:@"没有可以分享的对象"
                                                           delegate:nil
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil];
            [alert show];
            return;
        }
        
        if (self.cardId == nil) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                            message:@"分享名片卡号ID异常"
                                                           delegate:nil
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil];
            [alert show];
            return;
        }
        
        
        
        NSMutableArray *IdsNeedShared = [NSMutableArray array];
        for (int i = 0; i< self.cellInfoArr.count; i++) {
            SharedCard *card = [self.cellInfoArr objectAtIndex:i];
            NSNumber  *Id = card.Id;
            BOOL isSelected = [[self.selectedCell objectForKey:@(i)] boolValue];
            
            if (isSelected) {
                [IdsNeedShared addObject:Id];
            }
        }
        
        
        
        ShareHttpRequestService *request = [[ShareHttpRequestService alloc]init];
        [request deleteSharedUserByCardId:IdsNeedShared success:^(NSString *strToken) {
            
            
            [request getSharedUserByCardId:self.cardId.description username:@"" success:^(NSString *strToken) {
                NSLog(@"%@",strToken);
                
                NSData *data = [strToken dataUsingEncoding:NSUTF8StringEncoding];
                
                id responseJSON = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                
                self.selectedCell = [NSMutableDictionary dictionary];
                
                NSMutableArray* rooms = [RMMapper mutableArrayOfClass:[SharedCard class]
                                                fromArrayOfDictionary:responseJSON];
                
                self.cellInfoArr = rooms;
                [self.tableView reloadData];
                
            } error:^(NSString *strFail) {
                
            }];

            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                            message:@"取消成功"
                                                           delegate:nil
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil];
            [alert show];
        } error:^(NSString *strFail) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"分享失败"
                                                            message:@"请稍后重新进行分享"
                                                           delegate:nil
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil];
            [alert show];
        }];
        
    }
}

#pragma mark -

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView Delegate

//-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//    return 0;
//}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.cellInfoArr.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *CardShareListCellIdentifier = @"CardShareListCellIdentifier";
    if (!self.isNibRegistered) {
        UINib *nib = [UINib nibWithNibName:@"CardShareListCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:CardShareListCellIdentifier];
        self.isNibRegistered = YES;
    }
    
    CardShareListCell *cardListCell = [tableView dequeueReusableCellWithIdentifier:CardShareListCellIdentifier];
    
    if (indexPath.row == 0) {
        
    }
    
    
    BOOL isSelected = [[self.selectedCell objectForKey:@(indexPath.row)] boolValue];
    if (isSelected) {
        cardListCell.accessoryType = UITableViewCellAccessoryCheckmark;
    }else{
        cardListCell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    
    if (!cardListCell) {
        cardListCell = [[CardShareListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CardShareListCellIdentifier];
    }
    
    SharedCard *card = [self.cellInfoArr objectAtIndex:indexPath.row];
    cardListCell.nameLabel.text = card.ShareUsername;

    
    return cardListCell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    BOOL isSelected = [[self.selectedCell objectForKey:@(indexPath.row)] boolValue];
    [self.selectedCell setObject:@(!isSelected) forKey:@(indexPath.row)];
    
    [tableView reloadData];
}

#pragma mark UISearchBarDelegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    if (searchText.length==0) {
        return;
    }
    
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    
    
    ShareHttpRequestService *request = [[ShareHttpRequestService alloc]init];
    
    [request getSharedUserByCardId:self.cardId.description username:searchBar.text success:^(NSString *strToken) {
        NSLog(@"%@",strToken);
        
        NSData *data = [strToken dataUsingEncoding:NSUTF8StringEncoding];
        
        id responseJSON = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        
        self.selectedCell = [NSMutableDictionary dictionary];
        
        NSMutableArray* rooms = [RMMapper mutableArrayOfClass:[SharedCard class]
                                        fromArrayOfDictionary:responseJSON];
        
        self.cellInfoArr = rooms;
        
        self.selectedCell = [NSMutableDictionary dictionary];
        
        for (int i = 0; i < rooms.count; i++) {
            [self.selectedCell setObject:[NSNumber numberWithBool:NO] forKey:@(i)];
            //                [self.selectedCell setValue:@NO forKey:@(i)];
        }
        [self.tableView reloadData];
        
    } error:^(NSString *strFail) {
        
    }];
    
    
}
-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
}
-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
}
-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    [searchBar setShowsCancelButton:NO animated:YES];
}
-(int)selectCellCount{
    
    int sCount = 0;
    
    for (int i = 0; i < self.selectedCell.count; i++) {
        BOOL isSelected = [[self.selectedCell objectForKey:@(i)] boolValue];
        if (isSelected) {
            sCount++;
        }
    }
    
    return sCount;
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
