import UIKit
import RxSwift

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private let disposeBag = DisposeBag()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let apiClient = UserAPIClient()
        let repository = UserRepositoryImpl(apiClient: apiClient)
        let useCase = FetchUsersUseCaseImpl(repository: repository)
        
        let navigationController = UINavigationController()
        let coordinator = MainCoordinatorImpl(navigationController: navigationController)
        
        let viewModel = MainViewModel(useCase: useCase, coordinator: coordinator)
        
        let viewController = MainViewController(viewModel: viewModel)
        navigationController.viewControllers = [viewController]
        
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
    }

    func sceneWillResignActive(_ scene: UIScene) {
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
    }

}

