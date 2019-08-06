import UIKit

class CinePickerColors {
    
    public static var backgroundColor: UIColor {
        return getUIColorFromRGB(26, 26, 26)
    }
    
    public static var selectedBackgroundColor: UIColor {
        return getUIColorFromRGB(50, 50, 50)
    }
    
    public static var activityIndicatorColor: UIColor {
        return titleColor
    }
    
    public static var titleColor: UIColor {
        return getUIColorFromRGB(247, 247, 247)
    }
    
    public static var subtitleColor: UIColor {
        return getUIColorFromRGB(153, 153, 153)
    }
    
    public static var genresColor: UIColor {
        return subtitleColor
    }
    
    public static var topBarColor: UIColor {
        return bottomBarColor
    }
    
    public static var bottomBarColor: UIColor {
        return getUIColorFromRGB(65, 65, 65)
    }
    
    public static var textNegativeColor: UIColor {
        return getUIColorFromRGB(252, 54, 53)
    }
    
    public static var textNeutralColor: UIColor {
        return getUIColorFromRGB(255, 150, 0)
    }
    
    public static var textPositiveColor: UIColor {
        return getUIColorFromRGB(0, 180, 0)
    }
    
    public static var tagColor: UIColor {
        return titleColor
    }
    
    public static var willCheckItOutTagColor: UIColor {
        return getUIColorFromRGB(230, 144, 90)
    }
    
    public static var iLikeItTagColor: UIColor {
        return getUIColorFromRGB(227, 102, 95)
    }
    
    public static var releaseYearColor: UIColor {
        return subtitleColor
    }
    
    public static var voteCountColor: UIColor {
        return subtitleColor
    }
    
    public static var voteSeparatorColor: UIColor {
        return getUIColorFromRGB(153, 153, 153)
    }
    
    public static var messageColor: UIColor {
        return subtitleColor
    }
    
    public static var overviewColor: UIColor {
        return titleColor
    }
    
    public static var actionColor: UIColor {
        return getUIColorFromRGB(1, 122, 255)
    }
    
    public static var alertBorderColor: UIColor {
        return bottomBarColor
    }
    
    // TODO: This is workaround to 'hide' disappearing search bar when changing VC
    public static var navigationBarTintColor: UIColor {
        return getUIColorFromRGB(8, 8, 8)
    }
    
    // TODO: Issue for different themes
    public static let blackHex: UInt = 0x323232
    
    private static func getUIColorFromRGB(_ red: Int, _ green: Int, _ blue: Int) -> UIColor {
        let red = CGFloat(Double(red) / 255.0)
        let green = CGFloat(Double(green) / 255.0)
        let blue = CGFloat(Double(blue) / 255.0)
        
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
    
}
