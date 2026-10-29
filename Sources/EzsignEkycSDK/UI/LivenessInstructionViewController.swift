import UIKit
import AVFoundation
import MegLiveV5Detect

final class LivenessInstructionViewController: UIViewController {

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let cardView = UIView()

    private let titleLabel = UILabel()
    private let illustrationView = UIImageView()
    private let promptLabel = UILabel()

    private let startButton = UIButton(type: .system)
    private let activityIndicator = UIActivityIndicatorView(style: .medium)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = .white
        overrideUserInterfaceStyle = .light
        title = "Active Liveness Check"

        let shape = BackgroundShapeView(frame: CGRect(x: 0, y: -view.safeAreaInsets.top, width: view.bounds.width, height: 430))
        shape.autoresizingMask = [.flexibleWidth]
        view.addSubview(shape)

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        cardView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(cardView)

        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 30
        cardView.layer.masksToBounds = true

        titleLabel.text = "Preparation Before Active Liveness Check"
        titleLabel.font = EkycStyle.font(size: 14, weight: .medium)
        titleLabel.numberOfLines = 0
        titleLabel.textColor = UIColor(red: 0x5D/255.0, green: 0x5D/255.0, blue: 0x5D/255.0, alpha: 1.0)
        titleLabel.textAlignment = .center

        illustrationView.contentMode = .scaleAspectFit
        illustrationView.image = loadImage(named: "pre_active_liveness")

        promptLabel.numberOfLines = 0
        promptLabel.text = "For the best verification results, please make sure that:"
        promptLabel.font = EkycStyle.font(size: 12, weight: .medium)
        promptLabel.textColor = UIColor(red: 0x7B/255.0, green: 0x7B/255.0, blue: 0x7B/255.0, alpha: 1.0)

        let item1 = createChecklistItem(number: "1", title: "Lighting is good", desc: "Stay in a well-lit room and avoid strong backlight")
        let item2 = createChecklistItem(number: "2", title: "Your face is clearly visible", desc: "Remove any masks, sunglasses, or face coverings")
        let item3 = createChecklistItem(number: "3", title: "Your device is held steadily", desc: "Keep the camera stable and avoid shaking")
        let item4 = createChecklistItem(number: "4", title: "The background is simple", desc: "preferably in front of a plain wall")
        let item5 = createChecklistItem(number: "5", title: "Follow the instructions", desc: "you may be asked to perform certain actions (e.g., turn your head, blink, or smile)")

        let footerLabel = UILabel()
        footerLabel.numberOfLines = 0
        footerLabel.text = "When you are ready, select “Start Liveness” to proceed"
        footerLabel.font = EkycStyle.font(size: 12)
        footerLabel.textColor = UIColor(red: 0xAA/255.0, green: 0xAA/255.0, blue: 0xAA/255.0, alpha: 1.0)
        footerLabel.textAlignment = .center

