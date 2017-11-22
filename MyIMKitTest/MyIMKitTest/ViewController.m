//
//  ViewController.m
//  MyIMKitTest
//
//  Created by suojl on 2017/11/10.
//  Copyright © 2017年 com.dengyun. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import <SobotKit/SobotKit.h>
//

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnClick:(id)sender {


    // 设置推送是否是测试环境，测试环境将使用开发证书
    [ZCLibClient getZCLibClient].platformUnionCode = @"1001";
    [[ZCLibClient getZCLibClient] setIsDebugMode:YES];

    // 错误日志收集
    [ZCLibClient setZCLibUncaughtExceptionHandler];

    ZCLibInitInfo *initInfo = [ZCLibInitInfo new];//aaa

#pragma mark 设置默认APPKEY
//    initInfo.appKey         = @"6daf80b9ba1b48ed90f4c80f88bc3ab0";
    initInfo.appKey = @"2214500ad6d34511b851cf3ddb84c048";
    initInfo.userId = @"1019728";
//    initInfo.userId = @"1007391";

    // 关键设置，必须设置了参数才生效
    [[ZCLibClient getZCLibClient] setLibInitInfo:initInfo];
//        initInfo.serviceMode    = 4;
    // 组ID: 0abc24fed103436285cb9d3e40a9525f
    // 客服ID: 060001d0527d4996bfdb7a843b53c2ac
    initInfo.skillSetId = @"469efb3e757d4cd7a1e03af18203fe4a";
    //    initInfo.skillSetName = @"";
//    initInfo.receptionistId = @"4ef76f9d896c4be1b482f3f0eb01aacd";
    //    initInfo.titleType = @"2";
    initInfo.nickName = @"小锁";
//    initInfo.realName = @"";    // 用户真实姓名
//    initInfo.phone = @"";   //用户手机号
//    initInfo.avatarUrl = @""; //设置用户头像
//    initInfo.qqNumber = @"";    //QQ号码
//    initInfo.userRemark = @"";  //用户备注
//    initInfo.userSex = @"0";

    // 设置用户信息参数
//    [self customUserInformationWith:initInfo];

    ZCKitInfo *uiInfo=[ZCKitInfo new];
    uiInfo.isCloseAfterEvaluation = YES;
    // 点击返回是否触发满意度评价（符合评价逻辑的前提下）
    uiInfo.isOpenEvaluation = YES;

    /**   设置订单查询接口   **/

    // 设置md5加密格式
    uiInfo.md5MixPrefix = @"blln";
    uiInfo.md5MixPostfix = @"blln";
    uiInfo.versioNumber = @"1.3.0";
    uiInfo.orderStatusFlag = @"5";
    // 设置订单查询接口
    uiInfo.queryOrderListForKF = @"http://10.10.8.22:9214/blln-app/order/queryOrderListForKF.do";

//    uiInfo.md5MixPrefix = @"mtmy";
//    uiInfo.md5MixPostfix = @"mtmy";
//    uiInfo.versioNumber = @"1.3.0";
//    uiInfo.orderStatusFlag = @"5";
//    // 设置订单查询接口http://60.205.112.197/mtmy-app/queryMyOrder150.do
//    uiInfo.queryOrderListForKF = @"http://60.205.112.197/mtmy-app/order/queryMyOrder150.do";

    /**   ----------------------END----------------------   **/

//    [self customUnReadNumber:uiInfo];

//         切换服务器地址，默认https://api.sobot.com
    uiInfo.apiHost = @"http://221.122.116.98/";
//    uiInfo.apiHost = @"https://api.sobot.com";

    // 测试模式
    [ZCSobot setShowDebug:NO];

    [self customerGoodAndLeavePageWithParameter:uiInfo];
    NSLog(@"----%@",[[NSBundle mainBundle] pathForResource:@"SobotKit" ofType: @"bundle"]);
    // 启动
    [ZCSobot startZCChatView:uiInfo with:self target:nil pageBlock:^(ZCUIChatController *object, ZCPageBlockType type) {
        // 点击返回
        if(type==ZCPageBlockGoBack){
            NSLog(@"关闭聊天界面!!!");

            /*
             这是因为平台版本，初始化默认会取上一次的编号直接连接通道，保证没有进入聊天界面也可以收消息，所以再链接进入sdk的时候，通道已经连接好了，但是连接的可能是你以前没有设置平台版本号的通道，导致无法收消息
             */
            [[ZCLibClient getZCLibClient] removePush:^(NSString *uid, NSData *token, NSError *error) {
                NSLog(@"退出了,%@==%@",uid,error);
            }];
            [ZCLibClient closeAndoutZCServer:YES];
        }

        // 页面UI初始化完成，可以获取UIView，自定义UI
        if(type==ZCPageBlockLoadFinish){
            NSLog(@"成功打开聊天界面!!");
        }
    } messageLinkClick:nil];
}


