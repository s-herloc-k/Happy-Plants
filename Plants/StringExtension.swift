import Foundation

extension String {
    var localized: String {
        NSLocalizedString(self, comment: "\(self) could not e found in Localizable.strings")
    }
}
