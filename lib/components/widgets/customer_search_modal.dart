import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wifiber/config/app_colors.dart';
import 'package:wifiber/controllers/customer_controller.dart';
import 'package:wifiber/models/customer.dart';
import 'package:wifiber/providers/customer_provider.dart';

class CustomerSearchModal extends StatefulWidget {
  final Function(Customer) onCustomerSelected;
  final Customer? selectedCustomer;
  final String title;

  const CustomerSearchModal({
    super.key,
    required this.onCustomerSelected,
    this.selectedCustomer,
    this.title = 'Pilih Pelanggan',
  });

  @override
  State<CustomerSearchModal> createState() => _CustomerSearchModalState();
}

class _CustomerSearchModalState extends State<CustomerSearchModal> {
  late CustomerController _customerController;
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  static const Duration _debounceDuration = Duration(milliseconds: 500);

  @override
  void initState() {
    super.initState();
    _customerController = CustomerController(
      provider: Provider.of<CustomerProvider>(context, listen: false),
      context: context,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _customerController.getAllCustomers(showLoading: false);
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();

    _debounceTimer = Timer(_debounceDuration, () {
      if (value.isNotEmpty) {
        _customerController.searchCustomers(value);
      } else {
        _customerController.getAllCustomers(showLoading: false);
      }
    });
  }

  void _onClearSearch() {
    _debounceTimer?.cancel();
    _searchController.clear();
    _customerController.getAllCustomers(showLoading: false);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextFormField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Masukkan nama atau email pelanggan',
                    prefixIcon: const Icon(Icons.search),
                    border: const OutlineInputBorder(),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: _onClearSearch,
                          )
                        : null,
                  ),
                  onChanged: _onSearchChanged,
                ),
              ),

              const SizedBox(height: 16),

              Expanded(
                child: Consumer<CustomerProvider>(
                  builder: (context, provider, child) {
                    if (provider.isLoading) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text('Memuat data pelanggan...'),
                          ],
                        ),
                      );
                    }

                    if (provider.error != null) {
                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                size: 48,
                                color: Colors.red,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Terjadi kesalahan',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                provider.error!,
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  if (_searchController.text.isNotEmpty) {
                                    _customerController.searchCustomers(
                                      _searchController.text,
                                    );
                                  } else {
                                    _customerController.getAllCustomers(
                                      showLoading: false,
                                    );
                                  }
                                },
                                child: const Text('Coba Lagi'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    if (provider.customers.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.person_search,
                              size: 48,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchController.text.isNotEmpty
                                  ? 'Tidak ditemukan apapun.'
                                  : 'Belum ada data pelanggan',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            if (_searchController.text.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 4,
                                ),
                                child: Text(
                                  'Mohon maaf, tidak ditemukan pelanggan untuk pencarian "${_searchController.text}". Coba cari nama pelanggan lainnya.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: provider.customers.length,
                      itemBuilder: (context, index) {
                        final customer = provider.customers[index];
                        final isSelected =
                            widget.selectedCustomer?.id == customer.id;

                        return Card(
                          elevation: 0,
                          margin: const EdgeInsets.only(bottom: 8),
                          color: isSelected
                              ? AppColors.primary.withValues(alpha: 0.1)
                              : null,
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isSelected
                                  ? AppColors.primary
                                  : AppColors.primary.withValues(alpha: 0.8),
                              child: Text(
                                customer.name.isNotEmpty
                                    ? customer.name
                                          .substring(0, 1)
                                          .toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              customer.name,
                              style: TextStyle(
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  customer.phone,
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                            trailing: isSelected
                                ? Icon(
                                    Icons.check_circle,
                                    color: AppColors.primary,
                                  )
                                : const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              widget.onCustomerSelected(customer);
                              Navigator.pop(context);
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class CustomerSearchIconModal extends StatefulWidget {
  final Function(Customer) onCustomerSelected;
  final Customer? selectedCustomer;
  final IconData icon;
  final Color? iconColor;

  const CustomerSearchIconModal({
    super.key,
    required this.onCustomerSelected,
    this.selectedCustomer,
    this.icon = Icons.person_search,
    this.iconColor,
  });

  @override
  State<CustomerSearchIconModal> createState() => _CustomerSearchIconModalState();
}

class _CustomerSearchIconModalState extends State<CustomerSearchIconModal> {
  late CustomerController _customerController;
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  static const Duration _debounceDuration = Duration(milliseconds: 500);

  @override
  void initState() {
    super.initState();
    _customerController = CustomerController(
      provider: Provider.of<CustomerProvider>(context, listen: false),
      context: context,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _customerController.getAllCustomers(showLoading: false);
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();

    _debounceTimer = Timer(_debounceDuration, () {
      if (value.isNotEmpty) {
        _customerController.searchCustomers(value);
      } else {
        _customerController.getAllCustomers(showLoading: false);
      }
    });
  }

  void _onClearSearch() {
    _debounceTimer?.cancel();
    _searchController.clear();
    _customerController.getAllCustomers(showLoading: false);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Icon(
                  widget.icon,
                  size: 32,
                  color: widget.iconColor ?? AppColors.primary,
                ),
              ),

              const SizedBox(height: 16),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextFormField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Masukkan nama atau email pelanggan',
                    prefixIcon: const Icon(Icons.search),
                    border: const OutlineInputBorder(),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: _onClearSearch,
                    )
                        : null,
                  ),
                  onChanged: _onSearchChanged,
                ),
              ),

              const SizedBox(height: 16),

              Expanded(
                child: Consumer<CustomerProvider>(
                  builder: (context, provider, child) {
                    if (provider.isLoading) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text('Memuat data pelanggan...'),
                          ],
                        ),
                      );
                    }

                    if (provider.error != null) {
                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                size: 48,
                                color: Colors.red,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Terjadi kesalahan',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                provider.error!,
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  if (_searchController.text.isNotEmpty) {
                                    _customerController.searchCustomers(
                                      _searchController.text,
                                    );
                                  } else {
                                    _customerController.getAllCustomers(
                                      showLoading: false,
                                    );
                                  }
                                },
                                child: const Text('Coba Lagi'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    if (provider.customers.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.person_search,
                              size: 48,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchController.text.isNotEmpty
                                  ? 'Tidak ditemukan apapun.'
                                  : 'Belum ada data pelanggan',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            if (_searchController.text.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 4,
                                ),
                                child: Text(
                                  'Mohon maaf, tidak ditemukan pelanggan untuk pencarian "${_searchController.text}". Coba cari nama pelanggan lainnya.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: provider.customers.length,
                      itemBuilder: (context, index) {
                        final customer = provider.customers[index];
                        final isSelected =
                            widget.selectedCustomer?.id == customer.id;

                        return Card(
                          elevation: 0,
                          margin: const EdgeInsets.only(bottom: 8),
                          color: isSelected
                              ? AppColors.primary.withValues(alpha: 0.1)
                              : null,
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isSelected
                                  ? AppColors.primary
                                  : AppColors.primary.withValues(alpha: 0.8),
                              child: Text(
                                customer.name.isNotEmpty
                                    ? customer.name
                                    .substring(0, 1)
                                    .toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              customer.name,
                              style: TextStyle(
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  customer.phone,
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                            trailing: isSelected
                                ? Icon(
                              Icons.check_circle,
                              color: AppColors.primary,
                            )
                                : const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              widget.onCustomerSelected(customer);
                              Navigator.pop(context);
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}