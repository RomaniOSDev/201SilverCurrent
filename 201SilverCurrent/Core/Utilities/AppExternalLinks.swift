import Foundation

enum AppExternalLinks: String {
    case privacyPolicy = "https://silver201current.site/privacy/235"
    case termsOfUse = "https://silver201current.site/terms/235"

    var url: URL? {
        URL(string: rawValue)
    }
}
