//
//  KNBPartPresentTransitionViewController.h
//  SobotKit
//
//  Created by suojl on 2017/11/6.
//  Copyright © 2017年 zhichi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol KNBOrderViewControllerDelegate <NSObject>
@optional

-(void) dismissViewController:(UIViewController *)controller andSendOrderMessage:(NSString *)msg;
@end

@interface KNBPartPresentTransitionViewController : UIViewController <UIViewControllerTransitioningDelegate>

@end
