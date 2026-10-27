import UIKit

final class DemografiViewController: UIViewController {

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let cardView = UIView()

    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()

    private let nikField = UITextField()
    private let nameField = UITextField()
    private let birthDateField = UITextField()
    private let datePicker = UIDatePicker()

    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    private let continueButton = UIButton(type: .system)

    private let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "dd-MM-yyyy"
        return df
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        checkStatus()
    }

    private func setupUI() {
        view.backgroundColor = UIColor(red: 0xF5/255.0, green: 0xF6/255.0, blue: 0xFA/255.0, alpha: 1.0)
        title = EkycSession.shared.config?.title ?? "Verifikasi Identitas"

        let shape = BackgroundShapeView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 260))
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

        imageView.contentMode = .scaleAspectFit
        imageView.image = loadImage(named: "identity")

        titleLabel.text = "Personal Data"
        titleLabel.font = .boldSystemFont(ofSize: 17)
        titleLabel.textColor = UIColor(red: 0x7B/255.0, green: 0x7B/255.0, blue: 0x7B/255.0, alpha: 1.0)

        subtitleLabel.text = "Enter your personal data correctly"
        subtitleLabel.font = .systemFont(ofSize: 12)
        subtitleLabel.textColor = UIColor(red: 0x7B/255.0, green: 0x7B/255.0, blue: 0x7B/255.0, alpha: 1.0)

        configureTextField(nikField, placeholder: "Identity Number", keyboardType: .numberPad)
        configureTextField(nameField, placeholder: "Fullname", autocapitalization: .words)
        configureTextField(birthDateField, placeholder: "Date of Birth")

        datePicker.datePickerMode = .date
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        birthDateField.inputView = datePicker

        continueButton.setTitle("Continue", for: .normal)
        continueButton.setTitleColor(.white, for: .normal)
        continueButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .bold)
        continueButton.backgroundColor = UIColor(red: 0x15/255.0, green: 0xC1/255.0, blue: 0xE7/255.0, alpha: 1.0)
        continueButton.layer.cornerRadius = 12
        continueButton.addTarget(self, action: #selector(onContinueTapped), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [
            imageView, titleLabel, subtitleLabel, nikField, nameField, birthDateField, activityIndicator, continueButton
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

            imageView.heightAnchor.constraint(equalToConstant: 130),
            continueButton.heightAnchor.constraint(equalToConstant: 52),

            stack.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            stack.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -20)
        ])
    }

    private func configureTextField(_ tf: UITextField, placeholder: String, keyboardType: UIKeyboardType = .default, autocapitalization: UITextAutocapitalizationType = .none) {
        tf.placeholder = placeholder
        tf.keyboardType = keyboardType
        tf.autocapitalizationType = autocapitalization
        tf.borderStyle = .none
        tf.layer.cornerRadius = 8
        tf.layer.borderWidth = 1
        tf.layer.borderColor = UIColor(white: 0.85, alpha: 1.0).cgColor
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 48))
        tf.leftViewMode = .always
        tf.heightAnchor.constraint(equalToConstant: 48).isActive = true
    }

    @objc private func dateChanged() {
        birthDateField.text = dateFormatter.string(from: datePicker.date)
    }

    private func checkStatus() {
        guard let client = EkycSession.shared.client else { return }
        Task {
            do {
                let res = try await client.getEkycStatus()
                if res.data?.canEkyc == false {
                    showAlert(title: "Perhatian", message: res.message ?? "Akun tidak dapat melakukan eKYC") {
                        self.dismiss(animated: true)
                    }
                }
            } catch {
                // Continue flow
            }
        }
    }

    @objc private func onContinueTapped() {
        let nik = nikField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let name = nameField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let birthDate = birthDateField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        guard nik.count == 16 else {
            showAlert(title: "Perhatian", message: "NIK harus 16 digit angka.")
            return
        }
        guard !name.isEmpty else {
            showAlert(title: "Perhatian", message: "Nama lengkap wajib diisi.")
            return
        }
        guard !birthDate.isEmpty else {
            showAlert(title: "Perhatian", message: "Tanggal lahir wajib dipilih.")
            return
        }

        let alert = UIAlertController(
            title: "Review Your Information",
            message: "Identity Number: \(nik)\nFullname: \(name)\nDate of Birth: \(birthDate)\n\nPlease confirm that the information you entered is correct.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Review", style: .cancel))
        alert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { [weak self] _ in
            self?.submitDemografi(nik: nik, name: name, birthDate: birthDate)
        }))
        present(alert, animated: true)
    }

    private func submitDemografi(nik: String, name: String, birthDate: String) {
        guard let client = EkycSession.shared.client else { return }
        activityIndicator.startAnimating()
        continueButton.isEnabled = false

        Task {
            do {
                _ = try await client.checkDemografi(nama: name, nik: nik, birthDate: birthDate)
                await MainActor.run {
                    self.activityIndicator.stopAnimating()
                    self.continueButton.isEnabled = true
                    EkycSession.shared.nik = nik
                    EkycSession.shared.nama = name
                    EkycSession.shared.birthDate = birthDate

                    let otpVC = OtpViewController()
                    self.navigationController?.pushViewController(otpVC, animated: true)
                }
            } catch {
                await MainActor.run {
                    self.activityIndicator.stopAnimating()
                    self.continueButton.isEnabled = true
                    self.showAlert(title: "Gagal", message: error.localizedDescription)
                }
            }
        }
    }

    @objc func onCloseTapped() {
        let completion = EkycSession.shared.completion
        dismiss(animated: true) {
            completion?(.cancelled)
            EkycSession.shared.reset()
        }
    }

    private func loadImage(named: String) -> UIImage? {
        let bundle = Bundle(for: type(of: self))
        if let path = bundle.path(forResource: named, ofType: "png") {
            return UIImage(contentsOfFile: path)
        }
        if let mainPath = Bundle.main.path(forResource: named, ofType: "png") {
            return UIImage(contentsOfFile: mainPath)
        }
        return UIImage(named: named)
    }

    private func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in completion?() }))
        present(alert, animated: true)
    }
}
