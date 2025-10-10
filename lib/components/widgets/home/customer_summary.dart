import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:wifiber/components/reusables/ticket_component.dart';
import 'package:wifiber/controllers/tabs/dashboard_summary.dart';
import 'package:wifiber/models/dashboard.dart';

class CustomerSummary extends StatelessWidget {
  const CustomerSummary({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardSummaryController>(
      builder: (context, controller, _) {
        return SummaryCard(
          title: 'Data Pengguna Wifi',
          margin: const EdgeInsets.only(
            top: 16,
            left: 16,
            right: 16,
            bottom: 16,
          ),
          padding: const EdgeInsets.all(16),
          child: StateBuilder<DashboardSummaryController>(
            isLoading: controller.isLoading,
            error: controller.error,
            data: controller,
            loadingBuilder: () => DefaultStates.loading(),
            errorBuilder: (error) => DefaultStates.error(
              message: error,
              onRetry: controller.refresh,
            ),
            emptyBuilder: () => DefaultStates.empty(
              message: 'Data pengguna tidak tersedia',
              icon: PhosphorIcons.users(PhosphorIconsStyle.duotone),
            ),
            dataBuilder: (controller) =>
                _CustomerStatsList(customerInfo: controller.customerInfo!),
            isEmpty: (controller) => controller?.customerInfo == null,
          ),
        );
      },
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
      ),
      _CustomerStatData(
        label: 'Calon',
        value: customerInfo.newCustomer,
        icon: PhosphorIcons.userPlus(PhosphorIconsStyle.fill),
        color: Colors.blue,
      ),
      _CustomerStatData(
        label: 'Tidak Aktif',
        value: customerInfo.inactive,
        icon: PhosphorIcons.notEquals(PhosphorIconsStyle.fill),
        color: Colors.grey,
      ),
      _CustomerStatData(
        label: 'Isolir',
        value: customerInfo.isolir,
        icon: PhosphorIcons.warningOctagon(PhosphorIconsStyle.fill),
        color: Colors.orange,
      ),
      _CustomerStatData(
        label: 'Gratis',
        value: customerInfo.free,
        icon: PhosphorIcons.gift(PhosphorIconsStyle.fill),
        color: Colors.purple,
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

        Row(
          children: [
            Expanded(child: _CustomerStatTile(stat: stats[4])),
            const SizedBox(width: 12),
            const Spacer(),
          ],
        ),
      ],
    );
  }
}

class _CustomerStatTile extends StatelessWidget {
  const _CustomerStatTile({required this.stat});

  final _CustomerStatData stat;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: stat.color.withValues(alpha: 0.12),
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
        ],
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
  });

  final String label;
  final int value;
  final IconData icon;
  final Color color;
}
