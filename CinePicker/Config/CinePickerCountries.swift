class CinePickerCountries {
    
    private static let countries: [Country] = [
        Country(code: "AU", englishName: "Australia", russianName: "Австралия"),
        Country(code: "AT", englishName: "Austria", russianName: "Австрия"),
        Country(code: "AZ", englishName: "Azerbaijan", russianName: "Азербайджан"),
        Country(code: "AL", englishName: "Albania", russianName: "Албания"),
        Country(code: "DZ", englishName: "Algeria", russianName: "Алжир"),
        Country(code: "AR", englishName: "Argentina", russianName: "Аргентина"),
        Country(code: "AM", englishName: "Armenia", russianName: "Армения"),
        Country(code: "AF", englishName: "Afghanistan", russianName: "Афганистан"),
        Country(code: "BS", englishName: "Bahamas", russianName: "Багамские Острова"),
        Country(code: "BD", englishName: "Bangladesh", russianName: "Бангладеш"),
        Country(code: "BY", englishName: "Belarus", russianName: "Белоруссия"),
        Country(code: "BE", englishName: "Belgium", russianName: "Бельгия"),
        Country(code: "BG", englishName: "Bulgaria", russianName: "Болгария"),
        Country(code: "BO", englishName: "Bolivia", russianName: "Боливия"),
        Country(code: "BA", englishName: "Bosnia and Herzegovina", russianName: "Босния и Герцеговина"),
        Country(code: "BW", englishName: "Botswana", russianName: "Ботсвана"),
        Country(code: "BR", englishName: "Brazil", russianName: "Бразилия"),
        Country(code: "BT", englishName: "Bhutan", russianName: "Бутан"),
        Country(code: "GB", englishName: "United Kingdom", russianName: "Великобритания"),
        Country(code: "HU", englishName: "Hungary", russianName: "Венгрия"),
        Country(code: "VE", englishName: "Venezuela", russianName: "Венесуэла"),
        Country(code: "VN", englishName: "Vietnam", russianName: "Вьетнам"),
        Country(code: "GH", englishName: "Ghana", russianName: "Гана"),
        Country(code: "GN", englishName: "Guinea", russianName: "Гвинея"),
        Country(code: "DE", englishName: "Germany", russianName: "Германия"),
        Country(code: "HK", englishName: "Hong Kong", russianName: "Гонконг"),
        Country(code: "GR", englishName: "Greece", russianName: "Греция"),
        Country(code: "GE", englishName: "Georgia", russianName: "Грузия"),
        Country(code: "DK", englishName: "Denmark", russianName: "Дания"),
        Country(code: "EG", englishName: "Egypt", russianName: "Египет"),
        Country(code: "IL", englishName: "Israel", russianName: "Израиль"),
        Country(code: "IN", englishName: "India", russianName: "Индия"),
        Country(code: "ID", englishName: "Indonesia", russianName: "Индонезия"),
        Country(code: "JO", englishName: "Jordan", russianName: "Иордания"),
        Country(code: "IQ", englishName: "Iraq", russianName: "Ирак"),
        Country(code: "IR", englishName: "Iran", russianName: "Иран"),
        Country(code: "IE", englishName: "Ireland", russianName: "Ирландия"),
        Country(code: "IS", englishName: "Iceland", russianName: "Исландия"),
        Country(code: "ES", englishName: "Spain", russianName: "Испания"),
        Country(code: "IT", englishName: "Italy", russianName: "Италия"),
        Country(code: "KZ", englishName: "Kazakhstan", russianName: "Казахстан"),
        Country(code: "KH", englishName: "Cambodia", russianName: "Камбоджа"),
        Country(code: "CM", englishName: "Cameroon", russianName: "Камерун"),
        Country(code: "CA", englishName: "Canada", russianName: "Канада"),
        Country(code: "KG", englishName: "Kyrgyz Republic", russianName: "Киргизия"),
        Country(code: "CN", englishName: "China", russianName: "Китай"),
        Country(code: "KP", englishName: "North Korea", russianName: "КНДР"),
        Country(code: "CO", englishName: "Colombia", russianName: "Колумбия"),
        Country(code: "CD", englishName: "Congo", russianName: "ДР Конго"),
        Country(code: "CR", englishName: "Costa Rica", russianName: "Коста-Рика"),
        Country(code: "CU", englishName: "Cuba", russianName: "Куба"),
        Country(code: "KW", englishName: "Kuwait", russianName: "Кувейт"),
        Country(code: "LA", englishName: "Lao People's Democratic Republic", russianName: "Лаос"),
        Country(code: "LV", englishName: "Latvia", russianName: "Латвия"),
        Country(code: "LB", englishName: "Lebanon", russianName: "Ливан"),
        Country(code: "LY", englishName: "Libyan Arab Jamahiriya", russianName: "Ливия"),
        Country(code: "LT", englishName: "Lithuania", russianName: "Литва"),
        Country(code: "LI", englishName: "Liechtenstein", russianName: "Лихтенштейн"),
        Country(code: "LU", englishName: "Luxembourg", russianName: "Люксембург"),
        Country(code: "MR", englishName: "Mauritania", russianName: "Мавритания"),
        Country(code: "MT", englishName: "Malta", russianName: "Мальта"),
        Country(code: "MA", englishName: "Morocco", russianName: "Марокко"),
        Country(code: "MX", englishName: "Mexico", russianName: "Мексика"),
        Country(code: "MD", englishName: "Moldova", russianName: "Молдавия"),
        Country(code: "MC", englishName: "Monaco", russianName: "Монако"),
        Country(code: "MN", englishName: "Mongolia", russianName: "Монголия"),
        Country(code: "NA", englishName: "Namibia", russianName: "Намибия"),
        Country(code: "NP", englishName: "Nepal", russianName: "Непал"),
        Country(code: "NG", englishName: "Nigeria", russianName: "Нигерия"),
        Country(code: "NL", englishName: "Netherlands", russianName: "Нидерланды"),
        Country(code: "NZ", englishName: "New Zealand", russianName: "Новая Зеландия"),
        Country(code: "NO", englishName: "Norway", russianName: "Норвегия"),
        Country(code: "PK", englishName: "Pakistan", russianName: "Пакистан"),
        Country(code: "PS", englishName: "Palestinian Territory", russianName: "Государство Палестина"),
        Country(code: "PA", englishName: "Panama", russianName: "Панама"),
        Country(code: "PY", englishName: "Paraguay", russianName: "Парагвай"),
        Country(code: "PE", englishName: "Peru", russianName: "Перу"),
        Country(code: "PL", englishName: "Poland", russianName: "Польша"),
        Country(code: "PT", englishName: "Portugal", russianName: "Португалия"),
        Country(code: "RU", englishName: "Russia", russianName: "Россия"),
        Country(code: "RO", englishName: "Romania", russianName: "Румыния"),
        Country(code: "SA", englishName: "Saudi Arabia", russianName: "Саудовская Аравия"),
        Country(code: "MK", englishName: "Macedonia", russianName: "Северная Македония"),
        Country(code: "SN", englishName: "Senegal", russianName: "Сенегал"),
        Country(code: "RS", englishName: "Serbia", russianName: "Сербия"),
        Country(code: "SG", englishName: "Singapore", russianName: "Сингапур"),
        Country(code: "SY", englishName: "Syrian Arab Republic", russianName: "Сирия"),
        Country(code: "SK", englishName: "Slovakia", russianName: "Словакия"),
        Country(code: "SI", englishName: "Slovenia", russianName: "Словения"),
        Country(code: "SD", englishName: "Sudan", russianName: "Судан"),
        Country(code: "US", englishName: "United States of America", russianName: "США"),
        Country(code: "TJ", englishName: "Tajikistan", russianName: "Таджикистан"),
        Country(code: "TH", englishName: "Thailand", russianName: "Таиланд"),
        Country(code: "TW", englishName: "Taiwan", russianName: "Тайвань"),
        Country(code: "TN", englishName: "Tunisia", russianName: "Тунис"),
        Country(code: "TM", englishName: "Turkmenistan", russianName: "Туркмения"),
        Country(code: "TR", englishName: "Turkey", russianName: "Турция"),
        Country(code: "UZ", englishName: "Uzbekistan", russianName: "Узбекистан"),
        Country(code: "UA", englishName: "Ukraine", russianName: "Украина"),
        Country(code: "UY", englishName: "Uruguay", russianName: "Уругвай"),
        Country(code: "PH", englishName: "Philippines", russianName: "Филиппины"),
        Country(code: "FI", englishName: "Finland", russianName: "Финляндия"),
        Country(code: "FR", englishName: "France", russianName: "Франция"),
        Country(code: "HR", englishName: "Croatia", russianName: "Хорватия"),
        Country(code: "TD", englishName: "Chad", russianName: "Чад"),
        Country(code: "ME", englishName: "Montenegro", russianName: "Черногория"),
        Country(code: "CZ", englishName: "Czech Republic", russianName: "Чехия"),
        Country(code: "CL", englishName: "Chile", russianName: "Чили"),
        Country(code: "CH", englishName: "Switzerland", russianName: "Швейцария"),
        Country(code: "SE", englishName: "Sweden", russianName: "Швеция"),
        Country(code: "LK", englishName: "Sri Lanka", russianName: "Шри-Ланка"),
        Country(code: "EE", englishName: "Estonia", russianName: "Эстония"),
        Country(code: "ZA", englishName: "South Africa", russianName: "ЮАР"),
        Country(code: "KR", englishName: "South Korea", russianName: "Южная Корея"),
        Country(code: "JM", englishName: "Jamaica", russianName: "Ямайка"),
        Country(code: "JP", englishName: "Japan", russianName: "Япония")
    ]
    
    private static let countryMap: [String: Country] = {
        var map: [String: Country] = [:]
        for country in countries {
            map[country.code] = country
        }
        return map
    }()
    
    public static func getCountry(byCode code: String) -> Country? {
        return countryMap[code]
    }
}
