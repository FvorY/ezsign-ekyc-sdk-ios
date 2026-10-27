import UIKit

final class BackgroundShapeView: UIView {

    private let primaryColor = UIColor(red: 0x55/255.0, green: 0xC9/255.0, blue: 0xE9/255.0, alpha: 1.0)
    private let shadowColor = UIColor(red: 0x55/255.0, green: 0xC9/255.0, blue: 0xE9/255.0, alpha: 0.75)

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .clear
    }

    override func draw(_ rect: CGRect) {
        let w = rect.width
        let h = rect.height

        // Lower curve shadow
        let shadowPath = UIBezierPath()
        shadowPath.move(to: .zero)
        shadowPath.addLine(to: CGPoint(x: 0, y: h - 140))
        shadowPath.addQuadCurve(to: CGPoint(x: w, y: h - 140), controlPoint: CGPoint(x: w / 2, y: h + 30))
        shadowPath.addLine(to: CGPoint(x: w, y: 0))
        shadowPath.close()
        shadowColor.setFill()
        shadowPath.fill()

        // Main curve
        let primaryPath = UIBezierPath()
        primaryPath.move(to: .zero)
        primaryPath.addLine(to: CGPoint(x: 0, y: h - 170))
        primaryPath.addQuadCurve(to: CGPoint(x: w, y: h - 170), controlPoint: CGPoint(x: w / 2, y: h))
        primaryPath.addLine(to: CGPoint(x: w, y: 0))
        primaryPath.close()
        primaryColor.setFill()
        primaryPath.fill()
    }
}
