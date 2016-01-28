//
//  CardAddViewController.m
//  CardRecognition
//  新增名片视图控制器
//  Created by bournejason on 15/5/5.
//  Copyright (c) 2015年 bournejason. All rights reserved.
//

#import "CardAddViewController.h"
#import "MFSideMenu.h"
#import "ManualAddCardTableViewCell.h"
#import "DBCard.h"
#import "DBOperation.h"
#import "GroupItemTableView.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "UITextField+Other.h"
#import "IdentifierValidator.h"
#import "RecognizeResultViewController.h"
#import <recognizeAPI/Recognize4IOS.h>
#import "AppConfig.h"




#define kButtonBGColor 0x403f3f //左菜单单元背景颜色
#define kButtonHighliftColor 0x282828 //左菜单头背景颜色
#define kButtonFontColor 0xe1e4e3 //左菜单字体颜色



@interface CardAddViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>{
    NSMutableArray *titles,*types;
    DBCard *card;
    DBOperation *db;
    
    NSMutableArray *groupArray;
    NSNumber *groupID;
    NSString *groupName;
    UITableView *tableView;
    
    UIButton *btnGroup;
    
    NSArray *attrs;
    
    NSMutableArray *otherAttrs;
    
    NSMutableArray *valueArray;

    int index;
    
}

@end

@implementation CardAddViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    groupID = 0;
    
    //初始化名片类
    card = [[DBCard alloc]init];
    
    //初始化数据库操作
    db = [[DBOperation alloc]init];
    groupArray = [db QueryGroup];
    
    //初始化手动增加标题数组
    titles = [[NSMutableArray alloc]initWithObjects:@"姓名 *",@"职称",@"公司 *",@"邮编",@"传真",@"手机 *",@"固话",@"邮箱",@"地址",@"备注",nil];
    types = [[NSMutableArray alloc]initWithObjects:@"0",@"9",@"10",@"12",@"5",@"6",@"3",@"7",@"11",@"13",nil];
    index = 15;
    otherAttrs = [[NSMutableArray alloc]init];
    valueArray = [[NSMutableArray alloc]init];
    
