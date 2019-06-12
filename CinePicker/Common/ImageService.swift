import Foundation
import UIKit

class ImageService {
    
    private var queueDictionary: [String: OperationQueue] = [:]
    
    private var serialQueue = DispatchQueue(label: UUID().uuidString)
    
    public func download(by url: URL, callback: @escaping (_ image: UIImage?) -> Void) {
        let operation = ImageDownloadingOperation(url: url)
        
        operation.qualityOfService = .utility
        
        operation.completionBlock = {
            callback(operation.image)
        }
        
        let queue = OperationQueue()

        queue.addOperation(operation)
        
        serialQueue.sync {
            self.queueDictionary[url.path] = queue
        }
    }
    
    public func cancelDownloading(for url: URL) {
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
    
    private class ImageDownloadingOperation: AsyncOperation {
        
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
            
            let task = URLSession.shared.dataTask(with: url) { (data, _, _) in
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
            
            task.resume()
        }
        
    }
    
}
