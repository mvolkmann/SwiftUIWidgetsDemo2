import Foundation

extension Double {
    var roundedString: String {
        String(format: "%.0f", self)
    }
}
