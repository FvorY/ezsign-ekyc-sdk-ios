# ezsign-ekyc-sdk-ios

Native iOS SDK (Swift) untuk alur verifikasi identitas elektronik (eKYC) ezSign, mencakup verifikasi demografi kependudukan, validasi OTP SMS, serta integrasi Megvii FaceID Active Liveness Detection.

## Demo terbaru

Unduh [demo Android dan iOS](https://github.com/FvorY/ezsign-ekyc-sdk-ios/releases/tag/demo-ekyc-1.1).

Pembaruan ini menyesuaikan font, ikon, tombol, jarak, dan latar dengan acuan Flutter, serta memperbaiki penerusan token OTP dan endpoint refresh. IPA memerlukan signing sebelum dipasang. Ilustrasi identitas masih memakai PNG asli 245×210 piksel sehingga belum setajam aset vektor pada layar padat piksel.

## Fitur

* **Pemeriksaan Status eKYC:** Validasi eligibility akun dan kuota verifikasi.
* **Verifikasi Data Demografi:** Validasi NIK 16-digit, nama lengkap, dan tanggal lahir (`checkdata`, `verifyNik`, `checkdemografi`).
* **Verifikasi OTP Telepon:** Pengiriman kode OTP via SMS dengan timer cooldown dan verifikasi kode.
* **Active Liveness Detection:** Instruksi persiapan wajah dan deteksi keaktifan wajah native menggunakan Megvii FaceID LV5 SDK.
* **Penyelesaian Otomatis:** Submit hasil liveness dan update biodata akun ke server ezSign.

## Instalasi

### CocoaPods

Tambahkan baris berikut pada `Podfile` Anda:

```ruby
pod 'EzsignEkycSDK', :git => 'https://github.com/FvorY/ezsign-ekyc-sdk-ios.git', :tag => '1.0.0'
```

Lalu jalankan:

```bash
pod install
```

### Swift Package Manager (SPM)

Tambahkan package repository URL ke dalam Xcode:

```text
https://github.com/FvorY/ezsign-ekyc-sdk-ios.git
```

## Penggunaan

```swift
import EzsignEkycSDK

class ViewController: UIViewController {

    func startVerification(authToken: String) {
        let config = EkycConfig(
            authToken: authToken,
            baseUrl: "https://api.ezsign.id",
            title: "Verifikasi Identitas"
        )

        EzsignEkyc.start(from: self, config: config) { result in
            switch result {
            case .success(let regisStatus, let message):
                print("eKYC Berhasil (\(regisStatus)): \(message)")
            case .failure(let errorCode, let message):
                print("eKYC Gagal [\(errorCode)]: \(message)")
            case .cancelled:
                print("Dibatalkan oleh pengguna")
            }
        }
    }
}
```

## Konfigurasi Info.plist

Pastikan izin kamera telah ditambahkan pada file `Info.plist` aplikasi Anda:

```xml
<key>NSCameraUsageDescription</key>
<string>Aplikasi memerlukan akses kamera untuk melakukan verifikasi keaktifan wajah (liveness check).</string>
```

## Persyaratan Minimum

* iOS 14.0+
* Xcode 15.0+
* Swift 5.9+

## Lisensi

Didistribusikan di bawah lisensi MIT. Lihat `LICENSE` untuk informasi lebih lanjut.
