//
//  MercuryWebViewController.m
//  MercurySDK
//
//  Created by CherryKing on 2020/3/16.
//  Copyright © 2020 Mercury. All rights reserved.
//

#import "MercuryWebViewController.h"
#import <WebKit/WebKit.h>
#import "UIWindow+Mercury.h"
#import "MercuryPriHeader.h"

@interface MercuryWebViewController () <WKNavigationDelegate, WKUIDelegate>
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) NSString *urlStr;
@property (nonatomic, weak) id<MercuryBaseAdSKVCDelegate> delegate;

@end

@implementation MercuryWebViewController

+ (UINavigationController *)navcWithUrl:(NSString *)url delegate:(id<MercuryBaseAdSKVCDelegate>)delegate {
    UINavigationController *navc = [[UINavigationController alloc] initWithRootViewController:[[MercuryWebViewController alloc] initWithUrl:url delegate:delegate]];
    navc.modalPresentationStyle = 0;
    return navc;
}

- (instancetype)initWithUrl:(NSString *)url delegate:(id<MercuryBaseAdSKVCDelegate>)delegate {
    if (self = [super init]) {
        self.urlStr = url;
        self.delegate = delegate;
        self.modalPresentationStyle = 0;
    }
    return self;
}

- (void)dealloc {
    NSLog(@"%s", __func__);
}

- (void)setUrlStr:(NSString *)urlStr {
    _urlStr = urlStr;
    
    NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:_urlStr]];
    [self.webView loadRequest:req];
    // 检测title
    [self.webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"title"]) {
        if (object == self.webView) {
            self.title = self.webView.title;
        } else {
            [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;

    UIImage *backImg = [kMercuryImageNamed(@"_mercury_sdk3_0_webv_back") imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIImage *closeImg = [kMercuryImageNamed(@"_mercury_sdk3_0_webv_close") imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];

    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn setImage:backImg forState:UIControlStateNormal];
    backBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    backBtn.frame = CGRectMake(0, 0, 44, 44);
    backBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [backBtn addTarget:self action:@selector(webBack) forControlEvents:UIControlEventTouchUpInside];

    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeBtn setImage:closeImg forState:UIControlStateNormal];
    closeBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    closeBtn.frame = CGRectMake(0, 0, 44, 44);
    [closeBtn addTarget:self action:@selector(dismissSelf) forControlEvents:UIControlEventTouchUpInside];

    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    UIBarButtonItem *closeItem = [[UIBarButtonItem alloc] initWithCustomView:closeBtn];
    
    if (@available(iOS 11.0, *)) {
        backBtn.contentEdgeInsets = UIEdgeInsetsMake(0, -16, 0, 0);
        backBtn.imageEdgeInsets = UIEdgeInsetsMake(0, -16, 0, 0);
        backBtn.titleEdgeInsets = UIEdgeInsetsMake(0, -16, 0, 0);
        
        closeBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -16);
        closeBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -16);
        closeBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -16);
        
        self.navigationItem.leftBarButtonItems = @[backItem];
        self.navigationItem.rightBarButtonItems = @[closeItem];
    } else {
        UIBarButtonItem *negativeSpacer1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        negativeSpacer1.width = -16;
        UIBarButtonItem *negativeSpacer2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        negativeSpacer2.width = -16;
        
        self.navigationItem.leftBarButtonItems = @[negativeSpacer1, backItem];
        self.navigationItem.rightBarButtonItems = @[negativeSpacer2, closeItem];
    }

    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.view addSubview:self.webView];
    self.navigationController.navigationBar.translucent = NO;
    [self.webView.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:0].active = YES;
    [self.webView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor].active = YES;
    [self.webView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor].active = YES;
    [self.webView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
    
    if ([_delegate respondsToSelector:@selector(_mercury_skvcWillPresentFullScreenModal)]) {
        [_delegate _mercury_skvcWillPresentFullScreenModal];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ([_delegate respondsToSelector:@selector(_mercury_skvcDidPresentFullScreenModal)]) {
        [_delegate _mercury_skvcDidPresentFullScreenModal];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if ([_delegate respondsToSelector:@selector(_mercury_skvcWillDismissFullScreenModal)]) {
        [_delegate _mercury_skvcWillDismissFullScreenModal];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.webView removeObserver:self forKeyPath:@"title"];
    self.title = @"";
    if ([_delegate respondsToSelector:@selector(_mercury_skvcDidDismissFullScreenModal)]) {
        [_delegate _mercury_skvcDidDismissFullScreenModal];
    }
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    if (navigationAction.targetFrame == nil) {
        [webView loadRequest:navigationAction.request];
    }
    
    // 全部拦截
    // 判断是否是ulink
    if (@available(iOS 10.0, *)) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:navigationAction.request.URL.absoluteString] options:@{UIApplicationOpenURLOptionUniversalLinksOnly:@(YES)} completionHandler:^(BOOL success) {
            if (success) { } else {
                [self checkIsSchemeUrl:navigationAction.request.URL];
            }
        }];
    } else {
        [self checkIsSchemeUrl:navigationAction.request.URL];
    }
    
    // 拦截schem方式跳转
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)checkIsSchemeUrl:(NSURL *)url {
    NSArray *normalLink = @[@"http", @"https"];
    BOOL isScheme = ![normalLink containsObject:url.scheme];
    if (isScheme) {
        // 检测到scheme调整 走openurl
        if (@available(iOS 10.0, *)) {
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
                if (success) {
                    NSLog(@"成功打开了scheme");
                    [self dismissViewControllerAnimated:YES completion:nil];
                }
            }];
        } else {
            [[UIApplication sharedApplication] openURL:url];
        }
    }
}

- (void)dismissSelf {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)webBack {
    if (_webView.canGoBack) {
        [_webView goBack];
    } else {
//        [self dismissSelf];
    }
}

// MARK: ======================= get =======================
- (WKWebView *)webView {
    if (!_webView) {
        WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
        _webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:config];
        _webView.allowsBackForwardNavigationGestures = YES;
        _webView.backgroundColor = [UIColor clearColor];
        _webView.scrollView.backgroundColor = [UIColor clearColor];
        _webView.translatesAutoresizingMaskIntoConstraints = NO;
        _webView.UIDelegate = self;
        _webView.navigationDelegate = self;
    }
    return _webView;
}

@end
