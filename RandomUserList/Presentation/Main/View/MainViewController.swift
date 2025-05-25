import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class MainViewController: UIViewController {
    private let viewModel: MainViewModel
    private let disposeBag = DisposeBag()
    private let refreshControl = UIRefreshControl()
    private var currentListStyle: MainViewModel.ListStyle = .single
    private var isSelectionMode = false
    private var selectedUsers: Set<UserUIModel> = []
    private var currentUsers: [UserUIModel] = []
    private let deleteButton = UIBarButtonItem(title: "삭제", style: .plain, target: nil, action: nil)
    private let selectButton = UIBarButtonItem(title: "선택", style: .plain, target: nil, action: nil)
    private let cancelButton = UIBarButtonItem(title: "취소", style: .plain, target: nil, action: nil)
    
    // MARK: - UI Components
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        collectionView.register(UserCell.self, forCellWithReuseIdentifier: UserCell.identifier)
        return collectionView
    }()
    
    private lazy var genderSegmentedControl: UISegmentedControl = {
        let items = ["전체", "남성", "여성"]
        let control = UISegmentedControl(items: items)
        control.selectedSegmentIndex = 0
        return control
    }()
    
    private lazy var listStyleButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "square.grid.2x2"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 22
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        button.layer.shadowOpacity = 0.2
        return button
    }()
    
    init(viewModel: MainViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "사용자 목록"
        
        view.addSubview(genderSegmentedControl)
        view.addSubview(collectionView)
        view.addSubview(listStyleButton)
        
        let swipeLeftGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeLeftGesture.direction = .left
        view.addGestureRecognizer(swipeLeftGesture)
        
        let swipeRightGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeRightGesture.direction = .right
        view.addGestureRecognizer(swipeRightGesture)
        
        genderSegmentedControl.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(genderSegmentedControl.snp.bottom).offset(16)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        listStyleButton.snp.makeConstraints { make in
            make.bottom.right.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.width.height.equalTo(44)
        }
        
        collectionView.refreshControl = refreshControl
        
        navigationItem.rightBarButtonItems = [selectButton]
    }
    
    private func bindViewModel() {
        let input = MainViewModel.Input(
            viewDidLoad: Observable.just(()),
            refreshTrigger: refreshControl.rx.controlEvent(.valueChanged).asObservable(),
            loadMoreTrigger: collectionView.rx.willDisplayCell
                .filter { [weak self] cell, indexPath in
                    guard let self = self else { return false }
                    return indexPath.row == self.collectionView.numberOfItems(inSection: 0) - 1
                }
                .map { _ in () },
            genderTabSelected: genderSegmentedControl.rx.selectedSegmentIndex
                .map { index -> Gender in
                    switch index {
                    case 0: return .all
                    case 1: return .male
                    case 2: return .female
                    default: return .all
                    }
                },
            listStyleChanged: listStyleButton.rx.tap
                .map { [weak self] _ -> MainViewModel.ListStyle in
                    guard let self = self else { return .single }
                    let newStyle: MainViewModel.ListStyle = (self.currentListStyle == .single) ? .double : .single
                    self.currentListStyle = newStyle
                    return newStyle
                }
        )
        
        let output = viewModel.transform(input: input)
        
        output.users
            .map { users in users.map(UserUIModel.init) }
            .drive(onNext: { [weak self] users in
                self?.currentUsers = users
                self?.collectionView.reloadData()
            })
            .disposed(by: disposeBag)
        
        output.users
            .drive(collectionView.rx.items(cellIdentifier: UserCell.identifier, cellType: UserCell.self)) { _, user, cell in
                cell.configure(with: user)
            }
            .disposed(by: disposeBag)
        
        output.isLoading
            .drive(onNext: { [weak self] (isLoading: Bool) in
                if isLoading {
                    self?.refreshControl.beginRefreshing()
                } else {
                    self?.refreshControl.endRefreshing()
                }
            })
            .disposed(by: disposeBag)
        
        output.error
            .drive(onNext: { [weak self] error in
                self?.showErrorAlert(error: error)
            })
            .disposed(by: disposeBag)
        
        output.listStyle
            .drive(onNext: { [weak self] style in
                self?.updateListStyle(style)
            })
            .disposed(by: disposeBag)
        
        selectButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.isSelectionMode.toggle()
                self.selectedUsers.removeAll()
                self.updateSelectionMode()
            })
            .disposed(by: disposeBag)
        
        cancelButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.isSelectionMode = false
                self.selectedUsers.removeAll()
                self.updateSelectionMode()
            })
            .disposed(by: disposeBag)
        
        deleteButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                let alert = UIAlertController(
                    title: "선택한 사용자 삭제",
                    message: "선택한 \(self.selectedUsers.count)명의 사용자를 삭제하시겠습니까?",
                    preferredStyle: .alert
                )
                
                alert.addAction(UIAlertAction(title: "취소", style: .cancel))
                alert.addAction(UIAlertAction(title: "삭제", style: .destructive) { [weak self] _ in
                    guard let self = self else { return }
                    self.viewModel.deleteUsers(Array(self.selectedUsers))
                    self.selectedUsers.removeAll()
                    self.updateSelectionMode()
                })
                
                self.present(alert, animated: true)
            })
            .disposed(by: disposeBag)
        
        collectionView.rx.itemSelected
            .withLatestFrom(output.users) { indexPath, users in
                return UserUIModel(from: users[indexPath.row])
            }
            .subscribe(onNext: { [weak self] user in
                guard let self = self else { return }
                if self.isSelectionMode {
                    if self.selectedUsers.contains(user) {
                        self.selectedUsers.remove(user)
                    } else {
                        self.selectedUsers.insert(user)
                    }
                    self.updateSelectionMode()
                } else {
                    self.showDetail(for: user)
                }
            })
            .disposed(by: disposeBag)
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
    
    private func updateListStyle(_ style: MainViewModel.ListStyle) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        
        switch style {
        case .single:
            layout.itemSize = CGSize(width: view.bounds.width - 32, height: 100)
            listStyleButton.setImage(UIImage(systemName: "square.grid.2x2"), for: .normal)
        case .double:
            let width = (view.bounds.width - 48) / 2
            layout.itemSize = CGSize(width: width, height: width * 1.5)
            listStyleButton.setImage(UIImage(systemName: "list.bullet"), for: .normal)
        }
        
        collectionView.setCollectionViewLayout(layout, animated: true)
    }
    
    private func updateSelectionMode() {
        if isSelectionMode {
            navigationItem.rightBarButtonItems = [deleteButton, cancelButton]
            deleteButton.isEnabled = !selectedUsers.isEmpty
            collectionView.allowsMultipleSelection = true
            collectionView.indexPathsForSelectedItems?.forEach { indexPath in
                collectionView.deselectItem(at: indexPath, animated: false)
            }
        } else {
            navigationItem.rightBarButtonItems = [selectButton]
            collectionView.allowsMultipleSelection = false
            selectedUsers.removeAll()
        }
        
        collectionView.visibleCells.forEach { cell in
            if let userCell = cell as? UserCell {
                let indexPath = collectionView.indexPath(for: cell)!
                let user = currentUsers[indexPath.row]
                userCell.setSelectionMode(isSelectionMode)
                userCell.isSelected = selectedUsers.contains(user)
            }
        }
    }
    
    private func showDetail(for user: UserUIModel) {
        viewModel.showDetail(user: User(
            id: user.id,
            gender: user.gender,
            name: User.Name(title: "", first: user.name.components(separatedBy: " ").first ?? "", last: user.name.components(separatedBy: " ").last ?? ""),
            email: user.email,
            picture: User.Picture(large: user.profileImageURL, medium: "", thumbnail: ""),
            location: User.Location(
                street: User.Location.Street(number: 0, name: ""),
                city: user.location.components(separatedBy: ", ").first ?? "",
                state: "",
                country: user.location.components(separatedBy: ", ").last ?? ""
            ),
            login: User.Login(uuid: user.id, username: user.username)
        ))
    }
    
    @objc private func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        let currentIndex = genderSegmentedControl.selectedSegmentIndex
        
        switch gesture.direction {
        case .left:
            if currentIndex < genderSegmentedControl.numberOfSegments - 1 {
                genderSegmentedControl.selectedSegmentIndex = currentIndex + 1
                genderSegmentedControl.sendActions(for: .valueChanged)
            }
        case .right:
            if currentIndex > 0 {
                genderSegmentedControl.selectedSegmentIndex = currentIndex - 1
                genderSegmentedControl.sendActions(for: .valueChanged)
            }
        default:
            break
        }
    }
} 
