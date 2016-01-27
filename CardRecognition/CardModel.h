//
//  CardModel.h
//  CardRecognition
//
//  Created by bournejason on 15/6/2.
//  Copyright (c) 2015年 bournejason. All rights reserved.
//

#import "JSONModel.h"
@protocol CardModel <NSObject>

@end
@protocol CardPlus <NSObject>

@end
@interface CardPlus : JSONModel
@property (strong,nonatomic) NSNumber<Optional> *Cardid;
@property (strong,nonatomic) NSString<Optional> *CardBusinesscard;
@property (strong,nonatomic) NSString<Optional> *Createtime;
@property (strong,nonatomic) NSNumber<Optional> *Id;
@property (strong,nonatomic) NSNumber<Optional> *Optionid;
@property (strong,nonatomic) NSNumber<Optional> *Tagid;
@property (strong,nonatomic) NSString<Optional> *TagName;
@property (strong,nonatomic) NSString<Optional> *OptionValue;

@end
@interface CardModel : JSONModel
@property (strong,nonatomic) NSString<Optional> *Address;//地址
@property (strong,nonatomic) NSString<Optional> *Area;//地区对象
@property (strong,nonatomic) NSString<Optional> *AreaName;
@property (strong,nonatomic) NSNumber<Optional> *Areaid;//地区id
@property (strong,nonatomic) NSString<Optional> *Base64Image;
@property (strong,nonatomic) NSArray<CardPlus> *CardidPlusattributeofcards;//与当前名片相关自定义属性信息
@property (strong,nonatomic) NSString<Optional> *Cardimg;//名片图像
@property (strong,nonatomic) NSString<Optional> *CloseValue;//用户与名片的亲密度值
@property (strong,nonatomic) NSString<Optional> *CompanyName;//公司名称
@property (strong,nonatomic) NSNumber<Optional> *Companyid;//公司id(只作为查询用)
@property (strong,nonatomic) NSString<Optional> *CompanyidCustomercompany;//公司实体对象
@property (strong,nonatomic) NSString<Optional> *Createtime;//创建时间
@property (strong,nonatomic) NSString<Optional> *Createuser;//区域对象创建人
@property (strong,nonatomic) NSString<Optional> *Email;
@property (strong,nonatomic) NSString<Optional> *Fax;
@property (strong,nonatomic) NSNumber<Optional> *Gourpid;//所属分组的id
@property (strong,nonatomic) NSString<Optional> *GourpidCardgroup;//分组对象
@property (strong,nonatomic) NSString<Optional> *GroupName;
@property (strong,nonatomic) NSString<Optional> *Guid;//对象的唯一guid编号
@property (strong,nonatomic) NSString<Optional> *HasShare;

@property (strong,nonatomic) NSNumber<Optional> *Id;//名片的id
@property (strong,nonatomic) NSString<Optional> *Industry;//所属行业的对象
@property (strong,nonatomic) NSNumber<Optional> *Industryid;//所属行业的id
@property (strong,nonatomic) NSString<Optional> *IndustryName;
@property (strong,nonatomic) NSString<Optional> *Ischecked;//是否选中
@property (strong,nonatomic) NSString<Optional> *MainName;//维护人姓名
@property (strong,nonatomic) NSString<Optional> *Maintenanceuser;//维护人编号
@property (strong,nonatomic) NSString<Optional> *Mobilphone;//手机号码
@property (strong,nonatomic) NSString<Optional> *Modifiedtime;//修改时间
@property (strong,nonatomic) NSString<Optional> *Name;//名片名称
@property (strong,nonatomic) NSString<Optional> *Position;//职务
@property (strong,nonatomic) NSString<Optional> *Remark;//备注
@property (strong,nonatomic) NSString<Optional> *State;//状态id
@property (strong,nonatomic) NSString<Optional> *StateCardstate;//状态对象
@property (strong,nonatomic) NSString<Optional> *Telephone;//电话号码
@property (strong,nonatomic) NSNumber<Optional> *syncState;//(只作为同步使用)
@end
