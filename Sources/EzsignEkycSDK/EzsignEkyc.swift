import UIKit

public final class EzsignEkyc {

    private init() {}

    /**
     * Starts the eKYC verification flow presented modally on top of the given UIViewController.
     *
     * - Parameters:
     *   - presenter: UIViewController from which the eKYC modal is presented
     *   - config: Configuration containing authToken and baseUrl
     *   - completion: Callback returning EkycResult (.success, .failure, or .cancelled)
     */
    public static func start(
        from presenter: UIViewController,
        config: EkycConfig,
        completion: @escaping (EkycResult) -> Void
    ) {
        EkycSession.shared.reset()
        EkycSession.shared.config = config
        EkycSession.shared.client = EkycApiClient(baseUrl: config.baseUrl, authToken: config.authToken)
        EkycSession.shared.completion = completion

        let demografiVC = DemografiViewController()
        let navController = UINavigationController(rootViewController: demografiVC)
        navController.modalPresentationStyle = .fullScreen
        navController.overrideUserInterfaceStyle = .light

        // Setup custom nav bar appearance matching Flutter info color
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.backgroundColor = UIColor(red: 0x55/255.0, green: 0xC9/255.0, blue: 0xE9/255.0, alpha: 1.0)
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white, .font: EkycStyle.font(size: 18)]
        navController.navigationBar.standardAppearance = navBarAppearance
        navController.navigationBar.scrollEdgeAppearance = navBarAppearance
        navController.navigationBar.tintColor = .white

        demografiVC.navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: demografiVC,
            action: #selector(DemografiViewController.onCloseTapped)
        )

        presenter.present(navController, animated: true)
    }
}
