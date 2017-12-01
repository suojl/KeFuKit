//
//  KNBSaleAfterOrderInfo.m
//  SobotKit
//
//  Created by 索静龙 on 2017/12/1.
//  Copyright © 2017年 zhichi. All rights reserved.
//

#import "KNBSaleAfterOrderInfo.h"
#import "ZCUIConfigManager.h"

@implementation KNBSaleAfterModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"data" : KNBSaleAfterOrderInfo.class};
}
@end

@implementation KNBSaleAfterOrderInfo

+(NSDictionary *)modelCustomPropertyMapper{
    return @{
             @"orderId":@"id",
             @"goodsImgUrl":@"original_img",
             @"goodsTitle":@"goods_name",
             @"returnPrice":@"return_amount",
             @"applyDate":@"apply_date",
             @"returnState":@"return_status"
             };
}

-(void)setReturnState:(NSString *)orderState{
    if (orderState && ![@"" isEqualToString:orderState]) {
        NSDictionary *stateDic = [ZCUIConfigManager getInstance].kitInfo.afterSaleOrderStateDictionary;
        if (stateDic && [stateDic objectForKey:orderState]) {
            _returnState = [stateDic objectForKey:orderState];
        }else{
            _returnState = orderState;
        }
    }else{
        _returnState = @"未查到";
    }
}

-(void)setApplyDate:(NSString *)orderDate{
    if (orderDate && ![@"" isEqualToString: orderDate]) {
        if (orderDate.length > 10) {
            _applyDate = [orderDate substringToIndex:10];
        }else{
            _applyDate = orderDate;
        }
    }else{
        _applyDate = orderDate;
    }
}
@end
