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
#define SYSTEM_VERSION_GRATERTHAN_OR_EQUALTO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

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
    ZCLibInitInfo *initInfo = [ZCLibInitInfo new];
    
    [ZCLibClient getZCLibClient].platformUnionCode = @"1001";
    [[ZCLibClient getZCLibClient] setIsDebugMode:YES];
#pragma mark 设置默认APPKEY
    initInfo.appKey         = @"e9ad00cfe99e426c9912833c040f46b5";
//    initInfo.appKey = @"2214500ad6d34511b851cf3ddb84c048";
    initInfo.userId = @"1063015";

    // 关键设置，必须设置了参数才生效
    [[ZCLibClient getZCLibClient] setLibInitInfo:initInfo];
    initInfo.skillSetId = @"7aa09f4de20849be9b449d90052eb7cc";
    //    initInfo.serviceMode    = 4;
    // 组ID: 0abc24fed103436285cb9d3e40a9525f
    // 客服ID: 060001d0527d4996bfdb7a843b53c2ac
    //    initInfo.skillSetId = @"";
    //    initInfo.skillSetName = @"";
    //    initInfo.receptionistId = @"";
    //    initInfo.titleType = @"2";
    initInfo.nickName = @"mm1709136CIEK";
//    initInfo.userSex = @"0";
//        initInfo.zx = @"自定义字段测试";

    // 设置用户信息参数
//    [self customUserInformationWith:initInfo];

    ZCKitInfo *uiInfo=[ZCKitInfo new];
    uiInfo.isCloseAfterEvaluation = YES;
    // 点击返回是否触发满意度评价（符合评价逻辑的前提下）
    uiInfo.isOpenEvaluation = YES;

    /**   设置订单查询接口   **/

    // 设置md5加密格式
    //    uiInfo.md5MixPrefix = @"blln";
    //    uiInfo.md5MixPostfix = @"blln";
    //    uiInfo.versioNumber = @"1.3.0";
    ////    // 设置订单查询接口
    //    uiInfo.queryOrderListForKF = @"http://10.10.8.22:9214/blln-app/order/queryOrderListForKF.do";

    uiInfo.md5MixPrefix = @"mtmy";
    uiInfo.md5MixPostfix = @"mtmy";
    uiInfo.versioNumber = @"2.6.0";
    uiInfo.orderStatusFlag = @"5";
    //    // 设置订单查询接口http://60.205.112.197/mtmy-app/queryMyOrder150.do
    uiInfo.queryOrderListForKF = @"http://online-test.idengyun.com/mtmy-app/order/queryMyOrder150.do";
    uiInfo.querySaleAfterForKF = @"http://online-test.idengyun.com/mtmy-app/saleAfter/querySaleAfter.do";

    uiInfo.isShowOrderButton = YES;
    NSDictionary *mtmyOrderDictionary = @{
                                          @"-2" : @"已取消",
                                          @"-1" : @"待付款",
                                          @"1" : @"待发货",
                                          @"2" : @"待收货",
                                          @"3" : @"已退款",
                                          @"4" : @"已完成"
                                          };
    uiInfo.orderStateDictionary = mtmyOrderDictionary;
    // 显示售后订单按钮
    uiInfo.isShowAfterSaleButton = YES;
    uiInfo.afterSaleOrderStateDictionary = @{
                                             @"-10" : @"拒绝退货",
                                             @"11" : @"申请退货",
                                             @"12" : @"同意退货",
                                             @"13" : @"退货中",
                                             @"14" : @"退货完成",
                                             @"15" : @"退款中",
                                             @"16" : @"已退款",
                                             @"-20" : @"拒绝换货",
                                             @"21" : @"申请换货",
                                             @"22" : @"同意换货",
                                             @"23" : @"换货退货中",
                                             @"24" : @"换货退货完成",
                                             @"25" : @"换货中",
                                             @"26" : @"换货完成",
                                             };
    /**   ----------------------END----------------------   **/

//    [self customUnReadNumber:uiInfo];

//         切换服务器地址，默认https://api.sobot.com
//    uiInfo.apiHost = @"http://221.122.116.98";
//    uiInfo.apiHost = @"https://api.sobot.com";
    uiInfo.apiHost = @"http://kefu.idengyun.com";

    // 测试模式
    [ZCSobot setShowDebug:NO];

    [self customerGoodAndLeavePageWithParameter:uiInfo];
    NSLog(@"----%@",[[NSBundle mainBundle] pathForResource:@"SobotKit" ofType: @"bundle"]);


