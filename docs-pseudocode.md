# Dokumentasi Pseudo Code Sistem Informasi Manajemen ISP
**Judul Proyek:** Rancang Bangun Sistem Informasi Manajemen ISP Berbasis Mobile untuk Admin dan Teknisi
**Arsitektur:** MVVM / Provider Pattern (Layered Architecture)

Dokumen ini berisi rancangan **Pseudo Code Terstruktur** yang merepresentasikan alur logika (business logic), manajemen state, dan interaksi antarmuka pada aplikasi.

---

## 1. Model Layer (Data Representation)
Merepresentasikan entitas bisnis ISP. Bertugas mapping data dari JSON API ke objek aplikasi.

### Core Models
```text
Class Customer (Pelanggan):
    Properties: id, name, address, phone, package_id, area_id, status
    Function fromJson(json): Maps JSON fields to properties
    Function toJson(): Converts properties to JSON map

Class Ticket (Keluhan/Gangguan):
    Properties: id, ticket_number, issue_description, status (Open, Process, Done), technician_id, created_at
    Function fromJson(json): ...
    Function toJson(): ...

Class Bill (Tagihan):
    Properties: id, invoice_number, amount, period, status (Unpaid, Paid, Pending)
    Function fromJson(json): ...

Class User (Admin/Teknisi):
    Properties: id, username, role, token
```

---

## 2. Service Layer (Data Access API)
Bertanggung jawab menangani komunikasi HTTP Request ke Backend Server.

```text
Class ApiService:
    BaseUrl = "https://api.isp-system.com"

    // Generic Helper
    Function httpGet(endpoint):
        Response = HttpRequest.Get(BaseUrl + endpoint, headers: AuthHeader)
        Return handleResponse(Response)

    Function httpPost(endpoint, data):
        Response = HttpRequest.Post(BaseUrl + endpoint, body: data)
        Return handleResponse(Response)

    // Specific Business Methods
    Function fetchCustomers():
        Return httpGet("/customers")
    
    Function fetchBills(status):
        Return httpGet("/bills?status=" + status)
    
    Function submitTicket(ticketData):
        Return httpPost("/tickets/create", ticketData)

    Function login(username, password):
        Return httpPost("/login", {username, password})
```

---

## 3. Controller / Provider Layer (State Management)
Mengelola state aplikasi, menjembatani Service dengan UI.

```text
Class TicketProvider inherits ChangeNotifier:
    // State Variables
    Variable state = State.Initial // (Loading, Success, Empty, Error)
    Variable ticketList = []
    Variable errorMessage = ""

    // Fetch Logic
    Function loadTickets(statusFilter):
        state = State.Loading
        NotifyListeners() // Update UI

        Result = ApiService.fetchTickets(statusFilter)

        If Result is Success:
            ticketList = Result.data
            state = (ticketList.isEmpty) ? State.Empty : State.Success
        Else:
            errorMessage = Result.message
            state = State.Error
        
        NotifyListeners()

    // Submit Logic
    Function createTicket(formData):
        state = State.Loading
        NotifyListeners()

        Result = ApiService.submitTicket(formData)
        
        If Result is Success:
            loadTickets() // Refresh list setelah submit
            Return True
        Else:
            errorMessage = Result.message
            Return False
```

---

## 4. UI Layer - Tab System (Navigasi Kategori)
Mengelola tampilan berdasarkan kategori (misal: Tagihan Lunas vs Belum Lunas).

```text
Class BillPage extends StatefulWidget:
    Variable tabController

    Function init():
        // Inisialisasi 2 Tab: Belum Bayar, Lunas
        tabController = TabController(length: 2)

    Function build():
        Return Scaffold(
            appBar: AppBar(
                title: "Data Tagihan",
                bottom: TabBar(
                    controller: tabController,
                    tabs: ["Belum Bayar", "Lunas"]
                )
            ),
            body: TabBarView(
                controller: tabController,
                children: [
                    // Setiap tab memiliki instance list sendiri dengan filter berbeda
                    BillListScreen(status: "Unpaid"),
                    BillListScreen(status: "Paid")
                ]
            )
        )
```

