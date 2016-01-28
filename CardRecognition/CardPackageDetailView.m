//
//  CardPackageDetailView.m
//  CardRecognition
//
//  Created by bournejason on 15/6/8.
//  Copyright (c) 2015年 bournejason. All rights reserved.
//

#import "CardPackageDetailView.h"
#import "CardModel.h"
#import "CardDetailCell.h"
#import "CardPackageEditingViewController.h"
#import "DBGroup.h"
#import "DBOperation.h"
#import "UIPopoverListView.h"
#import "CustomOptionView.h"
#import "CardDetailViewController.h"
#import "AppConfig.h"
#import "SVProgressHUD.h"

#define kMenuCellBGColor 0xcccccc
#define kAlertCallNumberTag 1000

@interface CardPackageDetailView ()<UITableViewDataSource, UITableViewDelegate,UIPopoverListViewDataSource, UIPopoverListViewDelegate,UIScrollViewDelegate>{
    NSMutableArray *keys;
    NSMutableArray *values;
    NSMutableArray *groupArray;
    DBOperation *db;
    NSString *currentEditProperty;
    int index;
    
    //after 1.0.4
    NSString *strCardID,*strName,*strTitle,*strCompany;
    
    
}

@property (nonatomic, strong) UIImageView *cardImageView;
@property (nonatomic, strong) UITableView *theTableView;

@property (nonatomic) BOOL isEdittingCard;

@property (nonatomic) int groupId;
@property (nonatomic) NSString *groupName;

@property (nonatomic, strong) NSMutableArray *dataSourceArr;
@property (nonatomic) BOOL isChangedDataSource;
@property (nonatomic, copy) NSString *currentEdittingPropertyName;

@property(nonatomic, strong) UIView *updataBackgroundView;
@property(nonatomic, strong) UIButton *updataButton;
@property(nonatomic, strong) UIButton *addPropertyButton;
@property (nonatomic, strong) NSArray *defaultPropertyName;
@property(nonatomic, strong) UIPageControl *pageControl;
@property(nonatomic, strong) UIScrollView *scrollView;

@property(nonatomic, copy) NSString *numberMaybeCall;


