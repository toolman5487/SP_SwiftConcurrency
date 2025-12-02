import UIKit
import SnapKit

class ViewController: UIViewController {
    
    private let viewModel = SPViewModel()
    private var currentUser: User?
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.separatorStyle = .none
        return tableView
    }()
    
    private let reloadButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Reload User", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.contentEdgeInsets = UIEdgeInsets(top: 14, left: 16, bottom: 14, right: 16)
        return button
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    enum Section: Int, CaseIterable {
        case profileImage
        case nameAge
        case location
        case email
        case phone
        
        static var count: Int {
            return Section.allCases.count
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "RandomUser"
        setupUI()
        setupTableView()
        loadUser()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(tableView)
        view.addSubview(reloadButton)
        view.addSubview(loadingIndicator)
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(reloadButton.snp.top)
        }
        
        reloadButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(8)
        }
        
        loadingIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        reloadButton.addTarget(self, action: #selector(didTapReload), for: .touchUpInside)
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(ProfileImageCell.self, forCellReuseIdentifier: ProfileImageCell.identifier)
        tableView.register(NameAgeCell.self, forCellReuseIdentifier: NameAgeCell.identifier)
        tableView.register(LocationCell.self, forCellReuseIdentifier: LocationCell.identifier)
        tableView.register(InfoCell.self, forCellReuseIdentifier: InfoCell.identifier)
    }
    
    private func loadUser() {
        loadingIndicator.startAnimating()
        
        Task { [weak self] in
            guard let self else { return }
            
            do {
                let user = try await self.viewModel.loadUser()
                self.currentUser = user
                self.tableView.reloadData()
            } catch {
                self.showError(error)
            }
            
            self.loadingIndicator.stopAnimating()
        }
    }
    
    @objc
    private func didTapReload() {
        loadUser()
    }
    
    private func showError(_ error: Error) {
        let alert = UIAlertController(
            title: "Error",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = Section(rawValue: indexPath.section),
              let user = currentUser else {
            return UITableViewCell()
        }
        
        switch section {
        case .profileImage:
            let cell = tableView.dequeueReusableCell(withIdentifier: ProfileImageCell.identifier, for: indexPath) as! ProfileImageCell
            cell.configure(with: user.picture.large)
            return cell
            
        case .nameAge:
            let cell = tableView.dequeueReusableCell(withIdentifier: NameAgeCell.identifier, for: indexPath) as! NameAgeCell
            cell.configure(name: user.name.fullName, age: user.dob.age)
            return cell
            
        case .location:
            let cell = tableView.dequeueReusableCell(withIdentifier: LocationCell.identifier, for: indexPath) as! LocationCell
            cell.configure(city: user.location.city, state: user.location.state, country: user.location.country)
            return cell
            
        case .email:
            let cell = tableView.dequeueReusableCell(withIdentifier: InfoCell.identifier, for: indexPath) as! InfoCell
            cell.configure(title: "Email", value: user.email)
            return cell
            
        case .phone:
            let cell = tableView.dequeueReusableCell(withIdentifier: InfoCell.identifier, for: indexPath) as! InfoCell
            cell.configure(title: "Phone", value: user.phone)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let section = Section(rawValue: indexPath.section) else {
            return UITableView.automaticDimension
        }
        
        switch section {
        case .profileImage:
            return UITableView.automaticDimension
        case .nameAge:
            return UITableView.automaticDimension
        case .location:
            return UITableView.automaticDimension
        case .email, .phone:
            return UITableView.automaticDimension
        }
    }
}
