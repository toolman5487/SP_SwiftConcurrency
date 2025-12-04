import UIKit
import SnapKit
import SDWebImage

final class ProfileImageCell: UITableViewCell {
    
    static var identifier: String {
        String(describing: self)
    }
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 60
        imageView.clipsToBounds = true
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(profileImageView)
        selectionStyle = .none
        
        profileImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(120)
            make.top.bottom.equalToSuperview()
        }
    }
    
    func configure(with imageURL: String) {
        guard let url = URL(string: imageURL) else { return }
        profileImageView.sd_setImage(with: url)
    }
}

