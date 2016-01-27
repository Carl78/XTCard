//
//  CardPackageViewController.m
//  CardRecognition
//  名片夹视图控制器
//  Created by bournejason on 15/5/4.
//  Copyright (c) 2015年 bournejason. All rights reserved.
//
//

#import "CardPackageViewController.h"
#import "MFSideMenu.h"
#import "MLKMenuPopover.h"
#import "DBOperation.h"
#import "DBGroup.h"
//#import "MBProgressHUD.h"
#import "RecognizeResultViewController.h"
#import <recognizeAPI/Recognize4IOS.h>
#import "pinyin.h"
#import "DBCardListItem.h"
#import "CardPackageTableViewCell.h"
#import "CardDetailViewController.h"
#import "OtherHttpRequestService.h"
#import "GDataXMLNode/GDataXMLNode.h"
#import "AppConfig.h"
#import "AddressBookHelper.h"
#import <AddressBook/AddressBook.h>

#define kScreenWidth [[UIScreen mainScreen] bounds].size.width
#define kScreenHeight [[UIScreen mainScreen] bounds].size.height
#define kMenuCellBGColor 0x403f3f //右菜单单元背景颜色
#define kRightMenuWidth 60 //右菜单宽度
#define kRightButtonWidth 40 //右菜单中按钮的宽度
#define kRightButtonHeight 40 //右菜单按钮的高度
#define kRightItemHeight 50 //右菜单按钮加上下边距的高度
#define kRightPhotoViewBKHeight 60 //拍照按钮的背景的高度
#define kRightPhoneButtonHeight 40 //拍照按钮的高度
#define kRightHeaderHeight 80 //右菜单头部的高度
#define kMainHeaderHeight 80
#define kRightButtonMarginLeft 10 //右菜单的左边距值
#define kSearchBarHeight 45 //搜索栏的高度

#define kSortTypeIndex 0   //按姓名拼音首字母排序
#define kSortTypeTime 1    //按时间排序




@interface CardPackageViewController ()<MLKMenuPopoverDelegate>{
    bool isPopup;
    
    //固定右菜单数组
    NSMutableArray *rightButtons;
    //总右菜单数组
    NSMutableArray *groupArray;
    
    //数据库操作类
    DBOperation *db;
    
    UIScrollView *scrollView;
    UITableView *tableView;
    UISearchBar *bar;
    
    
    NSMutableArray *cardList;
    NSMutableDictionary *cardListShow;
    NSMutableDictionary *cardListSave;
    NSMutableDictionary *cardListByCharactor;
    NSMutableDictionary *cardListByTime;
    NSArray *sortedKeys;
    
    int sortType;
    int firstAppear;
    
    ABRecordID findRecordId;
    int currentVersion;
    int newVersion;
    //DBCardListItem *selectItem;
}

@property(nonatomic,strong) MLKMenuPopover *menuPopover;
@property(nonatomic,strong) NSArray *menuItems;
@property (assign,nonatomic) ABAddressBookRef addressBook;//通讯录
@property (nonatomic, strong) DBCard *cardRecord;

@end

@implementation CardPackageViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //检查更新
    [self checkNewVersion];
    
    //初始化主View
    UIView *mainView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    mainView.backgroundColor = [UIColor blackColor];
    self.view = mainView;
    
    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
    self.navigationController.navigationBar.translucent = YES;
    
    //设置视图标题view
    //self.title = @"名片夹";
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(41, 0, 100, 30)];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setText:@"本机名片"];
    titleLabel.font = [UIFont boldSystemFontOfSize:20];
    
    self.navigationItem.titleView = titleLabel;
    
    
    //创建左右导航按钮
    [self setupMenuBarButtonItems];
    
    //建立右排序列表内容
    self.menuItems = [NSArray arrayWithObjects:@"按姓名排序", @"按时间排序", nil];
    
    //搜索条
    bar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 64, kScreenWidth-kRightMenuWidth, kSearchBarHeight)];
    bar.delegate = self;
    
    [bar setPlaceholder:@"请输入姓名或公司名称"];
    /*for(UIView *view in  [[[bar subviews] objectAtIndex:0] subviews]) {
        
        if([view isKindOfClass:[NSClassFromString(@"UINavigationButton") class]]) {
            UIButton * cancel =(UIButton *)view;
            [cancel setTitle:@"取消" forState:UIControlStateNormal];
            [cancel  setTintColor:[UIColor blackColor]];
            [cancel.titleLabel setTextColor:[UIColor blackColor]];
        }
    }*/
    
    [self.view addSubview:bar];
    
    //创建table view
    CGRect frame = CGRectMake(0, kSearchBarHeight+64, kScreenWidth-kRightMenuWidth, kScreenHeight-kSearchBarHeight-64);
    tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.bounces = NO;

    // fyl 添加长按手势响应
    UILongPressGestureRecognizer * longPressGr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressTableCell:)];
    longPressGr.minimumPressDuration = 1.0;
    [tableView addGestureRecognizer:longPressGr];
    //[longPressGr release];
    
    [self.view addSubview:tableView];
    
    //创建scroll view
    
    //全部分组按钮
    DBGroup *bGroupAll = [[DBGroup alloc]init];
    bGroupAll.Id = [NSNumber numberWithInt:-2];
    bGroupAll.name = @"全部";
    
    //未分组按钮
    DBGroup *bGroupNo = [[DBGroup alloc]init];
    bGroupNo.Id = [NSNumber numberWithInt:-1];
    bGroupNo.name = @"未分组";
    
    //新建按钮
    DBGroup *bGroupNew = [[DBGroup alloc]init];
    bGroupNew.Id = [NSNumber numberWithInt:0];
    bGroupNew.name = @"新建\n分组";
    
    rightButtons = [NSMutableArray arrayWithObjects:bGroupAll,bGroupNo,bGroupNew,nil];
    scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(kScreenWidth-kRightMenuWidth, 0, kRightMenuWidth, kScreenHeight-kRightPhotoViewBKHeight)];
    scrollView.backgroundColor = [UIColor colorWithRed:((float)((kMenuCellBGColor & 0xFF0000) >> 16))/255.0 green:((float)((kMenuCellBGColor & 0xFF00) >> 8))/255.0 blue:((float)(kMenuCellBGColor & 0xFF))/255.0 alpha:1.0];
    scrollView.scrollEnabled = YES;
    
    //从数据库获取分组信息
    db = [[DBOperation alloc]init];
    cardList = [db getCardList];
    
    
    //排序
    sortType = 1;
    [self sortCardListByTime];
    
    groupArray = [db QueryGroup];
    //将固定分组的信息放入到groupArray中
    [groupArray insertObject:rightButtons[0] atIndex:0];
    [groupArray insertObject:rightButtons[1] atIndex:1];
    [groupArray insertObject:rightButtons[2] atIndex:groupArray.count];
    
    scrollView.contentSize = CGSizeMake(kRightMenuWidth, kRightHeaderHeight+kRightItemHeight*groupArray.count);
    //创建scroll view中的分组的button
    [self createRightScrollView];
    
    [self.view addSubview:scrollView];
    
    //创建拍照按钮
    UIView *photoView = [[UIView alloc]initWithFrame:CGRectMake(kScreenWidth-kRightMenuWidth, kScreenHeight-kRightPhotoViewBKHeight, kRightMenuWidth, kRightPhotoViewBKHeight)];
    photoView.backgroundColor = [UIColor colorWithRed:((float)((kMenuCellBGColor & 0xFF0000) >> 16))/255.0 green:((float)((kMenuCellBGColor & 0xFF00) >> 8))/255.0 blue:((float)(kMenuCellBGColor & 0xFF))/255.0 alpha:1.0];
    UIButton *photoButton = [[UIButton alloc]initWithFrame:CGRectMake(kRightButtonMarginLeft, 15, 40, 35)];
    [photoButton setBackgroundImage:[UIImage imageNamed:@"photo.png"] forState:UIControlStateNormal];
    
    [photoButton addTarget:self action:@selector(takePhoto:) forControlEvents:UIControlEventTouchUpInside];
    [photoView addSubview:photoButton];
    [self.view addSubview:photoView];
    
    firstAppear = 0;
    
    // 检查通讯录访问权限
    [AddressBookHelper CheckAddressBookAuthorization:^(bool isAuthorized)
    {
        if(isAuthorized)
        {
            //创建通讯录对象
            self.addressBook=ABAddressBookCreateWithOptions(NULL, NULL);
        }
    }];
    
}

