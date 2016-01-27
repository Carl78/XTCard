
//
//  OptionTableView.m
//  CardRecognition
//
//  Created by sunshinek31 on 15/6/6.
//  Copyright (c) 2015年 bournejason. All rights reserved.
//

#import "OptionTableView.h"
typedef void(^DidSelectedIndexPathBlock)(NSIndexPath *indexPath,NSString *context,NSInteger tag);

@interface OptionTableView ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, copy) DidSelectedIndexPathBlock didSelectedBlock;
@property (nonatomic) int selectedIndex;
@end

@implementation OptionTableView
{
@private
    NSArray *_cellArr;
}

-(id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    self = [super initWithFrame:frame style:style];
    if (self) {
        self.delegate = self;
        self.dataSource = self;
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style params:(NSArray *)params defaultSelectIndex:(int)selectedIndex {
    self = [self initWithFrame:frame style:style];
    if (self) {
        _cellArr = [NSArray arrayWithArray:params];
        self.selectedIndex = selectedIndex;
    }
    return self;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _cellArr.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* OptionTableViewCellIdentifier = @"OptionTableViewCellIdentifier";
    UITableViewCell *cell;
    cell = [self dequeueReusableCellWithIdentifier:OptionTableViewCellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:OptionTableViewCellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    

    cell.accessoryType = UITableViewCellAccessoryNone;
    
    if (indexPath.row == self.selectedIndex) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    cell.textLabel.text = _cellArr[indexPath.row];
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *context = _cellArr[indexPath.row];
    //if (indexPath.row == 0) {
       // context = nil;
    //}
    
    if (self.didSelectedBlock) {
        self.didSelectedBlock(indexPath, context, self.tag);
    }
}

-(void)didSelectIndexPath:(void (^)(NSIndexPath *indexPath, NSString *context, NSInteger tag))didSelectBlock {
    _didSelectedBlock = [didSelectBlock copy];
}

@end
