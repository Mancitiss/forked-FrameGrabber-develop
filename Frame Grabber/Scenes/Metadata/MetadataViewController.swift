import Combine
import MapKit
import Utility
import UIKit

class MetadataViewController: UITableViewController {
    
    typealias DataSource = UITableViewDiffableDataSource<MetadataViewModel.Section, MetadataViewModel.Item>

    var viewModel: MetadataViewModel!
        
    private lazy var tableDataSource = DataSource(tableView: tableView) {
        [weak self] _, indexPath, item in self?.cell(for: indexPath, item: item)
    }
    
    @IBOutlet private var locationHeader: MetadataLocationHeader!
    private var bindings = Set<AnyCancellable>()
    
    private var loadingView: UIView? {
        navigationItem.leftBarButtonItem?.customView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.async {
            self.configureViews()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if preferredContentSize != tableView.contentSize {
            preferredContentSize = tableView.contentSize
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        DispatchQueue.main.async {
            self.tableView.updateHeaderLayout(animated: false)
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.hasDifferentContentSize(comparedTo: previousTraitCollection) {
            DispatchQueue.main.async {
                self.tableView.updateHeaderLayout(animated: false)
                self.tableView.reloadData()  // Cells don't seem to shrink back on their own.
            }
        }
    }
    
    @IBAction private func done() {
        dismiss(animated: true)
    }
    
    @IBAction private func openInMaps() {
        viewModel.location?.mapItem?.openInMaps()
    }
        
    private func configureViews() {
        tableDataSource.defaultRowAnimation = .fade
        tableView.reloadData()  // Required.
        tableView.dataSource = tableDataSource

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(done)
        )

        configureHeader()
        configureBindings()
    }

    private func configureHeader() {
        locationHeader.translatesAutoresizingMaskIntoConstraints = false
        tableView.tableHeaderView = locationHeader

        locationHeader.widthAnchor.constraint(equalTo: tableView.widthAnchor).isActive = true
        locationHeader.centerXAnchor.constraint(equalTo: tableView.centerXAnchor).isActive = true
        locationHeader.topAnchor.constraint(equalTo: tableView.topAnchor).isActive = true
    }
    
    private func updateHeader(animated: Bool) {
        if let location = viewModel.location {
            locationHeader.mapPin = location.mapPin
            locationHeader.addressLabel.text = location.address
            locationHeader.setHeaderHidden(false)
        } else {
            locationHeader.setHeaderHidden(true)
        }
                
        tableView.updateHeaderLayout(animated: animated)
    }
    
    private func configureBindings() {
        viewModel
            .$isLoading
            .map { !$0 }
            .assignWeak(to: \.isHidden, on: loadingView)
            .store(in: &bindings)
        
        viewModel
            .$snapshot
            .sink { [weak self] snapshot in
                let isVisible = self?.view.window != nil
                self?.tableDataSource.apply(snapshot, animatingDifferences: isVisible)
            }
            .store(in: &bindings)
        
        viewModel
            .$location
            .removeDuplicates { $0?.address == $1?.address }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] location in
                let isVisible = self?.view.window != nil
                self?.updateHeader(animated: isVisible)
            }
            .store(in: &bindings)
    }

    private func cell(for indexPath: IndexPath, item: MetadataViewModel.Item) -> UITableViewCell {
        let id = MetadataCell.className
        let _cell = self.tableView.dequeueReusableCell(withIdentifier: id, for: indexPath)
        
        guard let cell = _cell as? MetadataCell else { fatalError("Wrong cell id or type.") }
        
        cell.titleLabel?.text = item.title
        cell.detailLabel?.text = item.detail
                    
        return cell
    }
}

private extension UITableView {

    /// Resizes the table header view according to its Auto Layout constraints.
    ///
    /// `UITableView` does not auto-size header or footers. Any change in the header affecting its
    /// layout needs to be updated manually.
    func updateHeaderLayout(animated: Bool, animationDuration: TimeInterval = 0.15) {
        let update = {
            let header = self.tableHeaderView
            header?.layoutIfNeeded()
            self.tableHeaderView = header  // Needs to be reset.
        }
        
        if animated {
            UIView.animate(
                withDuration: animationDuration,
                delay: 0,
                options: .beginFromCurrentState,
                animations: update,
                completion: nil
            )
        } else {
            update()
        }
    }
}
