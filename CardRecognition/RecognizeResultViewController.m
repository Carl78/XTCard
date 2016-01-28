//
//  RecognizeResultViewController.m
//  CardRecognition
//
//  Created by bournejason on 15/5/16.
//  Copyright (c) 2015年 bournejason. All rights reserved.
//

#import "RecognizeResultViewController.h"
#import "RecognitionResultTableViewCell.h"
#import "DBOperation.h"
#import "CustomOptionView.h"
#import "SVProgressHUD.h"
#import "CardPackageEditingViewController.h"
#import "CardPackageViewController.h"
#import "IdentifierValidator.h"
#import "AppConfig.h"

#define kMenuCellBGColor 0xcccccc
#define kViewBGColor 0x403f3f

@interface RecognizeResultViewController ()
<UIAlertViewDelegate>
{
    NSMutableDictionary *result;
    NSMutableArray *keys;
    NSMutableArray *values;
    //NSMutableArray *KK;
    //NSMutableArray *VV;
    
    UITableView *tableView;
    //数据库操作类
    DBOperation *db;
    
    NSMutableArray *groupArray;
    
    NSString *groupTitle;
    NSNumber *groupId;
    
    NSString *strName;
    NSString *strTitle;
    NSString *strCompany;
}
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic,weak) UIImage *image;
@property (nonatomic, strong) NSArray *defaultPropertyName;
@property (nonatomic, strong)UIScrollView *scrollView;

@property (nonatomic, strong) NSMutableArray *dataSourceArr;

@end

@implementation RecognizeResultViewController

