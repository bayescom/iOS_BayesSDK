# MercurySDK SPM 测试 App

这是独立的 iOS App，只通过 Swift Package Manager 引用 `https://github.com/bayescom/iOS_BayesSDK.git` 的 `5.0.1` 版本，不使用 CocoaPods。

1. 打开 `MercurySDKSPMTest.xcodeproj`，等待 Xcode 解析包依赖。
2. 选择一个 iOS 模拟器或真机运行。界面显示 `MercuryConfigManager.sdkVersion()` 即表示包已导入、编译和链接成功。
3. 如需验证 SDK 初始化，输入真实的 App ID 与 App Key，点击“初始化并启动 SDK”，查看回调结果。凭据只保留在输入框中，不写入项目文件。
4. App Target 的 `Other Linker Flags` 已设置为 `$(inherited) -ObjC`，与 CocoaPods podspec 对齐。

`5.0.1` 是新增 SPM 接入的包版本，仍使用 5.0.0 的 SDK 二进制，所以界面显示的 SDK 版本为 `5.0.0`。测试 App 的部署目标为 iOS 15.0；MercurySDK 二进制声明的最低 iOS 版本仍为 10.0。实际广告场景、隐私报告和真机归档需在发布前继续验证。