@end
@implementation CardPackageDetailView

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSLog(@"scrollViewDidEndDecelerating");
    CGFloat pageWidth = CGRectGetWidth(scrollView.frame);
    NSInteger page = floor((scrollView.contentOffset.x -pageWidth/2)/pageWidth) +1;
    self.pageControl.currentPage = page;
}

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
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
        

        CGFloat width = frame.size.width;
        CGFloat height = width /1600*960;
        
        //after 1.0.4

        UIImage* image = [[UIImage alloc]initWithContentsOfFile:[NSString stringWithFormat:@"%@/Documents/%@.jpg",NSHomeDirectory(),strCardID]];
        
        self.cardImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, height)];
        self.cardImageView.backgroundColor = [UIColor darkGrayColor];
        //UIImage *image = [UIImage imageNamed:self.card.pic_name];
        [self.cardImageView setImage:image];
        //[self addSubview:self.cardImageView];
        
        self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, height)];
        //scrollView.backgroundColor = [UIColor redColor];
        // 是否支持滑动最顶端
        //    scrollView.scrollsToTop = NO;
        self.scrollView.delegate = self;
        // 设置内容大小
        self.scrollView.contentSize = CGSizeMake(frame.size.width*2, height);
        // 是否反弹
        self.scrollView.bounces = NO;
        // 是否分页
        self.scrollView.pagingEnabled = YES;
        // 是否滚动
        self.scrollView.scrollEnabled = YES;
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.showsVerticalScrollIndicator = NO;
        self.scrollView.layer.masksToBounds = YES;
        self.scrollView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        self.scrollView.layer.borderWidth = 0.5f;
        
        // 设置indicator风格
        //    scrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
        // 设置内容的边缘和Indicators边缘
        //scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        //    scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 50, 0, 0);
        
        UIView *viewA=[[UIView alloc]initWithFrame:CGRectMake(frame.size.width,0,frame.size.width,height)];
        viewA.backgroundColor=[UIColor grayColor];
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(20, self.scrollView.frame.size.height/2-75 + 40, 80, 65)];
        [imageView setImage:[UIImage imageNamed:@"person_thumb"]];
        [viewA addSubview:imageView];
        
        UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(120, self.scrollView.frame.size.height/2-50, self.scrollView.frame.size.width-120, 20)];
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

        
        [viewA addSubview:nameLabel];
        [viewA addSubview:titleLabel];
        [viewA addSubview:companyLabel];
        [self.scrollView addSubview:viewA];
        
        //UIView * viewB=[[UIView alloc] initWithFrame:CGRectMake(frame.size.width,0,frame.size.width,height)];
        //viewB.backgroundColor=[UIColor yellowColor];
        [self.scrollView addSubview:self.cardImageView];
        
        // 提示用户,Indicators flash
        [self.scrollView flashScrollIndicators];
        // 是否同时运动,lock
        self.scrollView.directionalLockEnabled = YES;
        [self addSubview:self.scrollView];
        
        self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(self.scrollView.frame.size.width-100, self.scrollView.frame.size.height - 40, 100, 40)];
        [self.pageControl setBackgroundColor:[UIColor clearColor]];
        self.pageControl.currentPageIndicatorTintColor = [UIColor grayColor];
        self.pageControl.pageIndicatorTintColor = [UIColor whiteColor];
        self.pageControl.currentPage = 0;
        self.pageControl.numberOfPages = 2;
        [self addSubview:self.pageControl];
        
        self.theTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, height, frame.size.width, frame.size.height-height) style:UITableViewStylePlain];
        self.theTableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        self.theTableView.delegate = self;
        self.theTableView.dataSource = self;
        self.theTableView.bounces = YES;
        self.theTableView.showsVerticalScrollIndicator = YES;
        self.theTableView.rowHeight = 44;
        
        self.updataBackgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, self.theTableView.frame.size.height+height, self.frame.size.width, 45)];
        self.updataBackgroundView.backgroundColor = [UIColor whiteColor];
        [self insertSubview:self.updataBackgroundView aboveSubview:self.theTableView];
        //        [self addSubview:self.updataBackgroundView];
        
        self.updataButton = [[UIButton alloc]initWithFrame:CGRectMake(5, 0, self.updataBackgroundView.frame.size.width/2-10, 40)];
        //self.updataButton = [[UIButton alloc]initWithFrame:CGRectMake(5, 0, self.updataBackgroundView.frame.size.width-10, 40)];
        self.updataButton.layer.masksToBounds = YES;
        self.updataButton.layer.cornerRadius = 2.0f;
        self.updataButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
        self.updataButton.layer.borderWidth = 0.5f;
        [self.updataButton setTitle:@"更新名片" forState:UIControlStateNormal];
        [self.updataButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.updataButton addTarget:self action:@selector(updateCard) forControlEvents:UIControlEventTouchUpInside];
        [self.updataBackgroundView addSubview:self.updataButton];
        
        self.addPropertyButton =[[UIButton alloc]initWithFrame:CGRectMake(self.updataBackgroundView.frame.size.width/2+5, 0, self.updataBackgroundView.frame.size.width/2-10, 40)];
        self.addPropertyButton.layer.cornerRadius = 2.0f;
        self.addPropertyButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
        self.addPropertyButton.layer.borderWidth = 0.5f;
        [self.addPropertyButton setTitle:@"添加属性" forState:UIControlStateNormal];
        [self.addPropertyButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.addPropertyButton addTarget:self action:@selector(addProperty:) forControlEvents:UIControlEventTouchUpInside];
        [self.updataBackgroundView addSubview:self.addPropertyButton];

        
        //        UIButton *addPropertyBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        //        addPropertyBtn.frame = CGRectMake(10, height+2, frame.size.width/2-15, 42);
        //        [addPropertyBtn setTitle:@"添加属性" forState:UIControlStateNormal];
        ////        addPropertyBtn.backgroundColor = [UIColor lightGrayColor];
        //        [addPropertyBtn addTarget:self action:@selector(addProperty:) forControlEvents:UIControlEventTouchUpInside];
        //        [self addSubview:addPropertyBtn];
        
        
        //        UIButton *detelePropertyBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        //        detelePropertyBtn.frame = CGRectMake(frame.size.width/2+5, height+2, frame.size.width/2-15, 42);
        //        [detelePropertyBtn setTitle:@"删除属性" forState:UIControlStateNormal];
        //        [detelePropertyBtn addTarget:self action:@selector(deleteProperty:) forControlEvents:UIControlEventTouchUpInside];
        //        [self addSubview:detelePropertyBtn];
        
        [self addSubview:self.theTableView];
    }
    return self;
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

    
-(void)configCellInfo:(DBCard *)card {
    keys = [[NSMutableArray alloc]init];
    values = [[NSMutableArray alloc]init];
    
    if(self.card.name!=nil){
        NSArray *sep_str = [self.card.name componentsSeparatedByString:kSeparateChar];
        for (NSString *str in sep_str) {
            [keys addObject:@"姓名"];
            [values addObject:str];
        }
    }
    
    if(self.card.mobile!=nil){
        NSArray *sep_str = [self.card.mobile componentsSeparatedByString:kSeparateChar];
        for (NSString *str in sep_str) {
            [keys addObject:@"手机"];
            [values addObject:str];
        }
    }

    if(self.card.company!=nil){
        NSArray *sep_str = [self.card.company componentsSeparatedByString:kSeparateChar];
        for (NSString *str in sep_str) {
            [keys addObject:@"公司"];
            [values addObject:str];
        }
    }

    if(self.card.mail!=nil){
        NSArray *sep_str = [self.card.mail componentsSeparatedByString:kSeparateChar];
        for (NSString *str in sep_str) {
            [keys addObject:@"邮箱"];
            [values addObject:str];
        }
    }
    
    if(self.card.title!=nil){
        NSArray *sep_str = [self.card.title componentsSeparatedByString:kSeparateChar];
        for (NSString *str in sep_str) {
            [keys addObject:@"职称"];
            [values addObject:str];
        }
    }

//    if(self.card.department!=nil){
//        NSArray *sep_str = [self.card.department componentsSeparatedByString:kSeparateChar];
//        for (NSString *str in sep_str) {
//            [keys addObject:@"部门"];
//            [values addObject:str];
//        }
//    }
    
    if(self.card.job_tel!=nil){
        NSArray *sep_str = [self.card.job_tel componentsSeparatedByString:kSeparateChar];
        for (NSString *str in sep_str) {
            [keys addObject:@"固话"];
            [values addObject:str];
        }
    }
    
    if(self.card.fax!=nil){
        NSArray *sep_str = [self.card.fax componentsSeparatedByString:kSeparateChar];
        for (NSString *str in sep_str) {
            [keys addObject:@"传真"];
            [values addObject:str];
        }
    }
    
    if(self.card.address!=nil){
        NSArray *sep_str = [self.card.address componentsSeparatedByString:kSeparateChar];
        for (NSString *str in sep_str) {
            [keys addObject:@"地址"];
            [values addObject:str];
        }
    }
    if(self.card.post_code!=nil){
        NSArray *sep_str = [self.card.post_code componentsSeparatedByString:kSeparateChar];
        for (NSString *str in sep_str) {
            [keys addObject:@"邮编"];
            [values addObject:str];
        }
    }
    if(self.card.url!=nil){
        NSArray *sep_str = [self.card.url componentsSeparatedByString:kSeparateChar];
        for (NSString *str in sep_str) {
            [keys addObject:@"网址"];
            [values addObject:str];
        }
    }
    if(self.card.note!=nil){
        NSArray *sep_str = [self.card.note componentsSeparatedByString:kSeparateChar];
        for (NSString *str in sep_str) {
            [keys addObject:@"备注"];
            [values addObject:str];
        }
    }
    

    
//    if(self.card.home_tel!=nil){
//        NSArray *sep_str = [self.card.home_tel componentsSeparatedByString:kSeparateChar];
//        for (NSString *str in sep_str) {
//            [keys addObject:@"电话"];
//            [values addObject:str];
//        }
//    }
//    
//    if(self.card.post_code!=nil){
//        NSArray *sep_str = [self.card.post_code componentsSeparatedByString:kSeparateChar];
//        for (NSString *str in sep_str) {
//            [keys addObject:@"邮编"];
//            [values addObject:str];
//        }
//    }
//    
//    if(self.card.age!=nil){
//        NSArray *sep_str = [self.card.age componentsSeparatedByString:kSeparateChar];
//        for (NSString *str in sep_str) {
//            [keys addObject:@"年龄"];
//            [values addObject:str];
//        }
//    }
//    
//    if(self.card.date!=nil){
//        NSArray *sep_str = [self.card.date componentsSeparatedByString:kSeparateChar];
//        for (NSString *str in sep_str) {
//            [keys addObject:@"日期"];
//            [values addObject:str];
//        }
//    }
    
//    if(self.card.birthday!=nil){
//        NSArray *sep_str = [self.card.birthday componentsSeparatedByString:kSeparateChar];
//        for (NSString *str in sep_str) {
//            [keys addObject:@"生日"];
//            [values addObject:str];
//        }
//    }
    
    NSMutableDictionary *section_1 = [[NSMutableDictionary alloc]init];
    for (int i=0;i<keys.count;i++) {
        [section_1 setObject:values[i] forKey:keys[i]];
    }
    
    
    NSMutableArray *groupArray = [db QueryGroup];
    
    int gid = [self.card.gid intValue];
    if (gid==0) {
        
        self.groupId = 0;
        self.groupName = @"未分组";
        
    }else{
        
        for (DBGroup *group in groupArray) {
            
            if (group.Id == self.card.gid) {
                self.groupId = self.card.gid;
                self.groupName = group.name;
            }
            
        }
        
    }
    if(self.groupName==nil){
        self.groupName = @"未分组";
        self.groupId = 0;
    }
    NSMutableDictionary *section_2 = [[NSMutableDictionary alloc]init];
    [section_2 setObject:self.groupName forKey:@"分组"];
    
    _dataSourceArr = [[NSMutableArray alloc]init];
    [_dataSourceArr insertObject:section_1 atIndex:0];
    [_dataSourceArr insertObject:section_2 atIndex:1];
}

