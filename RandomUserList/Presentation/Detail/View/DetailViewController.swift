import UIKit
import RxSwift
import RxCocoa
import Kingfisher
import SnapKit

final class DetailViewController: UIViewController {
    private let viewModel: DetailViewModel
    private let disposeBag = DisposeBag()
    private var currentScale: CGFloat = 1.0
    private let maxScale: CGFloat = 2.0
    
    // MARK: - UI Components
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = maxScale
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.bounces = true
        scrollView.bouncesZoom = true
        scrollView.alwaysBounceVertical = true
        scrollView.alwaysBounceHorizontal = true
        return scrollView
    }()
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .title1)
        label.textColor = .label
        return label
    }()
    
    private lazy var emailLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private lazy var locationLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body)
        label.textColor = .secondaryLabel
        return label
    }()
    
    // MARK: - Initialization
    init(viewModel: DetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "사용자 상세"
        
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        view.addSubview(nameLabel)
        view.addSubview(emailLabel)
        view.addSubview(locationLabel)
        
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(scrollView.snp.width)
        }
        
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.height.equalTo(scrollView)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(scrollView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        emailLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        locationLabel.snp.makeConstraints { make in
            make.top.equalTo(emailLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        imageView.addGestureRecognizer(pinchGesture)
        
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        imageView.addGestureRecognizer(doubleTapGesture)
    }
    
    private func bindViewModel() {
        let input = DetailViewModel.Input(
            viewDidLoad: Observable.just(())
        )
        
        let output = viewModel.transform(input: input)
        
        output.user
            .drive(onNext: { [weak self] user in
                self?.configure(with: user)
            })
            .disposed(by: disposeBag)
        
        output.error
            .drive(onNext: { [weak self] error in
                self?.showErrorAlert(error: error)
            })
            .disposed(by: disposeBag)
    }
    
    private func configure(with user: User) {
        nameLabel.text = "\(user.name.title) \(user.name.first) \(user.name.last)"
        emailLabel.text = user.email
        locationLabel.text = "\(user.location.street.number) \(user.location.street.name), \(user.location.city), \(user.location.state), \(user.location.country)"
        
        if let url = URL(string: user.picture.large) {
            imageView.kf.setImage(with: url)
        }
    }
    
    private func showErrorAlert(error: Error) {
        let alert = UIAlertController(
            title: "오류",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
    
    @objc private func handlePinch(_ gesture: UIPinchGestureRecognizer) {
        guard let view = gesture.view else { return }
        
        switch gesture.state {
        case .changed:
            let scale = gesture.scale
            let newScale = currentScale * scale
            
            if newScale >= 1.0 && newScale <= maxScale {
                scrollView.setZoomScale(newScale, animated: false)
                currentScale = newScale
            }
            gesture.scale = 1.0
            
        case .ended:
            if currentScale < 1.0 {
                scrollView.setZoomScale(1.0, animated: true)
                currentScale = 1.0
            } else if currentScale > maxScale {
                scrollView.setZoomScale(maxScale, animated: true)
                currentScale = maxScale
            }
        default:
            break
        }
    }
    
    @objc private func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
        if currentScale > 1.0 {
            scrollView.setZoomScale(1.0, animated: true)
            currentScale = 1.0
        } else {
            scrollView.setZoomScale(maxScale, animated: true)
            currentScale = maxScale
        }
    }
}

// MARK: - UIScrollViewDelegate
extension DetailViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        currentScale = scrollView.zoomScale
        
        // 확대 시 이미지가 중앙에 위치하도록 조정
        let offsetX = max((scrollView.bounds.width - scrollView.contentSize.width) * 0.5, 0)
        let offsetY = max((scrollView.bounds.height - scrollView.contentSize.height) * 0.5, 0)
        scrollView.contentInset = UIEdgeInsets(top: offsetY, left: offsetX, bottom: 0, right: 0)
    }
} 