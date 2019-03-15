import Foundation

class AsyncOperation: Operation {
    
    public enum State: String {
        case isReady, isExecuting, isFinished
    }
    
    public var state: State = .isReady {
        willSet {
            willChangeValue(forKey: newValue.rawValue)
            willChangeValue(forKey: state.rawValue)
        }
        
        didSet {
            didChangeValue(forKey: oldValue.rawValue)
            didChangeValue(forKey: state.rawValue)
        }
    }
    
    override var isReady: Bool {
        return super.isReady && state == .isReady
    }
    
    override var isExecuting: Bool {
        return state == .isExecuting
    }
    
    override var isFinished: Bool {
        return state == .isFinished
    }
    
    override var isAsynchronous: Bool {
        return true
    }
    
    override func start () {
        if isCancelled {
            state = .isFinished
            return
        }
        
        main()
        
        state = .isExecuting
    }
    
    override func cancel () {
        super.cancel ()
        state = .isFinished
    }
    
}
