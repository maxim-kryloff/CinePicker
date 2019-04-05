import UIKit

class StatesViewController: UIViewController {

    public var tableViewDefinition: UITableView! {
        fatalError("tableViewDefinition must be overriden...'")
    }

    private var loadingView: UIView!
    
    private var isInLoadingState = false
    
    private var failedLoadingView: FailedLoadingUIView!
    
    private var messageView: MessageUIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        defineLoadingView()
        defineFailedLoadingView()
        defineMessageView()
    }
    
    public func onReloadData() { }
    
    public func updateTable<DataType>(withData data: [DataType]) { }
    
    private func defineLoadingView() {
        loadingView = UIViewHelper.getLoadingView(for: tableViewDefinition)
    }
    
    private func defineFailedLoadingView() {
        failedLoadingView = UIViewHelper.getFailedLoadingView(for: tableViewDefinition, onTouchDownHandler: onReloadData)
    }
    
    private func defineMessageView() {
        messageView = UIViewHelper.getMessageView(for: tableViewDefinition)
    }

}

extension StatesViewController {
    
    public func setLoadingState() {
        isInLoadingState = true
        
        tableViewDefinition.backgroundView = loadingView
        updateTable(withData: [])
    }
    
    public func unsetLoadingState() {
        if isInLoadingState {
            isInLoadingState = false
            tableViewDefinition.backgroundView = nil
        }
    }
    
    public func setFailedLoadingState() {
        tableViewDefinition.backgroundView = failedLoadingView
        updateTable(withData: [])
    }
    
    public func unsetFailedLoadingState() {
        if tableViewDefinition.backgroundView is FailedLoadingUIView {
            tableViewDefinition.backgroundView = nil
        }
    }
    
    public func setMessageState(withMessage message: String) {
        messageView.message = message
        tableViewDefinition.backgroundView = messageView
        
        updateTable(withData: [])
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
