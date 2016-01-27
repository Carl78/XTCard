//
//  CardMineAndSearchDetailView.m
//  CardRecognition
//
//  Created by bournejason on 15/6/11.
//  Copyright (c) 2015年 bournejason. All rights reserved.
//

#import "CardMineAndSearchDetailView.h"
#import "CardModel.h"
#import "CardDetailCell.h"
#import "CardPackageEditingViewController.h"
#import "CardHttpRequestService.h"
#import "Base64Data.h"
#import "AppConfig.h"
#import "SVProgressHUD.h"

#define kAlertCallNumberTag 1000


@interface CardMineAndSearchDetailView ()<UITableViewDataSource, UITableViewDelegate,UIAlertViewDelegate>
@property (nonatomic, strong) UIImageView *cardImageView;
@property (nonatomic, strong) UITableView *theTableView;

@property (nonatomic) BOOL isEdittingCard;

@property (nonatomic, strong) NSArray *dataSourceArr;
@property (nonatomic) BOOL isChangedDataSource;
@property (nonatomic, copy) NSString *currentEdittingPropertyName;

@property(nonatomic, strong) UIView *updataBackgroundView;
@property(nonatomic, strong) UIButton *updataButton;

@property(nonatomic, copy) NSString *numberMaybeCall;


@property(nonatomic) BOOL hasPlusGroup;
@property(nonatomic, strong) NSArray *allCardTag;
@property(nonatomic, strong) NSMutableDictionary *cardTagStoreDic;
@property(nonatomic, strong) NSMutableDictionary *cardTagNameAndId;
@property(nonatomic, strong) NSMutableDictionary *cardIndexAndTagname;
@property(nonatomic, strong) NSMutableDictionary *cardTagOptionNameAndId;
@end
@implementation CardMineAndSearchDetailView
-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
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
        
        self.updataButton = [[UIButton alloc]initWithFrame:CGRectMake(5, 0, self.updataBackgroundView.frame.size.width-10, 40)];
        
        self.updataButton.layer.masksToBounds = YES;
        self.updataButton.layer.cornerRadius = 2.0f;
        self.updataButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
        self.updataButton.layer.borderWidth = 0.5f;
        [self.updataButton setTitle:@"更新名片" forState:UIControlStateNormal];
        [self.updataButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.updataBackgroundView addSubview:self.updataButton];
        
        [self addSubview:self.theTableView];
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame andCardModel:(CardModel *)card{
    self = [self initWithFrame:frame];
    if (self) {
        [SVProgressHUD show];
        CardHttpRequestService *request = [[CardHttpRequestService alloc]init];
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
            NSData *imageData = [NSData dataFromBase64String:base64ImageString];
            UIImage *image = [UIImage imageWithData:imageData];
            self.cardImageView.image = image;
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
          ];*/
        
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
    
    if ([detailText isEqualToString:@"(null)"]) {
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

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.isEdittingCard){
        
        NSArray *dataArr = self.dataSourceArr[indexPath.section];
        NSMutableDictionary *dataDic = [dataArr[indexPath.row] mutableCopy];
        
        self.currentEdittingPropertyName = [dataDic objectForKey:@"keyName"];
        NSLog(@"当前编辑的属性名: %@",self.currentEdittingPropertyName);
        
        [dataDic removeObjectForKey:@"keyName"];
        
        NSString *text = dataDic.allKeys.firstObject;
        NSString *detailText = [dataDic objectForKey:text];
        
        
        
        
        
        CardPackageEditingViewController *nextViewController = [[CardPackageEditingViewController alloc]initWithName:text andTargetValue:detailText kcount:0];
        [self.parentViewController.navigationController pushViewController:nextViewController animated:YES];
    }
    
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

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == kAlertCallNumberTag && buttonIndex == 1) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",self.numberMaybeCall]]];
    }
}

@end
