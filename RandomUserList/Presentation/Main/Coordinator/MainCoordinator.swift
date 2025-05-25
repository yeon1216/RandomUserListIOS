import UIKit
import RxSwift

protocol MainCoordinator {
    func showDetail(user: User)
}

final class MainCoordinatorImpl: MainCoordinator {
    private let navigationController: UINavigationController
    private let disposeBag = DisposeBag()
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func showDetail(user: User) {
        let viewModel = DetailViewModel(user: user)
        let viewController = DetailViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }
} 
