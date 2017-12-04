//
//  KNBOrderViewController.m
//  SobotKit
//
//  Created by suojl on 2017/11/1.
//  Copyright © 2017年 zhichi. All rights reserved.
//

#import "KNBOrderViewController.h"
#import "ZCUIColorsDefine.h"
#import "ZCLIbGlobalDefine.h"
#import "KNBHistoryOrderCell.h"
#import "KNBOrderInfo.h"
#import "NSObject+YYModel.h"
#import "ZCLibClient.h"
#import "ZCUIConfigManager.h"

#define kHistoryOrderCell @"KNBHistoryOrderCell"

@interface KNBOrderViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    UILabel     *_titleLabel;       // 显示标题
    UIButton    *_closeBtn;         // 关闭按钮

    NSMutableArray  *_goodsInfoArray;

    UIView      *_emptyView;

    int _pageNumber;

}

@end

@implementation KNBOrderViewController

//  显示的tableview的高度
int hTableViewHeight = 227;
//  头部视图的高度
int hTopViewHeight = 45;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _pageNumber = 1;
    [self setupUI];
    _goodsInfoArray = [[NSMutableArray alloc] initWithCapacity:10];

        [self getDatasourceByNetwork];
    // 设置自动切换透明度(在导航栏下面自动隐藏)
//    _orderTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(getDatasourceByNetwork)];
//    [_orderTableView.mj_footer beginRefreshing];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/**
 初始化UI界面
 */
-(void)setupUI{
    CGFloat viewWidth = self.view.frame.size.width;
//    CGFloat viewHeight = self.view.frame.size.height;
    [self.view setBackgroundColor:[UIColor whiteColor]];
    _topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, viewWidth, hTopViewHeight)];
    [_topView setBackgroundColor:UIColorFromRGB(0xffffff)];
    _topView.layer.borderWidth = 1.0f;
    _topView.layer.borderColor = UIColorFromRGB(0xe6e7e5).CGColor;
    [self.view addSubview:_topView];

    // 初始化订单TableView
    _orderTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, hTopViewHeight, ScreenWidth, hTableViewHeight) style:UITableViewStylePlain];
    _orderTableView.delegate = self;
    _orderTableView.dataSource = self;
//    [_orderTableView setSeparatorColor:UIColorFromRGB(0xe6e7e5)];
    [_orderTableView setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    [_orderTableView registerClass:[KNBHistoryOrderCell class] forCellReuseIdentifier:kHistoryOrderCell];
    _orderTableView.backgroundColor = [UIColor clearColor];
    _orderTableView.tableFooterView = [UIView new];
    [self.view addSubview:_orderTableView];

    _titleLabel = [[UILabel alloc] init];
    _titleLabel.font = [UIFont systemFontOfSize:14];
    _titleLabel.numberOfLines = 1;
    _titleLabel.text = @"请点击想要发送的订单";
    _titleLabel.textColor = UIColorFromRGB(0x999999);
    _titleLabel.frame = CGRectMake(15, 15, ScreenWidth - 45, 15);
    [self.topView addSubview:_titleLabel];

    _closeBtn = [[UIButton alloc] init];
    [_closeBtn setImage:[ZCUITools knbUiGetBundleImage:@"KeFu_close"] forState:UIControlStateNormal];
    [_closeBtn addTarget:self action:@selector(closeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_closeBtn setFrame:CGRectMake(ScreenWidth - 45, 0, 45, 45)];
    [self.topView addSubview:_closeBtn];

    // 布局界面frame
//    _titleLabel.sd_layout.leftSpaceToView(_topView, 15).centerYEqualToView(_topView)
//    .widthIs(ScreenWidth - 45).heightIs(15);
//    _closeBtn.sd_layout.rightSpaceToView(_topView, 15).centerYEqualToView(_topView)
//    .widthIs(15).heightIs(15);

    /*---空页面---*/

    _emptyView = [[UIView alloc] initWithFrame:_orderTableView.frame];
    _emptyView.backgroundColor = [UIColor whiteColor];
    _emptyView.hidden = YES;
    CGFloat imageView_X = _orderTableView.frame.size.width/2 - 50;
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[ZCUITools knbUiGetBundleImage:@"KeFu_No_order"]];
    imageView.frame = CGRectMake(imageView_X, 55, 100, 81);
    [_emptyView addSubview:imageView];
    CGFloat labelY = CGRectGetMaxY(imageView.frame) + 20;
    UILabel *detailsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, labelY, viewWidth, 15)];
    detailsLabel.textAlignment = NSTextAlignmentCenter;
    detailsLabel.textColor = UIColorFromRGB(0x999999);
    detailsLabel.text = @"您还没有订单~";
    [_emptyView addSubview:detailsLabel];
    [self.view addSubview:_emptyView];
    [self createRefreshView];
}

