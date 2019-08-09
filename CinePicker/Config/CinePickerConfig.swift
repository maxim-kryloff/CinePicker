import Foundation

class CinePickerConfig {

    public static let apiPath = "https://api.themoviedb.org/3"
    
    public static let imagePath = "https://image.tmdb.org/t/p/w185"
    
    public static let originalImagePath = "https://image.tmdb.org/t/p/original"
    
    public static let apiToken = ""
    
    public static func setLanguage(language: CinePickerLanguageCode) {
        UserDefaults.standard.set(language.rawValue, forKey: CinePickerSettingKeys.language)
    }
    
    public static func getLanguage() -> CinePickerLanguageCode {
        return getLanguageCode() == CinePickerLanguageCode.ru.rawValue ? .ru : .en
    }
    
    public static func getLanguageCode() -> String {
        return UserDefaults.standard.string(forKey: CinePickerSettingKeys.language) ?? CinePickerLanguageCode.en.rawValue
    }
    
    public static func setTheme(theme: CinePickerTheme) {
        UserDefaults.standard.set(theme.rawValue, forKey: CinePickerSettingKeys.theme)
    }
    
    public static func getTheme() -> CinePickerTheme {
        guard let themeRawValue = UserDefaults.standard.string(forKey: CinePickerSettingKeys.theme) else {
            return .light
        }
        
        return themeRawValue == CinePickerTheme.light.rawValue ? .light : .dark
    }
    
}