-(void) checkNewVersion
{
    OtherHttpRequestService *otherHttp = [[OtherHttpRequestService alloc]init];
    [otherHttp getPlistVersion:^(NSString *strToken) {
        
        NSString *curVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        int curVersionValue = 0;
        NSArray *curV_str = [curVersion componentsSeparatedByString:@"."];
        for (NSString *str in curV_str) {
            curVersionValue *= 100;
            curVersionValue += [str intValue];
        }
        currentVersion = curVersionValue;

        
        NSString *str = [strToken substringToIndex:1];
        if ([str isEqualToString:@"<"]) {
            
        }else{
            NSRange range = [strToken rangeOfString:@"<"];
            int loaction = range.location;
            strToken = [strToken substringFromIndex:loaction];
        }
        
        
        GDataXMLDocument *xmlDoc = [[GDataXMLDocument alloc] initWithXMLString:strToken options:0 error:nil];
        GDataXMLElement *xmlEle = [xmlDoc rootElement];
        NSArray *array = [xmlEle children];//plist
        //NSLog(@"count : %d", [array count]);
        
        for (int i = 0; i < [array count]; i++) {
            
            GDataXMLElement *edict = [array objectAtIndex:0]; //dict根
            NSLog(@"%@",[edict name]);
            
            NSArray *aArray = [edict children];
            if ([aArray count]<2) {
                NSLog(@"xml string format error");
                break;
            }
            GDataXMLElement *eArray = [aArray objectAtIndex:1];// dict->array
            //NSLog(@"%@",[e1 name]);
            
            NSArray *a2 = [eArray children];
            if ([a2 count]<1) {
                NSLog(@"xml string format error");
                break;
            }
            GDataXMLElement *e2 = [a2 objectAtIndex:0];// dict->array->dict
            NSLog(@"%@",[e2 name]);
            
            NSArray *a3 = [e2 children];
            if ([a3 count]<4) {
                NSLog(@"xml string format error");
                continue;
            }
            GDataXMLElement *e3 = [a3 objectAtIndex:3];// dict->array->dict->dict
            //NSLog(@"%@",[e3 name]);
            
            NSArray *a4 = [e3 children];
            if ([a4 count]<4) {
                NSLog(@"xml string format error");
                break;
            }
            GDataXMLElement *e4 = [a4 objectAtIndex:3];// dict->array->dict->dict->bundle-version 的 string
            //NSLog(@"%@",[e4 name]);
            
            NSString *versionString = [e4 stringValue];

            //判断版本号的正确性
            NSString *regex = @"\\d{1,100}.\\d{0,100}.\\d{0,100}";
            // 创建谓词对象并设定条件的表达式
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
            // 对字符串进行判断
            if ([predicate evaluateWithObject:versionString]) {
                int newVersionValue = 0;
                NSArray *newV_str = [versionString componentsSeparatedByString:@"."];
                for (NSString *str in newV_str) {
                    newVersionValue *= 100;
                    newVersionValue += [str intValue];
                }
                newVersion = newVersionValue;

                if (currentVersion < newVersion) {
                    NSString *str = [NSString stringWithFormat:@"有%@新版本了，是否更新旧版本%@？",versionString,curVersion];
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"苏信名片通"
                                                                   message:str
                                                                  delegate:self
                                                         cancelButtonTitle:@"取消"
                                                         otherButtonTitles:@"更新",nil];
                    
                    alert.tag = -100;
                    [alert show];
                }
            }
            else {
                break;
            }
            
            // 根据标签名判断
            /*if ([[ele name] isEqualToString:@"name"]) {
             // 读标签里面的属性
             NSLog(@"name --> %@", [[ele attributeForName:@"value"] stringValue]);
             } else {
             // 直接读标签间的String
             NSLog(@"age --> %@", [ele stringValue]);
             }*/
            
        }
        
    } error:^(NSString *strFail) {
        
        
    }];
}

