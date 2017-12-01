//
//  KNBAfterSaleViewController.h
//  SobotKit
//
//  Created by suojl on 2017/11/30.
//  Copyright © 2017年 zhichi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KNBPartPresentTransitionViewController.h"

@interface KNBAfterSaleViewController : KNBPartPresentTransitionViewController

@property (nonatomic,strong) UIView *topView;
@property (nonatomic,strong) UITableView *orderTableView;

//刷新出来的View的总view
@property(strong, nonatomic)UIView * refreshView;
//上边的字体
@property(strong, nonatomic)UILabel * refreshLabel;

@property (strong, nonatomic) UIView      *emptyView;

@property (nonatomic, weak) id<KNBOrderViewControllerDelegate> vcDelegate;

@end
