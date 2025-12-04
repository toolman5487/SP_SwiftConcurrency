import UIKit
import SnapKit

@MainActor
final class ViewController: UIViewController {
    
    private let viewModel = SPViewModel()
    private var buttonObserverTask: Task<Void, Never>?
    private var loadUserTask: Task<Void, Never>?
    
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
        return button
    }()
    
    private lazy var reloadButtonTapStream = reloadButton.tapStream()

    private func observeReloadButton() {
        buttonObserverTask = Task { [weak self] in
            guard let self else { return }
            for await _ in reloadButtonTapStream {
                guard !self.viewModel.isLoading else { continue }
                self.loadUser()
            }
        }
    }
    
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
        observeReloadButton()
        loadUser()
    }
    
    deinit {
        loadUserTask?.cancel()
        buttonObserverTask?.cancel()
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
        loadUserTask?.cancel()
        
        loadUserTask = Task { @MainActor [weak self] in
            guard let self else { return }
            guard !Task.isCancelled else { return }
            
            self.loadingIndicator.startAnimating()
            self.reloadButton.isEnabled = false
            
            await self.viewModel.loadUser()
            
            guard !Task.isCancelled else {
                self.loadingIndicator.stopAnimating()
                self.reloadButton.isEnabled = true
                return
            }
            
            self.loadingIndicator.stopAnimating()
            self.reloadButton.isEnabled = true
            self.tableView.reloadData()
            
            if let errorMessage = self.viewModel.errorMessage {
                self.showError(message: errorMessage)
            }
        }
    }
    
    private func showError(message: String) {
        let alert = UIAlertController(
            title: "Error",
            message: message,
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
              let user = viewModel.user else {
            return UITableViewCell()
        }
        
        switch section {
        case .profileImage:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ProfileImageCell.identifier, for: indexPath) as? ProfileImageCell else {
                return UITableViewCell()
            }
            cell.configure(with: user.picture.large)
            return cell
            
        case .nameAge:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: NameAgeCell.identifier, for: indexPath) as? NameAgeCell else {
                return UITableViewCell()
            }
            cell.configure(name: user.name.fullName, age: user.dob.age)
            return cell
            
        case .location:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: LocationCell.identifier, for: indexPath) as? LocationCell else {
                return UITableViewCell()
            }
            cell.configure(city: user.location.city, state: user.location.state, country: user.location.country)
            return cell
            
        case .email:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: InfoCell.identifier, for: indexPath) as? InfoCell else {
                return UITableViewCell()
            }
            cell.configure(title: "Email", value: viewModel.formattedEmailInfo() ?? "")
            return cell
            
        case .phone:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: InfoCell.identifier, for: indexPath) as? InfoCell else {
                return UITableViewCell()
            }
            cell.configure(title: "Phone", value: viewModel.formattedPhoneInfo() ?? "")
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
}

extension UIButton {
    @MainActor
    func tapStream() -> AsyncStream<Void> {
        AsyncStream { continuation in
            let action = UIAction { _ in
                continuation.yield(())
            }
            self.addAction(action, for: .touchUpInside)
        }
    }
}
