import UIKit

class DiscoverSettingsItemsToSelectViewController: UIViewController {
    
    @IBOutlet var contentUIView: UIView!
    
    @IBOutlet weak var topBarView: UIView!
    
    @IBOutlet weak var discoverItemsToSelectTableView: UITableView!
    
    public var itemsToSelect: [DiscoverSettingsItemToSelect] = []
    
    public var selectedItems: [DiscoverSettingsItemToSelect] {
        get {
            return Array(selectedItemMap.values)
        }
        
        set {
            selectedItemMap = [:]
            
            for selectedItem in newValue {
                selectedItemMap[selectedItem.identifier] = selectedItem
            }
        }
    }
    
    public var allowsMultipleSelection: Bool = false
    
    public var onViewWillDisappear: ((_ selectedItems: [DiscoverSettingsItemToSelect]) -> Void)?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return CinePickerColors.statusBarStyle
    }
    
    private var selectedItemMap: [Int: DiscoverSettingsItemToSelect] = [:] {
        didSet {
            if selectedItemMap.isEmpty {
                disableCancelButton()
            } else if !isCancelButtonEnabled() {
                enableCancelButton()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        defineNavigationController()
        defineCancelButton()
        defineTableView()
        
        setDefaultColors()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        onViewWillDisappear?(selectedItems)
    }
    
    private func defineNavigationController() {
        navigationItem.backBarButtonItem = UIBarButtonItem(
            title: CinePickerCaptions.back, style: .plain, target: nil, action: nil
        )
        
        navigationItem.rightBarButtonItems = []
    }
    
    private func defineCancelButton() {
        let item = UIBarButtonItem(
            title: CinePickerCaptions.cancel,
            style: .plain,
            target: self,
            action: #selector(DiscoverSettingsItemsToSelectViewController.onPressCancel)
        )
        
        item.isEnabled = !selectedItemMap.isEmpty
        
        navigationItem.rightBarButtonItems?.append(item)
    }
    
    private func defineTableView() {
        discoverItemsToSelectTableView.rowHeight = DiscoverSettingsItemsToSelectTableViewCell.standardHeight
        discoverItemsToSelectTableView.tableFooterView = UIView(frame: .zero)
    }
    
    private func setDefaultColors() {
        contentUIView.backgroundColor = CinePickerColors.backgroundColor
        topBarView.backgroundColor = CinePickerColors.topBarColor
        discoverItemsToSelectTableView.backgroundColor = CinePickerColors.backgroundColor
    }
    
    private func enableCancelButton() {
        navigationItem.rightBarButtonItems?.first?.isEnabled = true
    }
    
    private func disableCancelButton() {
        navigationItem.rightBarButtonItems?.first?.isEnabled = false
    }
    
    private func isCancelButtonEnabled() -> Bool {
        return navigationItem.rightBarButtonItems?.first?.isEnabled ?? false
    }
    
    @objc private func onPressCancel() {
        selectedItems = []
        discoverItemsToSelectTableView.reloadData()
    }
    
}

extension DiscoverSettingsItemsToSelectViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemsToSelect.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.discoverSettingsItemsToSelect, for: indexPath) as! DiscoverSettingsItemsToSelectTableViewCell
        
        let itemToSelect = itemsToSelect[indexPath.row]
        
        cell.header = itemToSelect.valueToDisplay
        cell.isItemSelected = selectedItemMap[itemToSelect.identifier] != nil
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        defer {
            if !allowsMultipleSelection {
                discoverItemsToSelectTableView.reloadData()
            } else {
                discoverItemsToSelectTableView.reloadRows(at: [indexPath], with: .none)
            }
        }
        
        let itemToSelect = itemsToSelect[indexPath.row]
        
        if selectedItemMap[itemToSelect.identifier] != nil {
            selectedItemMap[itemToSelect.identifier] = nil
            return
        }
        
        if !allowsMultipleSelection {
            selectedItemMap = [:]
        }
        
        selectedItemMap[itemToSelect.identifier] = itemToSelect
    }
    
}
