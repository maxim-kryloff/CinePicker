class UIViewUtilsFactory {
    
    private static var instance: UIViewUtilsFactory?
    
    public static var shared: UIViewUtilsFactory {
        if instance == nil {
            instance = UIViewUtilsFactory()
        }
        return instance!
    }
    
    private init() { }
    
    public func getImageUtils() -> UIImageUtils {
        return UIImageUtils.shared
    }
    
    public func getAlertUtils() -> UIAlertUtils {
        return UIAlertUtils.shared
    }
}