//-(instancetype)init{
//    self = [super init];
//    if (self) {
//        CGFloat width = self.view.frame.size.width;
//        CGFloat height = width /1600*960;
//        self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 64, width, height)];
//        //scrollView.backgroundColor = [UIColor redColor];
//        // 是否支持滑动最顶端
//        self.scrollView.scrollsToTop = YES;
//        self.scrollView.delegate = self;
//        // 设置内容大小
//        self.scrollView.contentSize = CGSizeMake(width*2, height);
//        // 是否反弹
//        self.scrollView.bounces = NO;
//        // 是否分页
//        self.scrollView.pagingEnabled = YES;
//        // 是否滚动
//        self.scrollView.scrollEnabled = YES;
//        self.scrollView.showsHorizontalScrollIndicator = NO;
//        self.scrollView.showsVerticalScrollIndicator = NO;
//        self.scrollView.contentOffset = CGPointMake(0, 0);
//        [self.view addSubview:self.scrollView];
//    }
//    return self;
//}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    
    self.defaultPropertyName =
    @[@"姓名 *",
      @"手机 *",
      @"公司 *",
      @"邮箱",
      @"职称",
      @"固话",
      @"传真",
      @"地址",
      @"邮编",
      @"网址",
      @"备注"
      ];
    
    
    //
    groupId = 0;
    groupTitle = @"未分组";
    //初始化主View
    UIView *mainView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    mainView.backgroundColor = [UIColor blackColor];
    self.view = mainView;
    
    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
    self.navigationController.navigationBar.translucent = YES;
    
    //初始化数据库
    db = [[DBOperation alloc]init];
    groupArray = [db QueryGroup];
    
    //设置视图标题view
    //self.title = @"名片夹";
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(41, 0, 100, 30)];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setText:@"识别结果"];
    titleLabel.font = [UIFont boldSystemFontOfSize:20];
    
    self.navigationItem.titleView = titleLabel;
    
    //解析识别数据
    NSMutableArray *KKK = [[NSMutableArray alloc]init];
    NSMutableArray *VVV = [[NSMutableArray alloc]init];

    //4IOS
    NSArray* pKeys = [result allKeys];
    for (id  key in pKeys) {
        id obj = [result objectForKey:key];
        if([obj isKindOfClass:[NSMutableArray class]]){
            NSLog(@"key = %@",[key debugDescription]);
            NSMutableArray* pArray = (NSMutableArray*)obj;
            for (id item in pArray) {
                if([item isKindOfClass:[cardPair class]]){
                    cardPair* pPair  = (cardPair*)item;
                    //NSLog(@"recognize text %@",pPair.strText);
                    NSString *keyName =[self getKeyName:[key debugDescription]];
#ifdef DEBUG
                    NSLog(@"keyName = %@",keyName);
#endif
                    if ([keyName isEqualToString:@"姓名"]||[keyName isEqualToString:@"公司"]||[keyName isEqualToString:@"手机"]) {
                        [KKK addObject:[NSString stringWithFormat:@"%@ *",keyName]];
                    }else{
                        [KKK addObject:keyName];
                    }

                    [VVV addObject:pPair.strText];
                    
                    if ([keyName isEqualToString:@"姓名"]) {
                        strName = pPair.strText;
                    }else if ([keyName isEqualToString:@"职称"]){
                        strTitle = pPair.strText;
                    }else if ([keyName isEqualToString:@"公司"]){
                        strCompany = pPair.strText;
                    }
                }
            }
        }
        else if([obj isKindOfClass:[NSNumber class]]){
            NSNumber* pNumber = (NSNumber *)obj;
            NSLog(@"determine if the image need reverse, %d",[pNumber boolValue]);
        }
        else if([obj isKindOfClass:[UIImage class]]){
            //NSLog(@"the captured card image");
            self.image = (UIImage*)obj;
        }
     }
    
    // 暂存识别信息
    DBCard *card = [[DBCard alloc]init];
    for (int i=0; i<KKK.count; i++) {
        NSString *key = [KKK objectAtIndex:i];
        if ([key isEqualToString:@"姓名 *"]) {
            card.name = [self parseProperty:card.name appendValue:[VVV objectAtIndex:i]];
        }else if ([key isEqualToString:@"名字"]) {
            card.sur_name = [self parseProperty:card.sur_name appendValue:[VVV objectAtIndex:i]];
        }else if ([key isEqualToString:@"名称"]) {
            card.post_name = [self parseProperty:card.post_name appendValue:[VVV objectAtIndex:i]];
        }else if ([key isEqualToString:@"固话"]) {
            card.job_tel = [self parseProperty:card.job_tel appendValue:[VVV objectAtIndex:i]];
        }else if ([key isEqualToString:@"电话"]) {
            card.home_tel = [self parseProperty:card.home_tel appendValue:[VVV objectAtIndex:i]];
        }else if ([key isEqualToString:@"传真"]) {
            
            card.fax = [self parseProperty:card.fax appendValue:[VVV objectAtIndex:i]];
        }else if ([key isEqualToString:@"手机 *"]) {
            card.mobile = [self parseProperty:card.mobile appendValue:[VVV objectAtIndex:i]];
        }else if ([key isEqualToString:@"邮箱"]) {
            card.mail = [self parseProperty:card.mail appendValue:[VVV objectAtIndex:i]];
        }else if ([key isEqualToString:@"网址"]) {
            card.url = [self parseProperty:card.url appendValue:[VVV objectAtIndex:i]];
        }else if ([key isEqualToString:@"职称"]) {
            card.title = [self parseProperty:card.title appendValue:[VVV objectAtIndex:i]];
        }else if ([key isEqualToString:@"公司 *"]) {
            card.company = [self parseProperty:card.company appendValue:[VVV objectAtIndex:i]];
        }else if ([key isEqualToString:@"地址"]) {
            card.address = [self parseProperty:card.address appendValue:[VVV objectAtIndex:i]];
        }else if ([key isEqualToString:@"邮编"]){
            card.post_code = [self parseProperty:card.post_code appendValue:[VVV objectAtIndex:i]];
        }else if ([key isEqualToString:@"备注"]){
            card.note = [self parseProperty:card.note appendValue:[VVV objectAtIndex:i]];
        }else if ([key isEqualToString:@"年龄"]) {
            card.age = [self parseProperty:card.age appendValue:[VVV objectAtIndex:i]];
        }else if ([key isEqualToString:@"部门"]) {
            card.department = [self parseProperty:card.department appendValue:[VVV objectAtIndex:i]];
        }else if ([key isEqualToString:@"生日"]) {
            card.date = [self parseProperty:card.date appendValue:[VVV objectAtIndex:i]];
        }else if ([key isEqualToString:@"日期"]) {
            card.birthday = [self parseProperty:card.birthday appendValue:[VVV objectAtIndex:i]];
        }
    }
    
    // 按指定顺序记录识别信息
    keys = [[NSMutableArray alloc]init];
    values = [[NSMutableArray alloc]init];
    
    if(card.name!=nil){
        NSArray *sep_str = [card.name componentsSeparatedByString:kSeparateChar];
        for (NSString *str in sep_str) {
            [keys addObject:@"姓名 *"];
            [values addObject:str];
        }
    }
    if(card.mobile!=nil){
        NSArray *sep_str = [card.mobile componentsSeparatedByString:kSeparateChar];
        for (NSString *str in sep_str) {
            [keys addObject:@"手机 *"];
            [values addObject:str];
        }
    }
    if(card.company!=nil){
        NSArray *sep_str = [card.company componentsSeparatedByString:kSeparateChar];
        for (NSString *str in sep_str) {
            [keys addObject:@"公司 *"];
            [values addObject:str];
        }
    }
    if(card.mail!=nil){
        NSArray *sep_str = [card.mail componentsSeparatedByString:kSeparateChar];
        for (NSString *str in sep_str) {
            [keys addObject:@"邮箱"];
            [values addObject:str];
        }
    }
    if(card.title!=nil){
        NSArray *sep_str = [card.title componentsSeparatedByString:kSeparateChar];
        for (NSString *str in sep_str) {
            [keys addObject:@"职称"];
            [values addObject:str];
        }
    }
    if(card.job_tel!=nil){
        NSArray *sep_str = [card.job_tel componentsSeparatedByString:kSeparateChar];
        for (NSString *str in sep_str) {
            [keys addObject:@"固话"];
            [values addObject:str];
        }
    }
    if(card.fax!=nil){
        NSArray *sep_str = [card.fax componentsSeparatedByString:kSeparateChar];
        for (NSString *str in sep_str) {
            [keys addObject:@"传真"];
            [values addObject:str];
        }
    }
    if(card.address!=nil){
        NSArray *sep_str = [card.address componentsSeparatedByString:kSeparateChar];
        for (NSString *str in sep_str) {
            [keys addObject:@"地址"];
            [values addObject:str];
        }
    }
    if(card.post_code!=nil){
        NSArray *sep_str = [card.post_code componentsSeparatedByString:kSeparateChar];
        for (NSString *str in sep_str) {
            [keys addObject:@"邮编"];
            [values addObject:str];
        }
    }
    if(card.url!=nil){
        NSArray *sep_str = [card.url componentsSeparatedByString:kSeparateChar];
        for (NSString *str in sep_str) {
            [keys addObject:@"网址"];
            [values addObject:str];
        }
    }
    if(card.note!=nil){
        NSArray *sep_str = [card.note componentsSeparatedByString:kSeparateChar];
        for (NSString *str in sep_str) {
            [keys addObject:@"备注"];
            [values addObject:str];
        }
    }


    // 4IOS

    