//创建刷新的view,在屏幕外边,先添加到屏幕上,然后在添加tableView
-(void)createRefreshView
{
//    CGFloat refreshView_Y = CGRectGetMaxY(_orderTableView.frame);
    _refreshView = [[UIView alloc]initWithFrame:CGRectMake(0, hTopViewHeight+5, ScreenWidth, 20)];
    _refreshView.backgroundColor = [UIColor whiteColor];
    _refreshLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 20)];
    _refreshLabel.text = @"正在加载数据~";
    _refreshLabel.font = [UIFont systemFontOfSize:15];
    _refreshLabel.textColor = UIColorFromRGB(0xef508d);
    _refreshLabel.textAlignment = NSTextAlignmentCenter;

    [_refreshView addSubview:_refreshLabel];
    [self.view addSubview:_refreshView];
    [self.view bringSubviewToFront:_refreshView];
}

-(void)getDatasourceByNetwork{

    NSString *versionNumber = [ZCUIConfigManager getInstance].kitInfo.versioNumber;
    NSString *orderStatusFlag = [ZCUIConfigManager getInstance].kitInfo.orderStatusFlag;
    NSString *md5MixPrefix = [ZCUIConfigManager getInstance].kitInfo.md5MixPrefix;
    NSString *md5MixPostfix = [ZCUIConfigManager getInstance].kitInfo.md5MixPostfix;
    NSString *requestURL =  [ZCUIConfigManager getInstance].kitInfo.queryOrderListForKF;
//    NSString * requestURL = @"http://10.10.8.22:9214/blln-app/order/queryOrderListForKF.do";

    NSString *userId = [ZCLibClient getZCLibClient].libInitInfo.userId;

    NSString *paramters = [NSString stringWithFormat:@"{\"version\" : \"%@\", \"flag\" : %@, \"user_id\" : %@, \"page\" : %d}",versionNumber,orderStatusFlag,userId,_pageNumber];
    NSString *paramterString = [NSString stringWithFormat:@"%@%@%@",md5MixPrefix,paramters,md5MixPostfix];
    NSString *signMd5String = zcLibMd5(paramterString);
    NSString *jsonParamters = [NSString stringWithFormat:@"%@%@",md5MixPrefix,paramters];

    NSDictionary *parameters = @{@"sign": signMd5String,
                                 @"jsonStr": jsonParamters};
    NSURL *url = [NSURL URLWithString:requestURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";

    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:NULL];

    NSURLSession *session = [NSURLSession sharedSession];

    __weak __typeof(self)weakSelf = self;
    __weak __typeof(_goodsInfoArray)weakInfoArray = _goodsInfoArray;
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {

            NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"%@", result);
            KNBQueryBackInfo *orderData = [KNBQueryBackInfo yy_modelWithJSON:result];
             NSArray<KNBOrderInfo *> *orderArray = orderData.data;

             for (KNBOrderInfo *orderInfo in orderArray) {
                 for (KNBGoodsInfo *goodsInfo in orderInfo.goodsList) {
                     goodsInfo.orderNumber = orderInfo.orderNo;
                     goodsInfo.orderDate = orderInfo.createData;
                     goodsInfo.orderId = orderInfo.orderId;
                     goodsInfo.orderState = [NSString stringWithFormat:@"%ld",(long)orderInfo.orderStatus];
                     [weakInfoArray addObject:goodsInfo];
                 }
             }
             if (weakInfoArray.count == 0) {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     weakSelf.emptyView.hidden = NO;
                 });
             }
            if (orderArray.count == 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
//                    _orderTableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
//                    _refreshView.frame = CGRectMake(0, hTopViewHeight + hTableViewHeight,
//                                                    ScreenWidth, 20);
                    weakSelf.refreshLabel.text = @"没有更多数据";
                });
                return;
            }
            _pageNumber ++;
            dispatch_async(dispatch_get_main_queue(), ^{

                weakSelf.orderTableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
                weakSelf.refreshView.frame = CGRectMake(0, hTopViewHeight + hTableViewHeight,
                                                ScreenWidth, 20);
                weakSelf.refreshLabel.text = @"上拉加载更多";
                [weakSelf.orderTableView reloadData];
            });
    }];
    [dataTask resume];
}
-(void)closeBtnClick:(UIButton *)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark- UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _goodsInfoArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    KNBHistoryOrderCell *cell = [tableView dequeueReusableCellWithIdentifier:kHistoryOrderCell];
    if (cell == nil) {
        cell = [[KNBHistoryOrderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kHistoryOrderCell];
    }
    cell.goodsInfo = [_goodsInfoArray objectAtIndex:indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    KNBGoodsInfo *goodsInfo = [_goodsInfoArray objectAtIndex:indexPath.row];
    NSString *sendMessageString = [self makeGoodsToMessage:goodsInfo];
    if (self.vcDelegate && [self.vcDelegate respondsToSelector:@selector(dismissViewController:andSendOrderMessage:)]) {
        [self.vcDelegate dismissViewController:self andSendOrderMessage:sendMessageString];
    }
}
#pragma mark- UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 113;
}

