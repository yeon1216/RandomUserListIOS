import UIKit
import Kingfisher
import SnapKit

final class UserCell: UICollectionViewCell {
    static let identifier = "UserCell"
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .headline)
        label.textColor = .label
        return label
    }()
    
    private let emailLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let genderLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let selectionIndicator: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBlue.withAlphaComponent(0.2)
        view.layer.cornerRadius = 8
        view.isHidden = true
        return view
    }()
    
    private let checkmarkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "checkmark.circle.fill")
        imageView.tintColor = .systemBlue
        imageView.isHidden = true
        return imageView
    }()
    
    private var isSelectionMode = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(selectionIndicator)
        contentView.addSubview(checkmarkImageView)
        contentView.addSubview(imageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(emailLabel)
        contentView.addSubview(genderLabel)
        
        selectionIndicator.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        checkmarkImageView.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview().inset(8)
            make.width.height.equalTo(24)
        }
        
        imageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(60)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(imageView.snp.trailing).offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalTo(imageView)
        }
        
        emailLabel.snp.makeConstraints { make in
            make.leading.trailing.equalTo(nameLabel)
            make.top.equalTo(nameLabel.snp.bottom).offset(4)
        }
        
        genderLabel.snp.makeConstraints { make in
            make.leading.trailing.equalTo(nameLabel)
            make.top.equalTo(emailLabel.snp.bottom).offset(4)
        }
    }
    
    func configure(with user: User) {
        nameLabel.text = "\(user.name.title) \(user.name.first) \(user.name.last)"
        emailLabel.text = user.email
        genderLabel.text = user.gender == "male" ? "남성" : user.gender == "female" ? "여성" : "unknown"
        
        if let url = URL(string: user.picture.medium) {
            imageView.kf.setImage(with: url)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.kf.cancelDownloadTask()
        imageView.image = nil
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelectionMode {
                selectionIndicator.isHidden = !isSelected
                checkmarkImageView.isHidden = !isSelected
            } else {
                selectionIndicator.isHidden = true
                checkmarkImageView.isHidden = true
            }
        }
    }
    
    func setSelectionMode(_ isSelectionMode: Bool) {
        self.isSelectionMode = isSelectionMode
        if !isSelectionMode {
            selectionIndicator.isHidden = true
            checkmarkImageView.isHidden = true
        }
    }
} 
