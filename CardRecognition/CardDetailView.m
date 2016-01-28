//
//  CardDetailView.m
//  CardRecognition
//
//  Created by sunshinek31 on 15/6/4.
//  Copyright (c) 2015年 bournejason. All rights reserved.
//

#import "CardDetailView.h"
#import "CardModel.h"
#import "CardDetailCell.h"
#import "CardEdittingViewController.h"
#import "Base64Data.h"
#import "CustomOptionView.h"
#import "CardHttpRequestService.h"
#import "OtherHttpRequestService.h"
#import "Area.h"
#import "Industry.h"
#import "Cardgroup.h"
#import "RMMapper.h"
#import "JSONKit.h"
#import "ExceptionInfo.h"
#import "CardManageDetailViewController.h"
#import "GroupHttpRequestService.h"
#import "SVProgressHUD.h"
#import "IdentifierValidator.h"
#import "AppConfig.h"

#define kAlertCallNumberTag 1000

@interface CardDetailView ()<UITableViewDataSource, UITableViewDelegate,UIAlertViewDelegate>
@property (nonatomic, strong) UIImageView *cardImageView;
@property (nonatomic, strong) UITableView *theTableView;

@property (nonatomic) BOOL isEdittingCard;

@property (nonatomic, strong) NSArray *dataSourceArr;
@property (nonatomic) BOOL isChangedDataSource;
@property (nonatomic, copy) NSString *currentEdittingPropertyName;

@property(nonatomic, strong) UIView *updataBackgroundView;
@property(nonatomic, strong) UIButton *updataButton;
@property(nonatomic, strong) UIButton *addGroupButton;

@property(nonatomic, copy) NSString *numberMaybeCall;

@property(nonatomic) BOOL hasPlusGroup;
@property(nonatomic, strong) NSArray *allCardTag;
@property(nonatomic, strong) NSMutableDictionary *cardTagStoreDic;
@property(nonatomic, strong) NSMutableDictionary *cardTagNameAndId;
@property(nonatomic, strong) NSMutableDictionary *cardIndexAndTagname;
@property(nonatomic, strong) NSMutableDictionary *cardTagOptionNameAndId;

@property(nonatomic, strong) NSString *tempSaveString;

@property(nonatomic, strong) NSNumber *userid;
@end

@implementation CardDetailView

