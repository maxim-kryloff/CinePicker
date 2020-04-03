import UIKit

class StateViewController: UIViewController {
    
    public var tableViewDefinition: UITableView! {
        fatalError("tableViewDefinition must be overridden.")
    }
    
    private var loadingView: LoadingUIView!
    
    private var failedLoadingView: FailedLoadingUIView!
    
    private var messageView: MessageUIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        defineLoadingView()
        defineFailedLoadingView()
        defineMessageView()
    }
    
    public func onReloadData() { }
    
    public func updateTable<DataType>(providingData data: [DataType]) { }
    
    private func defineLoadingView() {
        loadingView = UIViewUtilsFactory.shared.getViewUtils()
            .getLoadingView(for: tableViewDefinition)
    }
    
    private func defineFailedLoadingView() {
        failedLoadingView = UIViewUtilsFactory.shared.getViewUtils()
            .getFailedLoadingView(for: tableViewDefinition, onTouchDown: onReloadData)
    }
    
    private func defineMessageView() {
        messageView = UIViewUtilsFactory.shared.getViewUtils()
            .getMessageView(for: tableViewDefinition)
    }
}

extension StateViewController {
    
    public func setLoadingState() {
        tableViewDefinition.backgroundView = loadingView
        updateTable(providingData: [])
    }
    
    public func unsetLoadingState() {
        if tableViewDefinition.backgroundView is LoadingUIView {
            tableViewDefinition.backgroundView = nil
        }
    }
    
    public func setFailedLoadingState() {
        tableViewDefinition.backgroundView = failedLoadingView
        updateTable(providingData: [])
    }
    
    public func unsetFailedLoadingState() {
        if tableViewDefinition.backgroundView is FailedLoadingUIView {
            tableViewDefinition.backgroundView = nil
        }
    }
    
    public func setMessageState(withMessage message: String) {
        messageView.message = message
        tableViewDefinition.backgroundView = messageView
        updateTable(providingData: [])
    }
    
    public func unsetMessageState() {
        if tableViewDefinition.backgroundView is MessageUIView {
            tableViewDefinition.backgroundView = nil
        }
    }
    
    public func unsetAllStates() {
        unsetLoadingState()
        unsetFailedLoadingState()
        unsetMessageState()
    }
}