//    CGFloat width = self.view.frame.size.width;
//    CGFloat height = width /1600*960;
//    
//    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 64, width, height)];
//    //scrollView.backgroundColor = [UIColor redColor];
//    // 是否支持滑动最顶端
//    self.scrollView.scrollsToTop = YES;
//    self.scrollView.delegate = self;
//    // 设置内容大小
//    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width*2, height);
//    // 是否反弹
//    self.scrollView.bounces = NO;
//    // 是否分页
//    self.scrollView.pagingEnabled = YES;
//    // 是否滚动
//    self.scrollView.scrollEnabled = YES;
//    self.scrollView.showsHorizontalScrollIndicator = NO;
//    self.scrollView.showsVerticalScrollIndicator = NO;
//    self.scrollView.contentOffset = CGPointMake(0, 0);
//    [self.view addSubview:self.scrollView];
//    
//    
//    UIView *viewA=[[UIView alloc]initWithFrame:CGRectMake(0,0,self.scrollView.frame.size.width,self.scrollView.frame.size.height)];
//    viewA.backgroundColor=[UIColor grayColor];
//    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(20, self.scrollView.frame.size.height/2-75+40, 80, 65)];
//    [imageView setImage:[UIImage imageNamed:@"person_thumb"]];
//    [viewA addSubview:imageView];
//    
//    UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(120, self.scrollView.frame.size.height/2-50, self.scrollView.frame.size.width-120, 10)];
//    nameLabel.text = strName;
//    nameLabel.textColor = [UIColor colorWithRed:((float)((kMenuCellBGColor & 0xFF0000) >> 16))/255.0 green:((float)((kMenuCellBGColor & 0xFF00) >> 8))/255.0 blue:((float)(kMenuCellBGColor & 0xFF))/255.0 alpha:1.0];
//    [nameLabel setFont:[UIFont fontWithName:@"STHeitiSC-Medium" size:20.00]];
//    
//    UILabel *title = [[UILabel alloc]initWithFrame:CGRectMake(120, self.scrollView.frame.size.height/2, self.scrollView.frame.size.width-120, 10)];
//    title.text = strTitle;
//    title.textColor = [UIColor colorWithRed:((float)((kMenuCellBGColor & 0xFF0000) >> 16))/255.0 green:((float)((kMenuCellBGColor & 0xFF00) >> 8))/255.0 blue:((float)(kMenuCellBGColor & 0xFF))/255.0 alpha:1.0];
//    [title setFont:[UIFont fontWithName:@"STHeitiSC-Medium" size:20.00]];
//    
//    
//    UILabel *companyLabel = [[UILabel alloc]initWithFrame:CGRectMake(120, self.scrollView.frame.size.height/2+50, self.scrollView.frame.size.width-120, 10)];
//    companyLabel.text = strCompany;
//    companyLabel.textColor = [UIColor colorWithRed:((float)((kMenuCellBGColor & 0xFF0000) >> 16))/255.0 green:((float)((kMenuCellBGColor & 0xFF00) >> 8))/255.0 blue:((float)(kMenuCellBGColor & 0xFF))/255.0 alpha:1.0];
//    [companyLabel setFont:[UIFont fontWithName:@"STHeitiSC-Medium" size:20.00]];
//    
//    //头信息
//    //UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 60)];
//    UIImageView *imgView = [[UIImageView alloc]initWithFrame:CGRectMake(self.scrollView.frame.size.width, 0, width, height)];
//    //imageView.bounds = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 160);
//    [imgView setImage:self.image];
//    //    [self.view addSubview:imgView];
//    
//    [viewA addSubview:nameLabel];
//    [viewA addSubview:title];
//    [viewA addSubview:companyLabel];
//    [self.scrollView addSubview:viewA];
//    [self.scrollView addSubview:imgView];
//    
//    self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(self.scrollView.frame.size.width-100, self.scrollView.frame.size.height+30, 100, 40)];
//    [self.pageControl setBackgroundColor:[UIColor clearColor]];
//    self.pageControl.currentPageIndicatorTintColor = [UIColor grayColor];
//    self.pageControl.pageIndicatorTintColor = [UIColor whiteColor];
//    self.pageControl.currentPage = 0;
//    self.pageControl.numberOfPages = 2;
//    [self.view addSubview:self.pageControl];
//    
//    UIView *addView = [[UIView alloc] initWithFrame:CGRectMake(0, 64+height, [UIScreen mainScreen].bounds.size.width, 40)];
//    addView.backgroundColor = [UIColor colorWithRed:((float)((kViewBGColor & 0xFF0000) >> 16))/255.0 green:((float)((kViewBGColor & 0xFF00) >> 8))/255.0 blue:((float)(kViewBGColor & 0xFF))/255.0 alpha:1.0];
//    addView.layer.masksToBounds = YES;
//    addView.layer.borderColor = [UIColor lightGrayColor].CGColor;
//    addView.layer.borderWidth = 0.5f;
//    
//    UIButton *add = [UIButton buttonWithType:UIButtonTypeCustom];
//    add.frame = CGRectMake(0, 5, [UIScreen mainScreen].bounds.size.width, 30);
//    [add setTitle:@"添加属性" forState:UIControlStateNormal];
//    [add setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    add.titleLabel.font = [UIFont boldSystemFontOfSize:20];
//    [add addTarget:self action:@selector(addProperty:) forControlEvents:UIControlEventTouchUpInside];
//    [addView addSubview:add];
//    
//    addView.backgroundColor = [UIColor whiteColor];
//    [self.view addSubview:addView];
//    
//    
//    /*
//    NSString  *jpgPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Test.jpg"];
//    // The value '1.0' represents image compression quality as value from 0.0 to 1.0
//    [UIImageJPEGRepresentation(self.image, 1.0) writeToFile:jpgPath atomically:YES];
//     */
//    
//    
//    //UIGraphicsEndImageContext();
//    //UIImageWriteToSavedPhotosAlbum(self.image, nil, nil, nil);
//    
//    //创建table view
//    CGRect frame = CGRectMake(0, 64+height+40, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-(64+height+40));
//    tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
//    tableView.delegate = self;
//    tableView.dataSource = self;
//    tableView.bounces = NO;
//
//    
//    [self.view addSubview:tableView];
//    
//    [self setupMenuBarButtonItems];
    
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
//    [self viewWillLayoutSubviews];
    [self.view setNeedsLayout];
}


