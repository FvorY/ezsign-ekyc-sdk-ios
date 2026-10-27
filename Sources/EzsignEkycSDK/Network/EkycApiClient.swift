import Foundation

final class EkycApiClient {
    private let baseUrl: String
    private let authToken: String
    private let session: URLSession

    init(baseUrl: String, authToken: String) {
        self.baseUrl = baseUrl.hasSuffix("/") ? String(baseUrl.dropLast()) : baseUrl
        self.authToken = authToken.hasPrefix("Bearer ") ? authToken : "Bearer \(authToken)"
        self.session = URLSession.shared
    }

    private func makeRequest(path: String, method: String = "POST", jsonBody: [String: Any]? = nil) throws -> URLRequest {
        guard let url = URL(string: "\(baseUrl)\(path)") else {
            throw NSError(domain: "EkycApiClient", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue(authToken, forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let jsonBody = jsonBody {
            request.httpBody = try JSONSerialization.data(withJSONObject: jsonBody, options: [])
        }
        return request
    }

    func getEkycStatus() async throws -> ApiResponse<EkycStatusData> {
        let req = try makeRequest(path: "/register/user/ekyc-status")
        let (data, _) = try await session.data(for: req)
        return try JSONDecoder().decode(ApiResponse<EkycStatusData>.self, from: data)
    }

    func checkDemografi(nama: String, nik: String, birthDate: String) async throws -> ApiResponse<EmptyData> {
        let body: [String: Any] = ["nama": nama, "nik": nik, "birthDate": birthDate]

        let reqCheck = try makeRequest(path: "/register/checkdata", jsonBody: body)
        let (checkData, _) = try await session.data(for: reqCheck)

        let reqNik = try makeRequest(path: "/register/verifyNik", jsonBody: ["nik": nik])
        let (nikData, _) = try await session.data(for: reqNik)

        let reqDemo = try makeRequest(path: "/register/checkdemografi", jsonBody: body)
        let (demoData, _) = try await session.data(for: reqDemo)
        return try JSONDecoder().decode(ApiResponse<EmptyData>.self, from: demoData)
    }

    func validatePhone(phone: String) async throws -> ApiResponse<ValidatePhoneData> {
        let body: [String: Any] = [
            "phone": phone,
            "otpType": 1,
            "menu": "register_update"
        ]
        let req = try makeRequest(path: "/otp/validatephone", jsonBody: body)
        let (data, _) = try await session.data(for: req)
        return try JSONDecoder().decode(ApiResponse<ValidatePhoneData>.self, from: data)
    }

    func verifyOtp(phone: String, otp: String, token: String? = nil) async throws -> ApiResponse<VerifyOtpData> {
        var body: [String: Any] = ["phoneNumber": phone, "otp": otp]
        if let token = token {
            body["token"] = token
        }
        let req = try makeRequest(path: "/register/user/verifyotp", jsonBody: body)
        let (data, _) = try await session.data(for: req)
        return try JSONDecoder().decode(ApiResponse<VerifyOtpData>.self, from: data)
    }

    func getBizToken() async throws -> ApiResponse<BizTokenData> {
        let req = try makeRequest(path: "/register/user/get-biz-token")
        let (data, _) = try await session.data(for: req)
        return try JSONDecoder().decode(ApiResponse<BizTokenData>.self, from: data)
    }

    func submitLiveness(bizToken: String, livenessId: String) async throws -> ApiResponse<EmptyData> {
        guard let url = URL(string: "\(baseUrl)/register/user/liveness-face-id") else {
            throw NSError(domain: "EkycApiClient", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }

        let boundary = "Boundary-\(UUID().uuidString)"
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(authToken, forHTTPHeaderField: "Authorization")
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()
        let fields: [String: String] = [
            "biz_token": bizToken,
            "verify_id": livenessId,
            "data_type": "0",
            "encryption_type": "0"
        ]

        for (key, value) in fields {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body

        let (data, _) = try await session.data(for: request)
        return try JSONDecoder().decode(ApiResponse<EmptyData>.self, from: data)
    }

    func updateMobile(nama: String, nik: String, birthDate: String, phone: String, otp: String, bizToken: String) async throws -> ApiResponse<EmptyData> {
        let body: [String: Any] = [
            "nama": nama,
            "nik": nik,
            "birthDate": birthDate,
            "phone": phone,
            "otp": otp,
            "bizToken": bizToken
        ]
        let req = try makeRequest(path: "/register/update-mobile", jsonBody: body)
        let (data, _) = try await session.data(for: req)
        return try JSONDecoder().decode(ApiResponse<EmptyData>.self, from: data)
    }

    func refreshAuth() async throws -> ApiResponse<AuthRefreshData> {
        let req = try makeRequest(path: "/auth/refresh")
        let (data, _) = try await session.data(for: req)
        return try JSONDecoder().decode(ApiResponse<AuthRefreshData>.self, from: data)
    }
}
