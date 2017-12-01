//
//  KNBSaleAfterOrderInfo.h
//  SobotKit
//
//  Created by 索静龙 on 2017/12/1.
//  Copyright © 2017年 zhichi. All rights reserved.
//

#import <Foundation/Foundation.h>

//@class KNBSaleAfterOrderInfo;
@interface KNBSaleAfterModel : NSObject

@property (nonatomic, assign) int code;
@property (nonatomic, strong) NSString *msg;
@property (nonatomic, strong) NSArray *data;

@end

@interface KNBSaleAfterOrderInfo : NSObject
/**
 订单的ID
 */
@property (nonatomic,strong) NSString *orderId;


// 商品首图
@property (nonatomic,strong) NSString *goodsImgUrl;

// 退款金额
@property (nonatomic,strong) NSString *returnPrice;

// 售后状态
@property (nonatomic,strong) NSString *returnState;

// 申请时间
@property (nonatomic,strong) NSString *applyDate;
// 商品名称
@property (nonatomic,strong) NSString *goodsTitle;
// 卡片类型 1. goods:商品  2. order:订单 3. saleOrder:售后订单
@property (nonatomic,strong) NSString *cardType;
@end