-(void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    
    CGFloat width = self.view.frame.size.width;
    CGFloat height = width /1600*960;
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 64, width, height)];
    //scrollView.backgroundColor = [UIColor redColor];
    // 是否支持滑动最顶端
    self.scrollView.scrollsToTop = YES;
    self.scrollView.delegate = self;
    // 设置内容大小
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width*2, height);
    // 是否反弹
    self.scrollView.bounces = NO;
    // 是否分页
    self.scrollView.pagingEnabled = YES;
    // 是否滚动
    self.scrollView.scrollEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.contentOffset = CGPointMake(0, 0);
    [self.view addSubview:self.scrollView];
    
    
    UIView *viewA=[[UIView alloc]initWithFrame:CGRectMake(self.scrollView.frame.size.width,0,self.scrollView.frame.size.width,self.scrollView.frame.size.height)];
    viewA.backgroundColor=[UIColor grayColor];
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(20, self.scrollView.frame.size.height/2-75+40, 80, 65)];
    [imageView setImage:[UIImage imageNamed:@"person_thumb"]];
    [viewA addSubview:imageView];
    
    UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(120, self.scrollView.frame.size.height/2-50, self.scrollView.frame.size.width-120, 40)];
    nameLabel.text = strName;
    nameLabel.textColor = [UIColor colorWithRed:((float)((kMenuCellBGColor & 0xFF0000) >> 16))/255.0 green:((float)((kMenuCellBGColor & 0xFF00) >> 8))/255.0 blue:((float)(kMenuCellBGColor & 0xFF))/255.0 alpha:1.0];
    [nameLabel setFont:[UIFont fontWithName:@"STHeitiSC-Medium" size:20.00]];
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(120, self.scrollView.frame.size.height/2, self.scrollView.frame.size.width-120, 40)];
    titleLabel.text = strTitle;
    titleLabel.textColor = [UIColor colorWithRed:((float)((kMenuCellBGColor & 0xFF0000) >> 16))/255.0 green:((float)((kMenuCellBGColor & 0xFF00) >> 8))/255.0 blue:((float)(kMenuCellBGColor & 0xFF))/255.0 alpha:1.0];
    titleLabel.numberOfLines = 2;
    [titleLabel setFont:[UIFont fontWithName:@"STHeitiSC-Medium" size:20.00]];
    
    
    UILabel *companyLabel = [[UILabel alloc]initWithFrame:CGRectMake(120, self.scrollView.frame.size.height/2+60, self.scrollView.frame.size.width-120, 40)];
    companyLabel.text = strCompany;
    companyLabel.textColor = [UIColor colorWithRed:((float)((kMenuCellBGColor & 0xFF0000) >> 16))/255.0 green:((float)((kMenuCellBGColor & 0xFF00) >> 8))/255.0 blue:((float)(kMenuCellBGColor & 0xFF))/255.0 alpha:1.0];
    [companyLabel setFont:[UIFont fontWithName:@"STHeitiSC-Medium" size:20.00]];
    companyLabel.numberOfLines = 2;
    
    //头信息
    //UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 60)];
    UIImageView *imgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, width, height)];
    //imageView.bounds = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 160);
    [imgView setImage:self.image];
    //    [self.view addSubview:imgView];
    
    [viewA addSubview:nameLabel];
    [viewA addSubview:titleLabel];
    [viewA addSubview:companyLabel];
    [self.scrollView addSubview:viewA];
    [self.scrollView addSubview:imgView];
    
    self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(self.scrollView.frame.size.width-100, self.scrollView.frame.size.height+30, 100, 40)];
    [self.pageControl setBackgroundColor:[UIColor clearColor]];
    self.pageControl.currentPageIndicatorTintColor = [UIColor grayColor];
    self.pageControl.pageIndicatorTintColor = [UIColor whiteColor];
    self.pageControl.currentPage = 0;
    self.pageControl.numberOfPages = 2;
    [self.view addSubview:self.pageControl];
    
    UIView *addView = [[UIView alloc] initWithFrame:CGRectMake(0, 64+height, [UIScreen mainScreen].bounds.size.width, 40)];
    addView.backgroundColor = [UIColor colorWithRed:((float)((kViewBGColor & 0xFF0000) >> 16))/255.0 green:((float)((kViewBGColor & 0xFF00) >> 8))/255.0 blue:((float)(kViewBGColor & 0xFF))/255.0 alpha:1.0];
    addView.layer.masksToBounds = YES;
    addView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    addView.layer.borderWidth = 0.5f;
    
    UIButton *add = [UIButton buttonWithType:UIButtonTypeCustom];
    add.frame = CGRectMake(0, 5, [UIScreen mainScreen].bounds.size.width, 30);
    [add setTitle:@"添加属性" forState:UIControlStateNormal];
    [add setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    add.titleLabel.font = [UIFont boldSystemFontOfSize:20];
    [add addTarget:self action:@selector(addProperty:) forControlEvents:UIControlEventTouchUpInside];
    [addView addSubview:add];
    
    addView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:addView];
    
    
    /*
     NSString  *jpgPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Test.jpg"];
     // The value '1.0' represents image compression quality as value from 0.0 to 1.0
     [UIImageJPEGRepresentation(self.image, 1.0) writeToFile:jpgPath atomically:YES];
     */
    
    
    //UIGraphicsEndImageContext();
    //UIImageWriteToSavedPhotosAlbum(self.image, nil, nil, nil);
    
    //创建table view
    CGRect frame = CGRectMake(0, 64+height+40, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-(64+height+40));
    tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.bounces = NO;
    
    
    [self.view addSubview:tableView];
    
    [self setupMenuBarButtonItems];
}

