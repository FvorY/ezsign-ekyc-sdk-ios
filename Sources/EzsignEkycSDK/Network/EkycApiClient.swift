import Foundation

final class EkycApiClient {
    private let baseUrl: String
    private let authToken: String
    private let session: URLSession

    init(baseUrl: String, authToken: String) {
        let clean = baseUrl.trimmingCharacters(in: CharacterSet(charactersIn: "/ "))
        self.baseUrl = clean.hasSuffix("/api") ? clean : "\(clean)/api"

        var cleanToken = authToken.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleanToken.hasPrefix("\"") && cleanToken.hasSuffix("\"") {
            cleanToken = String(cleanToken.dropFirst().dropLast()).trimmingCharacters(in: .whitespacesAndNewlines)
        }
        if cleanToken.lowercased().hasPrefix("bearer ") {
            cleanToken = String(cleanToken.dropFirst(7)).trimmingCharacters(in: .whitespacesAndNewlines)
        }
        cleanToken = cleanToken.replacingOccurrences(of: "\n", with: "")
            .replacingOccurrences(of: "\r", with: "")
            .replacingOccurrences(of: " ", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        self.authToken = "Bearer \(cleanToken)"
        self.session = URLSession.shared
    }

    private func makeRequest(path: String, method: String = "POST", jsonBody: [String: Any]? = nil) throws -> URLRequest {
        let cleanPath = path.hasPrefix("/") ? path : "/\(path)"
        guard let url = URL(string: "\(baseUrl)\(cleanPath)") else {
            throw NSError(domain: "EkycApiClient", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue(authToken, forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("ezSign-iOS", forHTTPHeaderField: "User-Agent")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        if let jsonBody = jsonBody {
            request.httpBody = try JSONSerialization.data(withJSONObject: jsonBody, options: [])
        }
        return request
    }

    private func parseResponse<T: Decodable>(_ data: Data, response: URLResponse) throws -> ApiResponse<T> {
        let httpRes = response as? HTTPURLResponse
        let statusCode = httpRes?.statusCode ?? 200

        let decoder = JSONDecoder()
        if let decoded = try? decoder.decode(ApiResponse<T>.self, from: data) {
            if decoded.code != 200 && decoded.code != 0 {
                var msg = decoded.message ?? "Terjadi kesalahan pada server"
                if msg.localizedCaseInsensitiveContains("JWT") || msg.localizedCaseInsensitiveContains("Unauthorized") {
                    msg = "Sesi token tidak valid atau kadaluarsa (\(msg)). Pastikan token masih aktif dan Base URL sesuai environment akun Anda."
                }
                throw NSError(domain: "EkycApiClient", code: decoded.code, userInfo: [NSLocalizedDescriptionKey: msg])
            }
            return decoded
        }

        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            var msg = (json["message"] as? String) ?? (json["error"] as? String) ?? "Terjadi kesalahan pada server (HTTP \(statusCode))"
            if msg.localizedCaseInsensitiveContains("JWT") || msg.localizedCaseInsensitiveContains("Unauthorized") {
                msg = "Sesi token tidak valid atau kadaluarsa (\(msg)). Pastikan token masih aktif dan Base URL sesuai environment akun Anda."
            }
            throw NSError(domain: "EkycApiClient", code: statusCode, userInfo: [NSLocalizedDescriptionKey: msg])
        }

        if statusCode < 200 || statusCode >= 300 {
            throw NSError(domain: "EkycApiClient", code: statusCode, userInfo: [NSLocalizedDescriptionKey: "HTTP \(statusCode)"])
        }

        throw NSError(domain: "EkycApiClient", code: -1, userInfo: [NSLocalizedDescriptionKey: "Gagal memproses respon server"])
    }

    func getEkycStatus() async throws -> ApiResponse<EkycStatusData> {
        let req = try makeRequest(path: "/register/user/ekyc-status")
        let (data, res) = try await session.data(for: req)
        return try parseResponse(data, response: res)
    }

    func checkDemografi(nama: String, nik: String, birthDate: String) async throws -> ApiResponse<EmptyData> {
        let body: [String: Any] = ["nama": nama, "nik": nik, "birthDate": birthDate]

        let reqCheck = try makeRequest(path: "/register/checkdata", jsonBody: body)
        let (checkData, resCheck) = try await session.data(for: reqCheck)
        let _: ApiResponse<EmptyData> = try parseResponse(checkData, response: resCheck)

        let reqNik = try makeRequest(path: "/register/verifyNik", jsonBody: ["nik": nik])
        let (nikData, resNik) = try await session.data(for: reqNik)
        let _: ApiResponse<EmptyData> = try parseResponse(nikData, response: resNik)

        let reqDemo = try makeRequest(path: "/register/checkdemografi", jsonBody: body)
        let (demoData, resDemo) = try await session.data(for: reqDemo)
        return try parseResponse(demoData, response: resDemo)
    }

    func validatePhone(phone: String) async throws -> ApiResponse<ValidatePhoneData> {
        let body: [String: Any] = [
            "phone": phone,
            "otpType": 1,
            "menu": "register_update"
        ]
        let req = try makeRequest(path: "/otp/validatephone", jsonBody: body)
        let (data, res) = try await session.data(for: req)
        return try parseResponse(data, response: res)
    }

    func verifyOtp(phone: String, otp: String, token: String? = nil) async throws -> ApiResponse<VerifyOtpData> {
        var body: [String: Any] = ["phoneNumber": phone, "otp": otp]
        if let token = token {
            body["token"] = token
        }
        let req = try makeRequest(path: "/register/user/verifyotp", jsonBody: body)
        let (data, res) = try await session.data(for: req)
        return try parseResponse(data, response: res)
    }

    func getBizToken() async throws -> ApiResponse<BizTokenData> {
        let req = try makeRequest(path: "/register/user/get-biz-token")
        let (data, res) = try await session.data(for: req)
        return try parseResponse(data, response: res)
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

        let (data, res) = try await session.data(for: request)
        return try parseResponse(data, response: res)
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
        let (data, res) = try await session.data(for: req)
        return try parseResponse(data, response: res)
    }

    func refreshAuth() async throws -> ApiResponse<AuthRefreshData> {
        let req = try makeRequest(path: "/auth/refresh")
        let (data, res) = try await session.data(for: req)
        return try parseResponse(data, response: res)
    }
}
