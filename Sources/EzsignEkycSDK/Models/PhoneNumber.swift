import Foundation

/// Indonesian phone numbers in the `+62…` form the ezSign API expects, matching formatPhone()
/// and the length check of the ezSign Flutter app (the Android SDK uses the same rules).
enum PhoneNumber {

    private static let countryCode = "+62"
    private static let minNationalDigits = 9

    /// Returns the normalized number, or nil when it is too short or not numeric.
    static func normalize(_ input: String) -> String? {
        let compact = input.filter { !$0.isWhitespace && $0 != "-" }
        var national: Substring
        if compact.hasPrefix(countryCode) {
            national = compact.dropFirst(countryCode.count)
        } else if compact.hasPrefix("62") {
            national = compact.dropFirst(2)
        } else {
            national = Substring(compact)
        }
        national = national.drop { $0 == "0" }
        guard national.count >= minNationalDigits, national.allSatisfy({ $0.isASCII && $0.isNumber }) else { return nil }
        return countryCode + national
    }
}