-(void) updateDBWithNewVersion:(int)newV andCurrentVersion:(int)curV
{
    // 1.0.4版更新
    if (curV < 10004 && newV >= 10004)
    {
        [db UpdateDB104];
    }
    
//    int newVersionValue = 0;
//    int curVersionValue = 0;
//    NSArray *newV_str = [newV componentsSeparatedByString:@"."];
//    for (NSString *str in newV_str) {
//        newVersionValue *= 100;
//        newVersionValue += [str intValue];
//    }
//    NSArray *curV_str = [curV componentsSeparatedByString:@"."];
//    for (NSString *str in curV_str) {
//        curVersionValue *= 100;
//        curVersionValue += [str intValue];
//    }

}

- (void)viewWillAppear:(BOOL)animated{
    if (firstAppear>0) {
        [self refreshTableData];
//        cardList = [db getCardList];
//        if(sortType == kSortTypeIndex)
//           [self sortCardListByIndex];
//        else
//            [self sortCardListByTime];
//        [tableView reloadData];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//由于在整个视图控制器周期内addressBook都驻留在内存中，所有当控制器视图销毁时销毁该对象
-(void)dealloc{
    if (self.addressBook!=NULL) {
        CFRelease(self.addressBook);
    }
}

#pragma mark - 私有方法

- (void)refreshTableData{
    cardList = [db getCardList];
    if(sortType == kSortTypeIndex)
        [self sortCardListByIndex];
    else
        [self sortCardListByTime];
    [tableView reloadData];
}

-(BOOL)isNewRecordwithName:(NSString *)name andMobile:(NSString *)mobile{
//    if(self.addressBook == nil)
//    {
//        //创建通讯录对象
//        self.addressBook=ABAddressBookCreateWithOptions(NULL, NULL);
//    }
    // 获取通讯录中所有的联系人
    NSArray *array = (__bridge NSArray*)ABAddressBookCopyArrayOfAllPeople(self.addressBook);
    
    int d;
    NSString *firstNameValue = @"";
    NSString *lastNameValue = @"";
    NSString *mobilValue = @"";

    for (id obj in array) {
        ABRecordRef people = (__bridge ABRecordRef)obj;
        
        firstNameValue = (__bridge NSString*)ABRecordCopyValue(people, kABPersonFirstNameProperty);
        lastNameValue = (__bridge NSString*)ABRecordCopyValue(people, kABPersonLastNameProperty);
        if(firstNameValue == nil)
            firstNameValue = @"";
        if(lastNameValue == nil)
            lastNameValue = @"";
        mobilValue = @"";
        
        ABMultiValueRef phoneMulti = ABRecordCopyValue(people, kABPersonPhoneProperty);
        for (int i=0; i<ABMultiValueGetCount(phoneMulti); i++) {
            CFStringRef currentPhoneLabel = ABMultiValueCopyLabelAtIndex(phoneMulti, i);
            CFStringRef currentPhoneValue = ABMultiValueCopyValueAtIndex(phoneMulti, i);
            
            if (CFStringCompare(currentPhoneLabel, kABPersonPhoneMobileLabel, 0) == kCFCompareEqualTo) {
                mobilValue = (__bridge NSString*)currentPhoneValue;
            }
            
            CFRelease(currentPhoneLabel);
            CFRelease(currentPhoneValue);
        }
        CFRelease(phoneMulti);
        
        mobilValue = [mobilValue stringByReplacingOccurrencesOfString:@"-" withString:@""];
        NSString *fullName = [lastNameValue stringByAppendingString:firstNameValue];
        
        // 如果姓名和手机号相同则认为是相同
        if(([lastNameValue isEqualToString:name] || [fullName isEqualToString:name]) && [mobilValue isEqualToString:mobile])
        {
            findRecordId = ABRecordGetRecordID(people);
            return false;
        }
    }
    
    return true;
}

- (void) addRecordToAddressBook:(DBCard *) item
{
    ABRecordRef recordRef= ABPersonCreate();
    //ABRecordSetValue(recordRef, kABPersonFirstNameProperty, (__bridge CFTypeRef)(item.sur_name), NULL);//添加名
    ABRecordSetValue(recordRef, kABPersonLastNameProperty, (__bridge CFTypeRef)(item.name), NULL);//添加姓
    ABRecordSetValue(recordRef, kABPersonOrganizationProperty, (__bridge CFTypeRef)(item.company), NULL);//添加单位
    ABRecordSetValue(recordRef, kABPersonDepartmentProperty, (__bridge CFTypeRef)(item.department), NULL);//添加部门
    ABRecordSetValue(recordRef, kABPersonJobTitleProperty, (__bridge CFTypeRef)(item.title), NULL);//添加职位
    ABRecordSetValue(recordRef, kABPersonNoteProperty, (__bridge CFTypeRef)(item.note), NULL);//添加备注
    //ABRecordSetValue(recordRef, kABPersonCreationDateProperty, (__bridge CFDateRef)(item.create_time), NULL);//添加录入时间
    
    // 电话信息
    ABMutableMultiValueRef multiValueRef =ABMultiValueCreateMutable(kABStringPropertyType);//添加设置多值属性
    NSArray *sep_str = [item.job_tel componentsSeparatedByString:kSeparateChar];
    for (NSString *str in sep_str) {
        ABMultiValueAddValueAndLabel(multiValueRef, (__bridge CFStringRef)(str), kABWorkLabel, NULL);//添加工作电话
    }
    ABMultiValueAddValueAndLabel(multiValueRef, (__bridge CFStringRef)(item.home_tel), kABHomeLabel, NULL);//添加家庭电话
    ABMultiValueAddValueAndLabel(multiValueRef, (__bridge CFStringRef)(item.mobile), kABPersonPhoneMobileLabel, NULL);//添加手机
    ABMultiValueAddValueAndLabel(multiValueRef, (__bridge CFStringRef)(item.fax), kABPersonPhoneWorkFAXLabel, NULL);//添加传真
    ABRecordSetValue(recordRef, kABPersonPhoneProperty, multiValueRef, NULL);
    
    // 邮箱信息
    multiValueRef =ABMultiValueCreateMutable(kABStringPropertyType);//添加设置多值属性
    sep_str = [item.mail componentsSeparatedByString:kSeparateChar];
    for (NSString *str in sep_str) {
        ABMultiValueAddValueAndLabel(multiValueRef, (__bridge CFStringRef)(str), kABWorkLabel, NULL);//添加工作邮箱
    }
    ABRecordSetValue(recordRef, kABPersonEmailProperty, multiValueRef, NULL);
    
    // 单位地址信息
    multiValueRef =ABMultiValueCreateMutable(kABDictionaryPropertyType);//添加设置多值属性
    CFStringRef keys[2];
    CFStringRef values[2];
    keys[0] = kABPersonAddressStreetKey;
    keys[1] = kABPersonAddressZIPKey;
    values[0] = (__bridge CFStringRef)(item.address);
    values[1] = (__bridge CFStringRef)(item.post_code);
    CFDictionaryRef aDict = CFDictionaryCreate(
                                               kCFAllocatorDefault,
                                               (void *)keys,
                                               (void *)values,
                                               2,
                                               NULL,
                                               NULL
                                               );
    ABMultiValueAddValueAndLabel(multiValueRef, aDict, kABWorkLabel, NULL);
    ABRecordSetValue(recordRef, kABPersonAddressProperty, multiValueRef, NULL);
    
    //添加记录
    ABAddressBookAddRecord(self.addressBook, recordRef, NULL);
    
    //保存通讯录，提交更改
    ABAddressBookSave(self.addressBook, NULL);
    //释放资源
    CFRelease(recordRef);
    CFRelease(multiValueRef);
    
    // 更新名片纪录保存状态
    [[[DBOperation alloc]init] UpdateCardSaveState:item.Id];
}

- (void) updateAddressBookRecord:(DBCard *) item withId:(ABRecordID) recordId{
    ABRecordRef recordRef = ABAddressBookGetPersonWithRecordID(self.addressBook, recordId);
    if (recordRef) {
        ABRecordSetValue(recordRef, kABPersonOrganizationProperty, (__bridge CFTypeRef)(item.company), NULL);//添加单位
        ABRecordSetValue(recordRef, kABPersonDepartmentProperty, (__bridge CFTypeRef)(item.department), NULL);//添加部门
        ABRecordSetValue(recordRef, kABPersonJobTitleProperty, (__bridge CFTypeRef)(item.title), NULL);//添加职位
        ABRecordSetValue(recordRef, kABPersonNoteProperty, (__bridge CFTypeRef)(item.note), NULL);//添加备注
        
        // 电话信息
        ABMutableMultiValueRef multiValueRef =ABMultiValueCreateMutable(kABStringPropertyType);//添加设置多值属性
        NSArray *sep_str = [item.job_tel componentsSeparatedByString:kSeparateChar];
        for (NSString *str in sep_str) {
            ABMultiValueAddValueAndLabel(multiValueRef, (__bridge CFStringRef)(str), kABWorkLabel, NULL);//添加工作电话
        }
        ABMultiValueAddValueAndLabel(multiValueRef, (__bridge CFStringRef)(item.home_tel), kABHomeLabel, NULL);//添加家庭电话
        ABMultiValueAddValueAndLabel(multiValueRef, (__bridge CFStringRef)(item.mobile), kABPersonPhoneMobileLabel, NULL);//添加手机
        ABMultiValueAddValueAndLabel(multiValueRef, (__bridge CFStringRef)(item.fax), kABPersonPhoneWorkFAXLabel, NULL);//添加传真
        ABRecordSetValue(recordRef, kABPersonPhoneProperty, multiValueRef, NULL);
        
        // 邮箱信息
        multiValueRef =ABMultiValueCreateMutable(kABStringPropertyType);//添加设置多值属性
        sep_str = [item.mail componentsSeparatedByString:kSeparateChar];
        for (NSString *str in sep_str) {
            ABMultiValueAddValueAndLabel(multiValueRef, (__bridge CFStringRef)(str), kABWorkLabel, NULL);//添加工作邮箱
        }
        ABRecordSetValue(recordRef, kABPersonEmailProperty, multiValueRef, NULL);
        
        // 地址信息
        multiValueRef =ABMultiValueCreateMutable(kABDictionaryPropertyType);//添加设置多值属性
        CFStringRef keys[2];
        CFStringRef values[2];
        keys[0] = kABPersonAddressStreetKey;
        keys[1] = kABPersonAddressZIPKey;
        values[0] = (__bridge CFStringRef)(item.address);
        values[1] = (__bridge CFStringRef)(item.post_code);
        CFDictionaryRef aDict = CFDictionaryCreate(
                                                   kCFAllocatorDefault,
                                                   (void *)keys,
                                                   (void *)values,
                                                   2,
                                                   NULL,
                                                   NULL
                                                   );
        ABMultiValueAddValueAndLabel(multiValueRef, aDict, kABWorkLabel, NULL);
        ABRecordSetValue(recordRef, kABPersonAddressProperty, multiValueRef, NULL);
        
        //保存通讯录，提交更改
        ABAddressBookSave(self.addressBook, NULL);
        //释放资源
        CFRelease(recordRef);
        CFRelease(multiValueRef);
    }
}

#pragma mark - 排序
- (void)sortCardListByIndexAndGroup{
    //按拼音排序,并放入到显示List中
    NSArray *allKeys = [cardListShow allKeys];
    sortedKeys = [allKeys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
}

- (void)sortCardListByIndex{
    //生成拼音索引
    NSMutableArray *cardArray;
    if(cardListByCharactor==nil){
        cardListByCharactor = [[NSMutableDictionary alloc]init];
    }else {
        [cardListByCharactor removeAllObjects];
    }
    for(DBCardListItem *item in cardList){
        
        NSString *index;
        
        if([item.name canBeConvertedToEncoding:NSASCIIStringEncoding]){
            index = [item.name substringToIndex:1];
        }else{
            index = [NSString stringWithFormat:@"%c",pinyinFirstLetter([item.name characterAtIndex:0])];
        }
        
        
        if ((cardArray=[cardListByCharactor objectForKey:index])==nil) {
            NSMutableArray *array = [[NSMutableArray alloc] init];
            [array addObject:item];
            [cardListByCharactor setObject:array forKey:index];
        }else{
            [cardArray addObject:item];
        }
    }
    //按拼音排序,并放入到显示List中
    NSArray *allKeys = [cardListByCharactor allKeys];
    sortedKeys = [allKeys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    
    if(cardListShow == nil){
        cardListShow = [[NSMutableDictionary alloc]init];
    }else{
        [cardListShow removeAllObjects];
    }
    
    for (NSString *index in sortedKeys) {
        [cardListShow setObject:[cardListByCharactor objectForKey:index] forKey:index];
    }
    
}


- (void)sortCardListByTimeAndGroup{
    //按时间排序
    NSArray *allKeys = [cardListShow allKeys];
    sortedKeys = [allKeys sortedArrayUsingComparator:^(id obj1, id obj2) {
        
        NSString *strDate1 = (NSString *)obj1;
        NSString *strDate2 = (NSString *)obj2;
        
        NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];//实例化一个NSDateFormatter对象
        [dateFormat setDateFormat:@"yyyy-MM-dd"];//设定时间格式,这里可以设置成自己需要的格式
        
        NSDate *date1 = [dateFormat dateFromString:strDate1];
        NSDate *date2 = [dateFormat dateFromString:strDate2];
        
        if ([date1 isEqualToDate:date2]) {
            return (NSComparisonResult)NSOrderedSame;
        }else{
            if ([date1 earlierDate:date2] == date1) {
                return (NSComparisonResult)NSOrderedAscending;
            }else{
                return (NSComparisonResult)NSOrderedDescending;
            }
        }
        
    }];
}
- (void)sortCardListByTime{
    if(cardListByTime==nil)
        cardListByTime = [[NSMutableDictionary alloc]init];
    else
        [cardListByTime  removeAllObjects];
    
    for (int i=0; i<cardList.count; i++) {
        DBCardListItem *item = [cardList objectAtIndex:i];
        NSString *create_time = item.create_time;
        
        if (create_time==nil) {
            continue;
        }
        
        if ([cardListByTime objectForKey:create_time]==nil) {
            NSMutableArray *array = [[NSMutableArray alloc]init];
            [array addObject:item];
            [cardListByTime setObject:array forKey:create_time];
        }else{
            NSMutableArray *array = [cardListByTime objectForKey:create_time];
            [array addObject:item];
            [cardListByTime setObject:array forKey:create_time];
        }
    }
    
    //按时间排序
    NSArray *allKeys = [cardListByTime allKeys];
    sortedKeys = [allKeys sortedArrayUsingComparator:^(id obj1, id obj2) {
        
        NSString *strDate1 = (NSString *)obj1;
        NSString *strDate2 = (NSString *)obj2;
        
        NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];//实例化一个NSDateFormatter对象
        [dateFormat setDateFormat:@"yyyy-MM-dd"];//设定时间格式,这里可以设置成自己需要的格式
        
        NSDate *date1 = [dateFormat dateFromString:strDate1];
        NSDate *date2 = [dateFormat dateFromString:strDate2];
        
        if ([date1 isEqualToDate:date2]) {
            return (NSComparisonResult)NSOrderedSame;
        }else{
            if ([date1 earlierDate:date2] == date1) {
                return (NSComparisonResult)NSOrderedAscending;
            }else{
                return (NSComparisonResult)NSOrderedDescending;
            }
        }
        
    }];
    //送入到cardListShow显示列表中
    if(cardListShow == nil){
        cardListShow = [[NSMutableDictionary alloc]init];
    }else{
        [cardListShow removeAllObjects];
    }
    
    for (NSString *index in sortedKeys) {
        [cardListShow setObject:[cardListByTime objectForKey:index] forKey:index];
    }
    
}

#pragma mark - action sheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(actionSheet.tag == 10000)
    {
        // 同步到通讯录
        if (buttonIndex==0)
        {
            // 检查通讯录访问权限
            [AddressBookHelper CheckAddressBookAuthorization:^(bool isAuthorized)
             {
                 if(isAuthorized)
                 {
                     if(self.addressBook == nil)
                     {
                         //创建通讯录对象
                         self.addressBook=ABAddressBookCreateWithOptions(NULL, NULL);
                     }
                     
                     DBCard *item = self.cardRecord;
                     bool isNew = [self isNewRecordwithName:item.name andMobile:item.mobile];
                     if(isNew)
                     {
                         [self addRecordToAddressBook:self.cardRecord];
                     }
                     else
                     {
                         [self updateAddressBookRecord:self.cardRecord withId:findRecordId];
                     }
                     
                     // 重置选中纪录信息
                     findRecordId = -1;
                     self.cardRecord = nil;
                     
                     UIAlertView *alert = [[UIAlertView alloc]
                                           initWithTitle:@"同步成功"
                                           message:nil
                                           delegate:self
                                           cancelButtonTitle:@"确定"
                                           otherButtonTitles:nil];
                     alert.tag = actionSheet.tag;
                     [alert show];
                 }
                 else
                 {
                     UIAlertView *alert = [[UIAlertView alloc]
                                           initWithTitle:@"没有访问本地通讯录权限"
                                           message:@"请到设置>隐私>通讯录打开本应用的权限设置"
                                           delegate:self
                                           cancelButtonTitle:@"确定"
                                           otherButtonTitles:nil];
                     [alert show];
                 }
             }];
        }
    }
    else
    {
        if (buttonIndex==0) { //删除操作
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:@"删除操作"
                                  message:@"确定删除"
                                  delegate:self
                                  cancelButtonTitle:@"确定"
                                  otherButtonTitles:@"取消",nil];
            alert.tag = actionSheet.tag;
            [alert show];
        }
        else if(buttonIndex==1){ //编辑操作
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:@"编辑分组"
                                  message:nil
                                  delegate:self
                                  cancelButtonTitle:@"确定"
                                  otherButtonTitles:@"取消",nil];
            alert.alertViewStyle = UIAlertViewStylePlainTextInput;
            alert.tag = actionSheet.tag+3000; //编辑与添加在alertview的冲突，加入3000区分编辑还是添加
            [alert show];
        }
    }
    
}

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet{
    for (UIView *subViwe in actionSheet.subviews) {
        if ([subViwe isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton*)subViwe;
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        }
    }
}