-(BOOL)isUserLogin{
    
    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
    
    //NSString * username = [defaults objectForKey:@"username"];
    NSString * userid = [defaults objectForKey:@"userid"];

    
    self.userid = [NSNumber numberWithInt:[userid intValue]];
    return YES;
}

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self isUserLogin];
        
        self.cardTagStoreDic = [NSMutableDictionary dictionary];
        self.cardIndexAndTagname = [NSMutableDictionary dictionary];
        self.cardTagNameAndId = [NSMutableDictionary dictionary];
        self.cardTagOptionNameAndId = [NSMutableDictionary dictionary];
        
        CGFloat width = frame.size.width;
        CGFloat height = width /1600*960;
        
        self.cardImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, height)];
        self.cardImageView.backgroundColor = [UIColor darkGrayColor];
        [self addSubview:self.cardImageView];
        
        self.theTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, height, frame.size.width, frame.size.height-height) style:UITableViewStylePlain];
        self.theTableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        self.theTableView.delegate = self;
        self.theTableView.dataSource = self;
        self.theTableView.bounces = NO;
        self.theTableView.showsVerticalScrollIndicator = NO;
        
        //        self.theTableView.estimatedRowHeight = 60;
        self.theTableView.rowHeight = 44;
        
        self.updataBackgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, self.theTableView.frame.size.height+height, self.frame.size.width, 45)];
        self.updataBackgroundView.backgroundColor = [UIColor whiteColor];
        [self insertSubview:self.updataBackgroundView aboveSubview:self.theTableView];
        //        [self addSubview:self.updataBackgroundView];
        
        self.updataButton = [[UIButton alloc]initWithFrame:CGRectMake(5, 0, self.updataBackgroundView.frame.size.width/2-10, 40)];
        
        self.updataButton.layer.masksToBounds = YES;
        self.updataButton.layer.cornerRadius = 2.0f;
        self.updataButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
        self.updataButton.layer.borderWidth = 0.5f;
        [self.updataButton setTitle:@"更新名片" forState:UIControlStateNormal];
        [self.updataButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.updataBackgroundView addSubview:self.updataButton];
        [self.updataButton addTarget:self action:@selector(updateCard:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.theTableView];
        
        self.addGroupButton =[[UIButton alloc]initWithFrame:CGRectMake(self.updataBackgroundView.frame.size.width/2+5, 0, self.updataBackgroundView.frame.size.width/2-10, 40)];
        self.addGroupButton.layer.cornerRadius = 2.0f;
        self.addGroupButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
        self.addGroupButton.layer.borderWidth = 0.5f;
        [self.addGroupButton setTitle:@"添加属性" forState:UIControlStateNormal];
        [self.addGroupButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.updataBackgroundView addSubview:self.addGroupButton];
        [self.addGroupButton addTarget:self action:@selector(addGroupTag:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame andCardModel:(CardModel *)card{
    self = [self initWithFrame:frame];
    if (self) {
        CardHttpRequestService *request = [[CardHttpRequestService alloc]init];
        [SVProgressHUD show];
        [request getBusinessCardById:card.Id success:^(NSString *strToken) {
            [SVProgressHUD dismiss];
            CardModel *card = [[CardModel alloc]initWithString:strToken usingEncoding:NSUTF8StringEncoding error:nil];
            self.card = card;
            if (self.card.CardidPlusattributeofcards != nil) {
                self.hasPlusGroup = YES;
                for (int i = 0; i<self.card.CardidPlusattributeofcards.count; i++) {
                    CardPlus *cardPlus = [self.card.CardidPlusattributeofcards objectAtIndex:i];
                    [self.cardTagStoreDic setObject:cardPlus.OptionValue forKey:cardPlus.TagName];
                    [self.cardIndexAndTagname setObject:cardPlus.TagName forKey:@(i)];
                    [self.cardTagNameAndId setObject:cardPlus.Tagid forKey:cardPlus.TagName];
                    [self.cardTagOptionNameAndId setObject:cardPlus.Id forKey:cardPlus.OptionValue];
                    
                }
                
                //                for (CardPlus *cardPlus in self.card.CardidPlusattributeofcards) {
                //                    [self.cardTagStoreDic setObject:cardPlus.OptionValue forKey:cardPlus.TagName];
                //                }
            }
            NSLog(@"%@",card);
            NSString *base64ImageString = self.card.Base64Image;
            if (base64ImageString!=nil) {
                NSData *imageData = [[NSData alloc]initWithBase64Encoding:base64ImageString];
                //NSData *imageData = [NSData dataFromBase64String:base64ImageString];
                UIImage *image = [UIImage imageWithData:imageData];
                self.cardImageView.image = image;
            }
            
            
            self.isChangedDataSource = YES;
            
            [self.theTableView reloadData];
        } error:^(NSString *strFail) {
            [SVProgressHUD dismiss];
        }];
        
        
        
    }
    return self;
}

-(NSArray *)dataSourceArr{
    
    if (_isChangedDataSource) {
        NSMutableArray *section_1 = [NSMutableArray array];
        if (self.card.Name) {
            NSArray *sep_str = [self.card.Name componentsSeparatedByString:kSeparateChar];
            for (NSString *str in sep_str) {
                [section_1 addObject:@{@"姓名":str,@"keyName":@"Name"}];
            }
        }
        if (self.card.Mobilphone) {
            NSArray *sep_str = [self.card.Mobilphone componentsSeparatedByString:kSeparateChar];
            for (NSString *str in sep_str) {
                [section_1 addObject:@{@"手机":str,@"keyName":@"Mobilphone"}];
            }
        }
        if (self.card.CompanyName) {
            NSArray *sep_str = [self.card.CompanyName componentsSeparatedByString:kSeparateChar];
            for (NSString *str in sep_str) {
                [section_1 addObject:@{@"公司":str ,@"keyName":@"CompanyName"}];
            }
        }
        if (self.card.Email) {
            NSArray *sep_str = [self.card.Email componentsSeparatedByString:kSeparateChar];
            for (NSString *str in sep_str) {
                [section_1 addObject:@{@"邮箱":str,@"keyName":@"Email"}];
            }
        }
        if (self.card.Position) {
            NSArray *sep_str = [self.card.Position componentsSeparatedByString:kSeparateChar];
            for (NSString *str in sep_str) {
                [section_1 addObject:@{@"职称":str,@"keyName":@"Postiton"}];
            }
        }
        if (self.card.Telephone) {
            NSArray *sep_str = [self.card.Telephone componentsSeparatedByString:kSeparateChar];
            for (NSString *str in sep_str) {
                [section_1 addObject:@{@"固话":str,@"keyName":@"Telephone"}];
            }
        }
        if (self.card.Fax) {
            NSArray *sep_str = [self.card.Fax componentsSeparatedByString:kSeparateChar];
            for (NSString *str in sep_str) {
                [section_1 addObject:@{@"传真":str,@"keyName":@"Fax"}];
            }
        }
        if (self.card.Address) {
            NSArray *sep_str = [self.card.Address componentsSeparatedByString:kSeparateChar];
            for (NSString *str in sep_str) {
                [section_1 addObject:@{@"地址":str,@"keyName":@"Address"}];
            }
        }
        if (self.card.Remark) {
            NSArray *sep_str = [self.card.Remark componentsSeparatedByString:kSeparateChar];
            for (NSString *str in sep_str) {
                [section_1 addObject:@{@"备注":str,@"keyName":@"Remark"}];
            }
        }
        
        NSArray *section_2 =
  @[@{@"分组":[NSString stringWithFormat:@"%@",self.card.GroupName],@"keyName":@"GroupName"},
    @{@"行业":[NSString stringWithFormat:@"%@",self.card.IndustryName],@"keyName":@"Industry"},
    @{@"地区":[NSString stringWithFormat:@"%@",self.card.AreaName],@"keyName":@"Area"}];
        
        NSArray *section_3 =
        @[@{@"":@""}];
        
        
        NSMutableArray *sourceArr = [NSMutableArray array];
        [sourceArr addObject:section_1];
        [sourceArr addObject:section_2];
        
        if (self.hasPlusGroup) {
            
            NSMutableArray *section_plus = [NSMutableArray array];
            [self.cardIndexAndTagname enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, NSString *obj, BOOL *stop) {
                
                NSString *value = [self.cardTagStoreDic objectForKey:obj];
                
                NSDictionary *taridCardtagvalue = @{obj:[NSString stringWithFormat:@"%@",value],@"keyName":obj};
                
                [section_plus addObject:taridCardtagvalue];
            }];
            
            [sourceArr insertObject:section_plus atIndex:2];
            
        }
        
        [sourceArr addObject:section_3];
        
        _dataSourceArr = [NSArray arrayWithArray:sourceArr];
        _isChangedDataSource = NO;
    }
    
    return _dataSourceArr;
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
    return [_dataSourceArr[section] count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CardDetailViewCellIdentifier = @"CardDetailViewCellIdentifier";
    static NSString *CardDetailCellIdentifier = @"CardDetailCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CardDetailViewCellIdentifier];
    CardDetailCell *cardDetailCell = [tableView dequeueReusableCellWithIdentifier:CardDetailCellIdentifier];
    
    
    //
    if (indexPath.section == self.dataSourceArr.count - 1) {
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CardDetailViewCellIdentifier];
            UILabel *label = [[UILabel alloc]initWithFrame:cell.bounds];
            [label setTextColor:[UIColor lightGrayColor]];
            NSString *text = @"维护人1:,最后维护时间: ";
            text = [NSString stringWithFormat:@"维护人:%@,最后维护时间:%@",self.card.Maintenanceuser,self.card.Createtime];
            
            label.text = text;
            label.font = [UIFont systemFontOfSize:14];
            label.textAlignment = NSTextAlignmentCenter;
            [cell addSubview:label];
        }
        return cell;
    }
    
    
    //
    if (!cardDetailCell) {
        cardDetailCell = [[CardDetailCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CardDetailCellIdentifier];
    }
    
    
    NSArray *dataArr = self.dataSourceArr[indexPath.section];
    NSMutableDictionary *dataDic = [dataArr[indexPath.row] mutableCopy];
    [dataDic removeObjectForKey:@"keyName"];
    NSString *text = dataDic.allKeys.firstObject;
    NSString *detailText = [dataDic objectForKey:text];
    
    if([detailText isEqualToString:@"(null)"]){
        detailText = @"";
    }
    
    [cardDetailCell setupTitle:text andContent:detailText];
    
    
    if (self.isEdittingCard) {
        cardDetailCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cardDetailCell.accessoryView = nil;
    }else{
        cardDetailCell.accessoryType = UITableViewCellAccessoryNone;
        
        if ([text isEqualToString:@"手机"] || [text isEqualToString:@"固话"]) {
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
            UIGraphicsEndImageContext();
            
        }else{
            cardDetailCell.accessoryView = nil;
        }
    }
    
    
    return cardDetailCell;
    
}

-(void)callByNumber:(UIButton *)sender{
    NSArray *dataArr = self.dataSourceArr[0];
    NSMutableDictionary *dataDic = [dataArr[sender.tag] mutableCopy];
    [dataDic removeObjectForKey:@"keyName"];
    NSString *text = dataDic.allKeys.firstObject;
    NSString *detailText = [dataDic objectForKey:text];
    
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:text
                                                   message:[NSString stringWithFormat:@"您是否要拨打号码: %@",detailText]
                                                  delegate:self
                                         cancelButtonTitle:@"取消"
                                         otherButtonTitles:@"确定", nil];
    alert.tag = kAlertCallNumberTag;
    
    [alert show];
    
    self.numberMaybeCall = detailText;
    
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.isEdittingCard){
        
        NSArray *dataArr = self.dataSourceArr[indexPath.section];
        NSMutableDictionary *dataDic = [dataArr[indexPath.row] mutableCopy];
        
        self.currentEdittingPropertyName = [dataDic objectForKey:@"keyName"];
        NSLog(@"当前编辑的属性名: %@",self.currentEdittingPropertyName);
        
        [dataDic removeObjectForKey:@"keyName"];
        
        NSString *text = dataDic.allKeys.firstObject;
        NSString *detailText = [dataDic objectForKey:text];
        
        if ([text isEqualToString:@"分组"]) {
            [self chooseGroup];
            return;
        }else if ([text isEqualToString:@"行业"]){
            [self chooseIndustry];
            return;
        }else if ([text isEqualToString:@"地区"]){
            [self chooseArea];
            return;
        }else if ([self.cardTagStoreDic.allKeys containsObject:text]){
            [self chooseValueOfCardPlus:text index:indexPath.row];
            return;
        }
        
        
        
        CardEdittingViewController *nextViewController = [[CardEdittingViewController alloc]initWithName:text andTargetValue:detailText];
        [nextViewController setCompleteOpertion:^(NSString *name, NSString *newValue) {
            [self changeCardValueWithName:name newValue:newValue];
        }];
        [nextViewController didDeleteBtnPressed:^(NSString *name, NSString *newValue) {
            [self changeCardValueWithName:text newValue:nil];
//            self.isChangedDataSource = YES;
            [nextViewController.navigationController popViewControllerAnimated:YES];
        }];
        
        self.tempSaveString = detailText;
        
        [self.parentViewController.navigationController pushViewController:nextViewController animated:YES];
    }
    
}