//    NSArray *array = [NSArray arrayWithObjects:@"",@"",@"",@"",@"", @"",@"",@"",@"",@"",nil];
//    valueArray = [[NSMutableArray alloc]initWithArray:array];
    
    //初始化属性数组
    attrs = [titles mutableCopy];
    
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
    [titleLabel setText:@"新增名片"];
    titleLabel.font = [UIFont boldSystemFontOfSize:20];
    
    self.navigationItem.titleView = titleLabel;
    
    
    //创建左右导航按钮
    [self setupMenuBarButtonItems];
    
    //上按钮条
    UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 64, [[UIScreen mainScreen] bounds].size.width/2, 40)];
    leftButton.backgroundColor = [UIColor colorWithRed:((float)((kButtonBGColor & 0xFF0000) >> 16))/255.0 green:((float)((kButtonBGColor & 0xFF00) >> 8))/255.0 blue:((float)(kButtonBGColor & 0xFF))/255.0 alpha:1.0];
    [leftButton setTitle:@"手动增加" forState:UIControlStateNormal];
    [leftButton setTitleColor:[UIColor colorWithRed:((float)((kButtonFontColor & 0xFF0000) >> 16))/255.0 green:((float)((kButtonFontColor & 0xFF00) >> 8))/255.0 blue:((float)(kButtonFontColor & 0xFF))/255.0 alpha:1.0] forState:UIControlStateNormal];
    leftButton.titleLabel.font = [UIFont systemFontOfSize: 14.0];
    [self.view addSubview:leftButton];
    
    UIButton *rightButton = [[UIButton alloc] initWithFrame:CGRectMake([[UIScreen mainScreen] bounds].size.width/2,64, [[UIScreen mainScreen] bounds].size.width/2, 40)];
    rightButton.backgroundColor = [UIColor colorWithRed:((float)((kButtonHighliftColor & 0xFF0000) >> 16))/255.0 green:((float)((kButtonHighliftColor & 0xFF00) >> 8))/255.0 blue:((float)(kButtonHighliftColor & 0xFF))/255.0 alpha:1.0];
    [rightButton setTitle:@"系统拍照" forState:UIControlStateNormal];
    [rightButton setTitleColor:[UIColor colorWithRed:((float)((kButtonFontColor & 0xFF0000) >> 16))/255.0 green:((float)((kButtonFontColor & 0xFF00) >> 8))/255.0 blue:((float)(kButtonFontColor & 0xFF))/255.0 alpha:1.0] forState:UIControlStateNormal];
    rightButton.titleLabel.font = [UIFont systemFontOfSize: 14.0];
    [rightButton addTarget:self action:@selector(takePhoto) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:rightButton];
    
    //新增Tableview
    tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 104, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height-104-40)];
    tableView.backgroundColor = [UIColor whiteColor];
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.bounces = NO;
    
    [self.view addSubview:tableView];
    
    //下操作条
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, [[UIScreen mainScreen] bounds].size.height-40, [[UIScreen mainScreen] bounds].size.width, 40)];
    view.backgroundColor = [UIColor colorWithRed:((float)((kButtonBGColor & 0xFF0000) >> 16))/255.0 green:((float)((kButtonBGColor & 0xFF00) >> 8))/255.0 blue:((float)(kButtonBGColor & 0xFF))/255.0 alpha:1.0];
    
    UIButton *groupButton = [[UIButton alloc] initWithFrame:CGRectMake(5, 5, [[UIScreen mainScreen] bounds].size.width/2-5, 32)];
    [groupButton setTitle:@"选择分组" forState:UIControlStateNormal];
    groupButton.backgroundColor = [UIColor blackColor];
    [groupButton setTitleColor:[UIColor colorWithRed:((float)((kButtonFontColor & 0xFF0000) >> 16))/255.0 green:((float)((kButtonFontColor & 0xFF00) >> 8))/255.0 blue:((float)(kButtonFontColor & 0xFF))/255.0 alpha:1.0] forState:UIControlStateNormal];
    [groupButton setTitleColor:[UIColor colorWithRed:((float)((kButtonHighliftColor & 0xFF0000) >> 16))/255.0 green:((float)((kButtonHighliftColor & 0xFF00) >> 8))/255.0 blue:((float)(kButtonHighliftColor & 0xFF))/255.0 alpha:1.0]  forState:UIControlStateHighlighted];
    groupButton.titleLabel.font = [UIFont systemFontOfSize: 14.0];
    [groupButton addTarget:self action:@selector(groupPressed) forControlEvents:UIControlEventTouchUpInside];
    btnGroup = groupButton;
    [view addSubview:groupButton];
    
    UIButton *attributeButton = [[UIButton alloc] initWithFrame:CGRectMake([[UIScreen mainScreen] bounds].size.width/2+5,5, [[UIScreen mainScreen] bounds].size.width/2-10, 32)];
    [attributeButton setTitle:@"添加属性" forState:UIControlStateNormal];
    [attributeButton setTitleColor:[UIColor colorWithRed:((float)((kButtonFontColor & 0xFF0000) >> 16))/255.0 green:((float)((kButtonFontColor & 0xFF00) >> 8))/255.0 blue:((float)(kButtonFontColor & 0xFF))/255.0 alpha:1.0] forState:UIControlStateNormal];
    [attributeButton setTitleColor:[UIColor colorWithRed:((float)((kButtonHighliftColor & 0xFF0000) >> 16))/255.0 green:((float)((kButtonHighliftColor & 0xFF00) >> 8))/255.0 blue:((float)(kButtonHighliftColor & 0xFF))/255.0 alpha:1.0]  forState:UIControlStateHighlighted];
    attributeButton.backgroundColor = [UIColor blackColor];
    attributeButton.titleLabel.font = [UIFont systemFontOfSize: 14.0];
    [attributeButton addTarget:self action:@selector(attributePressed) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:attributeButton];
    
    [self.view addSubview:view];
    
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    //打印出字典中的内容
    
    NSLog(@"get the media info: %@", info);
    
    //获取媒体类型
    
    NSString* mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    
    //判断是静态图像还是视频
    
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        
        //获取用户编辑之后的图像
        
        UIImage* editedImage = [info objectForKey:UIImagePickerControllerEditedImage];
        
        
        //保存图片文件名
        NSDate *date = [NSDate date];
        NSTimeInterval aInterval =[date timeIntervalSince1970]*1000;
        NSString *timeString = [NSString stringWithFormat:@"%.0f",aInterval];
        card.pic_name = timeString;
        
        
        
        //保存图片文件
        NSString *filename = [NSString stringWithFormat:@"Documents/"];
        filename = [filename stringByAppendingString:timeString];
        filename = [filename stringByAppendingString:@".jpg"];
        NSString  *jpgPath = [NSHomeDirectory() stringByAppendingPathComponent:filename];
        
        // Write a UIImage to JPEG with minimum compression (best quality)
        // The value 'image' must be a UIImage object
        // The value '1.0' represents image compression quality as value from 0.0 to 1.0
        [UIImageJPEGRepresentation(editedImage, 1.0) writeToFile:jpgPath atomically:YES];
        

        
    }
}
- (void)takePhoto{
    
    //1.0.4 after
    RecognizeResultViewController *resultController = [[RecognizeResultViewController alloc]init];
    resultController.source = 1;
    resultController.navigation = self.navigation;
    
    // 4IOS
    [Recognize4IOS startRecognize:self.navigationController image:nil pushController:resultController];
    
    /*NSArray *mediatypes=[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] &&[mediatypes count]>0){
        NSArray *mediatypes=[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
        UIImagePickerController *picker=[[UIImagePickerController alloc] init];
        picker.mediaTypes=mediatypes;
        picker.delegate=self;
        picker.allowsEditing=YES;
        picker.sourceType=UIImagePickerControllerSourceTypeCamera;
        NSString *requiredmediatype=(NSString *)kUTTypeImage;
        NSArray *arrmediatypes=[NSArray arrayWithObject:requiredmediatype];
        [picker setMediaTypes:arrmediatypes];
        [self presentModalViewController:picker animated:YES];
    }
    else{
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"错误信息!" message:@"当前设备不支持拍摄功能" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles: nil];
        [alert show];
    }*/
    
    
    /*//检查相机模式是否可用
     
     if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
     
     NSLog(@"sorry, no camera or camera is unavailable.");
     
     return;
     
     }
     
     //获得相机模式下支持的媒体类型
     
     NSArray* availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
     
     BOOL canTakePicture = NO;
     
     for (NSString* mediaType in availableMediaTypes) {
     
     if ([mediaType isEqualToString:(NSString*)kUTTypeImage]) {
     
     //支持拍照
     
     canTakePicture = YES;
     
     break;
     
     }
     
     }
     
     //检查是否支持拍照
     
     if (!canTakePicture) {
     
     NSLog(@"sorry, taking picture is not supported.");
     
     return;
     
     }
     
     //创建图像选取控制器
     
     UIImagePickerController* imagePickerController = [[UIImagePickerController alloc] init];
     
     //设置图像选取控制器的来源模式为相机模式
     
     imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
     
     //设置图像选取控制器的类型为静态图像
     
     imagePickerController.mediaTypes = [[[NSArray alloc] initWithObjects:(NSString*)kUTTypeImage, nil]autorelease];
     
     //允许用户进行编辑
     
     imagePickerController.allowsEditing = YES;
     
     //设置委托对象
     
     imagePickerController.delegate = self;
     
     //以模视图控制器的形式显示
     
     [self presentModalViewController:imagePickerController animated:YES];
     
     [imagePickerController release];*/
}
- (void) groupPressed{
    if (groupArray.count<=0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您目前没有自定义分组" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }else{
        CGFloat xWidth = [UIScreen mainScreen].bounds.size.width - 40.0f;
        CGFloat yHeight = 272.0f;
        CGFloat yOffset = ([UIScreen mainScreen].bounds.size.height - yHeight)/2.0f;
        UIPopoverListView *poplistview = [[UIPopoverListView alloc] initWithFrame:CGRectMake(10, yOffset, xWidth, yHeight)];
        poplistview.tag = 1;
        poplistview.delegate = self;
        poplistview.datasource = self;
        poplistview.listView.scrollEnabled = TRUE;
        [poplistview setTitle:@"请选择分组"];
        [poplistview show];
    }
}
- (void) attributePressed{
    CGFloat xWidth = [UIScreen mainScreen].bounds.size.width - 40.0f;
    CGFloat yHeight = 272.0f;
    CGFloat yOffset = ([UIScreen mainScreen].bounds.size.height - yHeight)/2.0f;
    UIPopoverListView *poplistview = [[UIPopoverListView alloc] initWithFrame:CGRectMake(10, yOffset, xWidth, yHeight)];
    poplistview.tag = 2;
    poplistview.delegate = self;
    poplistview.datasource = self;
    poplistview.listView.scrollEnabled = TRUE;
    [poplistview setTitle:@"请选择新属性"];
    [poplistview show];
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
#pragma mark - 右菜单创建函数
- (UIBarButtonItem *)rightMenuBarButtonItem {
    
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0,0,35,30)];
    [button setImage:[UIImage imageNamed:@"save.png"] forState:UIControlStateNormal];
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
#pragma mark - 右菜单处理函数
- (void)rightSideMenuButtonPressed:(id)sender {
    
    if(card.name==nil){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"姓名不能为空" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    if(card.company==nil){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"公司名称不能为空" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    if(card.mobile==nil){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"手机号码不能为空" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    /*if(card.mail==nil){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"邮箱名称不能为空" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }*/
    
    /*if(card.post_code!=nil){
        BOOL isValid = [IdentifierValidator isValid:IdentifierTypeZipCode value:card.post_code];
        if (!isValid) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"邮政编码格式不正确" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            return;
        }
    }
    if(card.fax!=nil){
        BOOL isValid = [IdentifierValidator isValid:IdentifierTypePhone value:card.fax];
        if (!isValid) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"传真格式不正确" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            return;
        }
    }
    if(card.job_tel!=nil){
        BOOL isValid = [IdentifierValidator isValid:IdentifierTypePhone value:card.job_tel];
        if (!isValid) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"固话格式不正确" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            return;
        }
    }*/
    /*if (card.mail!=nil) {
        BOOL isValid = [IdentifierValidator isValid:IdentifierTypeEmail value:card.mail];
        if (!isValid) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"邮箱格式不正确" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            return;
        }
    }*/
    /*if(card.mobile){
        BOOL isValid = [IdentifierValidator isValid:IdentifierTypeMobilePhone value:card.mobile];
        if (!isValid) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"手机号码格式不正确" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            return;
        }
    }*/
    
    if(index >15){
        for (int i=15; i<index; i++) {
            if (titles[i-5]==@"姓名") {
                card.name = [self parseProperty:card.name appendValue:otherAttrs[i-15]];
            }else if(titles[i-5]==@"职称"){
                card.title = [self parseProperty:card.title appendValue:otherAttrs[i-15]];
            }else if(titles[i-5]==@"公司"){
                card.company = [self parseProperty:card.company appendValue:otherAttrs[i-15]];
            }else if(titles[i-5]==@"邮编"){
                card.post_code = [self parseProperty:card.post_code appendValue:otherAttrs[i-15]];
            }else if(titles[i-5]==@"传真"){
                card.fax = [self parseProperty:card.fax appendValue:otherAttrs[i-15]];
            }else if(titles[i-5]==@"手机"){
                card.mobile = [self parseProperty:card.mobile appendValue:otherAttrs[i-15]];
            }else if(titles[i-5]==@"固话"){
                card.job_tel = [self parseProperty:card.job_tel appendValue:otherAttrs[i-15]];
            }else if(titles[i-5]==@"邮箱"){
                card.mail = [self parseProperty:card.mail appendValue:otherAttrs[i-15]];
            }else if(titles[i-5]==@"地址"){
                card.address = [self parseProperty:card.address appendValue:otherAttrs[i-15]];
            }else if(titles[i-5]==@"备注"){
                card.note = [self parseProperty:card.note appendValue:otherAttrs[i-15]];
            }
            
        }
        
    }
    
    //判断名片是否存在
    BOOL isExist = [db getCardyName:card.name phone:card.mobile company:card.company];
    if (isExist) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"此名片已存在！" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    //创建时间
    NSDate *create_date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-dd"];
    //名片创建时间
    card.create_time = [formatter stringFromDate:create_date];
    
    card.gid = groupID;
    
    
    [db InsertCard:card];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"保存新名片成功" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    
    //清空tableview 中的数据
    
}

#pragma mark - tableview
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return titles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"ManualAddCell";
    
    
    ManualAddCardTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[ManualAddCardTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }else{
        
        if([indexPath row] >= 10){
            int indexRows = indexPath.row - 10;
            int rows = otherAttrs.count - 1;
            if (indexRows > rows) {
                cell.valueTextField.text = @"";
            }else{
                if (otherAttrs[indexPath.row-10]==nil) {
                    cell.valueTextField.text = @"";
                }else{
                    cell.valueTextField.text = otherAttrs[indexPath.row-10];
                }
            }
            
        }else{
            NSLog(@"index path row is %d",indexPath.row);
            int rows = valueArray.count-1;
            if (indexPath.row > rows){
                cell.valueTextField.text = @"";
            }else{
                if (valueArray[indexPath.row]==nil) {
                    cell.valueTextField.text = @"";
                }else{
                    cell.valueTextField.text = valueArray[indexPath.row];
                    
                }
            }
            
        }
        
    }
    
    
    cell.titleLabel.text = [titles objectAtIndex:indexPath.row];
    int tag = [[types objectAtIndex:indexPath.row] intValue];
    cell.titleLabel.tag = tag;
    
    if(tag==12 || tag==5 || tag==6 || tag==3){
        cell.valueTextField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    }
    cell.valueTextField.delegate = self;
    cell.valueTextField.tag = tag;
    
    /*int count=1;
    for (int i=0; i<indexPath.row; i++) {
        if(titles[i]==titles[indexPath.row]){
            count++;
        }
    }
    
    
    cell.valueTextField.idx = [NSString stringWithFormat:@"%d",count];*/
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == titles.count-1) {
        if (groupArray.count<=0) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您目前没有自定义分组" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }else{
            
        }
        
    }
}



