import Foundation

final class EkycSession {
    static let shared = EkycSession()

    var config: EkycConfig?
    var client: EkycApiClient?

    var nik: String = ""
    var nama: String = ""
    var birthDate: String = ""

    var phone: String = ""
    var otp: String = ""
    var verifyToken: String?

    var bizToken: String = ""
    var livenessId: String = ""

    var completion: ((EkycResult) -> Void)?

    private init() {}

    func reset() {
        config = nil
        client = nil
        nik = ""
        nama = ""
        birthDate = ""
        phone = ""
        otp = ""
        verifyToken = nil
        bizToken = ""
        livenessId = ""
        completion = nil
    }
}
