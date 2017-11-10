//
//  ZCUIChatListCell.m
//  SobotKit
//
//  Created by zhangxy on 2017/9/5.
//  Copyright © 2017年 zhichi. All rights reserved.
//

#import "ZCUIChatListCell.h"
#import "ZCLIbGlobalDefine.h"
#import "ZCUIColorsDefine.h"
#import "ZCLibCommon.h"

@implementation ZCUIChatListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}


-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        _lblTime=[[UILabel alloc] initWithFrame:CGRectMake(ScreenWidth - 90, 5, 85, 50)];
        [_lblTime setTextAlignment:NSTextAlignmentRight];
        [_lblTime setFont:[ZCUITools zcgetListKitTimeFont]];
        [_lblTime setTextColor:[ZCUITools zcgetTimeTextColor]];
        [_lblTime setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:_lblTime];
        _lblTime.hidden=NO;
        
        
        _lblNickName =[[UILabel alloc] initWithFrame:CGRectMake(60, 5, ScreenWidth - 60 - 80, 25)];
        [_lblNickName setBackgroundColor:[UIColor clearColor]];
        [_lblNickName setTextAlignment:NSTextAlignmentLeft];
        [_lblNickName setFont:[ZCUITools zcgetListKitTitleFont]];
        [_lblNickName setTextColor:[ZCUITools zcgetGoodsTextColor]];
        [_lblNickName setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:_lblNickName];
        _lblNickName.hidden=NO;
        
        _ivHeader = [[ZCUIImageView alloc] initWithFrame:CGRectMake(5, 5, 50, 50)];
        [_ivHeader setContentMode:UIViewContentModeScaleAspectFill];
        [_ivHeader.layer setMasksToBounds:YES];
        [_ivHeader setBackgroundColor:[UIColor clearColor]];
        _ivHeader.layer.cornerRadius=4.0f;
        _ivHeader.layer.masksToBounds=YES;
        _ivHeader.layer.borderWidth = 0.5f;
        _ivHeader.layer.borderColor = [ZCUITools zcgetBackgroundColor].CGColor;
        [self.contentView addSubview:_ivHeader];
        
        _lblLastMsg =[[UILabel alloc] initWithFrame:CGRectMake(60, 30, ScreenWidth - 60 - 80, 25)];
        [_lblLastMsg setBackgroundColor:[UIColor clearColor]];
        [_lblLastMsg setTextAlignment:NSTextAlignmentLeft];
        [_lblLastMsg setFont:[ZCUITools zcgetListKitDetailFont]];
        [_lblLastMsg setTextColor:[ZCUITools zcgetServiceNameTextColor]];
        _lblLastMsg.numberOfLines = 1;
        [_lblLastMsg setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:_lblLastMsg];
        _lblLastMsg.hidden=NO;

        _lblUnRead =[[UILabel alloc] initWithFrame:CGRectMake(55-15, 3, 20, 20)];
        [_lblUnRead setBackgroundColor:[UIColor clearColor]];
        [_lblUnRead setTextAlignment:NSTextAlignmentCenter];
        [_lblUnRead setFont:[ZCUITools zcgetListKitTimeFont]];
        [_lblUnRead setTextColor:[UIColor whiteColor]];
        [_lblUnRead setBackgroundColor:UIColorFromRGB(BgDotRedColor)];
        _lblUnRead.layer.cornerRadius = 10;
        _lblUnRead.layer.masksToBounds = YES;
        [self.contentView addSubview:_lblUnRead];
        _lblUnRead.hidden=YES;
        
        
        self.userInteractionEnabled=YES;
    }
    return self;
}

-(void)dataToView:(ZCPlatformInfo *)info{
    if(info){
        _lblLastMsg.text = zcLibConvertToString(info.lastMsg);
        _lblNickName.text = zcLibConvertToString(info.platformName);
        
        _lblTime.text = zcLibDateTransformString(@"MM月dd日", zcLibStringFormateDate(info.lastDate));
        
        NSString *url = [zcLibConvertToString(info.avatar) stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [_ivHeader loadWithURL:[NSURL URLWithString:url] placeholer:[ZCUITools zcuiGetBundleImage:@"ZCIcon_UserAvatar_nol"] showActivityIndicatorView:NO];
        _lblUnRead.hidden = YES;
        if(info.unRead>0){
            _lblUnRead.hidden = NO;
            
            if(info.unRead>99){
                _lblUnRead.text = @"99+";
            }else{
                _lblUnRead.text = [NSString stringWithFormat:@"%d",info.unRead];
            }
        }
    }
    [self setBackgroundColor:[UIColor whiteColor]];
    [self setFrame:CGRectMake(0, 0, ScreenWidth, 60)];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