/*

    NSString *versionNumber = @"2.6.0";
    NSString *orderStatusFlag = @"5";
    NSString *md5MixPrefix = @"mtmy";
    NSString *md5MixPostfix = @"mtmy";
    NSString *requestURL =  @"http://online-test.idengyun.com/mtmy-app/order/queryMyOrder150.do";
    //    NSString * requestURL = @"http://10.10.8.22:9214/blln-app/order/queryOrderListForKF.do";
    NSLog(@"requestURL:%@",requestURL);
    NSString *userId = [ZCLibClient getZCLibClient].libInitInfo.userId;

    NSString *paramters = [NSString stringWithFormat:@"{\"version\" : \"%@\", \"flag\" : %@, \"user_id\" : %@, \"page\" : %d}",versionNumber,orderStatusFlag,userId,1];
    NSString *paramterString = [NSString stringWithFormat:@"%@%@%@",md5MixPrefix,paramters,md5MixPostfix];
    NSString *signMd5String = zcLibMd5(paramterString);

    NSString *jsonParamters = [NSString stringWithFormat:@"%@%@",md5MixPrefix,paramters];

    NSDictionary *parameters = @{@"sign": signMd5String,
                                 @"jsonStr": jsonParamters};
    NSURL *url = [NSURL URLWithString:requestURL];
    NSLog(@"----------查询订单接口参数:%@",parameters);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";

    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:NULL];

    NSURLSession *session = [NSURLSession sharedSession];

//    __weak __typeof(self)weakSelf = self;
//    __weak __typeof(_goodsInfoArray)weakInfoArray = _goodsInfoArray;
//    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
//
//        NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//        NSLog(@"%@", result);
//        KNBQueryBackInfo *orderData = [KNBQueryBackInfo yy_modelWithJSON:result];
//        NSArray<KNBOrderInfo *> *orderArray = orderData.data;
//
//        for (KNBOrderInfo *orderInfo in orderArray) {
//            for (KNBGoodsInfo *goodsInfo in orderInfo.goodsList) {
//                goodsInfo.orderNumber = orderInfo.orderNo;
//                goodsInfo.orderDate = orderInfo.createData;
//                goodsInfo.orderId = orderInfo.orderId;
//                goodsInfo.orderState = [NSString stringWithFormat:@"%ld",(long)orderInfo.orderStatus];
//                [weakInfoArray addObject:goodsInfo];
//            }
//        }
//        if (weakInfoArray.count == 0) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                weakSelf.emptyView.hidden = NO;
//                weakSelf.refreshView.hidden = YES;
//            });
//        }
//        if (orderArray.count == 0) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                //                    _orderTableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
//                //                    _refreshView.frame = CGRectMake(0, hTopViewHeight + hTableViewHeight,
//                //                                                    ScreenWidth, 20);
//                weakSelf.refreshLabel.text = @"没有更多数据";
//            });
//            return;
//        }
//        _pageNumber ++;
//        dispatch_async(dispatch_get_main_queue(), ^{
//
//            weakSelf.orderTableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
//            weakSelf.refreshView.frame = CGRectMake(0, hTopViewHeight + hTableViewHeight,
//                                                    ScreenWidth, 20);
//            weakSelf.refreshLabel.text = @"上拉加载更多";
//            [weakSelf.orderTableView reloadData];
//        });
//    }];
//    [dataTask resume];
//}
 */
    // 启动
    [ZCSobot startZCChatView:uiInfo with:self target:nil pageBlock:^(ZCUIChatController *object, ZCPageBlockType type) {
        // 点击返回
        if(type==ZCPageBlockGoBack){
            NSLog(@"关闭聊天界面!!!");

            //            [[ZCLibClient getZCLibClient] removePush:^(NSString *uid, NSData *token, NSError *error) {
            //                NSLog(@"退出了,%@==%@",uid,error);
            //            }];
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

    ZCProductInfo *productInfo = [ZCProductInfo new];
    productInfo.thumbUrl = @"http://f12.baidu.com/it/u=3087422712,1174175413&fm=72";
    productInfo.title = @"我是商品标题我是商品标题我是商品标题我是商品标题";
    productInfo.desc = @"商品描述商品描述商品描述商品描述商品描述商品描述商品描述";
    productInfo.label = @"商品标签，价格、分类等商品标签，价格、分类等";
    productInfo.link = @"http://f12.baidu.com/it/u=3087422712,1174175413&fm=72";
    productInfo.testAdd = @"自定义的添加字段";
    uiInfo.productInfo = productInfo;

    KNBGoodsInfo *goodsInfo = [KNBGoodsInfo new];
    goodsInfo.orderNumber = @"fads49534959032234";
    goodsInfo.orderState = @"待收货";
    goodsInfo.orderDate = @"2017-01-23";
    goodsInfo.goodsTitle = @"卡萨丁佛闻风丧胆";
    goodsInfo.goodsPrice = @"2434535";
    goodsInfo.goodsImgUrl = @"http://f12.baidu.com/it/u=3087422712,1174175413&fm=72";
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
    uiInfo.orderStateDictionary = mtmyOrderDictionary;
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