-(id)initWithFrame:(CGRect)frame andCardModel:(DBCard *)card{
    //after 1.0.4
    strCardID = card.pic_name;
    strName = card.name;
    strTitle = card.title;
    strCompany = card.company;
    self = [self initWithFrame:frame];
    if (self) {
        self.card = card;
    }
    
    db = [[DBOperation alloc]init];
    
    [self configCellInfo:card];
    
    
    
    if (!_isChangedDataSource) {
        
        /*NSArray *section_1 =
         @[
         @{@"姓名":[NSString stringWithFormat:@"%@",self.card.Name],@"keyName":@"Name"},
         @{@"公司":[NSString stringWithFormat:@"%@",self.card.CompanyName] ,@"keyName":@"CompanyName"},
         @{@"职称":[NSString stringWithFormat:@"%@",self.card.Position],@"keyName":@"Postiton"},
         @{@"手机":[NSString stringWithFormat:@"%@",self.card.Mobilphone],@"keyName":@"Mobilphone"},
         @{@"固话":[NSString stringWithFormat:@"%@",self.card.Telephone],@"keyName":@"Telephone"},
         @{@"传真":[NSString stringWithFormat:@"%@",self.card.Fax],@"keyName":@"Fax"},
         @{@"邮箱":[NSString stringWithFormat:@"%@",self.card.Email],@"keyName":@"Email"},
         @{@"地址":[NSString stringWithFormat:@"%@",self.card.Address],@"keyName":@"Address"},
         @{@"备注":[NSString stringWithFormat:@"%@",self.card.Remark],@"keyName":@"Remark"}
         ];
         
         NSArray *section_2 =
         @[@{@"分组":[NSString stringWithFormat:@"%@",self.card.GroupName],@"keyName":@"GroupName"},
         @{@"行业":[NSString stringWithFormat:@"%@",self.card.Industry],@"keyName":@"Industry"},
         @{@"地区":[NSString stringWithFormat:@"%@",self.card.Area],@"keyName":@"Area"}];
         
         NSArray *section_3 =
         @[@{@"":@""}];*/
        
        //_dataSourceArr = @[section_1,section_2,section_3];
        //_isChangedDataSource = YES;
    }
    
    //return _dataSourceArr;
    return self;
}