#pragma mark - alert view delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if(alertView.tag==-100){
        if(buttonIndex==1){
            [self updateDBWithNewVersion:newVersion andCurrentVersion:currentVersion];
            
            //跳到下载页面
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:APPDowdLoad]];
        }
        return;
    }
    //NSLog(@"button index %ld",buttonIndex);
    if (alertView.tag==0) { //新建处理事件
        if (buttonIndex==0) {
            UITextField *textField=[alertView textFieldAtIndex:0];
            NSString *name = textField.text;
            //判断用户输入用户名空检测
            if (name.length==0||[name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length==0) {
                [self buildProgressHUD:@"分组名称不能为空"];
                return;
            }
            
            [self insertGroup:name];
            
        }
    }
    // fyl
    if (alertView.tag==10000) { //同步到通讯录
        if (buttonIndex == 0)
        {
            [self refreshTableData];
        }
    }
    else
    {
        //其他自定义组事件
        if (alertView.tag >= 3000) {
            if (buttonIndex == 0) {
                UITextField *textField=[alertView textFieldAtIndex:0];
                NSString *name = textField.text;
                //判断用户输入用户名空检测
                if (name.length==0||[name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length==0)
                {
                    [self buildProgressHUD:@"分组名称不能为空"];
                    return;
                }
                
                [self updateGroup:alertView.tag-3000 name:name];
            }
        }
        else{
            if (buttonIndex == 0) {
                [self deleteGroup:alertView.tag];
            }
        }
    }
}

- (void) buildProgressHUD:(NSString *) title{
    /*MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
     [self.view addSubview:HUD];
     HUD.labelText = title;
     HUD.mode = MBProgressHUDModeText;
     
     //指定距离中心点的X轴和Y轴的偏移量，如果不指定则在屏幕中间显示
     HUD.yOffset = 100.0f;
     //    HUD.xOffset = 100.0f;
     
     [HUD showAnimated:YES whileExecutingBlock:^{
     sleep(2);
     } completionBlock:^{
     [HUD removeFromSuperview];
     
     }];*/
}

#pragma mark - 右边栏按钮

- (void)takePhoto:(UIButton *)button{
    RecognizeResultViewController *resultController = [[RecognizeResultViewController alloc]init];
    
    // 4IOS
    [Recognize4IOS startRecognize:self.navigationController image:nil pushController:resultController];
    
    firstAppear = 100;
}

- (void)rightButtonClick:(UIButton *)button{
    if(button.tag == 0){
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"添加分组"
                              message:nil
                              delegate:self
                              cancelButtonTitle:@"确定"
                              otherButtonTitles:@"取消",nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        alert.tag = button.tag;
        [alert show];
    }else{
        if (button.tag>0) {
            if (sortType == kSortTypeIndex) {
                [self sortCardListByIndex];
            }else{
                [self sortCardListByTime];
            }
            cardListSave = [cardListShow mutableCopy];
            [cardListShow removeAllObjects];
            for (NSString *key in cardListSave) {
                
                NSMutableArray *items = [cardListSave objectForKey:key];
                NSMutableArray *itemsCopy=nil;
                for (DBCardListItem *item in items){
                    if([item.gid intValue]==button.tag){
                        if (itemsCopy==nil) {
                            itemsCopy = [[NSMutableArray alloc]init];
                        }
                        [itemsCopy addObject:item];
                    }
                }
                
                if (itemsCopy!=nil) {
                    [cardListShow setObject:itemsCopy forKey:key];
                }
                
            }
            if (sortType == kSortTypeIndex) {
                [self sortCardListByIndexAndGroup];
            }else{
                [self sortCardListByTimeAndGroup];
            }
            [tableView reloadData];
        }
        
        if(button.tag==-2){//全部分组
            if (sortType == kSortTypeIndex) {
                [self sortCardListByIndex];
            }else{
                [self sortCardListByTime];
            }
            [tableView reloadData];
        }
        
        if(button.tag==-1){//未分组
            if (sortType == kSortTypeIndex) {
                [self sortCardListByIndex];
            }else{
                [self sortCardListByTime];
            }
            cardListSave = [cardListShow mutableCopy];
            [cardListShow removeAllObjects];
            for (NSString *key in cardListSave) {
                
                NSMutableArray *items = [cardListSave objectForKey:key];
                NSMutableArray *itemsCopy=nil;
                for (DBCardListItem *item in items){
                    if([item.gid intValue]==0){
                        if (itemsCopy==nil) {
                            itemsCopy = [[NSMutableArray alloc]init];
                        }
                        [itemsCopy addObject:item];
                    }
                }
                
                if (itemsCopy!=nil) {
                    [cardListShow setObject:itemsCopy forKey:key];
                }
                
            }
            if (sortType == kSortTypeIndex) {
                [self sortCardListByIndexAndGroup];
            }else{
                [self sortCardListByTimeAndGroup];
            }
            [tableView reloadData];
        }
        
        
        
        
    }
    //NSLog(@"button tag %ld",button.tag);
}

- (void)rightButtonLongPressed:(UILongPressGestureRecognizer *)gestureRecognizer{
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan){
        
        UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                      initWithTitle:nil
                                      delegate:self
                                      cancelButtonTitle:@"取消操作"
                                      destructiveButtonTitle:nil
                                      otherButtonTitles:@"删除分组", @"编辑分组",nil];
        actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
        
        actionSheet.tag = gestureRecognizer.view.tag;
        
        [actionSheet showInView:self.view];
        
        //NSLog(@"button long tag %ld",gestureRecognizer.view.tag);
    }
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

