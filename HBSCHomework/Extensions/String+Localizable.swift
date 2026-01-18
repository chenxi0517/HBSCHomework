import Foundation

extension String {
    var localized: String {
        return NSLocalizedString(self, tableName: "Localizable", bundle: Bundle.main, value: self, comment: "")
    }
    
    func localized(withComment comment: String) -> String {
        return NSLocalizedString(self, tableName: "Localizable", bundle: Bundle.main, value: self, comment: comment)
    }
}