- (NSString *)parseProperty:(NSString *)name appendValue:(NSString *)append{
    if (name.length<=0) {
        name = append;
    }else{
        NSString *string = [NSString stringWithFormat:@"%@%@",kSeparateChar,append];
        name = [name stringByAppendingString:string];
    }
    
    return name;
}

#pragma mark - 存储数据
- (void)saveCardData{
    //保存图片
    
    //保存到数据库
    DBCard *card = [[DBCard alloc]init];
    
    for (int i=0; i<keys.count; i++) {
        NSString *key = [keys objectAtIndex:i];
        if ([key isEqualToString:@"姓名 *"]) {
            card.name = [self parseProperty:card.name appendValue:[values objectAtIndex:i]];
        }else if ([key isEqualToString:@"名字"]) {
            card.sur_name = [self parseProperty:card.sur_name appendValue:[values objectAtIndex:i]];
        }else if ([key isEqualToString:@"名称"]) {
            card.post_name = [self parseProperty:card.post_name appendValue:[values objectAtIndex:i]];
        }else if ([key isEqualToString:@"固话"]) {
            /*BOOL isValid = [IdentifierValidator isValid:IdentifierTypePhone value:[values objectAtIndex:i]];
            if (!isValid) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"固话格式不正确" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                return;
            }*/
            card.job_tel = [self parseProperty:card.job_tel appendValue:[values objectAtIndex:i]];
        }else if ([key isEqualToString:@"电话"]) {
            card.home_tel = [self parseProperty:card.home_tel appendValue:[values objectAtIndex:i]];
        }else if ([key isEqualToString:@"传真"]) {
            card.fax = [self parseProperty:card.fax appendValue:[values objectAtIndex:i]];
        }else if ([key isEqualToString:@"手机 *"]) {
            /*BOOL isValid = [IdentifierValidator isValid:IdentifierTypeMobilePhone value:[values objectAtIndex:i]];
            if (!isValid) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"手机号码格式不正确" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                return;
            }*/
            card.mobile = [self parseProperty:card.mobile appendValue:[values objectAtIndex:i]];
        }else if ([key isEqualToString:@"邮箱"]) {
            /*BOOL isValid = [IdentifierValidator isValid:IdentifierTypeEmail value:[values objectAtIndex:i]];
            if (!isValid) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"邮箱格式不正确" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                return;
            }*/
            card.mail = [self parseProperty:card.mail appendValue:[values objectAtIndex:i]];
        }else if ([key isEqualToString:@"网址"]) {
            card.url = [self parseProperty:card.url appendValue:[values objectAtIndex:i]];
        }else if ([key isEqualToString:@"职称"]) {
            card.title = [self parseProperty:card.title appendValue:[values objectAtIndex:i]];
        }else if ([key isEqualToString:@"公司 *"]) {
            card.company = [self parseProperty:card.company appendValue:[values objectAtIndex:i]];
        }else if ([key isEqualToString:@"地址"]) {
            card.address = [self parseProperty:card.address appendValue:[values objectAtIndex:i]];
        }else if ([key isEqualToString:@"邮编"]){
            card.post_code = [self parseProperty:card.post_code appendValue:[values objectAtIndex:i]];
        }else if ([key isEqualToString:@"备注"]){
            card.note = [self parseProperty:card.note appendValue:[values objectAtIndex:i]];
        }else if ([key isEqualToString:@"年龄"]) {
            card.age = [self parseProperty:card.age appendValue:[values objectAtIndex:i]];
        }else if ([key isEqualToString:@"部门"]) {
            card.department = [self parseProperty:card.department appendValue:[values objectAtIndex:i]];
        }else if ([key isEqualToString:@"生日"]) {
            card.date = [self parseProperty:card.date appendValue:[values objectAtIndex:i]];
        }else if ([key isEqualToString:@"日期"]) {
            card.birthday = [self parseProperty:card.birthday appendValue:[values objectAtIndex:i]];
        }
    }
    
    
    //创建时间
    NSDate *create_date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-dd"];
    
    //分组信息
    card.gid = groupId;
    
    
    //保存图片文件名
    NSDate *date = [NSDate date];
    NSTimeInterval aInterval =[date timeIntervalSince1970]*1000;
    NSString *timeString = [NSString stringWithFormat:@"%.0f",aInterval];
    card.pic_name = timeString;
    
    //判断名片是否存在
    BOOL isExist = [db getCardyName:card.name phone:card.mobile company:card.company];
    if (isExist) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"此名片已存在！" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        alert.tag = 100;
        [alert show];
        return;
    }
    
    
    //保存图片文件
    NSString *filename = [NSString stringWithFormat:@"Documents/"];
    filename = [filename stringByAppendingString:timeString];
    filename = [filename stringByAppendingString:@".jpg"];
    NSString  *jpgPath = [NSHomeDirectory() stringByAppendingPathComponent:filename];
    
    //图片缩放
    UIGraphicsBeginImageContext(CGSizeMake(400, 240));
    // 绘制改变大小的图片
    [self.image drawInRect:CGRectMake(0, 0, 400, 240)];
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();

    
    // Write a UIImage to JPEG with minimum compression (best quality)
    // The value 'image' must be a UIImage object
    // The value '1.0' represents image compression quality as value from 0.0 to 1.0
    [UIImageJPEGRepresentation(scaledImage, 1.0) writeToFile:jpgPath atomically:YES];
    
    //名片创建时间
    card.create_time = [formatter stringFromDate:create_date];
    if ([self checkCard:card]) {
        [db InsertCard:card];
        
        if (self.source==1) {
            CardPackageViewController *cardPackageViewController;
            cardPackageViewController = [[CardPackageViewController alloc] init];
            NSArray *controllers;
            controllers = [NSArray arrayWithObject:cardPackageViewController];
            self.navigation.viewControllers = controllers;
        }else{
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }
}

