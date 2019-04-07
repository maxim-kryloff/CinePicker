import Foundation

class CinePickerConfig {

    public static let apiPath = "https://api.themoviedb.org/3"
    
    public static let imagesPath = "https://image.tmdb.org/t/p/w185"
    
    public static let apiToken = ""
    
    public static func getLanguage() -> String {
        return UserDefaults.standard.string(forKey: "Language") ?? "en-US"
    }

}