        startButton.setTitle("Start Liveness", for: .normal)
        startButton.setTitleColor(.white, for: .normal)
        startButton.titleLabel?.font = EkycStyle.font(size: 14, weight: .medium)
        startButton.backgroundColor = UIColor(red: 0x15/255.0, green: 0xC1/255.0, blue: 0xE7/255.0, alpha: 1.0)
        startButton.layer.cornerRadius = 25
        startButton.addTarget(self, action: #selector(onStartTapped), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [
            titleLabel, illustrationView, promptLabel, item1, item2, item3, item4, item5, footerLabel, activityIndicator, startButton
        ])
        stack.axis = .vertical
        stack.spacing = 16
        stack.setCustomSpacing(60, after: titleLabel)
        stack.setCustomSpacing(60, after: illustrationView)
        stack.setCustomSpacing(28, after: item5)
        stack.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(stack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 19),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -19),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),

            illustrationView.heightAnchor.constraint(equalToConstant: 136),
            startButton.heightAnchor.constraint(equalToConstant: 50),

            stack.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            stack.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -20)
        ])
    }

    private func createChecklistItem(number: String, title: String, desc: String) -> UIView {
        let container = UIView()

        let badge = UILabel()
        badge.text = number
        badge.textColor = .white
        badge.font = EkycStyle.font(size: 14, weight: .bold)
        badge.textAlignment = .center
        badge.backgroundColor = UIColor(red: 0x15/255.0, green: 0xC1/255.0, blue: 0xE7/255.0, alpha: 1.0)
        badge.layer.cornerRadius = 14
        badge.layer.masksToBounds = true
        badge.translatesAutoresizingMaskIntoConstraints = false

        let titleLbl = UILabel()
        titleLbl.text = title
        titleLbl.font = EkycStyle.font(size: 12, weight: .bold)
        titleLbl.textColor = UIColor(red: 0x7B/255.0, green: 0x7B/255.0, blue: 0x7B/255.0, alpha: 1.0)

        let descLbl = UILabel()
        descLbl.text = desc
        descLbl.font = EkycStyle.font(size: 12)
        descLbl.textColor = UIColor(red: 0xAA/255.0, green: 0xAA/255.0, blue: 0xAA/255.0, alpha: 1.0)
        descLbl.numberOfLines = 0

        let textStack = UIStackView(arrangedSubviews: [titleLbl, descLbl])
        textStack.axis = .vertical
        textStack.spacing = 2
        textStack.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(badge)
        container.addSubview(textStack)

        NSLayoutConstraint.activate([
            badge.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            badge.topAnchor.constraint(equalTo: container.topAnchor),
            badge.widthAnchor.constraint(equalToConstant: 28),
            badge.heightAnchor.constraint(equalToConstant: 28),

            textStack.leadingAnchor.constraint(equalTo: badge.trailingAnchor, constant: 12),
            textStack.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            textStack.topAnchor.constraint(equalTo: container.topAnchor),
            textStack.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])

        return container
    }

    @objc private func onStartTapped() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            prepareAndLaunchLiveness()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    if granted {
                        self?.prepareAndLaunchLiveness()
                    } else {
                        self?.showAlert(title: "Perhatian", message: "Izin kamera diperlukan untuk melakukan liveness check.")
                    }
                }
            }
        default:
            showAlert(title: "Perhatian", message: "Buka pengaturan perangkat untuk mengaktifkan izin kamera.")
        }
    }

    private func prepareAndLaunchLiveness() {
        guard let client = EkycSession.shared.client else { return }
        activityIndicator.startAnimating()
        startButton.isEnabled = false

        Task {
            do {
                let res = try await client.getBizToken()
                await MainActor.run {
                    self.activityIndicator.stopAnimating()
                    self.startButton.isEnabled = true

                    guard let data = res.data else {
                        self.showAlert(title: "Gagal", message: "Gagal mendapatkan token liveness.")
                        return
                    }

                    EkycSession.shared.bizToken = data.biz_token
                    EkycSession.shared.livenessId = data.liveness_id

                    self.startMegviiLiveness(bizToken: data.biz_token)
                }
            } catch {
                await MainActor.run {
                    self.activityIndicator.stopAnimating()
                    self.startButton.isEnabled = true
                    self.showAlert(title: "Gagal", message: error.localizedDescription)
                }
            }
        }
    }

    private func startMegviiLiveness(bizToken: String) {
        let config = MegLiveV5DetectInitConfigItem()
        config.phoneVertical = MegLiveV5DetectPhoneVerticalTypeDisable
        config.hostURL = "https://api-idn.megvii.com"
        config.bundleFilePath = EkycStyle.bundle.path(forResource: "MegLiveV5Detect", ofType: "bundle") ?? ""

        MegLiveV5DetectManager.megFaceIDLive(
            withBizToken: bizToken,
            configInfo: config,
            extraData: nil,
            startCallBack: { error, extra in
                if let err = error, err.errorCode.rawValue != 1000 {
                    DispatchQueue.main.async {
                        self.showMegviiError(code: Int(err.errorCode.rawValue), message: err.errorMessage)
                    }
                }
            },
            detectVC: self,
            endCallBack: { [weak self] error, token, extra in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    if let err = error, err.errorCode.rawValue == 1000 {
                        let resultVC = EkycResultViewController()
                        self.navigationController?.pushViewController(resultVC, animated: true)
                    } else {
                        self.showMegviiError(code: Int(error?.errorCode.rawValue ?? 0), message: error?.errorMessage ?? "")
                    }
                }
            },
            dismissCallBack: {}
        )
    }

    private func showMegviiError(code: Int, message: String) {
        let title = code == Self.megviiUserCancel ? "Liveness Cancelled" : "Liveness Check Failed"
        showAlert(title: title, message: describeMegviiError(code: code, message: message))
    }

    private static let megviiUserCancel = 1011
    private static let megviiNoCameraPermission = 1012
    private static let megviiDeviceNotSupported: Set<Int> = [1004, 1009, 1013]
    private static let megviiRetryable: Set<Int> = [1001, 1002, 1003, 1005, 1006, 1007, 1008, 1010, 1014, 1016, 1017, 1018, 1019]

    // Same grouping as the ezSign Flutter app. Megvii validates its license against the host
    // app's bundle ID, so AUTHENTICATION_FAIL / bundleid_error names the rejected bundle ID.
    private func describeMegviiError(code: Int, message: String) -> String {
        let upper = message.uppercased()
        let text: String
        if upper.contains("AUTHENTICATION_FAIL") || upper.contains("BUNDLEID") {
            let bundleId = Bundle.main.bundleIdentifier ?? "-"
            text = "The liveness license rejected \(bundleId). Register this bundle ID with the ezSign liveness license. (\(message))"
        } else if code == Self.megviiUserCancel {
            return "Liveness has been cancelled"
        } else if code == Self.megviiNoCameraPermission {
            text = "Camera permission is required. Please allow camera access and try again."
        } else if Self.megviiDeviceNotSupported.contains(code) {
            text = "Your device is currently not supported. Please try using a different device."
        } else if Self.megviiRetryable.contains(code) {
            text = "We couldn't complete the liveness check. Please try again in a few moments."
        } else if !message.isEmpty {
            text = message
        } else {
            text = "We couldn't complete the liveness check."
        }
        return "\(text) (\(code))"
    }

    private func loadImage(named: String) -> UIImage? {
        EkycStyle.image(named: named)
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
