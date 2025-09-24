import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:wifiber/components/ui/snackbars.dart';
import 'package:wifiber/config/app_colors.dart';
import 'package:wifiber/middlewares/auth_middleware.dart';
import 'package:wifiber/models/broadcast_customer.dart';
import 'package:wifiber/providers/area_provider.dart';
import 'package:wifiber/providers/broadcast_whatsapp_provider.dart';

class BroadcastWhatsappScreen extends StatefulWidget {
  const BroadcastWhatsappScreen({super.key});

  @override
  State<BroadcastWhatsappScreen> createState() =>
      _BroadcastWhatsappScreenState();
}

class _BroadcastWhatsappScreenState extends State<BroadcastWhatsappScreen> {
  final TextEditingController _manualMessageController =
      TextEditingController();
  final Set<int> _selectedAreaIds = <int>{};
  final Set<int> _selectedCustomerIds = <int>{};
  String _customerStatus = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final areaProvider = context.read<AreaProvider>();
      if (areaProvider.state == AreaState.initial) {
        areaProvider.loadAreas();
      }
      _refreshCustomers(showFeedback: false);
    });
  }

  @override
  void dispose() {
    _manualMessageController.dispose();
    super.dispose();
  }

  Future<void> _refreshCustomers({bool showFeedback = true}) async {
    final provider = context.read<BroadcastWhatsappProvider>();
    final selectedAreas =
        _selectedAreaIds.isEmpty ? null : _selectedAreaIds.toList();

    final success = await provider.fetchCustomers(
      selectedAreaIds: selectedAreas,
      customerStatus: _customerStatus,
    );

    if (!mounted) return;

    if (success) {
      setState(() {
        _selectedCustomerIds
          ..clear()
          ..addAll(
            provider.customers
                .where((customer) => customer.id > 0)
                .map((customer) => customer.id),
          );
      });

      if (showFeedback) {
        SnackBars.success(context, 'Daftar pelanggan berhasil diperbarui.');
      }
    } else if (showFeedback) {
      final message = provider.error ?? 'Gagal memuat daftar pelanggan.';
      SnackBars.error(context, message);
    }
  }

  void _toggleSelectAll(
    bool? value,
    BroadcastWhatsappProvider provider,
  ) {
    final shouldSelect = value ?? false;
    setState(() {
      _selectedCustomerIds.clear();
      if (shouldSelect) {
        _selectedCustomerIds.addAll(
          provider.customers
              .where((customer) => customer.id > 0)
              .map((customer) => customer.id),
        );
      }
    });
  }

  List<int>? _resolveTargetIds(BroadcastWhatsappProvider provider) {
    final allValidIds = provider.customers
        .map((customer) => customer.id)
        .where((id) => id > 0)
        .toSet();

    if (allValidIds.isEmpty) {
      return [];
    }

    final selectedValidIds =
        _selectedCustomerIds.where(allValidIds.contains).toSet();

    if (selectedValidIds.isEmpty) {
      return [];
    }

    if (selectedValidIds.length == allValidIds.length) {
      return null;
    }

    return selectedValidIds.toList();
  }

  Future<void> _handleSendUnpaidReminder(
    BroadcastWhatsappProvider provider,
  ) async {
    final targetIds = _resolveTargetIds(provider);

    if (targetIds != null && targetIds.isEmpty) {
      SnackBars.warning(
        context,
        'Pilih minimal satu pelanggan untuk mengirim pengingat.',
      );
      return;
    }

    final success = await provider.sendUnpaidReminder(customerIds: targetIds);

    if (!mounted) return;

    if (success) {
      SnackBars.success(context, 'Pengingat tagihan berhasil dikirim.');
    } else {
      final message = provider.error ?? 'Gagal mengirim pengingat tagihan.';
      SnackBars.error(context, message);
    }
  }

  Future<void> _handleSendManualMessage(
    BroadcastWhatsappProvider provider,
  ) async {
    final message = _manualMessageController.text.trim();
    if (message.isEmpty) {
      SnackBars.warning(context, 'Pesan tidak boleh kosong.');
      return;
    }

    final targetIds = _resolveTargetIds(provider);
    if (targetIds != null && targetIds.isEmpty) {
      SnackBars.warning(
        context,
        'Pilih minimal satu pelanggan untuk mengirim pesan.',
      );
      return;
    }

    FocusScope.of(context).unfocus();

    final success = await provider.sendManualMessage(
      message: message,
      customerIds: targetIds,
    );

    if (!mounted) return;

    if (success) {
      _manualMessageController.clear();
      SnackBars.success(context, 'Pesan broadcast berhasil dikirim.');
    } else {
      final message = provider.error ?? 'Gagal mengirim pesan broadcast.';
      SnackBars.error(context, message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthGuard(
      requiredPermissions: const ['integration'],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Broadcast Whatsapp'),
        ),
        body: SafeArea(
          child: Consumer2<BroadcastWhatsappProvider, AreaProvider>(
            builder: (context, broadcastProvider, areaProvider, child) {
              return RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () => _refreshCustomers(showFeedback: false),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildFilterCard(areaProvider, broadcastProvider),
                    const SizedBox(height: 16),
                    _buildCustomerListCard(broadcastProvider),
                    const SizedBox(height: 16),
                    _buildManualMessageCard(broadcastProvider),
                    const SizedBox(height: 16),
                    _buildReminderButton(broadcastProvider),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFilterCard(
    AreaProvider areaProvider,
    BroadcastWhatsappProvider broadcastProvider,
  ) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.filter_alt_rounded, color: AppColors.primary),
                SizedBox(width: 8),
                Text(
                  'Filter Pelanggan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _customerStatus,
              decoration: const InputDecoration(
                labelText: 'Status Pelanggan',
                helperText:
                    'Pilih status pelanggan untuk broadcast yang diinginkan.',
              ),
              items: const [
                DropdownMenuItem(
                  value: 'all',
                  child: Text('Semua pelanggan'),
                ),
                DropdownMenuItem(
                  value: 'unpaid',
                  child: Text('Belum bayar'),
                ),
                DropdownMenuItem(
                  value: 'isolir',
                  child: Text('Terisolir'),
                ),
              ],
              onChanged: broadcastProvider.isLoading
                  ? null
                  : (value) {
                      if (value == null) return;
                      setState(() {
                        _customerStatus = value;
                      });
                    },
            ),
            const SizedBox(height: 16),
            Text(
              'Area Pelanggan',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            _buildAreaChips(areaProvider, broadcastProvider),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: broadcastProvider.isLoading
                  ? null
                  : () {
                      _refreshCustomers();
                    },
              icon: const Icon(Icons.refresh_rounded),
              label: Text(
                broadcastProvider.isLoading
                    ? 'Memuat...'
                    : 'Perbarui Daftar',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAreaChips(
    AreaProvider areaProvider,
    BroadcastWhatsappProvider broadcastProvider,
  ) {
    if (areaProvider.state == AreaState.loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (areaProvider.state == AreaState.error) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            areaProvider.error ?? 'Gagal memuat daftar area.',
            style: const TextStyle(color: Colors.red),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () {
              areaProvider.loadAreas();
            },
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Coba lagi'),
          ),
        ],
      );
    }

    final areas = areaProvider.areas;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        FilterChip(
          label: const Text('Semua area'),
          selected: _selectedAreaIds.isEmpty,
          onSelected: broadcastProvider.isLoading
              ? null
              : (selected) {
                  setState(() {
                    _selectedAreaIds.clear();
                  });
                },
        ),
        ...areas.map((area) {
          final areaId = int.tryParse(area.id);
          if (areaId == null) {
            return const SizedBox.shrink();
          }
          return FilterChip(
            label: Text(area.name),
            selected: _selectedAreaIds.contains(areaId),
            onSelected: broadcastProvider.isLoading
                ? null
                : (selected) {
                    setState(() {
                      if (selected) {
                        _selectedAreaIds.add(areaId);
                      } else {
                        _selectedAreaIds.remove(areaId);
                      }
                    });
                  },
          );
        }),
      ],
    );
  }

  Widget _buildCustomerListCard(BroadcastWhatsappProvider provider) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.people_alt_rounded, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Daftar Pelanggan (${provider.customers.length})',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: provider.isLoading
                      ? null
                      : () {
                          _refreshCustomers();
                        },
                  icon: const Icon(Icons.refresh_rounded),
                  tooltip: 'Muat ulang',
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (provider.isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              )
            else if (provider.error != null)
              _buildErrorState(provider)
            else if (provider.customers.isEmpty)
              _buildEmptyState()
            else
              _buildCustomerSelectionList(provider),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BroadcastWhatsappProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          provider.error ?? 'Terjadi kesalahan saat memuat pelanggan.',
          style: const TextStyle(color: Colors.red),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: provider.isLoading
              ? null
              : () {
                  _refreshCustomers();
                },
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Coba lagi'),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Column(
      children: const [
        SizedBox(height: 16),
        Icon(
          Icons.contact_phone_outlined,
          size: 64,
          color: Colors.grey,
        ),
        SizedBox(height: 12),
        Text(
          'Tidak ada pelanggan sesuai filter.',
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 16),
      ],
    );
  }

  Widget _buildCustomerSelectionList(BroadcastWhatsappProvider provider) {
    final customers = provider.customers;
    final allValidIds = customers
        .map((customer) => customer.id)
        .where((id) => id > 0)
        .toSet();

    final isAllSelected =
        allValidIds.isNotEmpty && _selectedCustomerIds.containsAll(allValidIds);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CheckboxListTile(
          value: isAllSelected,
          onChanged: provider.isLoading
              ? null
              : (value) => _toggleSelectAll(value, provider),
          contentPadding: EdgeInsets.zero,
          title: const Text('Pilih semua pelanggan hasil filter'),
        ),
        const Divider(),
        SizedBox(
          height: 300,
          child: ListView.builder(
            itemCount: customers.length,
            itemBuilder: (context, index) {
              final customer = customers[index];
              return _buildCustomerTile(provider, customer);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCustomerTile(
    BroadcastWhatsappProvider provider,
    BroadcastCustomer customer,
  ) {
    final isValidId = customer.id > 0;
    final isSelected = _selectedCustomerIds.contains(customer.id);

    return CheckboxListTile(
      value: isValidId ? isSelected : false,
      onChanged: (!isValidId || provider.isLoading)
          ? null
          : (value) {
              setState(() {
                if (value ?? false) {
                  _selectedCustomerIds.add(customer.id);
                } else {
                  _selectedCustomerIds.remove(customer.id);
                }
              });
            },
      contentPadding: EdgeInsets.zero,
      title: Text(customer.name),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if ((customer.customerCode ?? '').isNotEmpty)
            Text('ID: ${customer.customerCode}'),
          if (customer.phone.isNotEmpty)
            Text('Whatsapp: ${customer.phone}'),
          if ((customer.areaName ?? '').isNotEmpty)
            Text('Area: ${customer.areaName}'),
          if ((customer.status ?? '').isNotEmpty)
            Text('Status: ${customer.status}'),
        ],
      ),
    );
  }

  Widget _buildManualMessageCard(BroadcastWhatsappProvider provider) {
    final isManualSending =
        provider.isSending && provider.activeSendType == BroadcastSendType.manual;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                PhosphorIcon(
                  PhosphorIcons.chatsCircle(PhosphorIconsStyle.duotone),
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Kirim Pesan Manual',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Tuliskan pesan broadcast manual yang akan dikirim ke pelanggan terpilih.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _manualMessageController,
              maxLines: 5,
              minLines: 3,
              decoration: const InputDecoration(
                labelText: 'Pesan Broadcast',
                alignLabelWithHint: true,
              ),
              enabled: !provider.isSending,
            ),
            const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: provider.isSending
                    ? null
                    : () {
                        _handleSendManualMessage(provider);
                      },
              icon: isManualSending
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send_rounded),
              label: Text(
                isManualSending ? 'Mengirim...' : 'Kirim Pesan Manual',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReminderButton(BroadcastWhatsappProvider provider) {
    final isReminderSending = provider.isSending &&
        provider.activeSendType == BroadcastSendType.reminder;

      return FilledButton.icon(
        onPressed: provider.isSending
            ? null
            : () {
                _handleSendUnpaidReminder(provider);
              },
      icon: isReminderSending
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Icon(Icons.notifications_active_outlined),
      label: Text(
        isReminderSending
            ? 'Mengirim pengingat...'
            : 'Kirim Pengingat Tagihan',
      ),
    );
  }
}
