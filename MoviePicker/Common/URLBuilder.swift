import Foundation

class URLBuilder {
    
    private var url: URL?
    
    private var queryItems: [URLQueryItem]
    
    init(string: String) {
        url = URL(string: string)
        queryItems = []
    }
    
    public func append(pathComponent: String) -> URLBuilder {
        url?.appendPathComponent(pathComponent)
        return self
    }
    
    public func append(queryItem: (String, String))  -> URLBuilder {
        let queryItem = URLQueryItem(name: queryItem.0, value: queryItem.1)
        queryItems.append(queryItem)
        
        return self
    }
    
    public func build() -> URL? {
        guard let url = url else {
            return nil
        }
        
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
        urlComponents?.queryItems = queryItems
        
        return urlComponents?.url
    }
    
}