#pragma mark - UITableView Delegate

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10;
}

#pragma mark - UITableView DataSourceDelegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dataSourceArr.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section==0){
        return keys.count;
    }
    return [_dataSourceArr[section] count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CardDetailViewCellIdentifier = @"CardDetailViewCellIdentifier";
    static NSString *CardDetailCellIdentifier = @"CardDetailCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CardDetailViewCellIdentifier];
    CardDetailCell *cardDetailCell = [tableView dequeueReusableCellWithIdentifier:CardDetailCellIdentifier];
    
    //
    /*if (indexPath.section == self.dataSourceArr.count - 1) {
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CardDetailViewCellIdentifier];
            UILabel *label = [[UILabel alloc]initWithFrame:cell.bounds];
            [label setTextColor:[UIColor lightGrayColor]];
            NSString *text = @"维护人1:,最后维护时间: ";
            
            label.text = text;
            label.font = [UIFont systemFontOfSize:14];
            label.textAlignment = NSTextAlignmentCenter;
            [cell addSubview:label];
        }
        return cell;
    }*/
    
    if (!cardDetailCell) {
        cardDetailCell = [[CardDetailCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CardDetailCellIdentifier];
        cardDetailCell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    NSMutableDictionary *dataArr = self.dataSourceArr[indexPath.section];
    //NSMutableDictionary *dataDic = [dataArr[indexPath.row] mutableCopy];
    //NSArray *keys = [dataArr allKeys];
    //NSString *detailText = [dataArr objectForKey:keys[indexPath.row]];
    if (indexPath.section==0) {
        if (self.isEdittingCard) {
            if ([keys[indexPath.row] isEqualToString:@"姓名"] || [keys[indexPath.row] isEqualToString:@"手机"]||[keys[indexPath.row] isEqualToString:@"公司"])
            {
                NSString *str = [NSString stringWithFormat:@"%@ *",[keys objectAtIndex:indexPath.row]];
                [cardDetailCell setupTitle:str andContent:[values objectAtIndex:indexPath.row]];
            }else{
                [cardDetailCell setupTitle:[keys objectAtIndex:indexPath.row] andContent:[values objectAtIndex:indexPath.row]];
            }
        }else{
           [cardDetailCell setupTitle:[keys objectAtIndex:indexPath.row] andContent:[values objectAtIndex:indexPath.row]];
        }
        
    }else{
        [cardDetailCell setupTitle:@"分组" andContent:[dataArr objectForKey:@"分组"]];
    }
    
    
    if (self.isEdittingCard) {
        cardDetailCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cardDetailCell.accessoryView = nil;
    }
    else{
        cardDetailCell.accessoryType = UITableViewCellAccessoryNone;
        
        if ([keys[indexPath.row] isEqualToString:@"手机"] || [keys[indexPath.row] isEqualToString:@"固话"]) {
            UIImage *img = [UIImage imageNamed:@"call_phone_pressed.png"];
            CGSize originSize = img.size;
            
            //  将图片缩放到理想大小,再绘入cell自带imageView中
            CGSize itemSize = CGSizeMake(originSize.width/4*3, originSize.height/4*3);
            UIGraphicsBeginImageContextWithOptions(itemSize, NO, 0);
            CGRect imageRect = CGRectMake(0, 0, itemSize.width, itemSize.height);
            [img drawInRect:imageRect];
            
            UIImage *newImg = UIGraphicsGetImageFromCurrentImageContext();
            
            UIButton *callbtn = [[UIButton alloc]initWithFrame:imageRect];
            callbtn.tag = indexPath.row;
            callbtn.backgroundColor = [UIColor clearColor];
            [callbtn addTarget:self action:@selector(callByNumber:) forControlEvents:UIControlEventTouchUpInside];
            [callbtn setBackgroundImage:newImg forState:UIControlStateNormal];
            cardDetailCell.accessoryView = callbtn;

            //cardDetailCell.accessoryView = [[UIImageView alloc]initWithImage: UIGraphicsGetImageFromCurrentImageContext()];
            UIGraphicsEndImageContext();
            
        }else{
            cardDetailCell.accessoryView = nil;
        }
    }
    
    
    return cardDetailCell;
    
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        
        return UITableViewCellEditingStyleDelete;
    }else{
        return UITableViewCellEditingStyleNone;
    }
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
//    [tableView setEditing:NO animated:YES];
    if (tableView.editing == YES && editingStyle == UITableViewCellEditingStyleDelete) {
        [keys removeObjectAtIndex:indexPath.row];
        [values removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationTop];
        
        [self updateCard];
        
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.isEdittingCard){
        
        if(groupArray==nil){
            groupArray = [db QueryGroup];
        }
        
        NSMutableDictionary *dataArr = self.dataSourceArr[indexPath.section];
        //NSMutableDictionary *dataDic = [dataArr[indexPath.row] mutableCopy];
        //NSArray *keys = [dataArr allKeys];
        NSString *detailText = [dataArr objectForKey:keys[indexPath.row]];
       
        if (indexPath.section == 1 && [[dataArr.allKeys firstObject] isEqualToString:@"分组"]) {
            if (groupArray.count<=0) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您目前没有自定义分组" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }else{
                CGFloat xWidth = [UIScreen mainScreen].bounds.size.width - 40.0f;
                CGFloat yHeight = 272.0f;
                CGFloat yOffset = ([UIScreen mainScreen].bounds.size.height - yHeight)/2.0f;
                UIPopoverListView *poplistview = [[UIPopoverListView alloc] initWithFrame:CGRectMake(10, yOffset, xWidth, yHeight)];
                poplistview.delegate = self;
                poplistview.datasource = self;
                poplistview.listView.scrollEnabled = TRUE;
                [poplistview setTitle:@"请选择分组"];
                [poplistview show];
            }
        }
        else{
            if ([keys[indexPath.row]isEqualToString: @"分组"]) {
                if (groupArray.count<=0) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您目前没有自定义分组" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                }else{
                    CGFloat xWidth = [UIScreen mainScreen].bounds.size.width - 40.0f;
                    CGFloat yHeight = 272.0f;
                    CGFloat yOffset = ([UIScreen mainScreen].bounds.size.height - yHeight)/2.0f;
                    UIPopoverListView *poplistview = [[UIPopoverListView alloc] initWithFrame:CGRectMake(10, yOffset, xWidth, yHeight)];
                    poplistview.delegate = self;
                    poplistview.datasource = self;
                    poplistview.listView.scrollEnabled = TRUE;
                    [poplistview setTitle:@"请选择分组"];
                    [poplistview show];
                }
                
            }
            else
            {
                currentEditProperty = keys[indexPath.row];
                int keysCount = 0;
                for (int i=0;i<keys.count;i++) {
                    if ([currentEditProperty isEqualToString:keys[i]]) {
                        keysCount ++;
                    }
                }
                
                index = indexPath.row;
                
                CardPackageEditingViewController *nextViewController = [[CardPackageEditingViewController alloc]initWithName:[keys objectAtIndex:indexPath.row] andTargetValue:[values objectAtIndex:indexPath.row] kcount:keysCount];
                //nextViewController.count = count;
                nextViewController.keyCount = keysCount;
                [nextViewController setCompleteOpertion:^(NSString *newValue){
                    values[index] = newValue;
//                    NSMutableDictionary *section_1 = [[NSMutableDictionary alloc]init];
//                    for (int i=0;i<keys.count;i++) {
//                        [section_1 setObject:values[i] forKey:keys[i]];
//                    }
//                    
//                    
//                    //[dataArr setObject:newValue forKey:currentEditProperty];
//                    [self.dataSourceArr setObject:section_1 atIndexedSubscript:0];//更新显示
                    
                    [self.theTableView reloadData];
                    //[self.dataSourceArr[indexPath.row][
                    
                }];
                [nextViewController didDeleteOpertion:^(NSString *newValue) {
                    [values removeObjectAtIndex:index];
                    [keys removeObjectAtIndex:index];
                    
                    [tableView reloadData];
                    [nextViewController.navigationController popViewControllerAnimated:YES];
                }];
                
                [self.parentViewController.navigationController pushViewController:nextViewController animated:YES];
                
            }
            
        }
    }
    
}