-(void)createRightScrollView{
    //创建scroll view中的分组的button
    for (int i=0; i<groupArray.count; i++) {
        UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(kRightButtonMarginLeft, kRightHeaderHeight + kRightItemHeight*i, kRightButtonWidth, kRightButtonHeight)];
        [button setBackgroundImage:[UIImage imageNamed:@"group_normal.png"] forState:UIControlStateNormal];
        
        NSString *title = ((DBGroup *)groupArray[i]).name;
        //截断过长字符串
        [button setTitle:title.length>6?[title substringToIndex:6]:title forState:UIControlStateNormal];
        
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont fontWithName:@"Helvetica-BoldOblique" size:10];
        [button.titleLabel setNumberOfLines:0];
        
        [button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter|UIControlContentVerticalAlignmentCenter];
        //设置文字边距
        button.contentEdgeInsets = UIEdgeInsetsMake(1,1,1,1);
        
        //设置tag,用户自定义分组菜单使用数据表中的ID,非自定义采用固定的 -2 -1 0
        button.tag = [((DBGroup *)groupArray[i]).Id intValue];
        
        //设置按钮点击事件
        [button addTarget:self action:@selector(rightButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        //设置按钮长按事件
        if([((DBGroup *)groupArray[i]).Id intValue]>0){
            UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(rightButtonLongPressed:)];
            longPress.minimumPressDuration = 0.8; //定义按的时间
            [button addGestureRecognizer:longPress];
        }
        
        
        [scrollView addSubview:button];
    }
}