// 设置用户信息参数
- (void)customUserInformationWith:(ZCLibInitInfo *)initInfo{

    //    initInfo.customInfo = @{@"标题1":@"自定义1",@"内容1":@"我是一个自定义字段。",@"标题2":@"自定义字段2",@"内容2":@"我是一个自定义字段，我是一个自定义字段，我是一个自定义字段，我是一个自定义字段。",@"标题3":@"自定义字段字段3",@"内容3":@"<a href=\"www.baidu.com\" target=\"_blank\">www.baidu.com</a>",@"标题4":@"自定义4",@"内容4":@"我是一个自定义字段 https://www.sobot.com/chat/pc/index.html?sysNum=9379837c87d2475dadd953940f0c3bc8&partnerId=112"};
    initInfo.customInfo = @{

                            @"zx":@"自定义1",
                            @"内容1":@"我是一个自定义字段。",
                            @"标题2":@"自定义字段2",
                            @"AppAcronym":@"blln"
                            };
    initInfo.customerFields = @{@"customField1":@"自定义字段"};

}


// 自定义参数 商品信息相关
- (void)customerGoodAndLeavePageWithParameter:(ZCKitInfo *)uiInfo{

//    ZCProductInfo *productInfo = [ZCProductInfo new];
//    productInfo.thumbUrl = @"http://f12.baidu.com/it/u=3087422712,1174175413&fm=72";
//    productInfo.title = @"我是商品标题我是商品标题我是商品标题我是商品标题";
//    productInfo.desc = @"商品描述商品描述商品描述商品描述商品描述商品描述商品描述";
//    productInfo.label = @"商品标签，价格、分类等商品标签，价格、分类等";
//    productInfo.link = @"http://f12.baidu.com/it/u=3087422712,1174175413&fm=72";
//    productInfo.testAdd = @"自定义的添加字段";
//    uiInfo.productInfo = productInfo;

    KNBGoodsInfo *goodsInfo = [KNBGoodsInfo new];
//    goodsInfo.orderNumber = @"fads49534959032234";
//    goodsInfo.orderState = @"待收货";
//    goodsInfo.orderDate = @"2017-01-23";
    goodsInfo.goodsTitle = @"卡萨丁佛闻风丧胆";
    goodsInfo.goodsPrice = @"2434535";
    goodsInfo.goodsImgUrl = @"http://imgsrc.baidu.com/image/c0%3Dshijue1%2C0%2C0%2C294%2C40/sign=cfb53f93c3177f3e0439f44e18a651b2/6609c93d70cf3bc7814060c9db00baa1cd112a56.jpg";
    goodsInfo.cardType = @"商品";
    uiInfo.orderGoodsInfo = goodsInfo;

    //mtmy订单状态（-2：取消订单；-1：待付款；1：待发货；2：待收货；3：已退款（退货并退款使用）；4：已完成；）
    //blln定制订单状态（-2：取消订单；-1：待支付；1：待量体；2：量体完成；3：待审核；4：打版；
    //5：裁剪；6：制作；7：质检；8：快递；9：试穿；10：待评价；11：完成）
    NSDictionary *mtmyOrderDictionary = @{
                                          @"-2":@"已取消",
                                          @"-1":@"待付款",
                                          @"1":@"待发货",
                                          @"2":@"待收货",
                                          @"3":@"已退款",
                                          @"4":@"已完成"
                                          };
    NSDictionary *bllnOrderDictionary = @{
                                          @"-2":@"已取消",
                                          @"-1":@"待支付",
                                          @"1":@"待量体",
                                          @"2":@"已量体",
                                          @"3":@"待审核",
                                          @"4":@"打版",
                                          @"5":@"裁剪",
                                          @"6":@"制作",
                                          @"7":@"质检",
                                          @"8":@"快递",
                                          @"9":@"试穿",
                                          @"10":@"待评价",
                                          @"11":@"已完成"
                                          };
    uiInfo.orderStateDictionary = bllnOrderDictionary;
}


// 未读消息数
- (void)customUnReadNumber:(ZCKitInfo *)uiInfo{

    // [[ZCLibClient getZCLibClient] setAutoNotification:YES];



//    [ZCLibClient getZCLibClient].receivedBlock = ^(id obj,int unRead){
//        NSLog(@"当前消息数：%d \n %@",unRead,obj);
//
//        if(SYSTEM_VERSION_GRATERTHAN_OR_EQUALTO(@"10.0")){
//            [self registerNotification:(NSString *)obj];
//        }else{
//            [self registerLocalNotificationInOldWay:(NSString *)obj];
//        }
//
//    };

}

@end