-(void)setCardEditting:(BOOL)isEdittingCard{
    self.isEdittingCard = isEdittingCard;
    
    if (self.theTableView.isEditing) {
        [self.theTableView setEditing:NO animated:YES];
    }
    
    CGRect frame = self.theTableView.frame;
    CGRect tFrame = self.updataBackgroundView.frame;
    
    [self bringSubviewToFront:self.updataBackgroundView];
    if (self.isEdittingCard) {
    
        [UIView animateWithDuration:0.2 animations:^{
            self.theTableView.frame =
            CGRectMake(frame.origin.x,
                       frame.origin.y,
                       frame.size.width,
                       frame.size.height-44);
            
            self.updataBackgroundView.frame =
            CGRectMake(tFrame.origin.x,
                       tFrame.origin.y-45,
                       tFrame.size.width,
                       tFrame.size.height);
        }];
    }else{
        
        [UIView animateWithDuration:0.2 animations:^{
            self.theTableView.frame =
            CGRectMake(frame.origin.x,
                       frame.origin.y,
                       frame.size.width,
                       frame.size.height+44);
            self.updataBackgroundView.frame =
            CGRectMake(tFrame.origin.x,
                       tFrame.origin.y+45,
                       tFrame.size.width,
                       tFrame.size.height);
        }];
        
    }
    
    [self.theTableView reloadData];
}

