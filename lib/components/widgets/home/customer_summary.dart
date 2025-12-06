import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:wifiber/components/reusables/ticket_component.dart';
import 'package:wifiber/controllers/tabs/dashboard_summary.dart';
import 'package:wifiber/models/dashboard.dart';
import 'package:wifiber/screens/dashboard/customers/customer_list_screen.dart';
import 'package:wifiber/services/customer_service.dart';

class CustomerSummary extends StatelessWidget {
  const CustomerSummary({super.key});

  @override
  Widget build(BuildContext context) {
    try {
      context.watch<DashboardSummaryController>();
      return const _CustomerSummaryContent();
    } on ProviderNotFoundException {
      return ChangeNotifierProvider(
        create: (_) => DashboardSummaryController()..loadDashboardData(),
        child: const _CustomerSummaryContent(),
      );
    }
  }
}

class _CustomerSummaryContent extends StatelessWidget {
  const _CustomerSummaryContent();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<DashboardSummaryController>();

    return SummaryCard(
      title: 'Data Pengguna Wifi',
      margin: const EdgeInsets.only(top: 8, left: 16, right: 16, bottom: 16),
      padding: const EdgeInsets.all(16),
      child: StateBuilder<DashboardSummaryController>(
        isLoading: controller.isLoading,
        error: controller.error,
        data: controller,
        loadingBuilder: () => DefaultStates.loading(),
        errorBuilder: (error) =>
            DefaultStates.error(message: error, onRetry: controller.refresh),
        emptyBuilder: () => DefaultStates.empty(
          message: 'Data pengguna tidak tersedia',
          icon: PhosphorIcons.users(PhosphorIconsStyle.duotone),
        ),
        dataBuilder: (controller) =>
            _CustomerStatsList(customerInfo: controller.customerInfo!),
        isEmpty: (controller) => controller?.customerInfo == null,
      ),
    );
  }
}

class _CustomerStatsList extends StatelessWidget {
  const _CustomerStatsList({required this.customerInfo});

  final CustomerInfo customerInfo;

  @override
  Widget build(BuildContext context) {
    final stats = <_CustomerStatData>[
      _CustomerStatData(
        label: 'Aktif',
        value: customerInfo.active,
        icon: PhosphorIcons.wifiHigh(PhosphorIconsStyle.fill),
        color: Colors.green,
        status: CustomerStatus.customer,
      ),
      _CustomerStatData(
        label: 'Baru',
        value: customerInfo.newCustomer,
        icon: PhosphorIcons.userPlus(PhosphorIconsStyle.fill),
        color: Colors.blue,
        status: null,
      ),
      _CustomerStatData(
        label: 'Tidak Aktif',
        value: customerInfo.inactive,
        icon: PhosphorIcons.notEquals(PhosphorIconsStyle.fill),
        color: Colors.grey,
        status: CustomerStatus.inactive,
      ),
      _CustomerStatData(
        label: 'Isolir',
        value: customerInfo.isolir,
        icon: PhosphorIcons.warningOctagon(PhosphorIconsStyle.fill),
        color: Colors.orange,
        status: CustomerStatus.isolir,
      ),
      _CustomerStatData(
        label: 'Gratis',
        value: customerInfo.free,
        icon: PhosphorIcons.gift(PhosphorIconsStyle.fill),
        color: Colors.purple,
        status: CustomerStatus.free,
      ),
    ];

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _CustomerStatTile(stat: stats[0])),
            const SizedBox(width: 12),
            Expanded(child: _CustomerStatTile(stat: stats[1])),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _CustomerStatTile(stat: stats[2])),
            const SizedBox(width: 12),
            Expanded(child: _CustomerStatTile(stat: stats[3])),
          ],
        ),
        const SizedBox(height: 12),
        _CustomerStatTile(stat: stats[4]),
      ],
    );
  }
}

class _CustomerStatTile extends StatelessWidget {
  const _CustomerStatTile({required this.stat});

  final _CustomerStatData stat;

  void _navigateToCustomerList(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CustomerListScreen(initialStatus: stat.status),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    debugPrint(stat.color.toString());

    return InkWell(
      onTap: () => _navigateToCustomerList(context),
      borderRadius: BorderRadius.circular(12),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          border: Border.all(
            color: Colors.grey.shade400.withValues(alpha: 0.4),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: stat.color.withValues(alpha: 0.18),
                shape: BoxShape.circle,
              ),
              child: PhosphorIcon(stat.icon, color: stat.color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stat.label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    stat.value.toString(),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: stat.color,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: stat.color.withValues(alpha: 0.6),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomerStatData {
  const _CustomerStatData({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.status,
  });

  final String label;
  final int value;
  final IconData icon;
  final Color color;
  final CustomerStatus? status;
}