-(void)changeCardValueWithName:(NSString *)name
                      newValue:(NSString *)newValue
{
    if ([name isEqualToString:@"姓名"]) {
        NSMutableArray *sep_str = [[self.card.Name componentsSeparatedByString:kSeparateChar] mutableCopy];
        for (int i=0;i<sep_str.count;i++){
            NSString *str = sep_str[i];
            if ([str isEqualToString:self.tempSaveString]) {
                if (newValue==nil) { //delete
                    [sep_str removeObject:self.tempSaveString];
                }else{ //modify
                    [sep_str replaceObjectAtIndex:i withObject:newValue];
                }
            }
        }
        self.card.Name = [sep_str componentsJoinedByString:@"|"];
    }
    else if ([name isEqualToString:@"公司"]){
        NSMutableArray *sep_str = [[self.card.CompanyName componentsSeparatedByString:kSeparateChar] mutableCopy];
        for (int i=0;i<sep_str.count;i++){
            NSString *str = sep_str[i];
            if ([str isEqualToString:self.tempSaveString]) {
                if (newValue==nil) { //delete
                    [sep_str removeObject:self.tempSaveString];
                }else{ //modify
                    [sep_str replaceObjectAtIndex:i withObject:newValue];
                }
            }
        }
        self.card.CompanyName = [sep_str componentsJoinedByString:@"|"];
    }
    else if ([name isEqualToString:@"职称"]){
        NSMutableArray *sep_str = [[self.card.Position componentsSeparatedByString:kSeparateChar] mutableCopy];
        for (int i=0;i<sep_str.count;i++){
            NSString *str = sep_str[i];
            if ([str isEqualToString:self.tempSaveString]) {
                if (newValue==nil) { //delete
                    [sep_str removeObject:self.tempSaveString];
                }else{ //modify
                    [sep_str replaceObjectAtIndex:i withObject:newValue];
                }
            }
        }
        
        self.card.Position = [sep_str componentsJoinedByString:@"|"];
    }
    else if ([name isEqualToString:@"手机"]){
        NSMutableArray *sep_str = [[self.card.Mobilphone componentsSeparatedByString:kSeparateChar] mutableCopy];
        for (int i=0;i<sep_str.count;i++){
            NSString *str = sep_str[i];
            if ([str isEqualToString:self.tempSaveString]) {
                if (newValue==nil) { //delete
                    [sep_str removeObject:self.tempSaveString];
                }else{ //modify
                    [sep_str replaceObjectAtIndex:i withObject:newValue];
                }
            }
        }
        
        self.card.Mobilphone = [sep_str componentsJoinedByString:@"|"];
    }else if ([name isEqualToString:@"固话"]){
        NSMutableArray *sep_str = [[self.card.Telephone componentsSeparatedByString:kSeparateChar] mutableCopy];
        for (int i=0;i<sep_str.count;i++){
            NSString *str = sep_str[i];
            if ([str isEqualToString:self.tempSaveString]) {
                if (newValue==nil) { //delete
                    [sep_str removeObject:self.tempSaveString];
                }else{ //modify
                    [sep_str replaceObjectAtIndex:i withObject:newValue];
                }
            }
        }
        
        self.card.Telephone = [sep_str componentsJoinedByString:@"|"];
    }else if ([name isEqualToString:@"传真"]){
        NSMutableArray *sep_str = [[self.card.Fax componentsSeparatedByString:kSeparateChar] mutableCopy];
        for (int i=0;i<sep_str.count;i++){
            NSString *str = sep_str[i];
            if ([str isEqualToString:self.tempSaveString]) {
                if (newValue==nil) { //delete
                    [sep_str removeObject:self.tempSaveString];
                }else{ //modify
                    [sep_str replaceObjectAtIndex:i withObject:newValue];
                }
            }
        }
        
        self.card.Fax = [sep_str componentsJoinedByString:@"|"];
    }else if ([name isEqualToString:@"邮箱"]){
        NSMutableArray *sep_str = [[self.card.Email componentsSeparatedByString:kSeparateChar] mutableCopy];
        for (int i=0;i<sep_str.count;i++){
            NSString *str = sep_str[i];
            if ([str isEqualToString:self.tempSaveString]) {
                if (newValue==nil) { //delete
                    [sep_str removeObject:self.tempSaveString];
                }else{ //modify
                    [sep_str replaceObjectAtIndex:i withObject:newValue];
                }
            }
        }
        
        self.card.Email = [sep_str componentsJoinedByString:@"|"];
    }else if ([name isEqualToString:@"地址"]){
        NSMutableArray *sep_str = [[self.card.Address componentsSeparatedByString:kSeparateChar] mutableCopy];
        for (int i=0;i<sep_str.count;i++){
            NSString *str = sep_str[i];
            if ([str isEqualToString:self.tempSaveString]) {
                if (newValue==nil) { //delete
                    [sep_str removeObject:self.tempSaveString];
                }else{ //modify
                    [sep_str replaceObjectAtIndex:i withObject:newValue];
                }
            }
        }
        
        self.card.Address = [sep_str componentsJoinedByString:@"|"];
    }else if ([name isEqualToString:@"备注"]){
        NSMutableArray *sep_str = [[self.card.Remark componentsSeparatedByString:kSeparateChar] mutableCopy];
        for (int i=0;i<sep_str.count;i++){
            NSString *str = sep_str[i];
            if ([str isEqualToString:self.tempSaveString]) {
                if (newValue==nil) { //delete
                    [sep_str removeObject:self.tempSaveString];
                }else{ //modify
                    [sep_str replaceObjectAtIndex:i withObject:newValue];
                }
            }
        }
        
        self.card.Remark = [sep_str componentsJoinedByString:@"|"];
    }
    
    self.isChangedDataSource = YES;
    [self.theTableView reloadData];
}