-(NSString *)makeGoodsToMessage:(KNBGoodsInfo *)goodsInfo{
//        [消息类型]:[123]
//        [订单编号]:[18264532919127139187478]
//        [商品编号]:[023823]
//        [订单状态]:[代收货]
//        [商品首图]:[http://f12.baidu.com/it/u=3087422712,1174175413&fm=72]
//        [商品金额]:[1232323]
//        [订单日期]:[2017-10-23]
    NSString *contextStr = @"[消息类型]:[订单]\n";
    contextStr = [contextStr stringByAppendingFormat:@"[订单编号]:[%@]\n",goodsInfo.orderNumber];
    contextStr = [contextStr stringByAppendingFormat:@"[订单状态]:[%@]\n",goodsInfo.orderState];
    contextStr = [contextStr stringByAppendingFormat:@"[下单时间]:[%@]\n",goodsInfo.orderDate];
    contextStr = [contextStr stringByAppendingFormat:@"[商品名称]:[%@]\n",goodsInfo.goodsTitle];
    contextStr = [contextStr stringByAppendingFormat:@"[商品价格]:[%@]\n",goodsInfo.goodsPrice];
    contextStr = [contextStr stringByAppendingFormat:@"[商品首图]:[%@]",goodsInfo.goodsImgUrl];

    return contextStr;
}

//检测tableView的滚动
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y + scrollView.frame.size.height >= scrollView.contentSize.height) {

        CGFloat move = scrollView.contentOffset.y + scrollView.frame.size.height - scrollView.contentSize.height;
        if (move <= 20) {
                _orderTableView.contentInset = UIEdgeInsetsMake(0, 0, move, 0);
                CGFloat refreshView_Y = CGRectGetMaxY(_orderTableView.frame);
                _refreshView.frame = CGRectMake(0, refreshView_Y - move, ScreenWidth, 20);
        }
    }else{
        _orderTableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        _refreshView.frame = CGRectMake(0, hTopViewHeight + hTableViewHeight,
                                        ScreenWidth, 20);
    }
}

//tableView滚动结束后调用的方法
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    CGFloat offset = scrollView.contentOffset.y + scrollView.frame.size.height - scrollView.contentSize.height;
    if (offset >= 20) {
        _refreshLabel.text = @"正在加载数据";
        [self getDatasourceByNetwork];
    }else{
        _orderTableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        _refreshView.frame = CGRectMake(0, hTopViewHeight + hTableViewHeight,
                                        ScreenWidth, 20);
    }
}

@end
