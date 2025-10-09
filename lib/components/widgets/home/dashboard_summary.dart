import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:wifiber/components/reusables/ticket_component.dart';
import 'package:wifiber/controllers/tabs/dashboard_summary.dart';

class DashboardSummary extends StatelessWidget {
  const DashboardSummary({super.key, this.onTransactionTap});

  final VoidCallback? onTransactionTap;

  @override
  Widget build(BuildContext context) {
    final existingController =
        Provider.maybeOf<DashboardSummaryController>(context, listen: false);

    if (existingController != null) {
      return _DashboardSummaryView(onTransactionTap: onTransactionTap);
    }

    return ChangeNotifierProvider(
      create: (_) => DashboardSummaryController()..loadDashboardData(),
      child: _DashboardSummaryView(onTransactionTap: onTransactionTap),
    );
  }
}

enum WidgetSize { small, large }

class _DashboardSummaryView extends StatelessWidget {
  final VoidCallback? onTransactionTap;

  const _DashboardSummaryView({this.onTransactionTap});

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardSummaryController>(
      builder: (context, controller, _) {
        return SummaryCard(
          title: '',
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(12),
          backgroundImage: const DecorationImage(
            image: AssetImage('assets/summary-image.png'),
            fit: BoxFit.cover,
          ),
          child: StateBuilder<DashboardSummaryController>(
            isLoading: controller.isLoading,
            error: controller.error,
            data: controller,
            loadingBuilder: () => DefaultStates.loading(color: Colors.white),
            errorBuilder: (error) => DefaultStates.error(
              message: error,
              onRetry: controller.refresh,
              backgroundColor: Colors.red.shade100,
              textColor: Colors.red.shade700,
            ),
            emptyBuilder: () => DefaultStates.empty(
              message: 'No data available',
              textColor: Colors.white,
            ),
            dataBuilder: (controller) => Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildSummaryItem(
                        context,
                        label: 'Total Kas Bulan Ini',
                        icon: PhosphorIcons.cardholder(PhosphorIconsStyle.fill),
                        value: controller.getFormattedTotalCashFlow(),
                        isObscured: (c) => c.obscureTotalCashFlow,
                        onToggle: (c) => c.toggleCashFlowVisibility(),
                        size: WidgetSize.large,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildUnpaidInvoiceItem(context),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryItem(
                        context,
                        label: 'Pemasukan',
                        icon: PhosphorIcons.arrowCircleUp(PhosphorIconsStyle.fill),
                        value: controller.getFormattedTotalIncome(),
                        isObscured: (c) => c.obscureTotalIncome,
                        onToggle: (c) => c.toggleIncomeVisibility(),
                        iconColor: Colors.green,
                        size: WidgetSize.small,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildSummaryItem(
                        context,
                        label: 'Pengeluaran',
                        icon: PhosphorIcons.arrowCircleDown(PhosphorIconsStyle.fill),
                        value: controller.getFormattedTotalExpense(),
                        isObscured: (c) => c.obscureTotalExpense,
                        onToggle: (c) => c.toggleExpenseVisibility(),
                        iconColor: Colors.red,
                        size: WidgetSize.small,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: onTransactionTap,
                  child: SizedBox(
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Lihat Semuanya",
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: Colors.white),
                          ),
                          const Icon(
                            Icons.keyboard_arrow_right_rounded,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            isEmpty: (controller) => controller == null,
          ),
        );
      },
    );
  }

  Widget _buildUnpaidInvoiceItem(BuildContext context) {
    return Consumer<DashboardSummaryController>(
      builder: (context, controller, _) {
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.amber.shade200,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              PhosphorIcon(
                PhosphorIcons.fileText(PhosphorIconsStyle.duotone),
                size: 14,
                color: Colors.orange.shade900,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'Terdapat ${controller.unpaidInvoiceCount} faktur belum dibayar',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.orange.shade900,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryItem(
      BuildContext context, {
        required String label,
        required IconData icon,
        required String value,
        required bool Function(DashboardSummaryController) isObscured,
        required void Function(DashboardSummaryController) onToggle,
        Color? iconColor,
        WidgetSize size = WidgetSize.large,
      }) {
    final theme = Theme.of(context);

    final iconSize = size == WidgetSize.small ? 24.0 : 48.0;
    final spacing = size == WidgetSize.small ? 8.0 : 12.0;
    final labelStyle = size == WidgetSize.small
        ? theme.textTheme.bodySmall?.copyWith(
      color: Colors.white.withValues(alpha: 0.9),
      fontSize: 10,
    )
        : theme.textTheme.bodyMedium?.copyWith(
      color: Colors.white.withValues(alpha: 0.9),
    );
    final valueStyle = size == WidgetSize.small
        ? theme.textTheme.bodyMedium?.copyWith(
      color: Colors.white,
      fontWeight: FontWeight.w600,
    )
        : theme.textTheme.bodyLarge?.copyWith(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    );

    return Consumer<DashboardSummaryController>(
      builder: (context, controller, _) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            PhosphorIcon(
              icon,
              size: iconSize,
              color: iconColor ?? Colors.white,
            ),
            SizedBox(width: spacing),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: labelStyle),
                  const SizedBox(height: 2),
                  Text(
                    controller.displayValue(value, isObscured(controller)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: valueStyle,
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => onToggle(controller),
              icon: Icon(
                isObscured(controller)
                    ? PhosphorIcons.eyeSlash(PhosphorIconsStyle.fill)
                    : PhosphorIcons.eye(PhosphorIconsStyle.fill),
                color: Colors.white,
                size: size == WidgetSize.small ? 16 : 20,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        );
      },
    );
  }
}