import Foundation

class DebounceActionService {
    
    private let debounceQueue = DispatchQueue(label: UUID().uuidString, qos: .utility, attributes: [.concurrent])
    
    private var debounceWorkItem: DispatchWorkItem?
    
    public func async(delay: DispatchTimeInterval, _ callback: @escaping () -> Void = {}) {
        debounceWorkItem?.cancel()
        debounceWorkItem = DispatchWorkItem(block: callback)
        debounceQueue.asyncAfter(deadline: .now() + delay, execute: debounceWorkItem!)
    }
}
