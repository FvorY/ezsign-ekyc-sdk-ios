# ezsign-ekyc-sdk-ios

SDK iOS native (Swift, UIKit) untuk alur verifikasi identitas elektronik (eKYC) ezSign. Satu pemanggilan menjalankan seluruh alur: validasi data kependudukan, verifikasi OTP nomor handphone, active liveness wajah dengan Megvii FaceID, sampai finalisasi data ke server ezSign.

SDK Android dengan API, alur, teks, dan kode error yang sama ada di [ezsign-ekyc-sdk-android](https://github.com/FvorY/ezsign-ekyc-sdk-android).

## Daftar isi

- [Demo](#demo)
- [Fitur](#fitur)
- [Persyaratan](#persyaratan)
- [Komponen Megvii FaceID](#komponen-megvii-faceid)
- [Prasyarat lisensi liveness (wajib)](#prasyarat-lisensi-liveness-wajib)
- [Instalasi](#instalasi)
- [Konfigurasi Info.plist](#konfigurasi-infoplist)
- [Mulai cepat](#mulai-cepat)
- [Referensi API](#referensi-api)
- [Alur verifikasi](#alur-verifikasi)
- [Arsitektur liveness](#arsitektur-liveness)
- [Endpoint server](#endpoint-server)
- [Penanganan hasil dan kode error](#penanganan-hasil-dan-kode-error)
- [Kode error Megvii](#kode-error-megvii)
- [Data dan privasi](#data-dan-privasi)
- [Keselarasan Android dan iOS](#keselarasan-android-dan-ios)
- [Aplikasi Example](#aplikasi-example)
- [Troubleshooting](#troubleshooting)
- [Struktur proyek](#struktur-proyek)
- [Lisensi](#lisensi)

## Demo

APK dan IPA demo tersedia di halaman [Releases](https://github.com/FvorY/ezsign-ekyc-sdk-ios/releases), versi terbaru [demo-ekyc-1.3](https://github.com/FvorY/ezsign-ekyc-sdk-ios/releases/tag/demo-ekyc-1.3).

`ezSign-eKYC-iOS-unsigned.ipa` belum ditandatangani. Untuk memasangnya di iPhone, tandatangani dengan Apple ID Anda menggunakan Sideloadly atau AltStore:

1. Pasang [Sideloadly](https://sideloadly.io) di Mac atau Windows.
2. Sambungkan iPhone lewat USB, buka kuncinya, lalu pilih **Trust**.
3. Seret file IPA ke Sideloadly, isi Apple ID, lalu klik **Start**.
4. Di iPhone (iOS 16 ke atas), aktifkan **Settings → Privacy & Security → Developer Mode**. iPhone akan restart.
5. Percayai profil pengembang di **Settings → General → VPN & Device Management**.
6. Buka aplikasi, isi Base URL dan token sesi login ezSign, lalu mulai verifikasi.

> IPA demo memakai Bundle ID `com.sign.livenessdemo`. Liveness hanya berjalan bila Bundle ID tersebut terdaftar di lisensi Megvii untuk iOS. Sideloadly dapat mengganti Bundle ID saat signing; Bundle ID hasil akhirnya yang harus terdaftar. Lihat [Prasyarat lisensi liveness](#prasyarat-lisensi-liveness-wajib).

## Fitur

- **Pemeriksaan status eKYC**: memastikan akun boleh melakukan eKYC (`canEkyc`) sebelum alur dimulai.
- **Validasi demografi**: NIK 16 digit, nama lengkap, dan tanggal lahir divalidasi ke server.
- **Verifikasi OTP**: nomor handphone dinormalkan ke format `+62…`, OTP dikirim lewat SMS dengan cooldown kirim ulang, lalu diverifikasi.
- **Active liveness**: layar instruksi persiapan, lalu deteksi wajah native Megvii FaceID.
- **Finalisasi otomatis**: mengirim hasil liveness, memperbarui biodata akun, me-refresh sesi, dan mengembalikan `regisStatus` dari server.
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
| Jaringan | Akses ke `baseUrl` ezSign dan ke `https://api-idn.megvii.com` |
| Akun | Token sesi akun ezSign yang valid di environment yang dipakai |

## Komponen Megvii FaceID

| Komponen | Nilai |
|---|---|
| Framework | `MegLiveV5Detect` dan `MGFaceIDBaseKit` (library statis, build `b2aa1b5` 11 Desember 2024). `.xcframework` untuk SPM, `.framework` untuk CocoaPods. |
| Resource | `MegLiveV5Detect.bundle` (model, gambar, audio, teks), dimuat lewat `bundleFilePath` dari resource bundle SDK |
| Bahasa layar deteksi | Inggris. SDK memakai `languageType` bawaan (`Ch`, folder `ch`), dan folder tersebut berisi teks bahasa Inggris versi overseas. |
| Host Megvii | `https://api-idn.megvii.com` (`hostURL`, region Indonesia) |
| Mode integrasi | `MegLiveV5DetectModel_A`: lisensi dan konfigurasi liveness diambil oleh SDK Megvii |
| Framework sistem | AVFoundation, CoreMedia, CoreMotion, SystemConfiguration, WebKit, MediaPlayer, ReplayKit, dan `libc++` ditautkan otomatis oleh `Package.swift` dan podspec |

Dokumen Megvii mencantumkan dukungan iOS 9–18. SDK ini memakai batas yang lebih ketat, yaitu iOS 14.

Megvii adalah library Objective-C++ statis. Dokumen Megvii meminta aplikasi memiliki file `.mm` atau mengatur **Compile Sources As** ke Objective-C++. Pada SDK ini kebutuhan itu sudah dipenuhi dengan menautkan `libc++`, jadi aplikasi host tidak perlu mengubah pengaturan apa pun.

## Prasyarat lisensi liveness (wajib)

Lisensi Megvii FaceID terikat pada **Bundle ID aplikasi** yang menjalankan SDK. Saat liveness dimulai, SDK Megvii memverifikasi Bundle ID ke server Megvii. Kalau Bundle ID belum terdaftar di akun Megvii ezSign, liveness gagal sebelum kamera terbuka dengan kode `1003` (`AUTHENTICATION_FAIL{…}`) atau `1009` (`INVALID_BUNDLE_ID`).

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

Package ini sudah membawa framework Megvii, resource-nya (gambar, font Inter, `MegLiveV5Detect.bundle`), dan pengaturan link framework sistem.

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
            case .success(let regisStatus, _):
                if ["in_kyc", "reject_ra", "reject_ra_rekey_exp"].contains(regisStatus) {
                    self.restartEkyc()
                } else {
                    self.openDashboard() // "wait_ra": menunggu persetujuan RA
                }
            case .failure(let errorCode, let message):
                self.showError("[\(errorCode)] \(message)")
            case .cancelled:
                break // Pengguna menutup alur sebelum selesai
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
| `title` | `String` | `Your Identity` | Judul navigasi di layar pertama (Data Identitas). Layar berikutnya memakai judul tetap. |
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
| `.success` | `regisStatus: String`, `message: String` | Semua langkah berhasil dan pengguna menekan **Finish**. Lihat tabel `regisStatus` di bawah. |
| `.failure` | `errorCode: String`, `message: String` | Alur berhenti karena error. Lihat [kode error](#penanganan-hasil-dan-kode-error). |
| `.cancelled` | — | Pengguna menekan tombol close (X) di layar Data Identitas. |

Nilai `regisStatus` diambil dari respons `auth/user/refresh` setelah finalisasi, sama seperti aplikasi ezSign. Jika refresh gagal, nilainya `wait_ra`.

| `regisStatus` | Arti | Tindakan aplikasi host |
|---|---|---|
| `wait_ra` | Data menunggu persetujuan Registration Authority (RA). | Arahkan pengguna ke dashboard. |
| `in_kyc`, `reject_ra` | Server meminta data identitas diverifikasi ulang (rekey). | Jalankan alur eKYC lagi. |
| `reject_ra_rekey_exp` | Verifikasi ulang diperlukan karena masa berlaku data sudah habis. | Jalankan alur eKYC lagi. |
| lainnya | Status registrasi lain dari server. | Tangani sesuai aturan bisnis ezSign. |

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

1. **Data Identitas** (judul `config.title`): saat layar dibuka, SDK memeriksa `ekyc-status`. Jika `canEkyc` bernilai `false`, SDK menampilkan peringatan lalu mengakhiri alur dengan `.failure(errorCode: "EKYC_NOT_ALLOWED")`. Pengguna mengisi NIK (16 digit), nama sesuai KTP, dan tanggal lahir, lalu mengonfirmasi data di dialog **Review Your Information**. Alurnya sama dengan aplikasi ezSign: tidak ada foto KTP maupun selfie terpisah.
2. **Verification Phone**: nomor handphone dinormalkan ke `+62…` (minimal 9 digit setelah `+62`). Setelah OTP terkirim lewat SMS, pengguna memasukkan 6 digit kode. Token dari respons `verifyotp` disimpan untuk dipakai saat finalisasi.
3. **Active Liveness Check**: menampilkan instruksi persiapan. SDK meminta izin kamera bila belum diberikan, meminta `biz_token` dan `liveness_id` ke server ezSign, lalu membuka layar deteksi Megvii.
4. **Verification**: SDK mengirim hasil liveness, memperbarui biodata akun beserta nomor handphone, lalu me-refresh sesi. `regisStatus` dari respons refresh dikembalikan ke aplikasi host.

Navigasi:

- Layar pertama memakai tombol close (X). Tombol ini mengakhiri alur dengan `.cancelled`.
- Di layar OTP dan liveness, tombol back kembali ke layar sebelumnya.
- Layar hasil tidak memiliki tombol back. Alur berakhir lewat tombol **Finish** (sukses) atau **Close** (gagal).

## Arsitektur liveness

Dokumen Megvii membagi autentikasi liveness menjadi lima langkah. Kredensial Megvii (`api_key`, `api_secret`) hanya ada di server ezSign, tidak pernah di aplikasi.

| Langkah Megvii | Dikerjakan oleh | Implementasi |
|---|---|---|
| 1. Membuat `sign` dari `api_key`/`api_secret` | Server ezSign | — |
| 2. `get_biz_token` | Server ezSign | SDK memanggil `/register/user/get-biz-token`, respons berisi `biz_token` dan `liveness_id`. |
| 3. Preprocessing (lisensi dan konfigurasi) | SDK Megvii di perangkat | `MegLiveV5DetectManager.megFaceIDLive(withBizToken:…)`, hasil di `startCallBack`. |
| 4. Deteksi wajah dan callback hasil | SDK Megvii di perangkat | Hasil di `endCallBack`; kode selain `1000` ditangani sesuai [Kode error Megvii](#kode-error-megvii). |
| 5. Verify (perbandingan dan anti-spoofing) | Server ezSign | SDK memanggil `/register/user/liveness-face-id` dengan `biz_token`, `verify_id = liveness_id`, `data_type = 0` (data SDK 5.x lewat `biz_token`), dan `encryption_type = 0`. |

Respons Verify Megvii (`result_code` seperti `1000 SUCCESS`, `2000 PASS_LIVING_NOT_THE_SAME`, `4100 FAIL_LIVING_FACE_ATTACK`/`VIDEO_LACK_FRAMES`, serta info risiko perangkat dan wajah) dievaluasi oleh server ezSign dan tidak diteruskan ke aplikasi. Aplikasi hanya menerima `code` dan `message` ezSign. Jika Verify tidak lolos, alur berakhir dengan `.failure(errorCode: "LIVENESS_SUBMIT_FAILED")` berisi pesan dari server.

## Endpoint server

Semua request memakai `POST` dengan header `Authorization: Bearer <authToken>`. Path di bawah relatif terhadap `baseUrl`.

| Langkah | Endpoint | Body |
|---|---|---|
| Status eKYC | `/register/user/ekyc-status` | — |
| Cek data | `/register/checkdata` | `nama`, `nik`, `birthDate` (`dd-MM-yyyy`) |
| Verifikasi NIK | `/register/verifyNik` | `nik` |
| Cek demografi | `/register/checkdemografi` | `nama`, `nik`, `birthDate` |
| Kirim OTP | `/otp/validatephone` | `phone` (`+62…`), `otpType: 1`, `menu: "register_phone_number_validation"` |
| Verifikasi OTP | `/register/user/verifyotp` | `phoneNumber` (`+62…`), `otp`, `token` |
| Biz token liveness | `/register/user/get-biz-token` | — (respons berisi `biz_token`, `liveness_id`) |
| Submit liveness | `/register/user/liveness-face-id` | multipart: `biz_token`, `verify_id`, `data_type: 0`, `encryption_type: 0` |
| Update profil | `/register/update-mobile` | `nama`, `nik`, `birthDate`, `phone`, `otp`, `bizToken`, `token` |
| Refresh sesi | `/auth/user/refresh` | — (respons berisi `regisStatus`) |

Respons dianggap berhasil hanya jika HTTP 2xx **dan** field `code` bernilai `200` atau `0`. Jika tidak, `message` dari server ditampilkan ke pengguna.

## Penanganan hasil dan kode error

| `errorCode` | Penyebab | Saran penanganan |
|---|---|---|
| `EKYC_NOT_ALLOWED` | `ekyc-status` mengembalikan `canEkyc = false`, misalnya akun sudah eKYC, kuota habis, atau akun WNA. | Tampilkan `message` dan arahkan pengguna sesuai status akunnya. |
| `LIVENESS_SUBMIT_FAILED` | `liveness-face-id` ditolak, misalnya wajah tidak cocok, liveness tidak lolos, atau error server. | Beri pengguna kesempatan mengulang eKYC. |
| `UPDATE_PROFILE_FAILED` | `update-mobile` ditolak. | Tampilkan `message`, lalu ulangi atau hubungi dukungan. |
| `INCOMPLETE` | Layar hasil ditutup sebelum finalisasi selesai. | Perlakukan sebagai gagal dan izinkan pengguna mengulang. |

Error di langkah demografi, OTP, pembuatan biz token, dan deteksi Megvii ditampilkan sebagai alert di layar masing-masing. Pengguna bisa mencoba lagi tanpa keluar dari alur, sehingga error ini tidak dikembalikan sebagai `.failure`.

## Kode error Megvii

Kode berikut berasal dari `MegLiveV5DetectErrorType` di `startCallBack` dan `endCallBack` (dokumen Megvii FaceID SDK, bagian 3.2.4.5). SDK menampilkannya dalam alert **Liveness Check Failed** dengan pengelompokan pesan yang sama seperti aplikasi ezSign, diikuti kodenya, misalnya `(1016)`.

| Kode | Enum Megvii | Arti | Pesan yang ditampilkan SDK |
|---|---|---|---|
| 1000 | `…ErrorTypeOK` | Liveness selesai | — (lanjut ke finalisasi) |
| 1001 | `…BizTokenDenied` | `biz_token` tidak valid | Coba lagi* |
| 1002 | `…IllegalParameter` | Parameter tidak valid | Coba lagi* |
| 1003 | `…AuthenticationFail` | Autentikasi lisensi gagal | Bundle ID yang ditolak dan cara mendaftarkannya |
| 1004 | `…MobileNotSupport` | Perangkat tidak didukung | Perangkat tidak didukung** |
| 1005 | `…NullPointException` | Exception internal Megvii | Coba lagi* |
| 1006 | `…RequestFrequently` | Pemanggilan bersamaan di perangkat yang sama | Coba lagi* |
| 1007 | `…NetworkTimeout` | Request jaringan timeout | Coba lagi* |
| 1008 | `…InternalError` | Error konfigurasi jaringan | Coba lagi* |
| 1009 | `…InvalidBundleID` | Verifikasi informasi gagal | Perangkat tidak didukung** |
| 1010 | `…NetworkError` | Tidak ada koneksi internet | Coba lagi* |
| 1011 | `…UserCancel` | Pengguna membatalkan | `Liveness has been cancelled` (judul **Liveness Cancelled**) |
| 1012 | `…NoCameraPermission` | Tidak ada izin kamera | Minta izin kamera |
| 1013 | `…NoCameraSupport` | Kamera tidak bisa dibuka | Perangkat tidak didukung** |
| 1014 | `…FaceInitFail` | Pengenalan wajah gagal dimulai | Coba lagi* |
| 1016 | `…LivenessFailure` | Liveness gagal | Coba lagi* |
| 1017 | `…GotoBackground` | Aplikasi masuk background | Coba lagi* |
| 1018 | `…LivenessTimeout` | Pengguna tidak bergerak terlalu lama | Coba lagi* |
| 1019 | `…DataUploadFail` | Upload data gagal | Coba lagi* |
| 1020–1027 | NFC, perekaman layar, `…VideoRecordFail` | Fitur yang tidak dipakai SDK | Pesan Megvii apa adanya |
| lainnya | — | Kode baru dari Megvii | Pesan Megvii apa adanya |

\* `We couldn't complete the liveness check. Please try again in a few moments.`
\** `Your device is currently not supported. Please try using a different device.`

Setelah alert ditutup, pengguna tetap di layar **Active Liveness Check** dan bisa menekan **Start Liveness** lagi.

## Data dan privasi

- NIK, nama, tanggal lahir, nomor handphone, dan OTP hanya dikirim ke `baseUrl` ezSign lewat HTTPS. Data sesi di memori dihapus saat alur berakhir.
- Video dan foto wajah diambil dan dikirim oleh SDK Megvii ke host Megvii. SDK ezSign tidak menyimpan file liveness lokal (`extraOutDict` dari Megvii diabaikan).
- SDK tidak menulis log berisi token, data identitas, maupun body HTTP.

## Keselarasan Android dan iOS

Kedua SDK memakai alur, endpoint, teks layar, aturan validasi, kode `errorCode`, nilai `regisStatus`, dan pemetaan kode error Megvii yang sama. Perbedaannya hanya pada hal yang memang khas platform:

| Aspek | Android | iOS |
|---|---|---|
| Entry point | `EzsignEkyc.Contract()` / `EzsignEkyc.start()` | `EzsignEkyc.start(from:config:completion:)` |
| Hasil | `EkycResult.Success` / `Failed` / `Cancelled` | `.success` / `.failure` / `.cancelled` |
| Library Megvii | `faceidv5.aar` 5.7.21A | `MegLiveV5Detect` + `MGFaceIDBaseKit` (build Desember 2024) |
| Identitas lisensi | `applicationId` | Bundle ID |
| Izin kamera | Runtime permission | `NSCameraUsageDescription` + permintaan izin sistem |
| Deteksi posisi tegak perangkat | Bawaan Megvii | Dinonaktifkan (`phoneVertical = Disable`), sama seperti aplikasi ezSign |
| Kode `INVALID_CONFIG` | Ada (Activity tanpa config) | Tidak ada (config wajib di API) |
| Kode `INCOMPLETE` | Tidak ada | Ada (layar hasil ditutup sebelum finalisasi selesai) |

## Aplikasi Example

Folder `Example` berisi aplikasi simulasi fintech yang memanggil SDK lewat Swift Package lokal.

```bash
open Example/EzsignEkycExample.xcodeproj
```

Pilih Team signing Anda, sambungkan iPhone, lalu jalankan skema **EzsignEkycExample**. Proyek dihasilkan dengan XcodeGen dari `Example/project.yml`. Jika file proyek perlu dibuat ulang, jalankan `xcodegen` di folder `Example`.

Bundle ID bawaan Example adalah `com.sign.livenessdemo`. Untuk menguji dengan Bundle ID lain, ganti `PRODUCT_BUNDLE_IDENTIFIER` dengan Bundle ID yang sudah terdaftar di lisensi Megvii.

Build untuk perangkat tanpa signing (untuk CI):

```bash
xcodebuild -project Example/EzsignEkycExample.xcodeproj \
  -scheme EzsignEkycExample -sdk iphoneos -configuration Debug \
  CODE_SIGNING_ALLOWED=NO build
```

## Troubleshooting

**Alert "Liveness Check Failed" berisi "The liveness license rejected …"**
SDK menampilkan alert seperti ini:

```
The liveness license rejected com.example.myapp. Register this bundle ID with
the ezSign Megvii account. (AUTHENTICATION_FAIL{illegal_param}) (1003)
```

Bundle ID yang tertulis di alert belum terdaftar di lisensi Megvii ezSign. Kode di dalam kurung bisa berupa `AUTHENTICATION_FAIL{illegal_param}` atau `bundleid_error`. Daftarkan Bundle ID tersebut atau gunakan Bundle ID yang sudah terdaftar.

**Aplikasi tertutup sendiri saat masuk ke kamera**
`NSCameraUsageDescription` belum ada di `Info.plist` aplikasi host. Lihat [Konfigurasi Info.plist](#konfigurasi-infoplist).

**Build gagal untuk Simulator (`building for iOS Simulator, but linking in object file built for iOS`)**
Framework Megvii hanya berisi arsitektur perangkat (arm64, armv7). Build dan jalankan di iPhone fisik.

**`Undefined symbols` dari Megvii saat link**
Biasanya muncul bila framework Megvii ditambahkan manual tanpa framework sistem yang dibutuhkan. Pasang SDK lewat SPM atau CocoaPods agar AVFoundation, CoreMedia, CoreMotion, SystemConfiguration, WebKit, MediaPlayer, ReplayKit, dan `libc++` ditautkan otomatis.

**Error `NO_ADD_RESOURCE` saat liveness dimulai**
`MegLiveV5Detect.bundle` tidak ditemukan. Jangan menghapus resource bundle `EzsignEkycSDK_EzsignEkycSDK.bundle` dari aplikasi, karena SDK memuat resource Megvii dari bundle tersebut.

**`Unauthorized` / `JWT validation failed`**
Token sudah kedaluwarsa atau diterbitkan oleh environment lain. Login ulang di host yang sama dengan `baseUrl`, lalu pakai `data.token` dari respons login. Jangan memakai token dari respons OTP sebagai `authToken`.

**Liveness gagal setelah instal lewat Sideloadly/AltStore**
Alat tersebut bisa mengganti Bundle ID saat signing. Pastikan Bundle ID hasil akhirnya terdaftar di lisensi Megvii.

## Struktur proyek

```
Sources/EzsignEkycSDK/
  EzsignEkyc.swift            Entry point publik
  Models/EkycModels.swift     EkycConfig, EkycResult, model API
  Models/PhoneNumber.swift    Normalisasi nomor handphone +62
  Network/EkycApiClient.swift Klien HTTP (URLSession, async/await)
  UI/                         View controller per langkah, sesi, gaya
Resources/                    Gambar, font Inter, asset catalog, MegLiveV5Detect.bundle
Frameworks/                   MegLiveV5Detect & MGFaceIDBaseKit (.xcframework untuk SPM, .framework untuk CocoaPods)
Example/                      Aplikasi simulasi
Package.swift                 Manifest Swift Package Manager
EzsignEkycSDK.podspec         Spesifikasi CocoaPods
```

## Lisensi

Kode SDK didistribusikan di bawah lisensi MIT; lihat [`LICENSE`](LICENSE). Framework dan resource Megvii FaceID (`MegLiveV5Detect`, `MGFaceIDBaseKit`, `MegLiveV5Detect.bundle`) tunduk pada perjanjian lisensi Megvii yang terpisah.
