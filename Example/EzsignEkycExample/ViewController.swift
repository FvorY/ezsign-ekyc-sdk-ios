import UIKit
import EzsignEkycSDK

class ViewController: UIViewController {

    private let tokenField = UITextField()
    private let startButton = UIButton(type: .system)
    private let statusLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0xF5/255.0, green: 0xF6/255.0, blue: 0xFA/255.0, alpha: 1.0)

        let titleLabel = UILabel()
        titleLabel.text = "ezSign eKYC iOS Sample"
        titleLabel.font = .boldSystemFont(ofSize: 20)
        titleLabel.textColor = UIColor(red: 0x4F/255.0, green: 0x4F/255.0, blue: 0x4F/255.0, alpha: 1.0)
        titleLabel.textAlignment = .center

        tokenField.placeholder = "Bearer Auth Token"
        tokenField.borderStyle = .roundedRect
        tokenField.autocapitalizationType = .none

        startButton.setTitle("Mulai eKYC", for: .normal)
        startButton.setTitleColor(.white, for: .normal)
        startButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .bold)
        startButton.backgroundColor = UIColor(red: 0x15/255.0, green: 0xC1/255.0, blue: 0xE7/255.0, alpha: 1.0)
        startButton.layer.cornerRadius = 12
        startButton.heightAnchor.constraint(equalToConstant: 52).isActive = true
        startButton.addTarget(self, action: #selector(onStartTapped), for: .touchUpInside)

        statusLabel.font = .systemFont(ofSize: 14)
        statusLabel.textColor = UIColor(red: 0x7B/255.0, green: 0x7B/255.0, blue: 0x7B/255.0, alpha: 1.0)
        statusLabel.textAlignment = .center
        statusLabel.numberOfLines = 0

        let stack = UIStackView(arrangedSubviews: [titleLabel, tokenField, startButton, statusLabel])
        stack.axis = .vertical
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            tokenField.heightAnchor.constraint(equalToConstant: 48)
        ])
    }

    @objc private func onStartTapped() {
        let token = tokenField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !token.isEmpty else {
            statusLabel.text = "Error: Auth token tidak boleh kosong"
            return
        }

        let config = EkycConfig(
            authToken: token,
            baseUrl: "https://api.ezsign.id",
            title = "Verifikasi Identitas"
        )

        EzsignEkyc.start(from: self, config: config) { [weak self] result in
            switch result {
            case .success(let regisStatus, let message):
                self?.statusLabel.text = "Status: Berhasil (\(regisStatus))\n\(message)"
            case .failure(let code, let message):
                self?.statusLabel.text = "Status: Gagal [\(code)]\n\(message)"
            case .cancelled:
                self?.statusLabel.text = "Status: Dibatalkan oleh pengguna"
            }
        }
    }
}
