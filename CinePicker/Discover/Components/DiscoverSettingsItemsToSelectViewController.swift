import UIKit

class DiscoverSettingsItemsToSelectViewController: UIViewController {
    
    @IBOutlet var contentUIView: UIView!
    
    @IBOutlet weak var topBarView: UIView!
    
    @IBOutlet weak var discoverItemsToSelectTableView: UITableView!
    
    public var itemsToSelect: [DiscoverSettingsItemToSelect] = []
    
    public var selectedItems: [DiscoverSettingsItemToSelect] {
        get {
            return Array(selectedItemDictionary.values)
        }
        set {
            selectedItemDictionary = [:]
            for selectedItem in newValue {
                selectedItemDictionary[selectedItem.identifier] = selectedItem
            }
        }
    }
    
    public var multipleSelectionIsAllowed: Bool = false
    
    public var onViewWillDisappear: ((_ selectedItems: [DiscoverSettingsItemToSelect]) -> Void)?
    
    private var selectedItemDictionary: [Int: DiscoverSettingsItemToSelect] = [:] {
        didSet {
            if selectedItemDictionary.isEmpty {
                disableCancelButton()
            } else if !cancelButtonIsEnabled() {
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
        navigationItem.backBarButtonItem = UIViewUtilsFactory.shared.getViewUtils().getBackBarButtonItem()
        navigationItem.rightBarButtonItems = []
    }
    
    private func defineCancelButton() {
        let item = UIBarButtonItem(
            title: CinePickerCaptions.cancel,
            style: .plain,
            target: self,
            action: #selector(DiscoverSettingsItemsToSelectViewController.onPressCancel)
        )
        item.isEnabled = !selectedItemDictionary.isEmpty
        navigationItem.rightBarButtonItems?.append(item)
    }
    
    private func defineTableView() {
        discoverItemsToSelectTableView.rowHeight = DiscoverSettingsItemsToSelectTableViewCell.standardHeight
        discoverItemsToSelectTableView.tableFooterView = UIView(frame: .zero)
    }
    
    private func setDefaultColors() {
        contentUIView.backgroundColor = CinePickerColors.getBackgroundColor()
        topBarView.backgroundColor = CinePickerColors.getTopBarColor()
        discoverItemsToSelectTableView.backgroundColor = CinePickerColors.getBackgroundColor()
    }
    
    private func enableCancelButton() {
        navigationItem.rightBarButtonItems?.first?.isEnabled = true
    }
    
    private func disableCancelButton() {
        navigationItem.rightBarButtonItems?.first?.isEnabled = false
    }
    
    private func cancelButtonIsEnabled() -> Bool {
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
        setCellProperties(cell: cell, indexPath: indexPath)
        return cell
    }
    
    private func setCellProperties(cell: DiscoverSettingsItemsToSelectTableViewCell, indexPath: IndexPath) {
        let itemToSelect = itemsToSelect[indexPath.row]
        cell.header = itemToSelect.valueToDisplay
        cell.itemIsSelected = selectedItemDictionary[itemToSelect.identifier] != nil
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        defer {
            if multipleSelectionIsAllowed {
                discoverItemsToSelectTableView.reloadRows(at: [indexPath], with: .none)
            } else {
                discoverItemsToSelectTableView.reloadData()
            }
        }
        let itemToSelect = itemsToSelect[indexPath.row]
        if selectedItemDictionary[itemToSelect.identifier] != nil {
            selectedItemDictionary[itemToSelect.identifier] = nil
            return
        }
        if !multipleSelectionIsAllowed {
            selectedItemDictionary = [:]
        }
        selectedItemDictionary[itemToSelect.identifier] = itemToSelect
    }
}
