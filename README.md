# ezsign-ekyc-sdk-ios

SDK iOS native (Swift, UIKit) untuk alur verifikasi identitas elektronik (eKYC) ezSign. Satu pemanggilan menjalankan seluruh alur: validasi data kependudukan, verifikasi OTP nomor handphone, active liveness wajah dengan Megvii FaceID LV5, sampai finalisasi data ke server ezSign.

SDK Android dengan API dan alur yang sama ada di [ezsign-ekyc-sdk-android](https://github.com/FvorY/ezsign-ekyc-sdk-android).

## Daftar isi

- [Demo](#demo)
- [Fitur](#fitur)
- [Persyaratan](#persyaratan)
- [Prasyarat lisensi liveness (wajib)](#prasyarat-lisensi-liveness-wajib)
- [Instalasi](#instalasi)
- [Konfigurasi Info.plist](#konfigurasi-infoplist)
- [Mulai cepat](#mulai-cepat)
- [Referensi API](#referensi-api)
- [Alur verifikasi](#alur-verifikasi)
- [Endpoint server](#endpoint-server)
- [Penanganan hasil dan kode error](#penanganan-hasil-dan-kode-error)
- [Aplikasi Example](#aplikasi-example)
- [Troubleshooting](#troubleshooting)
- [Struktur proyek](#struktur-proyek)
- [Lisensi](#lisensi)

## Demo

APK dan IPA demo tersedia di halaman [Releases](https://github.com/FvorY/ezsign-ekyc-sdk-ios/releases), versi terbaru [demo-ekyc-1.2](https://github.com/FvorY/ezsign-ekyc-sdk-ios/releases/tag/demo-ekyc-1.2).

`ezSign-eKYC-iOS-unsigned.ipa` belum ditandatangani. Untuk memasangnya di iPhone, tandatangani dengan Apple ID Anda menggunakan Sideloadly atau AltStore:

1. Pasang [Sideloadly](https://sideloadly.io) di Mac atau Windows.
2. Sambungkan iPhone lewat USB, buka kuncinya, lalu pilih **Trust**.
3. Seret file IPA ke Sideloadly, isi Apple ID, lalu klik **Start**.
4. Di iPhone (iOS 16 ke atas), aktifkan **Settings → Privacy & Security → Developer Mode**. iPhone akan restart.
5. Percayai profil pengembang di **Settings → General → VPN & Device Management**.
6. Buka aplikasi, isi Base URL dan token sesi login ezSign, lalu mulai verifikasi.

> Langkah liveness hanya berjalan bila Bundle ID aplikasi terdaftar di lisensi Megvii. Sideloadly dapat mengganti Bundle ID saat signing; Bundle ID hasil akhirnya yang harus terdaftar. Lihat [Prasyarat lisensi liveness](#prasyarat-lisensi-liveness-wajib).

## Fitur

- **Pemeriksaan status eKYC**: memastikan akun boleh melakukan eKYC (`canEkyc`) sebelum alur dimulai.
- **Validasi demografi**: NIK 16 digit, nama lengkap, dan tanggal lahir divalidasi ke server.
- **Verifikasi OTP**: mengirim OTP lewat SMS dengan cooldown kirim ulang, lalu memverifikasi kodenya.
- **Active liveness**: layar instruksi persiapan, lalu deteksi wajah native Megvii FaceID LV5.
- **Finalisasi otomatis**: mengirim hasil liveness, memperbarui biodata akun, dan me-refresh sesi.
- **UI siap pakai**: tampilan mengikuti aplikasi ezSign (font Inter, warna, ilustrasi) dan selalu memakai mode terang.
- **Hasil bertipe**: `EkycResult.success`, `.failure`, atau `.cancelled`.

## Persyaratan

| Item | Nilai |
|---|---|
| iOS minimum | 14.0 |
| Xcode | 15.0+ |
| Swift | 5.9+ |
| Perangkat | iPhone fisik (arm64). Framework Megvii tidak menyertakan slice Simulator. |
| Orientasi | Portrait |
| Akun | Token sesi akun ezSign yang valid di environment yang dipakai |

## Prasyarat lisensi liveness (wajib)

Lisensi Megvii FaceID terikat pada **Bundle ID aplikasi** yang menjalankan SDK. Saat liveness dimulai, SDK Megvii memverifikasi Bundle ID ke server Megvii. Kalau Bundle ID belum terdaftar di akun Megvii ezSign, liveness gagal sebelum kamera terbuka, dengan pesan seperti `AUTHENTICATION_FAIL{illegal_param}`.

Sebelum integrasi:

1. Tentukan Bundle ID final aplikasi Anda, termasuk varian untuk debug, staging, dan release.
2. Minta tim ezSign mendaftarkan setiap Bundle ID tersebut ke lisensi Megvii FaceID.
3. Untuk Android, daftarkan juga `applicationId` aplikasinya.

Langkah demografi dan OTP tidak bergantung pada lisensi ini. Karena itu, masalah lisensi baru terlihat di layar **Active Liveness Check**.

## Instalasi

### Swift Package Manager

1. Di Xcode, buka **File → Add Package Dependencies…**
2. Masukkan URL:

   ```text
   https://github.com/FvorY/ezsign-ekyc-sdk-ios.git
   ```

3. Pilih tag rilis yang tersedia (atau branch `main`), lalu tambahkan produk **EzsignEkycSDK** ke target aplikasi.

Atau lewat `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/FvorY/ezsign-ekyc-sdk-ios.git", branch: "main")
],
targets: [
    .target(name: "MyApp", dependencies: [
        .product(name: "EzsignEkycSDK", package: "ezsign-ekyc-sdk-ios")
    ])
]
```

Package ini sudah membawa `MegLiveV5Detect.xcframework`, `MGFaceIDBaseKit.xcframework`, dan resource-nya (gambar, font Inter, `MegLiveV5Detect.bundle`).

### CocoaPods

```ruby
platform :ios, '14.0'

target 'MyApp' do
  use_frameworks!
  pod 'EzsignEkycSDK', :git => 'https://github.com/FvorY/ezsign-ekyc-sdk-ios.git', :tag => '<tag>'
end
```

Ganti `<tag>` dengan tag rilis yang tersedia, atau gunakan `:branch => 'main'`. Lalu jalankan:

```bash
pod install
```

Framework Megvii berupa library statis, sehingga tidak perlu di-embed secara manual.

## Konfigurasi Info.plist

Tambahkan deskripsi penggunaan kamera ke `Info.plist` aplikasi host. Tanpa key ini, iOS menutup paksa aplikasi saat kamera liveness diakses.

```xml
<key>NSCameraUsageDescription</key>
<string>Kamera diperlukan untuk verifikasi keaktifan wajah (liveness check).</string>
```

## Mulai cepat

```swift
import EzsignEkycSDK

final class ProfileViewController: UIViewController {

    func startVerification(sessionToken: String) {
        let config = EkycConfig(
            authToken: sessionToken,
            baseUrl: "https://api.ezsign.id/api"
        )

        EzsignEkyc.start(from: self, config: config) { result in
            switch result {
            case .success(let regisStatus, let message):
                // regisStatus bernilai "wait_ra": data menunggu persetujuan RA
                print("eKYC selesai (\(regisStatus)): \(message)")
            case .failure(let errorCode, let message):
                print("eKYC gagal [\(errorCode)]: \(message)")
            case .cancelled:
                print("Dibatalkan oleh pengguna")
            }
        }
    }
}
```

SDK ditampilkan sebagai modal layar penuh di atas `presenter`. Closure `completion` dipanggil di main thread setelah modal tertutup, tepat satu kali per pemanggilan `start`.

## Referensi API

### `EzsignEkyc`

```swift
public static func start(
    from presenter: UIViewController,
    config: EkycConfig,
    completion: @escaping (EkycResult) -> Void
)
```

| Parameter | Keterangan |
|---|---|
| `presenter` | View controller yang menampilkan modal eKYC. |
| `config` | Konfigurasi alur, lihat `EkycConfig`. |
| `completion` | Dipanggil dengan `EkycResult` setelah alur selesai, gagal, atau dibatalkan. |

Hanya satu sesi eKYC yang boleh berjalan pada satu waktu. Memanggil `start` lagi akan mereset sesi sebelumnya.

### `EkycConfig`

| Properti | Tipe | Default | Keterangan |
|---|---|---|---|
| `authToken` | `String` | wajib | Token sesi login ezSign (`data.token` dari respons login). Awalan `Bearer ` dan tanda kutip di sekelilingnya dibersihkan otomatis. |
| `baseUrl` | `String` | `https://gtm.myesign.id/api` | Base URL API ezSign. Garis miring di akhir dibuang dan `/api` ditambahkan bila belum ada. |
| `title` | `String` | `Verifikasi Identitas` | Judul navigasi di layar pertama (Data Identitas). Layar berikutnya memakai judul tetap. |
| `primaryColorHex` | `String` | `#15C1E7` | Disediakan untuk kustomisasi warna. Saat ini belum diterapkan; UI memakai palet ezSign. |

Base URL per environment:

| Environment | Base URL |
|---|---|
| DEV | `https://gtm.myesign.id/api` |
| STG | `https://devapi.mesign.id/api` |
| PROD | `https://api.ezsign.id/api` |

Token harus diterbitkan oleh host yang sama dengan `baseUrl`. Token DEV tidak berlaku di STG/PROD, begitu juga sebaliknya.

### `EkycResult`

| Case | Nilai terkait | Kapan |
|---|---|---|
| `.success` | `regisStatus: String`, `message: String` | Semua langkah berhasil dan pengguna menekan tombol selesai. Saat ini `regisStatus` bernilai `wait_ra`. |
| `.failure` | `errorCode: String`, `message: String` | Alur berhenti karena error. Lihat [kode error](#penanganan-hasil-dan-kode-error). |
| `.cancelled` | — | Pengguna menekan tombol close di layar Data Identitas. |

## Alur verifikasi

```
Aplikasi host
  └─ EzsignEkyc.start(from:config:completion:)
       1. Data Identitas  ── ekyc-status → checkdata → verifyNik → checkdemografi
       2. Verifikasi OTP  ── validatephone (kirim OTP) → verifyotp
       3. Active Liveness ── get-biz-token → Megvii FaceID (kamera)
       4. Hasil           ── liveness-face-id → update-mobile → auth/user/refresh
  ◀─ completion(EkycResult)
```

1. **Data Identitas**: saat layar dibuka, SDK memeriksa `ekyc-status`. Jika `canEkyc` bernilai `false`, SDK menampilkan peringatan lalu mengakhiri alur dengan `.failure(errorCode: "EKYC_NOT_ALLOWED")`. Pengguna lalu mengisi NIK (16 digit), nama sesuai KTP, dan tanggal lahir.
2. **Verifikasi OTP**: pengguna memasukkan nomor handphone, menerima OTP lewat SMS, lalu memasukkan kodenya. Token dari respons `verifyotp` disimpan untuk dipakai saat finalisasi.
3. **Active Liveness Check**: menampilkan instruksi persiapan. SDK meminta `biz_token` dan `liveness_id` ke server ezSign, lalu membuka deteksi Megvii. iOS meminta izin kamera saat pertama kali kamera diakses.
4. **Hasil**: SDK mengirim hasil liveness, memperbarui biodata akun beserta nomor handphone, lalu me-refresh sesi. Status akhir `wait_ra` berarti data menunggu persetujuan Registration Authority (RA).

## Endpoint server

Semua request memakai `POST` dengan header `Authorization: Bearer <authToken>`. Path di bawah relatif terhadap `baseUrl`.

| Langkah | Endpoint | Body |
|---|---|---|
| Status eKYC | `/register/user/ekyc-status` | — |
| Cek data | `/register/checkdata` | `nama`, `nik`, `birthDate` (`dd-MM-yyyy`) |
| Verifikasi NIK | `/register/verifyNik` | `nik` |
| Cek demografi | `/register/checkdemografi` | `nama`, `nik`, `birthDate` |
| Kirim OTP | `/otp/validatephone` | `phone`, `otpType: 1`, `menu: "register_phone_number_validation"` |
| Verifikasi OTP | `/register/user/verifyotp` | `phoneNumber`, `otp`, `token` |
| Biz token liveness | `/register/user/get-biz-token` | — (respons berisi `biz_token`, `liveness_id`) |
| Submit liveness | `/register/user/liveness-face-id` | multipart: `biz_token`, `verify_id`, `data_type`, `encryption_type` |
| Update profil | `/register/update-mobile` | `nama`, `nik`, `birthDate`, `phone`, `otp`, `bizToken`, `token` |
| Refresh sesi | `/auth/user/refresh` | — |

Respons dianggap berhasil hanya jika HTTP 2xx **dan** field `code` bernilai `200` atau `0`. Jika tidak, `message` dari server ditampilkan ke pengguna.

Deteksi wajah memakai host Megvii `https://api-idn.megvii.com`.

## Penanganan hasil dan kode error

| `errorCode` | Penyebab | Saran penanganan |
|---|---|---|
| `EKYC_NOT_ALLOWED` | `ekyc-status` mengembalikan `canEkyc = false`, misalnya akun sudah eKYC, kuota habis, atau akun WNA. | Tampilkan `message` dan arahkan pengguna sesuai status akunnya. |
| `LIVENESS_SUBMIT_FAILED` | `liveness-face-id` ditolak, misalnya wajah tidak cocok, liveness tidak lolos, atau error server. | Beri pengguna kesempatan mengulang eKYC. |
| `UPDATE_PROFILE_FAILED` | `update-mobile` ditolak. | Tampilkan `message`, lalu ulangi atau hubungi dukungan. |
| `INCOMPLETE` | Layar hasil ditutup sebelum finalisasi selesai. | Perlakukan sebagai gagal dan izinkan pengguna mengulang. |

Error di langkah demografi, OTP, dan pembuatan biz token ditampilkan sebagai alert di layar masing-masing. Pengguna bisa mencoba lagi tanpa keluar dari alur, sehingga error ini tidak dikembalikan sebagai `.failure`.

Kode hasil Megvii yang ditangani di layar liveness:

| Kode | Arti |
|---|---|
| `1000` | Berhasil, lanjut ke finalisasi. |
| `1011` | Pengguna membatalkan deteksi wajah. Pengguna tetap di layar instruksi dan bisa mencoba lagi. |
| lainnya | Ditampilkan sebagai alert. `AUTHENTICATION_FAIL{...}` berarti Bundle ID belum terdaftar di lisensi Megvii. |

## Aplikasi Example

Folder `Example` berisi aplikasi simulasi fintech yang memanggil SDK lewat Swift Package lokal.

```bash
open Example/EzsignEkycExample.xcodeproj
```

Pilih Team signing Anda, sambungkan iPhone, lalu jalankan skema **EzsignEkycExample**. Proyek dihasilkan dengan XcodeGen dari `Example/project.yml`. Jika file proyek perlu dibuat ulang, jalankan `xcodegen` di folder `Example`.

Bundle ID bawaan Example adalah `io.github.fvory.ekyc.example`. Agar langkah liveness bisa diuji, ganti `PRODUCT_BUNDLE_IDENTIFIER` dengan Bundle ID yang sudah terdaftar di lisensi Megvii.

Build untuk perangkat tanpa signing (untuk CI):

```bash
xcodebuild -project Example/EzsignEkycExample.xcodeproj \
  -scheme EzsignEkycExample -sdk iphoneos -configuration Debug \
  CODE_SIGNING_ALLOWED=NO build
```

## Troubleshooting

**`AUTHENTICATION_FAIL{illegal_param}` atau `bundleid_error` saat memulai liveness**
Bundle ID aplikasi belum terdaftar di lisensi Megvii ezSign. Alert dari SDK menyebutkan Bundle ID yang ditolak. Daftarkan Bundle ID tersebut atau gunakan Bundle ID yang sudah terdaftar.

**Aplikasi tertutup sendiri saat masuk ke kamera**
`NSCameraUsageDescription` belum ada di `Info.plist` aplikasi host. Lihat [Konfigurasi Info.plist](#konfigurasi-infoplist).

**Build gagal untuk Simulator (`building for iOS Simulator, but linking in object file built for iOS`)**
Framework Megvii hanya berisi arsitektur perangkat (arm64, armv7). Build dan jalankan di iPhone fisik.

**`Unauthorized` / `JWT validation failed`**
Token sudah kedaluwarsa atau diterbitkan oleh environment lain. Login ulang di host yang sama dengan `baseUrl`, lalu pakai `data.token` dari respons login. Jangan memakai token dari respons OTP sebagai `authToken`.

**Liveness gagal setelah instal lewat Sideloadly/AltStore**
Alat tersebut bisa mengganti Bundle ID saat signing. Pastikan Bundle ID hasil akhirnya terdaftar di lisensi Megvii.

## Struktur proyek

```
Sources/EzsignEkycSDK/
  EzsignEkyc.swift            Entry point publik
  Models/EkycModels.swift     EkycConfig, EkycResult, model API
  Network/EkycApiClient.swift Klien HTTP (URLSession, async/await)
  UI/                         View controller per langkah, sesi, gaya
Resources/                    Gambar, font Inter, asset catalog, MegLiveV5Detect.bundle
Frameworks/                   MegLiveV5Detect & MGFaceIDBaseKit (.xcframework untuk SPM, .framework untuk CocoaPods)
Example/                      Aplikasi simulasi
Package.swift                 Manifest Swift Package Manager
EzsignEkycSDK.podspec         Spesifikasi CocoaPods
```

## Lisensi

Kode SDK didistribusikan di bawah lisensi MIT; lihat [`LICENSE`](LICENSE). Framework Megvii FaceID (`MegLiveV5Detect`, `MGFaceIDBaseKit`) tunduk pada perjanjian lisensi Megvii yang terpisah.