-(NSString *)getKeyName:(NSString *)key{
    
    NSString *keyName;
    int intKey = [key intValue];
    
    switch (intKey) {
        case eCardNameItem:
            keyName = @"姓名";
            break;
        case eCardSurNameItem:
            keyName = @"名字";
            break;
        case eCardPostNameItem:
            keyName = @"名称";
            break;
        case eCardJobTelephoneItem:
            keyName = @"固话";
            break;
        case eCardHomeTelephoneItem:
            keyName = @"电话";
            break;
        case eCardFaxItem:
            keyName = @"传真";
            break;
        case eCardMobileItem:
            keyName = @"手机";
            break;
        case eCardMailItem:
            keyName = @"邮箱";
            break;
        case eCardURLItem:
            keyName = @"网址";
            break;
        case eCardTitleItem:
            keyName = @"职称";
            break;
        case eCardCompanyItem:
            keyName = @"公司";
            break;
        case eCardAddressItem:
            keyName = @"地址";
            break;
        case eCardPostcodeItem:
            keyName = @"邮编";
            break;
        case eCardNoteItem:
            keyName = @"备注";
            break;
        case eCardAgeItem:
            keyName = @"年龄";
            break;
        case eCardDepartmentItem:
            keyName = @"部门";
            break;
        case eCardDateItem:
            keyName = @"生日";
            break;
        case eCardBirthDayItem:
            keyName = @"日期";
            break;
            
        default:
            keyName = @"";
            break;
    }
    
    return keyName;
}

