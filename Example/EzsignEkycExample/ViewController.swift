import UIKit
import EzsignEkycSDK

class ViewController: UIViewController {

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let statusBadge = UILabel()
    private let startButton = UIButton(type: .system)
    private let tokenField = UITextField()
    private let baseUrlField = UITextField()
    private let resultLabel = UILabel()

    private var isVerified = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = UIColor(red: 0xF5/255.0, green: 0xF6/255.0, blue: 0xFA/255.0, alpha: 1.0)

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])

        // 1. Profile Bar
        let avatarView = UIView()
        avatarView.backgroundColor = UIColor(red: 0x15/255.0, green: 0xC1/255.0, blue: 0xE7/255.0, alpha: 1.0)
        avatarView.layer.cornerRadius = 24
        avatarView.translatesAutoresizingMaskIntoConstraints = false
        avatarView.widthAnchor.constraint(equalToConstant: 48).isActive = true
        avatarView.heightAnchor.constraint(equalToConstant: 48).isActive = true

        let avatarLabel = UILabel()
        avatarLabel.text = "AF"
        avatarLabel.textColor = .white
        avatarLabel.font = .boldSystemFont(ofSize: 18)
        avatarLabel.textAlignment = .center
        avatarLabel.translatesAutoresizingMaskIntoConstraints = false
        avatarView.addSubview(avatarLabel)
        avatarLabel.centerXAnchor.constraint(equalTo: avatarView.centerXAnchor).isActive = true
        avatarLabel.centerYAnchor.constraint(equalTo: avatarView.centerYAnchor).isActive = true

        let greetingLabel = UILabel()
        greetingLabel.text = "Selamat Datang,"
        greetingLabel.font = .systemFont(ofSize: 12)
        greetingLabel.textColor = UIColor(red: 0x71/255.0, green: 0x80/255.0, blue: 0x96/255.0, alpha: 1.0)

        let nameLabel = UILabel()
        nameLabel.text = "Ahmad Fauzi"
        nameLabel.font = .boldSystemFont(ofSize: 17)
        nameLabel.textColor = UIColor(red: 0x2D/255.0, green: 0x37/255.0, blue: 0x48/255.0, alpha: 1.0)

        let nameStack = UIStackView(arrangedSubviews: [greetingLabel, nameLabel])
        nameStack.axis = .vertical
        nameStack.spacing = 2

        statusBadge.text = " Belum eKYC "
        statusBadge.font = .boldSystemFont(ofSize: 11)
        statusBadge.textColor = UIColor(red: 0xD9/255.0, green: 0x77/255.0, blue: 0x06/255.0, alpha: 1.0)
        statusBadge.backgroundColor = UIColor(red: 0xFE/255.0, green: 0xF3/255.0, blue: 0xC7/255.0, alpha: 1.0)
        statusBadge.layer.cornerRadius = 10
        statusBadge.layer.masksToBounds = true
        statusBadge.textAlignment = .center
        statusBadge.heightAnchor.constraint(equalToConstant: 24).isActive = true

        let profileRow = UIStackView(arrangedSubviews: [avatarView, nameStack, statusBadge])
        profileRow.axis = .horizontal
        profileRow.spacing = 14
        profileRow.alignment = .center

        // 2. Verification Action Card
        let verifCard = createCardView()
        let verifTitle = UILabel()
        verifTitle.text = "Sertifikat Elektronik"
        verifTitle.font = .boldSystemFont(ofSize: 16)
        verifTitle.textColor = UIColor(red: 0x2D/255.0, green: 0x37/255.0, blue: 0x48/255.0, alpha: 1.0)

        let verifDesc = UILabel()
        verifDesc.text = "Lakukan verifikasi eKYC untuk mengaktifkan tanda tangan digital berbadan hukum."
        verifDesc.font = .systemFont(ofSize: 12)
        verifDesc.textColor = UIColor(red: 0x71/255.0, green: 0x80/255.0, blue: 0x96/255.0, alpha: 1.0)
        verifDesc.numberOfLines = 0

        startButton.setTitle("Mulai Verifikasi eKYC", for: .normal)
        startButton.setTitleColor(.white, for: .normal)
        startButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
        startButton.backgroundColor = UIColor(red: 0x15/255.0, green: 0xC1/255.0, blue: 0xE7/255.0, alpha: 1.0)
        startButton.layer.cornerRadius = 12
        startButton.heightAnchor.constraint(equalToConstant: 48).isActive = true
        startButton.addTarget(self, action: #selector(onStartEkycTapped), for: .touchUpInside)

        let verifStack = UIStackView(arrangedSubviews: [verifTitle, verifDesc, startButton])
        verifStack.axis = .vertical
        verifStack.spacing = 12
        verifStack.translatesAutoresizingMaskIntoConstraints = false
        verifCard.addSubview(verifStack)

        NSLayoutConstraint.activate([
            verifStack.topAnchor.constraint(equalTo: verifCard.topAnchor, constant: 18),
            verifStack.leadingAnchor.constraint(equalTo: verifCard.leadingAnchor, constant: 18),
            verifStack.trailingAnchor.constraint(equalTo: verifCard.trailingAnchor, constant: -18),
            verifStack.bottomAnchor.constraint(equalTo: verifCard.bottomAnchor, constant: -18)
        ])

        // 3. Services Title & Grid
        let servicesTitle = UILabel()
        servicesTitle.text = "Layanan Tanda Tangan"
        servicesTitle.font = .boldSystemFont(ofSize: 16)
        servicesTitle.textColor = UIColor(red: 0x2D/255.0, green: 0x37/255.0, blue: 0x48/255.0, alpha: 1.0)

        let item1 = createServiceButton(icon: "✍️", title: "Tanda Tangan", subtitle: "Tandatangani PDF", tag: 1)
        let item2 = createServiceButton(icon: "📄", title: "Kirim Dokumen", subtitle: "Minta ttd lain", tag: 2)
        let row1 = UIStackView(arrangedSubviews: [item1, item2])
        row1.axis = .horizontal
        row1.distribution = .fillEqually
        row1.spacing = 12

        let item3 = createServiceButton(icon: "🔏", title: "Segel Elektronik", subtitle: "Cap institusi", tag: 3)
        let item4 = createServiceButton(icon: "📜", title: "Sertifikat Saya", subtitle: "Status sertifikat CA", tag: 4)
        let row2 = UIStackView(arrangedSubviews: [item3, item4])
        row2.axis = .horizontal
        row2.distribution = .fillEqually
        row2.spacing = 12

        let gridStack = UIStackView(arrangedSubviews: [row1, row2])
        gridStack.axis = .vertical
        gridStack.spacing = 12

        // 4. Developer / Test Settings Card
        let configCard = createCardView()
        let configTitle = UILabel()
        configTitle.text = "Konfigurasi Pengujian SDK"
        configTitle.font = .boldSystemFont(ofSize: 13)
        configTitle.textColor = UIColor(red: 0x2D/255.0, green: 0x37/255.0, blue: 0x48/255.0, alpha: 1.0)

        baseUrlField.placeholder = "Base URL"
        baseUrlField.text = "https://gtm.myesign.id/api"
        configureField(baseUrlField)

        tokenField.placeholder = "Bearer Auth Token"
        configureField(tokenField)

        resultLabel.text = "Status Callback SDK: Belum dijalankan"
        resultLabel.font = .systemFont(ofSize: 11)
        resultLabel.textColor = UIColor(red: 0x71/255.0, green: 0x80/255.0, blue: 0x96/255.0, alpha: 1.0)
        resultLabel.numberOfLines = 0

        let configStack = UIStackView(arrangedSubviews: [configTitle, baseUrlField, tokenField, resultLabel])
        configStack.axis = .vertical
        configStack.spacing = 10
        configStack.translatesAutoresizingMaskIntoConstraints = false
        configCard.addSubview(configStack)

        NSLayoutConstraint.activate([
            configStack.topAnchor.constraint(equalTo: configCard.topAnchor, constant: 16),
            configStack.leadingAnchor.constraint(equalTo: configCard.leadingAnchor, constant: 16),
            configStack.trailingAnchor.constraint(equalTo: configCard.trailingAnchor, constant: -16),
            configStack.bottomAnchor.constraint(equalTo: configCard.bottomAnchor, constant: -16)
        ])

        // Main Stack
        let mainStack = UIStackView(arrangedSubviews: [
            profileRow, verifCard, servicesTitle, gridStack, configCard
        ])
        mainStack.axis = .vertical
        mainStack.spacing = 20
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(mainStack)

        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            mainStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            mainStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24)
        ])
    }

    private func createCardView() -> UIView {
        let card = UIView()
        card.backgroundColor = .white
        card.layer.cornerRadius = 16
        card.layer.borderWidth = 1
        card.layer.borderColor = UIColor(red: 0xE2/255.0, green: 0xE8/255.0, blue: 0xF0/255.0, alpha: 1.0).cgColor
        return card
    }

    private func configureField(_ tf: UITextField) {
        tf.borderStyle = .none
        tf.layer.cornerRadius = 8
        tf.layer.borderWidth = 1
        tf.layer.borderColor = UIColor(red: 0xCB/255.0, green: 0xD5/255.0, blue: 0xE1/255.0, alpha: 1.0).cgColor
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 40))
        tf.leftViewMode = .always
        tf.font = .systemFont(ofSize: 12)
        tf.autocapitalizationType = .none
        tf.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }

    private func createServiceButton(icon: String, title: String, subtitle: String, tag: Int) -> UIButton {
        let btn = UIButton(type: .system)
        btn.backgroundColor = .white
        btn.layer.cornerRadius = 14
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor(red: 0xE2/255.0, green: 0xE8/255.0, blue: 0xF0/255.0, alpha: 1.0).cgColor
        btn.tag = tag
        btn.addTarget(self, action: #selector(onServiceTapped(_:)), for: .touchUpInside)

        let iconLabel = UILabel()
        iconLabel.text = icon
        iconLabel.font = .systemFont(ofSize: 22)

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .boldSystemFont(ofSize: 13)
        titleLabel.textColor = UIColor(red: 0x2D/255.0, green: 0x37/255.0, blue: 0x48/255.0, alpha: 1.0)

        let subLabel = UILabel()
        subLabel.text = subtitle
        subLabel.font = .systemFont(ofSize: 11)
        subLabel.textColor = UIColor(red: 0x71/255.0, green: 0x80/255.0, blue: 0x96/255.0, alpha: 1.0)

        let stack = UIStackView(arrangedSubviews: [iconLabel, titleLabel, subLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .leading
        stack.isUserInteractionEnabled = false
        stack.translatesAutoresizingMaskIntoConstraints = false
        btn.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: btn.topAnchor, constant: 14),
            stack.leadingAnchor.constraint(equalTo: btn.leadingAnchor, constant: 14),
            stack.trailingAnchor.constraint(equalTo: btn.trailingAnchor, constant: -14),
            stack.bottomAnchor.constraint(equalTo: btn.bottomAnchor, constant: -14)
        ])

        return btn
    }

    @objc private func onServiceTapped(_ sender: UIButton) {
        let serviceNames = [
            1: "Tanda Tangan Dokumen",
            2: "Kirim Dokumen",
            3: "Segel Elektronik",
            4: "Sertifikat Saya"
        ]
        let name = serviceNames[sender.tag] ?? "Layanan"

        if !isVerified {
            let alert = UIAlertController(
                title: "Fitur Terkunci",
                message: "Layanan '\(name)' memerlukan akun terverifikasi eKYC. Silakan selesaikan verifikasi identitas terlebih dahulu.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "Nanti", style: .cancel))
            alert.addAction(UIAlertAction(title: "Verifikasi Sekarang", style: .default, handler: { [weak self] _ in
                self?.onStartEkycTapped()
            }))
            present(alert, animated: true)
        } else {
            let alert = UIAlertController(
                title: name,
                message: "Akun Anda telah menyelesaikan eKYC. Layanan siap digunakan setelah disetujui Registration Authority.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }

    @objc private func onStartEkycTapped() {
        let token = tokenField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let baseUrl = baseUrlField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "https://api.ezsign.id"

        guard !token.isEmpty else {
            let alert = UIAlertController(
                title: "Perhatian",
                message: "Silakan masukkan Bearer Auth Token akun Anda pada bagian konfigurasi di bawah untuk pengujian.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }

        let config = EkycConfig(
            authToken: token,
            baseUrl: baseUrl.isEmpty ? "https://api.ezsign.id" : baseUrl,
            title: "Verifikasi Identitas"
        )

        EzsignEkyc.start(from: self, config: config) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let regisStatus, let message):
                self.isVerified = true
                self.statusBadge.text = " eKYC Selesai "
                self.statusBadge.textColor = UIColor(red: 0x05/255.0, green: 0x96/255.0, blue: 0x69/255.0, alpha: 1.0)
                self.statusBadge.backgroundColor = UIColor(red: 0xD1/255.0, green: 0xFA/255.0, blue: 0xE5/255.0, alpha: 1.0)

                self.startButton.setTitle("eKYC Selesai (Menunggu RA)", for: .normal)
                self.startButton.isEnabled = false

                self.resultLabel.text = "Callback: Success\nStatus: \(regisStatus)\nPesan: \(message)"

            case .failure(let errorCode, let message):
                self.resultLabel.text = "Callback: Failed [\(errorCode)]\nPesan: \(message)"

            case .cancelled:
                self.resultLabel.text = "Callback: Cancelled oleh pengguna"
            }
        }
    }
}
