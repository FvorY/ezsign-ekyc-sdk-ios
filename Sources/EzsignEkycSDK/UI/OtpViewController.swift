import UIKit

final class OtpViewController: UIViewController {

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let cardView = UIView()

    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()

    private let phoneField = UITextField()
    private let sendOtpButton = UIButton(type: .system)
    private let timerLabel = UILabel()

    private let otpField = UITextField()
    private let verifyButton = UIButton(type: .system)
    private let activityIndicator = UIActivityIndicatorView(style: .medium)

    private var countdownTimer: Timer?
    private var remainingSeconds: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = .white
        overrideUserInterfaceStyle = .light
        title = "Verification Phone"

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

        titleLabel.text = "Verification Phone"
        titleLabel.font = EkycStyle.font(size: 17, weight: .bold)
        titleLabel.textColor = UIColor(red: 0x7B/255.0, green: 0x7B/255.0, blue: 0x7B/255.0, alpha: 1.0)

        subtitleLabel.numberOfLines = 0
        subtitleLabel.text = "Enter your active phone number to receive OTP code"
        subtitleLabel.font = EkycStyle.font(size: 12)
        subtitleLabel.textColor = UIColor(red: 0x7B/255.0, green: 0x7B/255.0, blue: 0x7B/255.0, alpha: 1.0)

        configureTextField(phoneField, placeholder: "Phone Number", keyboardType: .phonePad)
        phoneField.text = "+62"

        sendOtpButton.setTitle("Send OTP", for: .normal)
        sendOtpButton.setTitleColor(UIColor(red: 0x15/255.0, green: 0xC1/255.0, blue: 0xE7/255.0, alpha: 1.0), for: .normal)
        sendOtpButton.layer.borderWidth = 1
        sendOtpButton.layer.borderColor = UIColor(red: 0x15/255.0, green: 0xC1/255.0, blue: 0xE7/255.0, alpha: 1.0).cgColor
        sendOtpButton.layer.cornerRadius = 8
        sendOtpButton.titleLabel?.font = EkycStyle.font(size: 13, weight: .semibold)
        sendOtpButton.addTarget(self, action: #selector(onSendOtpTapped), for: .touchUpInside)

        let phoneRow = UIStackView(arrangedSubviews: [phoneField, sendOtpButton])
        phoneRow.axis = .horizontal
        phoneRow.spacing = 8
        sendOtpButton.widthAnchor.constraint(equalToConstant: 95).isActive = true

        timerLabel.font = EkycStyle.font(size: 12)
        timerLabel.textColor = UIColor(red: 0x7B/255.0, green: 0x7B/255.0, blue: 0x7B/255.0, alpha: 1.0)
        timerLabel.isHidden = true

        configureTextField(otpField, placeholder: "Verification Code", keyboardType: .numberPad)

        verifyButton.setTitle("Continue", for: .normal)
        verifyButton.setTitleColor(.white, for: .normal)
        verifyButton.titleLabel?.font = EkycStyle.font(size: 14, weight: .medium)
        verifyButton.backgroundColor = UIColor(red: 0x15/255.0, green: 0xC1/255.0, blue: 0xE7/255.0, alpha: 1.0)
        verifyButton.layer.cornerRadius = 25
        verifyButton.addTarget(self, action: #selector(onVerifyTapped), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [
            titleLabel, subtitleLabel, phoneRow, timerLabel, otpField, activityIndicator, verifyButton
        ])
        stack.axis = .vertical
        stack.spacing = 15
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

            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),

            verifyButton.heightAnchor.constraint(equalToConstant: 50),

            stack.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            stack.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -20)
        ])
    }

    private func configureTextField(_ tf: UITextField, placeholder: String, keyboardType: UIKeyboardType = .default) {
        tf.placeholder = placeholder
        EkycStyle.configureField(tf)
        tf.keyboardType = keyboardType
        tf.borderStyle = .none
        tf.layer.cornerRadius = 8
        tf.layer.borderWidth = 1
        tf.layer.borderColor = UIColor(white: 0.85, alpha: 1.0).cgColor
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 48))
        tf.leftViewMode = .always
        tf.heightAnchor.constraint(equalToConstant: 48).isActive = true
    }

    @objc private func onSendOtpTapped() {
        guard let phone = PhoneNumber.normalize(phoneField.text ?? "") else {
            showAlert(title: "Perhatian", message: "Nomor handphone tidak valid.")
            return
        }

        guard let client = EkycSession.shared.client else { return }
        activityIndicator.startAnimating()
        sendOtpButton.isEnabled = false

        Task {
            do {
                let res = try await client.validatePhone(phone: phone)
                await MainActor.run {
                    self.activityIndicator.stopAnimating()
                    EkycSession.shared.phone = phone
                    let cooldown = Int((res.data?.cooldown ?? 2.0) * 60)
                    self.startTimer(seconds: cooldown)
                }
            } catch {
                await MainActor.run {
                    self.activityIndicator.stopAnimating()
                    self.sendOtpButton.isEnabled = true
                    self.showAlert(title: "Gagal", message: error.localizedDescription)
                }
            }
        }
    }

    private func startTimer(seconds: Int) {
        countdownTimer?.invalidate()
        remainingSeconds = seconds
        timerLabel.isHidden = false

        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            self.remainingSeconds -= 1
            self.timerLabel.text = "Kirim ulang dalam \(self.remainingSeconds) detik"
            if self.remainingSeconds <= 0 {
                timer.invalidate()
                self.timerLabel.isHidden = true
                self.sendOtpButton.isEnabled = true
            }
        }
    }

    @objc private func onVerifyTapped() {
        let phone = EkycSession.shared.phone
        let otp = otpField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        guard !phone.isEmpty else {
            showAlert(title: "Perhatian", message: "Kirim OTP terlebih dahulu.")
            return
        }

        guard otp.count == 6 else {
            showAlert(title: "Perhatian", message: "Masukkan 6 digit kode OTP.")
            return
        }

        guard let client = EkycSession.shared.client else { return }
        activityIndicator.startAnimating()
        verifyButton.isEnabled = false

        Task {
            do {
                let res = try await client.verifyOtp(phone: phone, otp: otp)
                await MainActor.run {
                    self.activityIndicator.stopAnimating()
                    self.verifyButton.isEnabled = true
                    EkycSession.shared.otp = otp
                    EkycSession.shared.verifyToken = res.data?.token

                    let livenessVC = LivenessInstructionViewController()
                    self.navigationController?.pushViewController(livenessVC, animated: true)
                }
            } catch {
                await MainActor.run {
                    self.activityIndicator.stopAnimating()
                    self.verifyButton.isEnabled = true
                    self.showAlert(title: "Gagal", message: error.localizedDescription)
                }
            }
        }
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    deinit {
        countdownTimer?.invalidate()
    }
}
