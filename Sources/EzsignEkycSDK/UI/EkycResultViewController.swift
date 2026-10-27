import UIKit

final class EkycResultViewController: UIViewController {

    private let cardView = UIView()
    private let titleLabel = UILabel()
    private let descLabel = UILabel()
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private let finishButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        finalizeEkyc()
    }

    private func setupUI() {
        view.backgroundColor = UIColor(red: 0xF5/255.0, green: 0xF6/255.0, blue: 0xFA/255.0, alpha: 1.0)
        navigationItem.hidesBackButton = true
        title = "Verifikasi"

        let shape = BackgroundShapeView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 260))
        shape.autoresizingMask = [.flexibleWidth]
        view.addSubview(shape)

        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 30
        cardView.layer.masksToBounds = true
        cardView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cardView)

        titleLabel.text = "Processing Verification"
        titleLabel.font = .boldSystemFont(ofSize: 18)
        titleLabel.textColor = UIColor(red: 0x5D/255.0, green: 0x5D/255.0, blue: 0x5D/255.0, alpha: 1.0)
        titleLabel.textAlignment = .center

        descLabel.text = "Please wait while we finalize your identity verification..."
        descLabel.font = .systemFont(ofSize: 13)
        descLabel.textColor = UIColor(red: 0x7B/255.0, green: 0x7B/255.0, blue: 0x7B/255.0, alpha: 1.0)
        descLabel.textAlignment = .center
        descLabel.numberOfLines = 0

        finishButton.setTitle("Finish", for: .normal)
        finishButton.setTitleColor(.white, for: .normal)
        finishButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .bold)
        finishButton.backgroundColor = UIColor(red: 0x15/255.0, green: 0xC1/255.0, blue: 0xE7/255.0, alpha: 1.0)
        finishButton.layer.cornerRadius = 12
        finishButton.isEnabled = false
        finishButton.addTarget(self, action: #selector(onFinishTapped), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [activityIndicator, titleLabel, descLabel, finishButton])
        stack.axis = .vertical
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(stack)

        NSLayoutConstraint.activate([
            cardView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            cardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 19),
            cardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -19),

            finishButton.heightAnchor.constraint(equalToConstant: 52),

            stack.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 32),
            stack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            stack.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -32)
        ])
    }

    private func finalizeEkyc() {
        activityIndicator.startAnimating()
        guard let client = EkycSession.shared.client else { return }

        Task {
            do {
                _ = try await client.submitLiveness(
                    bizToken: EkycSession.shared.bizToken,
                    livenessId: EkycSession.shared.livenessId
                )

                _ = try await client.updateMobile(
                    nama: EkycSession.shared.nama,
                    nik: EkycSession.shared.nik,
                    birthDate: EkycSession.shared.birthDate,
                    phone: EkycSession.shared.phone,
                    otp: EkycSession.shared.otp,
                    bizToken: EkycSession.shared.bizToken
                )

                _ = try? await client.refreshAuth()

                await MainActor.run {
                    self.activityIndicator.stopAnimating()
                    self.titleLabel.text = "Verification Complete"
                    self.descLabel.text = "Your personal identity has been verified and is waiting for RA approval."
                    self.finishButton.isEnabled = true
                }
            } catch {
                await MainActor.run {
                    self.activityIndicator.stopAnimating()
                    self.titleLabel.text = "Verification Failed"
                    self.descLabel.text = error.localizedDescription
                    self.finishButton.setTitle("Close", for: .normal)
                    self.finishButton.isEnabled = true
                }
            }
        }
    }

    @objc private func onFinishTapped() {
        let completion = EkycSession.shared.completion
        dismiss(animated: true) {
            completion?(.success(regisStatus: "wait_ra", message: "Verifikasi eKYC selesai"))
            EkycSession.shared.reset()
        }
    }
}