#pragma mark - UIPopoverListViewDataSource

- (UITableViewCell *)popoverListView:(UIPopoverListView *)popoverListView
                    cellForIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cell";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                   reuseIdentifier:identifier];
    
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
    self.groupId = [group.Id intValue];
    self.groupName = group.name;

    NSMutableDictionary *section_2 = [[NSMutableDictionary alloc]init];
    [section_2 setObject:self.groupName forKey:@"分组"];
    
    [self.dataSourceArr setObject:section_2 atIndexedSubscript:1];
    [self.theTableView reloadData];
}

- (CGFloat)popoverListView:(UIPopoverListView *)popoverListView
   heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}


#pragma mark - AlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == kAlertCallNumberTag && buttonIndex == 1) {
        // 拨打电话
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",self.numberMaybeCall]]];
    }
    else if (alertView.tag == 1001 && buttonIndex == 1) {
        // 添加属性
        NSString *key = alertView.message;
        NSString *value = [alertView textFieldAtIndex:0].text;
        
        if (value==nil || [[value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]) {
            [SVProgressHUD showErrorWithStatus:@"无效内容, 无法添加" duration:1];
        }else{
            [keys addObject:key];
            [values addObject:value];
            
            [self.theTableView reloadData];
        }
    }
}

#pragma mark - selector 方法

