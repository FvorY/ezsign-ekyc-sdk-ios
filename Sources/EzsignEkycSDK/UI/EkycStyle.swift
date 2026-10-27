import UIKit
import CoreText

internal enum EkycStyle {
    static var bundle: Bundle {
        #if SWIFT_PACKAGE
        return .module
        #else
        return Bundle(for: BackgroundShapeView.self)
        #endif
    }

    private static let registerFont: Void = {
        guard let url = bundle.url(forResource: "InterVariable", withExtension: "ttf") else { return }
        CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
    }()

    static func font(size: CGFloat, weight: UIFont.Weight = .regular) -> UIFont {
        _ = registerFont
        guard let base = UIFont(name: "InterVariable", size: size) ?? UIFont(name: "Inter-Regular", size: size) else {
            return .systemFont(ofSize: size, weight: weight)
        }
        let value: CGFloat = weight == .bold ? 700 : weight == .semibold ? 600 : weight == .medium ? 500 : 400
        let descriptor = base.fontDescriptor.addingAttributes([
            UIFontDescriptor.AttributeName(rawValue: kCTFontVariationAttribute as String): [NSNumber(value: 0x77676874): NSNumber(value: Double(value))]
        ])
        return UIFont(descriptor: descriptor, size: size)
    }

    static func image(named name: String) -> UIImage? {
        UIImage(named: name, in: bundle, compatibleWith: nil)
            ?? bundle.url(forResource: name, withExtension: "png").flatMap { UIImage(contentsOfFile: $0.path) }
    }

    static func configureField(_ field: UITextField, icon: String? = nil) {
        field.font = font(size: 16)
        if let placeholder = field.placeholder {
            field.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [
                .font: font(size: 16),
                .foregroundColor: UIColor(white: 0x7B / 255.0, alpha: 1)
            ])
        }
        field.textColor = UIColor(white: 0.2, alpha: 1)
        field.backgroundColor = .white
        field.layer.borderColor = UIColor(white: 0xBD / 255.0, alpha: 1).cgColor
        field.tintColor = UIColor(red: 85/255, green: 201/255, blue: 233/255, alpha: 1)
        if let icon = icon {
            let container = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 48))
            let image = UIImageView(image: image(named: icon)?.withRenderingMode(.alwaysTemplate))
            image.tintColor = UIColor(red: 19/255, green: 15/255, blue: 38/255, alpha: 1)
            image.frame = CGRect(x: 16, y: 12, width: 24, height: 24)
            image.contentMode = .scaleAspectFit
            container.addSubview(image)
            field.leftView = container
            field.leftViewMode = .always
        }
    }
}