#pragma mark - text field
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return NO;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    
    NSString *strTag = [NSString stringWithFormat:@"%d",textField.tag];
    
    //int index = [textField.idx intValue];
    //int count = 0;
    

    
    if (textField.tag < 15 ) {
        [tableView setContentOffset:CGPointMake(0, 44*[types indexOfObject:strTag]) animated:YES];
    }else{
        /*int i;
        for (i=0;i<types.count ; i++) {
            if (types[i]==strTag) {
                count++;
                if (count==index) {
                    break;
                }
            }
        }*/
        [tableView setContentOffset:CGPointMake(0, 44*(10+index-15)) animated:YES];
    }
    
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

- (void)textFieldDidEndEditing:(UITextField *)textField{
    NSLog(@"%d",textField.tag);
    
    [tableView setContentOffset:CGPointMake(0, 0) animated:YES];

    
    switch (textField.tag) {
        case 0:
            card.name = textField.text;
            [valueArray insertObject:textField.text atIndex:0];
            break;
        case 9:
            card.title = textField.text;
            [valueArray insertObject:textField.text atIndex:1];
            break;
        case 10:
            card.company = textField.text;
            [valueArray insertObject:textField.text atIndex:2];
            break;
        case 12:
            card.post_code = textField.text;
            [valueArray insertObject:textField.text atIndex:3];
            break;
        case 5:
            card.fax = textField.text;
            [valueArray insertObject:textField.text atIndex:4];
            break;
        case 6:
            card.mobile = textField.text;
            [valueArray insertObject:textField.text atIndex:5];
            break;
        case 3:
            card.job_tel = textField.text;
            [valueArray insertObject:textField.text atIndex:6];
            break;
        case 7:
            card.mail = textField.text;
            [valueArray insertObject:textField.text atIndex:7];
            break;
        case 11:
            card.address = textField.text;
            [valueArray insertObject:textField.text atIndex:8];
            break;
        case 13:
            card.note = textField.text;
            [valueArray insertObject:textField.text atIndex:9];
            break;
        default:
            break;
    }
    
    if (textField.tag >= 15) {
        [otherAttrs insertObject:textField.text atIndex:textField.tag-15];
    }
    
}