-(void)callByNumber:(UIButton *)sender{
    NSMutableDictionary *dataArr = self.dataSourceArr[0];
    NSString *key = keys[sender.tag];
    NSString *detailText = [dataArr objectForKey:key];
    
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:key
                                                   message:[NSString stringWithFormat:@"您是否要拨打号码: %@",detailText]
                                                  delegate:self
                                         cancelButtonTitle:@"取消"
                                         otherButtonTitles:@"确定", nil];
    alert.tag = kAlertCallNumberTag;
    
    [alert show];
    
    self.numberMaybeCall = detailText;
}

-(void)updateCard{
    DBCard *card = [[DBCard alloc]init];
    
    for (int i=0; i<keys.count; i++) {
        NSString *key = [keys objectAtIndex:i];
        if ([key isEqualToString:@"姓名"]) {
            card.name = [self parseProperty:card.name appendValue:[values objectAtIndex:i]];
        }
        //        if ([key isEqualToString:@"名字"]) {
        //            card.name = [self parseProperty:card.name appendValue:[values objectAtIndex:i]];
        //        }
        //        else if ([key isEqualToString:@"姓名"]) {
        //            card.sur_name = [self parseProperty:card.sur_name appendValue:[values objectAtIndex:i]];
        //        }else if ([key isEqualToString:@"名称"]) {
        //            card.post_name = [self parseProperty:card.post_name appendValue:[values objectAtIndex:i]];
        //        }
        else if ([key isEqualToString:@"固话"]) {
            card.job_tel = [self parseProperty:card.job_tel appendValue:[values objectAtIndex:i]];
        }else if ([key isEqualToString:@"电话"]) {
            card.home_tel = [self parseProperty:card.home_tel appendValue:[values objectAtIndex:i]];
        }else if ([key isEqualToString:@"传真"]) {
            card.fax = [self parseProperty:card.fax appendValue:[values objectAtIndex:i]];
        }else if ([key isEqualToString:@"手机"]) {
            card.mobile = [self parseProperty:card.mobile appendValue:[values objectAtIndex:i]];
        }else if ([key isEqualToString:@"邮箱"]) {
            card.mail = [self parseProperty:card.mail appendValue:[values objectAtIndex:i]];
        }else if ([key isEqualToString:@"网址"]) {
            card.url = [self parseProperty:card.url appendValue:[values objectAtIndex:i]];
        }else if ([key isEqualToString:@"职称"]) {
            card.title = [self parseProperty:card.title appendValue:[values objectAtIndex:i]];
        }else if ([key isEqualToString:@"公司"]) {
            card.company = [self parseProperty:card.company appendValue:[values objectAtIndex:i]];
        }else if ([key isEqualToString:@"地址"]) {
            card.address = [self parseProperty:card.address appendValue:[values objectAtIndex:i]];
        }else if ([key isEqualToString:@"邮编"]){
            card.note = [self parseProperty:card.note appendValue:[values objectAtIndex:i]];
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
    
    card.Id= self.card.Id;
    //分组信息
    
    card.gid =  [NSNumber numberWithInt:self.groupId];
    
    //名片创建时间
    card.create_time = self.card.create_time;
    card.pic_name = self.card.pic_name;
    
    [db UpdateCard:card];
    
    if (self.isEdittingCard) {
        [self setCardEditting:NO];
    }
    if (self.parentViewController && [self.parentViewController isKindOfClass:[CardDetailViewController class]]) {
        CardDetailViewController *vc = (CardDetailViewController *)self.parentViewController;
        vc.isEdittingCard = NO;
    }
    self.card = card;
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                    message:@"更新成功"
                                                   delegate:nil
                                          cancelButtonTitle:@"确定"
                                          otherButtonTitles:nil];
    [alert show];
    
    [self.theTableView reloadData];
}

-(void)addProperty:(UIButton *)sender{
    CustomOptionView *view = [[CustomOptionView alloc]initWithParams:self.defaultPropertyName defaultSelectIndex:-1];
    [view didSelectIndexPath:^(NSIndexPath *indexPath, NSString *context, NSInteger tag) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"添加属性" message:[NSString stringWithFormat:@"%@",context] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
        alertView.tag = 1001;
        [alertView show];
    }];
}