-(void)setRecognizedData:(NSMutableDictionary*)pRecognizedData{
    
    result = pRecognizedData;
    
    /*NSArray* pKeys = [pRecognizedData allKeys];
    for (id  key in pKeys) {
        id obj = [pRecognizedData objectForKey:key];
        if([obj isKindOfClass:[NSMutableArray class]]){
            NSLog(@"key = %@",[key debugDescription]);
            NSMutableArray* pArray = (NSMutableArray*)obj;
            for (id item in pArray) {
                if([item isKindOfClass:[cardPair class]]){
                    cardPair* pPair  = (cardPair*)item;
                    NSLog(@"recognize text %@",pPair.strText);
                }
            }
        }
        else if([obj isKindOfClass:[NSNumber class]]){
            NSNumber* pNumber = (NSNumber *)obj;
            NSLog(@"determine if the image need reverse, %d",[pNumber boolValue]);
        }
        else if([obj isKindOfClass:[UIImage class]]){
            NSLog(@"the captured card image");
        }
    }*/
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark -数据表操作
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return values.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"RecognitonCell";
    
    RecognitionResultTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[RecognitionResultTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if (indexPath.row == values.count) {
        cell.titleLabel.text = @"分组";
        if (groupId!=0) {
            cell.contentLabel.text = groupTitle;
        }else{
            cell.contentLabel.text = @"未分组";
        }
        cell.accessoryType = UITableViewCellAccessoryNone;
    }else{
        cell.titleLabel.text = [keys objectAtIndex:indexPath.row];
        cell.contentLabel.text = [values objectAtIndex:indexPath.row];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row == values.count){
        return 60;
    }else{
        return 38;
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == values.count) {
        if (groupArray.count<=0) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您目前没有自定义分组" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }else{
            CGFloat xWidth = self.view.bounds.size.width - 20.0f;
            CGFloat yHeight = 272.0f;
            CGFloat yOffset = (self.view.bounds.size.height - yHeight)/2.0f;
            UIPopoverListView *poplistview = [[UIPopoverListView alloc] initWithFrame:CGRectMake(10, yOffset, xWidth, yHeight)];
            poplistview.delegate = self;
            poplistview.datasource = self;
            poplistview.listView.scrollEnabled = TRUE;
            [poplistview setTitle:@"请选择分组"];
            [poplistview show];
        }
        
    }else{
        
        __block NSInteger index = indexPath.row;
        
        NSString *currentKey = [keys objectAtIndex:indexPath.row];
        
        int keysCount = 0;
        
        for (int i=0;i<keys.count;i++) {
            if ([currentKey isEqualToString:keys[i]]) {
                keysCount ++;
            }
        }
        
        
        CardPackageEditingViewController *nextViewController = [[CardPackageEditingViewController alloc]initWithName:[keys objectAtIndex:indexPath.row] andTargetValue:[values objectAtIndex:indexPath.row] kcount:keysCount];
        
        
        [nextViewController setCompleteOpertion:^(NSString *newValue){
            
            values[index] = newValue;
            [tableView reloadData];
        }];
        
        [nextViewController didDeleteOpertion:^(NSString *newValue) {
            [values removeObjectAtIndex:index];
            [keys removeObjectAtIndex:index];
            [nextViewController.navigationController popViewControllerAnimated:YES];
            [tableView reloadData];
        }];
        [self.navigationController pushViewController:nextViewController animated:YES];
    }
}