---

## 5. UI Layer - List Rendering & Scroll Behavior
Menampilkan data list dan menghandle interaksi Scroll untuk FAB.

```text
Class BillListScreen extends StatefulWidget:
    Input: statusFilter
    
    Variable provider
    Variable scrollController
    Variable isFabVisible = True

    Function init():
        provider = Provider.of(context)
        scrollController = ScrollController()
        
        // Setup Scroll Listener untuk FAB Animation
        scrollController.addListener( () -> 
            If scroll.direction == Reverse AND isFabVisible:
                isFabVisible = False; UpdateState()
            Else If scroll.direction == Forward AND !isFabVisible:
                isFabVisible = True; UpdateState()
        )

        // Load Data Awal
        provider.loadBills(statusFilter)

    Function build():
        Return Scaffold(
            // Pull to Refresh
            body: RefreshIndicator(
                onRefresh: () -> provider.loadBills(statusFilter),
                
                // Consumer mendengarkan perubahan state provider
                child: Consumer(provider, (state, data) -> 
                    Switch (state):
                        Case Loading: Return CircularProgressIndicator()
                        Case Error:   Return ErrorView(provider.errorMessage)
                        Case Empty:   Return EmptyStateView("Tidak ada tagihan")
                        
                        Case Success:
                            Return ListView.builder(
                                controller: scrollController, // Bind Controller
                                itemCount: data.length,
                                itemBuilder: (index) ->
                                    BillItemWidget(data[index])
                            )
                )
            ),
            
            // FAB dengan animasi Visibility
            floatingActionButton: AnimatedOpacity(
                opacity: isFabVisible ? 1.0 : 0.0,
                child: FloatingActionButton( icon: Add, onPress: goToCreateBill )
            )
        )
```

---

## 6. Form Submission & Validation
Logic untuk input data baru (contoh: Input Pelanggan Baru).

```text
Class AddCustomerForm extends StatefulWidget:
    Variable formKey = GlobalKey<FormState>()
    Variable nameController, addressController

    Function onSubmit():
        // 1. Validasi Input UI
        If formKey.currentState.validate():
            
            // 2. Persiapkan Data
            formData = {
                "name": nameController.text,
                "address": addressController.text
            }

            // 3. Panggil Controller/Provider
            isSuccess = await Provider.addCustomer(formData)

            // 4. Feedback & Navigation
            If isSuccess:
                ShowSnackbar("Pelanggan Berhasil Ditambahkan", Color.Green)
                Navigator.pop() // Kembali ke layar sebelumnya
            Else:
                ShowSnackbar("Gagal: " + Provider.error, Color.Red)

    Function build():
        Return Form(
            key: formKey,
            child: Column(
                children: [
                    TextFormField(
                        controller: nameController,
                        validator: (value) -> (value.isEmpty ? "Nama wajib diisi" : null)
                    ),
                    TextFormField(
                        controller: addressController
                        validator: (value) -> (value.isEmpty ? "Alamat wajib diisi" : null)
                    ),
                    Button(
                        label: "Simpan Data",
                        onPressed: onSubmit
                    )
                ]
            )
        )
```

---

## 7. Snackbar / Feedback System
Mekanisme feedback visual kepada pengguna.

```text
Function ShowSnackbar(message, color):
    SnackBar snackBar = SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: 3 seconds,
        action: SnackBarAction("Tutup")
    )
    ScaffoldMessenger.of(context).showSnackBar(snackBar)

// Representasi Logic Penggunaan:
// - Sukses: ShowSnackbar("Data Saved", Green)
// - Server Error: ShowSnackbar("Server Timeout 500", Red)
// - Validation Error: ShowSnackbar("Mohon lengkapi form", Orange)
```
