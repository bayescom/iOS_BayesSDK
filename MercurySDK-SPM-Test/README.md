# MercurySDK SPM 测试 App

这是仓库内的 iOS 测试 App，用于在发布 Git tag 后通过 Swift Package Manager 验证远程接入，不使用 CocoaPods。工程目前未绑定 `MercurySDK` 包，需要手动添加依赖后才能编译。

1. 打开 `MercurySDKSPMTest.xcodeproj`，选择 **File → Add Package Dependencies**。
2. 输入 `https://github.com/bayescom/iOS_BayesSDK.git`，选择 **Exact Version** `5.0.1`，将 `MercurySDK` 产品添加到 App Target。
3. 选择一个 iOS 模拟器或真机运行。界面显示 `MercuryConfigManager.sdkVersion()` 即表示包已导入、编译和链接成功。
4. 如需验证 SDK 初始化，输入真实的 App ID 与 App Key，点击“初始化并启动 SDK”，查看回调结果。凭据只保留在输入框中，不写入项目文件。

App Target 的 `Other Linker Flags` 已设置为 `$(inherited) -ObjC`，与 CocoaPods podspec 对齐。

当前 MercurySDK 二进制版本为 `5.0.1`，界面中的 SDK 版本也应显示 `5.0.1`。测试 App 的部署目标为 iOS 15.0；MercurySDK 二进制声明的最低 iOS 版本仍为 10.0。

实际广告场景、隐私报告和真机归档仍需单独验证。
