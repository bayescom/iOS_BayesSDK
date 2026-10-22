# MercurySDK

bayescom iOS SDK。

Blink倍联——免费透明的流量变现神器。600+ 移动媒体选择的广告商业化管理工具，定制私有的移动媒体商业化解决方案。优质上游资源一网打尽，接入方式快速透明稳定。支持流量分发、渠道策略、精准投放、数据报表、排期管理、广告审核等全流程业务场景。

- 官方网站：[bayescom.com](http://www.bayescom.com/)
- 源码与版本仓库：[bayescom/iOS_BayesSDK](https://github.com/bayescom/iOS_BayesSDK)
- 平台与最低版本：iOS 10.0
- 授权：[MIT](LICENSE)
- 维护者：bayescom；guangyao <wangguangyao6818@163.com>

## Swift Package Manager

在 Xcode 中选择 **File → Add Package Dependencies**，输入：

```text
https://github.com/bayescom/iOS_BayesSDK.git
```

选择 `5.0.1` 或更新版本，并把 `MercurySDK` 产品添加到 App Target。Swift 代码中使用 `import MercurySDK`。

**必需的链接设置：** 在 App Target 的 **Build Settings → Other Linker Flags** 中添加 `$(inherited) -ObjC`。MercurySDK 是包含 Objective-C Category 的静态框架；这项设置对应 podspec 中的 `OTHER_LDFLAGS = -ObjC`。SwiftPM 的 binary target 没有等价的安全参数可直接传递此链接选项，因此需要由最终 App Target 设置。

`Package.swift` 与 podspec 一样，声明了 StoreKit、CoreTelephony、AdSupport、SystemConfiguration 和 AVFoundation 五个系统框架，并引用同一份 `MercurySDK/MercurySDK.xcframework`。SwiftPM 使用 Git tag 作为包版本；仓库中的 `LICENSE` 和本文件承载 podspec 的授权、作者、简介、网站与仓库信息。

podspec 中的 `VALID_ARCHS = x86_64 armv7 arm64` 没有 SwiftPM 对应设置。实际可用架构由 XCFramework 决定：目前提供 iOS 真机 arm64，以及 iOS 模拟器 arm64、x86_64；**不包含 armv7**。

发布版本 `5.0.1` 新增 SPM 接入，仍使用原有 SDK 二进制；因此 `MercuryConfigManager.sdkVersion()` 当前返回 `5.0.0`。可用独立测试 App 检查导入、运行以及真实凭据下的初始化回调。

当前沿用的 XCFramework 尚未签名。若需使用发布团队证书签名，应在签名后创建新版本，不要改写已发布 tag 中的二进制。

## CocoaPods

```ruby
pod 'MercurySDK'
```

现有 CocoaPods 示例位于 `Example`。进入该目录执行 `pod install`，然后打开 `MercurySDK.xcworkspace`。

## 发布检查

1. 确认 XCFramework 包含目标设备和模拟器架构、公开头文件、module map 与隐私清单。
2. 使用发布团队证书签名 XCFramework，并核对隐私清单内容。
3. 用独立 App 通过 SPM 编译、运行和归档；检查实际广告流程及归档中的隐私报告。
4. 提交 `Package.swift`、文档、podspec 版本以及需要更新的二进制，然后给该提交打与 podspec 一致的 Git tag。

## License

MercurySDK is available under the MIT license. See [LICENSE](LICENSE).
