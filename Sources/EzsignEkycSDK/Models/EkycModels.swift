import Foundation

public struct EkycConfig {
    public let authToken: String
    public let baseUrl: String
    public let title: String
    public let primaryColorHex: String

    public init(
        authToken: String,
        baseUrl: String = "https://gtm.myesign.id/api",
        title: String = "Your Identity",
        primaryColorHex: String = "#15C1E7"
    ) {
        self.authToken = authToken
        self.baseUrl = baseUrl
        self.title = title
        self.primaryColorHex = primaryColorHex
    }
}

public enum EkycResult {
    case success(regisStatus: String, message: String)
    case failure(errorCode: String, message: String)
    case cancelled
}

struct ApiResponse<T: Decodable>: Decodable {
    let code: Int
    let message: String?
    let data: T?
}

/// Accepts any `data` value (object, array, string, number or null), like the Android SDK,
/// for endpoints whose payload the SDK does not read.
struct EmptyData: Decodable {
    init(from decoder: Decoder) throws {}
}

struct EkycStatusData: Decodable {
    let canEkyc: Bool
    let citizenshipCode: String?
}

struct ValidatePhoneData: Decodable {
    let cooldown: Double?

    private enum CodingKeys: String, CodingKey { case cooldown }

    // The server may send the cooldown as a number or a numeric string.
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let value = try? container.decodeIfPresent(Double.self, forKey: .cooldown) {
            cooldown = value
        } else if let text = try? container.decodeIfPresent(String.self, forKey: .cooldown) {
            cooldown = Double(text)
        } else {
            cooldown = nil
        }
    }
}

struct VerifyOtpData: Decodable {
    let token: String?
}

struct BizTokenData: Decodable {
    let biz_token: String
    let liveness_id: String
}

struct AuthRefreshData: Decodable {
    let regisStatus: String?
    let token: String?
}