//清除现有的右栏的button
- (void)deleteRightScrollView{
    for(UIView *view in scrollView.subviews){
        if ([view isKindOfClass:[UIButton class]]) {
            [view removeFromSuperview];
        }
    }
}

- (void)updateGroup:(NSInteger)Id name:(NSString *)name{
    
    if ([self searchGroupExist:name]) {
        [self buildProgressHUD:@"分组已经存在"];
        return;
    }
    
    //在数据库中更新分组
    [db UpdateGroup:name id:[NSString stringWithFormat:@"%ld",Id]];
    //更新界面的标题
    int i;
    for (i=0;i<groupArray.count;i++){
        NSNumber *num = ((DBGroup *)groupArray[i]).Id;
        if ([num longValue]==Id) {
            ((DBGroup *)groupArray[i]).name = name;
            break;
        }
    }
    //清除现有的右栏
    [self deleteRightScrollView];
    //重新构造右栏
    [self createRightScrollView];
}

- (void)deleteGroup:(NSInteger)Id{
    //在数据库中删除分组
    [db DeleteGroup:[NSString stringWithFormat:@"%ld",Id]];
    
    //删除的分组关联的名片的操作
    
    
    //删除内存中存储分组的名称
    int i;
    for (i=0;i<groupArray.count;i++){
        NSNumber *num = ((DBGroup *)groupArray[i]).Id;
        if ([num longValue]==Id) {
            break;
        }
    }
    [groupArray removeObjectAtIndex:i];
    //清除现有的右栏
    [self deleteRightScrollView];
    //重新构造右栏
    [self createRightScrollView];
}

