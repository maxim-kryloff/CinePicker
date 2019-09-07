class NumericDiscoverSettingsItemToSelect {
    
    public let value: Double
    
    public let label: String
    
    init(value: Double, label: String) {
        self.value = value
        self.label = label
    }
    
}

extension NumericDiscoverSettingsItemToSelect: DiscoverSettingsItemToSelect {
    
    var identifier: Int {
        // Unique value for rating...
        return Int(value * 10)
    }
    
    var valueToDisplay: String {
        return label
    }
    
}