//-(void)addProperty:(UIButton *)sender{
//    
//    if (self.theTableView.isEditing) {
//        [self.theTableView setEditing:NO animated:YES];
//    }
//    
//    CustomOptionView *view = [[CustomOptionView alloc]initWithParams:self.defaultPropertyName defaultSelectIndex:-1];
//    [view didSelectIndexPath:^(NSIndexPath *indexPath, NSString *context, NSInteger tag) {
//        
//        for (NSString *title in keys) {
//            if ([context isEqualToString:title]) {
//                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"操作失败" message:@"该属性已被添加显示" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
//                [alert show];
//                return;
//            }
//        }
//        
//        if ([context isEqualToString:@"姓名"]) {
//            self.card.name = @"";
//            
//        }else if ([context isEqualToString:@"职称"]){
//            self.card.title = @"";
//        }else if ([context isEqualToString:@"公司"]){
//            self.card.company = @"";
//        }else if ([context isEqualToString:@"邮编"]){
//            self.card.post_code = @"";
//        }else if ([context isEqualToString:@"传真"]){
//            self.card.fax = @"";
//        }else if ([context isEqualToString:@"手机"]){
//            self.card.mobile = @"";
//        }else if ([context isEqualToString:@"固话"]){
//            self.card.job_tel = @"";
//        }else if ([context isEqualToString:@"邮箱"]){
//            self.card.mail = @"";
//        }else if ([context isEqualToString:@"地址"]){
//            self.card.address = @"";
//        }else if ([context isEqualToString:@"备注"]){
//            self.card.note = @"";
//        }
//        
//        [self configCellInfo:self.card];
//        [self updateCard];
//        [self.theTableView reloadData];
//        
//        
//    }];
//}
//-(void)deleteProperty:(UIButton *)sender{
//    [self.theTableView setEditing:!self.theTableView.isEditing animated:YES];
//}
//-(BOOL)checkCard{
//    
//    if (self.card.name == nil || [self.card.name isEqualToString:@""]) {
//        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"警告" message:@"姓名不能为空,请填写完整" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
//        [alertView show];
//        return NO;
//    }
//    if (self.card.company == nil || [self.card.company isEqualToString:@""]) {
//        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"警告" message:@"公司不能为空,请填写完整" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
//        [alertView show];
//        return NO;
//    }
//    
//    if (self.card.mobile == nil || [self.card.mobile isEqualToString:@""]) {
//        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"警告" message:@"手机不能为空,请填写完整" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
//        [alertView show];
//        return NO;
//    }
//    if (self.card.mail == nil || [self.card.mail isEqualToString:@""]) {
//        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"警告" message:@"邮箱不能为空,请填写完整" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
//        [alertView show];
//        return NO;
//    }
//    
//    
//    return YES;
//}
@end