#pragma mark - UIPopoverListViewDataSource

- (UITableViewCell *)popoverListView:(UIPopoverListView *)popoverListView
                    cellForIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cell";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                   reuseIdentifier:identifier];
    if (popoverListView.tag==1) {
        DBGroup *group = [groupArray objectAtIndex:indexPath.row];
        
        cell.textLabel.text = group.name;
    }else{
        cell.textLabel.text = attrs[indexPath.row];
    }
    
    
    
    //cell.textLabel.tag = group.Id;
    
    
    return cell;
}

- (NSInteger)popoverListView:(UIPopoverListView *)popoverListView
       numberOfRowsInSection:(NSInteger)section
{
    if (popoverListView.tag==1) {
        return groupArray.count;

    }else{
        return attrs.count;

    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIPopoverListViewDelegate
- (void)popoverListView:(UIPopoverListView *)popoverListView
     didSelectIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"%s : %d", __func__, indexPath.row);
    // your code here
    if (popoverListView.tag==1) {
        DBGroup *group = [groupArray objectAtIndex:indexPath.row];
        groupID = group.Id;
        groupName = group.name;
        card.gid = group.Id;
        
        btnGroup.titleLabel.text = groupName;
        
    }else{
        NSString *title = [titles objectAtIndex:indexPath.row];
        NSString *type = [NSString stringWithFormat:@"%d",index++];
        
        [types insertObject:type atIndex:types.count];
        [titles insertObject:title atIndex:titles.count];
        
        [tableView reloadData];
        
    }
    
    
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

@end