//-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
//    if (section == self.dataSourceArr.count - 1 ) {
//        return 44;
//    }else{
//        return 0;
//    }
//}
//-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
//    UIView *view;
//
//    if (section == self.dataSourceArr.count - 1 ) {
//
//    }
//
//    return view;
//}

-(void)setCardEditting:(BOOL)isEdittingCard{
    self.isEdittingCard = isEdittingCard;
    
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

#pragma mark - 分组选择

-(void)chooseGroup{
    OtherHttpRequestService *request = [[OtherHttpRequestService alloc]init];
    
    [request getGroupByUserId:self.userid success:^(NSString *strToken) {
        NSLog(@"%@",strToken);
        
        NSData *data = [strToken dataUsingEncoding:NSUTF8StringEncoding];
        NSArray *dataArr = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        NSMutableArray *groupArr = [NSMutableArray array];
        NSMutableArray *nameArr = [NSMutableArray array];
        for (NSDictionary *dic in dataArr) {
            Cardgroup *obj = [RMMapper objectWithClass:[Cardgroup class] fromDictionary:dic];
            NSString *name = [NSString stringWithFormat:@"%@",obj.Name];
            [nameArr addObject:name];
            [groupArr addObject:obj];
        }
        
        CustomOptionView *view = [[CustomOptionView alloc]initWithParams:nameArr defaultSelectIndex:-1];
        [view didSelectIndexPath:^(NSIndexPath *indexPath, NSString *context, NSInteger tag) {
            
            Cardgroup *obj = groupArr[indexPath.row];
            self.card.GroupName = context;
            self.card.Gourpid = obj.Id;
            
            self.isChangedDataSource = YES;
            [self.theTableView reloadData];
            
        }];
    } error:^(NSString *strFail) {
        
    }];
}

#pragma mark - 行业选择

-(void)chooseIndustry{
    OtherHttpRequestService *request = [[OtherHttpRequestService alloc]init];
    [request getAllIndustry:^(NSString *strToken) {
        NSLog(@"%@",strToken);
        
        NSData *data = [strToken dataUsingEncoding:NSUTF8StringEncoding];
        NSArray *dataArr = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        NSMutableArray *industryArr = [NSMutableArray array];
        NSMutableArray *nameArr = [NSMutableArray array];
        for (NSDictionary *dic in dataArr) {
            Industry *industryObj = [RMMapper objectWithClass:[Industry class] fromDictionary:dic];
            NSString *word = [NSString stringWithFormat:@"%@",industryObj.Words];
            [nameArr addObject:word];
            [industryArr addObject:industryObj];
        }
        
        CustomOptionView *view = [[CustomOptionView alloc]initWithParams:nameArr defaultSelectIndex:-1];
        [view didSelectIndexPath:^(NSIndexPath *indexPath, NSString *context, NSInteger tag) {
            
            Industry *obj = industryArr[indexPath.row];
            
            self.card.IndustryName = context;
            self.card.Industryid = obj.Id;
            self.isChangedDataSource = YES;
            [self.theTableView reloadData];
            
        }];
        
        
    } error:^(NSString *strFail) {
        
    }];
}

#pragma mark - 地区选择

-(void)chooseArea{
    OtherHttpRequestService *request = [[OtherHttpRequestService alloc]init];
    [request getAllCardTag:^(NSString *strToken) {
        NSLog(@"%@",strToken);
        NSData *data = [strToken dataUsingEncoding:NSUTF8StringEncoding];
        NSArray *dataArr = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        NSMutableArray *areaArr = [NSMutableArray array];
        NSMutableArray *nameArr = [NSMutableArray array];
        for (NSDictionary *dic in dataArr) {
            Area *areaObj = [RMMapper objectWithClass:[Area class] fromDictionary:dic];
            NSString *word = [NSString stringWithFormat:@"%@",areaObj.Words];
            [nameArr addObject:word];
            [areaArr addObject:areaObj];
        }
        
        CustomOptionView *view = [[CustomOptionView alloc]initWithParams:nameArr defaultSelectIndex:-1];
        [view didSelectIndexPath:^(NSIndexPath *indexPath, NSString *context, NSInteger tag) {
            
            Area *obj = areaArr[indexPath.row];
            
            self.card.AreaName = context;
            self.card.Areaid = obj.Id;
            self.isChangedDataSource = YES;
            [self.theTableView reloadData];
        }];
        
        
    } error:^(NSString *strFail) {
        
    }];
}

#pragma mark - 更新名片信息

-(void)updateCard:(UIButton *)sender{
    CardHttpRequestService *request = [[CardHttpRequestService alloc]init];
    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
    NSString *username = [defaults objectForKey:@"username"];//根据键值取出name
    NSString *userid = [defaults objectForKey:@"userid"];//根据键值取出id
    
    self.card.Createuser = userid;
    self.card.Maintenanceuser = userid;
    
    NSMutableArray *cardPlusArr = [NSMutableArray array];
    
    //名片属性检查
    if([self.card.Name isEqualToString:@""]||self.card.Name==nil){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"姓名不能为空" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    if([self.card.Mobilphone isEqualToString:@""]||self.card.Mobilphone==nil){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"手机不能为空" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    //电话
    /*if (self.card.Telephone!=nil) {
        BOOL isValid = [IdentifierValidator isValid:IdentifierTypePhone value:self.card.Telephone];
        if (!isValid) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"固话格式不正确" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            return;
        }
    }*/
    
    //手机
    /*if (self.card.Mobilphone!=nil) {
        BOOL isValid = [IdentifierValidator isValid:IdentifierTypeMobilePhone value:self.card.Mobilphone];
        if (!isValid) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"手机号码格式不正确" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            return;
        }
    }*/
    
    //邮箱
    /*if (self.card.Email!=nil) {
        BOOL isValid = [IdentifierValidator isValid:IdentifierTypeEmail value:self.card.Email];
        if (!isValid) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"邮箱格式不正确" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            return;
        }
    }*/
    
    
    [self.cardIndexAndTagname enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, NSString *obj, BOOL *stop) {
        
        NSString *value = [self.cardTagStoreDic objectForKey:obj];//optionName
        NSNumber *tagid = [self.cardTagNameAndId objectForKey:obj];
        NSNumber *optionid = [self.cardTagOptionNameAndId objectForKey:value];
        
        CardPlus *cardplus = [[CardPlus alloc]init];
        cardplus.Tagid = tagid;
        cardplus.Cardid = self.card.Id;
        cardplus.Optionid = optionid;
        
        
//        NSDictionary *attributeDic =
//        @{@"Tagid":tagid,
//          @"Cardid":self.card.Id,
//          @"Optionid":optionid
//          };
//        [cardPlusArr addObject:attributeDic];
        [cardPlusArr addObject:cardplus];
    }];
    
    self.card.CardidPlusattributeofcards = cardPlusArr;
    
    [request addBusinessCardByItem:self.card success:^(NSString *strToken) {
        NSLog(@"%@",strToken);
        
        NSData *data = [strToken dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        ExceptionInfo *info = [RMMapper objectWithClass:[ExceptionInfo class] fromDictionary:dict];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:[NSString stringWithFormat:@"%@",info.Info]
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        
        [alert show];
        if ([info.Result intValue] > 0) {
            [self setCardEditting:NO];
            if ([self.parentViewController isKindOfClass:[CardManageDetailViewController class]]) {
                CardManageDetailViewController *vc = (CardManageDetailViewController *)self.parentViewController;
                vc.isEdittingCard = NO;
            }
        }
    } error:^(NSString *strFail) {
        
    }];
}

#pragma mark -

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == kAlertCallNumberTag && buttonIndex == 1) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",self.numberMaybeCall]]];
    }
}