- (void)insertGroup:(NSString *)name{
    
    //查询分组名是否存在
    if ([self searchGroupExist:name]) {
        [self buildProgressHUD:@"分组已经存在"];
    }else{
        //在数据库中插入分组
        [db InsertGroup:name];
        NSNumber *Id = [self searchGroupID:name];
        
        //创建内右边栏的新分组的图
        DBGroup *group = [[DBGroup alloc]init];
        group.Id = Id;
        group.name = name;
        
        [groupArray insertObject:group atIndex:groupArray.count-1];
        //清除现有的右栏
        [self deleteRightScrollView];
        //重新构造右栏
        [self createRightScrollView];
        
        //设置Scroll View的Content size
        CGSize size = scrollView.contentSize;
        size.height += 40;
        scrollView.contentSize = size;
    }
    
    
    
}

- (BOOL)searchGroupExist:(NSString *)name{
    NSMutableArray *array = [db QueryGroup];
    for(int i=0 ; i<array.count ;i++){
        DBGroup *group = (DBGroup *)array[i];
        if([group.name isEqualToString:name])
            return YES;
    }
    
    return NO;
}

- (NSNumber *)searchGroupID:(NSString *)name{
    NSMutableArray *array = [db QueryGroup];
    for(int i=0 ; i<array.count ;i++){
        DBGroup *group = (DBGroup *)array[i];
        if([group.name isEqualToString:name])
            return group.Id;
    }
    
    return [NSNumber numberWithInt:-1];
}

#pragma mark - 左右菜单

