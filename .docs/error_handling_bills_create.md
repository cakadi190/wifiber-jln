# Error Handling Documentation untuk Bills Create Screen

## Ringkasan
File `bills_create_screen.dart` telah diperbarui untuk menangani berbagai skenario error response dari backend API dengan lebih baik.

## Struktur Error Response yang Didukung

### 1. Validation Error (HTTP 422)
Response dengan error validasi field-specific:
```json
{
    "success": false,
    "message": "validation error",
    "error": {
        "code": "VALIDATION_ERROR",
        "message": {
            "customer_id": "Pelanggan belum dipilih",
            "period": "Periode tagihan belum dipilih"
        }
    }
}
```

**Cara Penanganan:**
- HttpService akan otomatis menangkap response dengan status code 422
- Membuat `ValidationException` dengan field errors dari `error.message`
- BillsCreateScreen menangkap exception dan menampilkan:
  - Error message utama di SnackBar
  - Field-specific errors di bawah field yang bersangkutan (dengan border merah)
  - **Auto-scroll ke field pertama yang error** untuk memudahkan user melihat error

### 2. Success dengan Warning Message
Response sukses tapi ada warning/error di operasi lain:
```json
{
    "success": true,
    "message": "Tagihan berhasil dibuat, namun gagal mengaktifkan PPPoE Silahkan lakukan secara manual.",
    "error": {
        "code": "INTERNAL_SERVER_ERROR",
        "message": "Internal server error"
    }
}
```

**Cara Penanganan:**
- BillsProvider menyimpan message bahkan ketika `success: true`
- BillsCreateScreen mengecek apakah message mengandung kata "gagal"
- Jika ya, tampilkan error SnackBar dengan message tersebut
- Jika tidak, tampilkan success SnackBar
- Tetap menutup screen dan refresh data

### 3. Internal Server Error
Response dengan error server:
```json
{
    "success": false,
    "message": "Internal server error",
    "error": {
        "code": "INTERNAL_SERVER_ERROR",
        "message": "C:\\Users\\genes\\Documents\\GitHub\\x1-anto-billing\\app\\Controllers\\RestBillV1.php:88 - Not implemented"
    }
}
```

**Cara Penanganan:**
- HttpService akan throw `StringException` untuk status code 500+
- BillsCreateScreen menangkap dan menampilkan pesan yang lebih user-friendly
- Cek apakah error message mengandung "Internal server error"
- Tampilkan pesan: "Terjadi kesalahan pada server. Silakan coba lagi."

## File yang Dimodifikasi

### 1. `bills_create_screen.dart`
- **Method `_createBill()`**: Updated untuk menangani berbagai skenario error
- **Widget Customer Field**: Ditambahkan visual error (red border) dan pesan error
- **Widget Period Field**: Ditambahkan visual error (red border) dan pesan error

### 2. `bills_provider.dart`
- **Method `createBill()`**: Menyimpan message bahkan ketika sukses untuk menangani warning

### 3. `http_service.dart` (Sudah ada, tidak perlu diubah)
- **Method `_handleResponseErrors()`**: Menangani HTTP 422 dan membuat ValidationException
- **Method `_handleStreamedResponseErrors()`**: Sama seperti di atas untuk streamed response

### 4. `validation_exceptions.dart` (Sudah ada, tidak perlu diubah)
- Class untuk menyimpan validation errors dengan field-specific messages

### 5. `backend_validation_mixin.dart` (Sudah ada, tidak perlu diubah)
- Mixin untuk menangani backend validation errors di form

## Flow Error Handling

```
API Response
    ↓
HttpService (parse response)
    ↓
├─ HTTP 422 → ValidationException (field errors)
├─ HTTP 500+ → StringException (server error)
├─ HTTP 200/201 → BillResponse
│   ├─ success: true → return data + message
│   └─ success: false → return error
└─ Other → StringException
    ↓
BillsService (propagate exception)
    ↓
BillsProvider (handle exception, set error state)
    ↓
BillsCreateScreen (display errors)
    ├─ ValidationException → setBackendErrors() + SnackBar
    ├─ SocketException → SnackBar (connection error)
    └─ Other Exception → SnackBar (generic error)
```

## Cara Menambahkan Field Error Baru

Jika ada field baru yang perlu menampilkan backend validation error:

1. Pastikan field menggunakan `TextFormField` dengan `validator: validator('field_name')`
   ```dart
   TextFormField(
     controller: _controller,
     validator: validator('field_name'),
     decoration: InputDecoration(
       labelText: 'Label',
     ),
   )
   ```

2. Untuk field non-input (seperti dropdown), tambahkan:
   ```dart
   Container(
     decoration: BoxDecoration(
       border: Border.all(
         color: backendErrorFor('field_name') != null
             ? Colors.red
             : Colors.grey.shade300,
         width: backendErrorFor('field_name') != null ? 2 : 1,
       ),
     ),
     // ... rest of widget
   ),
   if (backendErrorFor('field_name') != null)
     Padding(
       padding: const EdgeInsets.only(top: 8, left: 12),
       child: Text(
         backendErrorFor('field_name')!,
         style: const TextStyle(
           color: Colors.red,
           fontSize: 12,
         ),
       ),
     ),
   ```

3. **Untuk auto-scroll ke field error**, tambahkan GlobalKey:
   ```dart
   // Di State class
   final _fieldNameKey = GlobalKey();
   
   // Di _scrollToFirstError method, tambahkan mapping
   final fieldKeys = {
     'field_name': _fieldNameKey,
     // ... existing fields
   };
   
   // Di widget field
   TextFormField(
     key: _fieldNameKey,
     // ... rest of properties
   )
   ```

## Auto-Scroll Feature

Ketika terjadi validation error, aplikasi secara otomatis akan scroll ke field pertama yang memiliki error.

### Cara Kerja:
1. Setiap field yang bisa memiliki validation error diberi `GlobalKey`
2. Ketika `ValidationException` terjadi:
   - `setBackendErrors()` dipanggil untuk menyimpan errors
   - `_scrollToFirstError()` dipanggil untuk scroll ke field error pertama
3. Method `_scrollToFirstError()`:
   - Mencari field pertama yang memiliki error
   - Menggunakan `Scrollable.ensureVisible()` untuk smooth scroll
   - Delay 100ms untuk memastikan setState selesai
   - Posisi field di 20% dari viewport top

### Konfigurasi:
- **Duration**: 300ms (smooth scroll)
- **Curve**: `Curves.easeInOut`
- **Alignment**: 0.2 (20% dari top)
- **Delay**: 100ms (wait for setState)

### Field yang Didukung:
- `customer_id` - Field pelanggan
- `period` - Field periode
- `payment_method` - Field metode pembayaran  
- `payment_note` - Field catatan pembayaran

## Testing

Untuk menguji error handling:

1. **Validation Error**: Kirim request tanpa memilih customer atau periode
2. **Success dengan Warning**: Simulasi gagal aktivasi PPPoE setelah tagihan dibuat
3. **Server Error**: Simulasi internal server error

## Catatan
- Semua error message menggunakan bahasa Indonesia untuk UX yang lebih baik
- Backend validation errors ditampilkan di field yang sesuai untuk memudahkan user
- Loading state dihandle dengan baik untuk mencegah double submit