#pragma mark - UIPopoverListViewDataSource

- (UITableViewCell *)popoverListView:(UIPopoverListView *)popoverListView
                    cellForIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cell";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                    reuseIdentifier:identifier];
    
    int row = indexPath.row;
    
    DBGroup *group = [groupArray objectAtIndex:indexPath.row];
    
    cell.textLabel.text = group.name;

    //cell.textLabel.tag = group.Id;
    
    
    return cell;
}

- (NSInteger)popoverListView:(UIPopoverListView *)popoverListView
       numberOfRowsInSection:(NSInteger)section
{
    return groupArray.count;
}

#pragma mark - UIPopoverListViewDelegate
- (void)popoverListView:(UIPopoverListView *)popoverListView
     didSelectIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"%s : %d", __func__, indexPath.row);
    // your code here
    DBGroup *group = [groupArray objectAtIndex:indexPath.row];
    groupTitle = group.name;
    groupId = group.Id;
    
    [tableView reloadData];
}

- (CGFloat)popoverListView:(UIPopoverListView *)popoverListView
   heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - AlertViewDelegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (alertView.tag==100) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }else{
        if (buttonIndex == 1) {
            NSString *key = alertView.message;
            NSString *value = [alertView textFieldAtIndex:0].text;
            
            if (value==nil || [[value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]) {
                [SVProgressHUD showErrorWithStatus:@"无效内容, 无法添加" duration:1];
            }else{
                [keys addObject:key];
                [values addObject:value];
                
                [tableView reloadData];
            }
        }
    }
}

#pragma mark - selector 方法

-(void)addProperty:(UIButton *)sender{
    
//    if (self.theTableView.isEditing) {
//        [self.theTableView setEditing:NO animated:YES];
//    }
    
    CustomOptionView *view = [[CustomOptionView alloc]initWithParams:self.defaultPropertyName defaultSelectIndex:-1];
    [view didSelectIndexPath:^(NSIndexPath *indexPath, NSString *context, NSInteger tag) {
        
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"添加属性" message:[NSString stringWithFormat:@"%@",context] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
        [alertView show];
    }];
}


-(BOOL)checkCard:(DBCard *)card{
    if (card.name == nil || [card.name isEqualToString:@""]) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"警告" message:@"缺少姓名属性,请填写完整" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertView show];
        return NO;
    }
    if (card.company == nil || [card.company isEqualToString:@""]) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"警告" message:@"缺少公司属性,请填写完整" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertView show];
        return NO;
    }
    
    if (card.mobile == nil || [card.mobile isEqualToString:@""]) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"警告" message:@"缺少手机属性,请填写完整" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertView show];
        return NO;
    }
    /*if (card.mail == nil || [card.mail isEqualToString:@""]) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"警告" message:@"缺少邮箱属性,请填写完整" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertView show];
        return NO;
    }*/
    
    
    return YES;
}


#pragma mark - 菜单相关
- (UIBarButtonItem *)leftMenuBarButtonItem {
    
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0,0,30,30)];
    [button setImage:[UIImage imageNamed:@"icon_menu.png"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(leftSideMenuButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [button setTitleEdgeInsets:UIEdgeInsetsMake(-1, -55, 0, 0)];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithCustomView:button];
    
    return item;
}

- (UIBarButtonItem *)rightMenuBarButtonItem {
    
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0,0,35,30)];
    [button setImage:[UIImage imageNamed:@"save.png"] forState:UIControlStateNormal];
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
    /*[self.menuContainerViewController toggleLeftSideMenuCompletion:^{
     [self setupMenuBarButtonItems];
     }];*/
    
    [self.navigationController popToRootViewControllerAnimated:YES];
    
}

- (void)rightSideMenuButtonPressed:(id)sender {
    
    [self saveCardData];
    //    [self.navigationController popToRootViewControllerAnimated:YES];
}


@end
