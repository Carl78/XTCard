//
//  GroupItemTableView.m
//  CardRecognition
//
//  Created by bournejason on 15/6/3.
//  Copyright (c) 2015年 bournejason. All rights reserved.
//

#import "GroupItemTableView.h"
#define kInputBackColor 0x707070
@implementation GroupItemTableView
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        int width = [UIScreen mainScreen].bounds.size.width;
        
        
        
        UILabel *name = [[UILabel alloc]init];
        name.frame = CGRectMake(10, 20, 50, 30);
        name.font = [UIFont fontWithName:@"Helvetica-BoldOblique" size:16];;
        self.titleLabel = name;
        [self.contentView addSubview:name];
        
        UILabel *title = [[UILabel alloc]init];
        title.frame = CGRectMake(60, 20, width-70, 30);
        title.font = [UIFont fontWithName:@"Helvetica" size:12];
        self.contentLabel = title;
        
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 60)];
        view.backgroundColor = [UIColor colorWithRed:((float)((kInputBackColor & 0xFF0000) >> 16))/255.0 green:((float)((kInputBackColor & 0xFF00) >> 8))/255.0 blue:((float)(kInputBackColor & 0xFF))/255.0 alpha:1.0];
        
        [view addSubview:name];
        [view addSubview:title];
        
        [self.contentView addSubview:view];
        
        
        
    }
    return self;
}


@end