-(void)addGroupTag:(UIButton *)sender
{
    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
    NSString *username = [defaults objectForKey:@"username"];//根据键值取出name
    NSString *userid = [defaults objectForKey:@"userid"];//根据键值取出id
    
    
    GroupHttpRequestService *request = [[GroupHttpRequestService alloc]init];
    [request getAllCardTag:^(NSArray *allCardTag) {
        self.allCardTag = allCardTag;
        NSMutableArray *nameArr = [NSMutableArray array];
        for (int i = 0; i < allCardTag.count; i++) {
            CardTag *cardTag = allCardTag[i];
            NSString *name = cardTag.Tagname;
            [nameArr addObject:name];
        }
        
        CustomOptionView *option = [[CustomOptionView alloc]initWithParams:nameArr defaultSelectIndex:-1];
        [option didSelectIndexPath:^(NSIndexPath *indexPath, NSString *context, NSInteger tag) {
            
            if ([self.cardTagStoreDic.allKeys containsObject:context]) {
                NSLog(@"重复属性");
                return ;
            }
            CardTag *cardTag = allCardTag[indexPath.row];
            //            TagidCardtagvalue *value = [[TagidCardtagvalue alloc]init];
            //            value.Optionvalue = @"";
            
            [self.cardTagStoreDic setObject:@"" forKey:context];
            [self.cardIndexAndTagname setObject:context forKey:@(indexPath.row)];
            [self.cardTagNameAndId setObject:cardTag.Id forKey:context];
            
            self.isChangedDataSource = YES;
            self.hasPlusGroup = YES;
            [self.theTableView reloadData];
        }];
        
    } error:^(NSString *strFail) {
        
    }];
    
}

