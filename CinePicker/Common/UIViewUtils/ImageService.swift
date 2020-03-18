import Foundation
import UIKit

class ImageService {
    
    private var queueDictionary: [String: OperationQueue] = [:]
    
    private var serialQueue = DispatchQueue(label: UUID().uuidString)
    
    public func download(by url: URL, onComplete callback: @escaping (_ image: UIImage?) -> Void) {
        let operation = createDownloadImageOperation(downloadImageBy: url, onComplete: callback)
        let queue = createOperationQueue(andPut: operation)
        serialQueue.sync {
            self.queueDictionary[url.path] = queue
        }
    }
    
    private func createDownloadImageOperation(
        downloadImageBy url: URL,
        onComplete callback: @escaping (_ image: UIImage?) -> Void
    ) -> AsyncOperation {
        let operation = DownloadImageOperation(url: url)
        operation.qualityOfService = .utility
        operation.completionBlock = {
            callback(operation.image)
        }
        return operation
    }
    
    private func createOperationQueue(andPut operation: AsyncOperation) -> OperationQueue {
        let queue = OperationQueue()
        queue.addOperation(operation)
        return queue
    }
    
    public func cancelDownloading(by url: URL) {
        serialQueue.sync {
            guard let queue = self.queueDictionary[url.path] else {
                return
            }
            queue.cancelAllOperations()
            self.queueDictionary[url.path] = nil
        }
    }
}

extension ImageService {
    
    private class DownloadImageOperation: AsyncOperation {
        
        var url: URL
        
        var image: UIImage?
        
        init(url: URL) {
            self.url = url
            super.init()
        }
        
        override func main() {
            if isCancelled {
                return
            }
            downloadImage()
        }
        
        private func downloadImage() {
            let task = createDownloadImageTask()
            task.resume()
        }
        
        private func createDownloadImageTask() -> URLSessionDataTask {
            return URLSession.shared.dataTask(with: url) { (data, _, _) in
                if self.isCancelled {
                    return
                }
                guard let data = data else {
                    self.state = .isFinished
                    return
                }
                self.image = UIImage(data: data)
                self.state = .isFinished
            }
        }
    }
}