- (UIBarButtonItem *)leftMenuBarButtonItem {
    
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0,0,30,30)];
    [button setImage:[UIImage imageNamed:@"icon_menu.png"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(leftSideMenuButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [button setTitleEdgeInsets:UIEdgeInsetsMake(-1, -55, 0, 0)];

    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithCustomView:button];
    
    return item;
}

- (UIBarButtonItem *)rightMenuBarButtonItem {
    
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0,0,30,30)];
    [button setImage:[UIImage imageNamed:@"icon_sort.png"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(rightSideMenuButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithCustomView:button];
    
    return item;
}

- (void)leftSideMenuButtonPressed:(id)sender {
    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{
        [self setupMenuBarButtonItems];
    }];
}

- (void)rightSideMenuButtonPressed:(id)sender {
    if (isPopup) {
        [self.menuPopover dismissMenuPopover];
        isPopup = NO;
    }else{
        
        NSArray *imageNames = @[@"name_order",@"time_order"];
        
        self.menuPopover = [[MLKMenuPopover alloc] initWithFrame:CGRectMake(kScreenWidth-140-60, 50, 120+60, 44*2) menuItems:self.menuItems andImages:imageNames];
        self.menuPopover.menuPopoverDelegate = self;
        [self.menuPopover showInView:self.view];
        isPopup = YES;
    }
}

- (void)menuPopover:(MLKMenuPopover *)menuPopover didSelectMenuItemAtIndex:(NSInteger)selectedIndex
{
    [self.menuPopover dismissMenuPopover];
    isPopup = NO;
    
    if (selectedIndex == kSortTypeIndex) {
        [self sortCardListByIndex];
        sortType = kSortTypeIndex;
    }else if(selectedIndex==kSortTypeTime){
        [self sortCardListByTime];
        sortType = kSortTypeTime;
    }
    
    [tableView reloadData];
}


#pragma mark UISearchBarDelegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    if (searchText.length==0) {
        if(db==nil)
            db = [[DBOperation alloc]init];
        cardList = [db getCardListBySearchText:searchBar.text];
        
        
        if(sortType == kSortTypeTime){
            [self sortCardListByTime];
        }else if(sortType == kSortTypeIndex){
            [self sortCardListByIndex];
        }
        
        [tableView reloadData];
        [searchBar resignFirstResponder];
    }
    
    
    
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    NSLog(@"searchBarSearchButtonClicked");
    if(db==nil)
        db = [[DBOperation alloc]init];
    cardList = [db getCardListBySearchText:searchBar.text];
    
    
    if(sortType == kSortTypeTime){
        [self sortCardListByTime];
    }else if(sortType == kSortTypeIndex){
        [self sortCardListByIndex];
    }
    
    [tableView reloadData];
    [searchBar resignFirstResponder];
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

#pragma mark UITableview delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [cardListShow count];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSString *key = [sortedKeys objectAtIndex:section];
    return [[cardListShow objectForKey:key] count];
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{

    if (sortedKeys > 0) {
        return [sortedKeys objectAtIndex:section];
    }
    return nil;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *cellIdentifier = @"Cell";
    
    CardPackageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(cell == nil) {
        cell = [[CardPackageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    NSString *key = [sortedKeys objectAtIndex:indexPath.section];
    NSMutableArray *array = [cardListShow objectForKey:key];
    DBCardListItem *item = [array objectAtIndex:indexPath.row];
    
    //NSLog(@"%@",[NSString stringWithFormat:@"%@/Documents/%@.jpg",NSHomeDirectory(),item.pic_name]);
    UIImage* image = [[UIImage alloc]initWithContentsOfFile:[NSString stringWithFormat:@"%@/Documents/%@.jpg",NSHomeDirectory(),item.pic_name]];
    cell.cardImageView.image = image;
    cell.nameLabel.text = item.name;
    //UIImage *imageBook = UIIMage im
    UIImage *imageBook = [UIImage imageNamed:@"AddressBook.png"];
    if(item.is_saved && [item.is_saved isEqualToNumber:[NSNumber numberWithInt:1]])
         cell.cardBookImageView.image = imageBook;
        
//    NSString *name = nil;
//    if(!item.is_saved || [item.is_saved isEqualToNumber:[NSNumber numberWithInt:0]])
//        name = [NSString stringWithFormat:@"%@",item.name];
//    else
//    {
//        name = [NSString stringWithFormat:@"%@(L)",item.name];
//    }
    cell.nameLabel.text = [NSString stringWithFormat:@"%@",item.name];
    cell.titleLabel.text = item.title;
    cell.companyLabel.text = item.company;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    firstAppear = 100;
    
    
    NSString *key = [sortedKeys objectAtIndex:indexPath.section];
    NSMutableArray *array = [cardListShow objectForKey:key];
    DBCardListItem *item = [array objectAtIndex:indexPath.row];
    
    CardDetailViewController *cardDetail = [[CardDetailViewController alloc]initWithFrame:[UIScreen mainScreen].bounds andCardModel:[item.Id integerValue]];
    
    //cardDetail.cardID = [item.Id integerValue];
    
    [self.navigationController pushViewController:cardDetail animated:YES];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)longPressTableCell:(UILongPressGestureRecognizer *)gesture
{
    if(gesture.state == UIGestureRecognizerStateBegan)
    {
        CGPoint point = [gesture locationInView:tableView];
        
        NSIndexPath * indexPath = [tableView indexPathForRowAtPoint:point];
        if(indexPath == nil)
            return ;
        
        NSString *key = [sortedKeys objectAtIndex:indexPath.section];
        NSMutableArray *array = [cardListShow objectForKey:key];
        DBCardListItem *item = [array objectAtIndex:indexPath.row];
        
        db = [[DBOperation alloc]init];
        self.cardRecord = [db getCardInfoById:[item.Id integerValue]];
        
        UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                      initWithTitle:@"操作"
                                      delegate:self
                                      cancelButtonTitle:@"取消"
                                      destructiveButtonTitle:nil
                                      otherButtonTitles:@"同步到本地通讯录", nil];
        actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
        actionSheet.tag = 10000;
        
        [actionSheet showInView:self.view];
    }
}



@end
