#import "ActivityManageView.h"
#import "ActivityHttpRequestService.h"
#import "RMMapper.h"
#import "CreateActivityViewController.h"
#import "SVProgressHUD.h"

@interface ActivityManageView ()<UITableViewDelegate, UITableViewDataSource>
@property(nonatomic, strong) UITableView *contentTableView;
@property(nonatomic, strong) NSArray *dataSourceArr;
@end

@implementation ActivityManageView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.contentTableView = [[UITableView alloc]initWithFrame:self.bounds style:UITableViewStylePlain];
        self.contentTableView.delegate = self;
        self.contentTableView.dataSource = self;
        //self.contentTableView.estimatedRowHeight = 50;
        self.contentTableView.rowHeight = 50;
        //self.contentTableView.rowHeight = UITableViewAutomaticDimension;
        [self addSubview:self.contentTableView];
    }
    return self;
}

-(void)configSourceDataWithCardId:(NSString *)cardId {
    
    ActivityHttpRequestService *activityRequest = [[ActivityHttpRequestService alloc]init];
    //显示加载动画
    [SVProgressHUD show];
    
    [activityRequest getContactByCard:cardId pageNumber:1 pageSize:1000 success:^(NSString *strToken) {
        
        [SVProgressHUD dismiss];
        
        NSData *data = [strToken dataUsingEncoding:NSUTF8StringEncoding];
        id obj = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        
        NSLog(@"%@",obj);
        
        NSDictionary *dataSource = obj;
        if (![obj isKindOfClass:[NSNull class]] &&[dataSource.allKeys containsObject:@"Items"] ) {
            
            self.dataSourceArr = [dataSource objectForKey:@"Items"];
        }else{
            self.dataSourceArr = nil;
        }
        
        [self.contentTableView reloadData];
        
    } error:^(NSString *strFail) {
        [SVProgressHUD dismiss];
    }];
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSourceArr.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *ActivityManageCellIdentifier = @"ActivityManageCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ActivityManageCellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ActivityManageCellIdentifier];
    }
    
    
    
    NSDictionary *dict = self.dataSourceArr[indexPath.row];
    
    Contactactivity *contactactivity = [RMMapper objectWithClass:[Contactactivity class] fromDictionary:dict];
    NSString *activitypeName = [NSString stringWithFormat:@"%@",contactactivity.ActivitypeName];
    NSString *activitytime = [NSString stringWithFormat:@"%@",contactactivity.Activitytime];
    cell.imageView.image = [UIImage imageNamed:@"my_menu"];
    cell.textLabel.text = activitypeName;
    cell.detailTextLabel.text = activitytime;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *dict = self.dataSourceArr[indexPath.row];
    
    Contactactivity *contactactivity = [RMMapper objectWithClass:[Contactactivity class] fromDictionary:dict];
    CreateActivityViewController *nextViewController = [[CreateActivityViewController alloc]initWithNibName:@"CreateActivityViewController" bundle:nil];
    nextViewController.contactactivity = contactactivity;
    [self.parentViewController.navigationController pushViewController:nextViewController animated:YES];
}

@end