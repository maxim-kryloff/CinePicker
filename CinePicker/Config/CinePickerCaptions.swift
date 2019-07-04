class CinePickerCaptions {
    
    public static var bookmarks: String {
        if CinePickerConfig.getLanguage() == "ru-RU" {
            return "Закладки"
        }
        
        return "Bookmarks"
    }
    
    public static var saveToBookmarks: String {
        if CinePickerConfig.getLanguage() == "ru-RU" {
            return "Добавить в закладки"
        }
        
        return "Save to Bookmarks"
    }
    
    public static var removeFromBookmarks: String {
        if CinePickerConfig.getLanguage() == "ru-RU" {
            return "Убрать из закладок"
        }
        
        return "Remove from Bookmarks"
    }
    
    public static var goToFullCast: String {
        if CinePickerConfig.getLanguage() == "ru-RU" {
            return "Все актеры"
        }
        
        return "Go to Full Cast"
    }
    
    public static var goToFullCrew: String {
        if CinePickerConfig.getLanguage() == "ru-RU" {
            return "Съемочная группа"
        }
        
        return "Go to Full Crew"
    }
    
    public static var cast: String {
        if CinePickerConfig.getLanguage() == "ru-RU" {
            return "Актер"
        }
        
        return "Cast"
    }
    
    public static var crew: String {
        if CinePickerConfig.getLanguage() == "ru-RU" {
            return "Участник съемок"
        }
        
        return "Crew"
    }
    
    public static var loadingData: String {
        if CinePickerConfig.getLanguage() == "ru-RU" {
            return "Загрузка данных..."
        }
        
        return "Loading data..."
    }
    
    public static var couldntReloadData: String {
        if CinePickerConfig.getLanguage() == "ru-RU" {
            return "Ошибка загрузки данных..."
        }
        
        return "Couldn't load data..."
    }
    
    public static var reload: String {
        if CinePickerConfig.getLanguage() == "ru-RU" {
            return "Загрузить"
        }
        
        return "Reload"
    }
    
    public static var thereIsNoDataFound: String {
        if CinePickerConfig.getLanguage() == "ru-RU" {
            return "Данные не найдены..."
        }
        
        return "There is no data found..."
    }
    
    public static var thereAreNoMoviesFound: String {
        if CinePickerConfig.getLanguage() == "ru-RU" {
            return "Фильмы не найдены..."
        }
        
        return "There are no movies found..."
    }
    
    public static var more: String {
        if CinePickerConfig.getLanguage() == "ru-RU" {
            return "Еще"
        }
        
        return "More"
    }
    
    public static var lang: String {
        if CinePickerConfig.getLanguage() == "ru-RU" {
            return "Язык"
        }
        
        return "Lang"
    }
    
    public static var typeMovieOrActor: String {
        if CinePickerConfig.getLanguage() == "ru-RU" {
            return "Название фильма, имя актера..."
        }
        
        return "Type movie or actor..."
    }
    
    public static var eraseBookmarks: String {
        if CinePickerConfig.getLanguage() == "ru-RU" {
            return "Очистить закладки"
        }
        
        return "Erase Bookmarks"
    }
    
    public static var english: String {
        if CinePickerConfig.getLanguage() == "ru-RU" {
            return "Английский язык"
        }
        
        return "English"
    }
    
    public static var russian: String {
        if CinePickerConfig.getLanguage() == "ru-RU" {
            return "Русский язык"
        }
        
        return "Russian"
    }
    
    public static var backToSearch: String {
        if CinePickerConfig.getLanguage() == "ru-RU" {
            return "Назад к поиску"
        }
        
        return "Back to Search"
    }
    
    public static var goToSimilarMovies: String {
        if CinePickerConfig.getLanguage() == "ru-RU" {
            return "Похожие фильмы"
        }
        
        return "Go to Similar Movies"
    }
    
    public static var back: String {
        if CinePickerConfig.getLanguage() == "ru-RU" {
            return "Назад"
        }
        
        return "Back"
    }
    
    public static var cancel: String {
        if CinePickerConfig.getLanguage() == "ru-RU" {
            return "Отмена"
        }
        
        return "Cancel"
    }
    
    public static var otherInCollection: String {
        if CinePickerConfig.getLanguage() == "ru-RU" {
            return "Другие части"
        }
        
        return "Other in Collection"
    }
    
    public static func movies(ofPerson personName: String) -> String {
        if CinePickerConfig.getLanguage() == "ru-RU" {
            return "Фильмы \(personName)"
        }
        
        return "\(personName)'s Movies"
    }
    
    public static func moviesSimilar(to movieTitle: String) -> String {
        if CinePickerConfig.getLanguage() == "ru-RU" {
            return "\(movieTitle). Похожие фильмы"
        }
        
        return "Similar to \(movieTitle)"
    }

}
