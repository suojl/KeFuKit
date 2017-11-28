//
//  KNBOrderViewController.h
//  SobotKit
//
//  Created by suojl on 2017/11/1.
//  Copyright © 2017年 zhichi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KNBPartPresentTransitionViewController.h"

@protocol KNBOrderViewControllerDelegate <NSObject>
@optional

-(void) dismissViewController:(UIViewController *)controller andSendOrderMessage:(NSString *)msg;
@end

@interface KNBOrderViewController : KNBPartPresentTransitionViewController

@property (nonatomic,strong) UIView *topView;
@property (nonatomic,strong) UITableView *orderTableView;

//刷新出来的View的总view
@property(strong, nonatomic)UIView * refreshView;
//上边的字体
@property(strong, nonatomic)UILabel * refreshLabel;

@property (nonatomic, weak) id<KNBOrderViewControllerDelegate> vcDelegate;

@end
