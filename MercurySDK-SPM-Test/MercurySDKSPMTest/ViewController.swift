import UIKit
import MercurySDK

final class ViewController: UIViewController {
    private let appIDField = UITextField()
    private let appKeyField = UITextField()
    private let statusLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "MercurySDK SPM Test"
        view.backgroundColor = .systemBackground

        let versionLabel = UILabel()
        versionLabel.text = "SDK 版本：\(MercuryConfigManager.sdkVersion())"
        versionLabel.numberOfLines = 0

        let helpLabel = UILabel()
        helpLabel.text = "已通过 SPM 导入 MercurySDK。输入真实的 App ID 和 App Key 后，可验证 SDK 启动回调。"
        helpLabel.numberOfLines = 0
        helpLabel.font = .preferredFont(forTextStyle: .subheadline)

        appIDField.placeholder = "App ID"
        appIDField.borderStyle = .roundedRect
        appIDField.autocapitalizationType = .none
        appIDField.autocorrectionType = .no

        appKeyField.placeholder = "App Key"
        appKeyField.borderStyle = .roundedRect
        appKeyField.autocapitalizationType = .none
        appKeyField.autocorrectionType = .no

        let startButton = UIButton(type: .system)
        startButton.setTitle("初始化并启动 SDK", for: .normal)
        startButton.addTarget(self, action: #selector(startSDK), for: .touchUpInside)

        statusLabel.text = "等待测试"
        statusLabel.numberOfLines = 0
        statusLabel.accessibilityIdentifier = "sdkStatus"

        let stack = UIStackView(arrangedSubviews: [versionLabel, helpLabel, appIDField, appKeyField, startButton, statusLabel])
        stack.axis = .vertical
        stack.spacing = 18
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32)
        ])
    }

    @objc private func startSDK() {
        let appID = appIDField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let appKey = appKeyField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !appID.isEmpty, !appKey.isEmpty else {
            statusLabel.text = "请先输入 App ID 和 App Key"
            return
        }

        statusLabel.text = "正在启动 SDK…"
        MercuryConfigManager.initWithAppId(appID, appKey: appKey)
        MercuryConfigManager.start { [weak self] success, error in
            DispatchQueue.main.async {
                self?.statusLabel.text = success
                    ? "SDK 启动成功"
                    : "SDK 启动失败：\(error.localizedDescription)"
            }
        }
    }
}