-(void)chooseValueOfCardPlus:(NSString *)name index:(NSUInteger)index{
    
    NSLog(@"选择属性");
    
    __block NSArray *tagidCardtagvalues = [NSArray array];
    
    NSNumber *tagid = [self.cardTagNameAndId objectForKey:name];
    
    GroupHttpRequestService *request = [[GroupHttpRequestService alloc]init];
    [request getCardTagById:tagid success:^(CardTag *cardTag) {
        tagidCardtagvalues = cardTag.TagidCardtagvalues;
        
        NSMutableArray *nameArr = [NSMutableArray array];
        for (TagidCardtagvalue *tagidcardtag in tagidCardtagvalues) {
            [nameArr addObject:tagidcardtag.Optionvalue];
        }
        
        CustomOptionView *option = [[CustomOptionView alloc]initWithParams:nameArr defaultSelectIndex:-1];
        [option didSelectIndexPath:^(NSIndexPath *indexPath, NSString *context, NSInteger tag) {
            TagidCardtagvalue *optin = tagidCardtagvalues[indexPath.row];
            
            NSString *cardPlusName = name;
            [self.cardTagStoreDic setObject:context forKey:cardPlusName];
            [self.cardTagOptionNameAndId setObject:optin.Id forKey:context];
            self.isChangedDataSource = YES;
            [self.theTableView reloadData];
        }];
        
        
    } error:^(NSString *strFail) {
        
    }];
    
    
    
}

@end
