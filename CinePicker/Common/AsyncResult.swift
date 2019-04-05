enum AsyncResult<ResultType> {
    
    case success(ResultType)
    
    case failure(Error)
    
    public func getValue() throws -> ResultType {
        switch self {
        case AsyncResult.success(let value): return value
        case AsyncResult.failure(let error): throw error
        }
    }
    
}
