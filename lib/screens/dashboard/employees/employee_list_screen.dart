import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wifiber/components/system_ui_wrapper.dart';
import 'package:wifiber/config/app_colors.dart';
import 'package:wifiber/helpers/system_ui_helper.dart';
import 'package:wifiber/middlewares/auth_middleware.dart';
import 'package:wifiber/models/employee.dart';
import 'package:wifiber/providers/employee_provider.dart';
import 'package:wifiber/screens/dashboard/employees/employee_form_screen.dart';
import 'package:wifiber/screens/dashboard/employees/employee_detail_modal.dart';
import 'package:wifiber/screens/dashboard/employees/employee_delete_modal.dart';
import 'package:wifiber/components/reusables/options_bottom_sheet.dart';

class EmployeeListScreen extends StatefulWidget {
  const EmployeeListScreen({super.key});

  @override
  State<EmployeeListScreen> createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends State<EmployeeListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EmployeeProvider>().loadEmployees();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    final provider = context.read<EmployeeProvider>();
    if (query.isEmpty) {
      provider.loadEmployees();
    } else {
      provider.loadEmployees(search: query);
    }
  }

  void _navigateToForm({Employee? employee}) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            EmployeeFormScreen(employee: employee, isEdit: employee != null),
      ),
    );
    if (mounted) {
      context.read<EmployeeProvider>().refresh();
    }
  }

  void _showDetail(Employee employee) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => EmployeeDetailModal(
        employee: employee,
        onEdit: () {
          Navigator.of(context).pop();
          _navigateToForm(employee: employee);
        },
        onDelete: () {
          Navigator.of(context).pop();
          EmployeeDeleteModal.show(context, employee);
        },
      ),
    );
  }

  void _showActionBottomSheet(Employee employee) {
    showOptionModalBottomSheet(
      context: context,
      header: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primary,
            child: Text(
              employee.name.isNotEmpty ? employee.name[0] : '?',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              employee.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      items: [
        OptionMenuItem(
          icon: Icons.visibility,
          title: 'Lihat Detail',
          subtitle: 'Tampilkan informasi karyawan',
          onTap: () {
            Navigator.pop(context);
            _showDetail(employee);
          },
        ),
        OptionMenuItem(
          icon: Icons.edit,
          title: 'Edit Karyawan',
          subtitle: 'Ubah data karyawan',
          onTap: () {
            Navigator.pop(context);
            _navigateToForm(employee: employee);
          },
        ),
        OptionMenuItem(
          icon: Icons.delete,
          title: 'Hapus Karyawan',
          subtitle: 'Hapus karyawan dari daftar',
          isDestructive: true,
          onTap: () {
            Navigator.pop(context);
            EmployeeDeleteModal.show(context, employee);
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SystemUiWrapper(
      style: SystemUiHelper.duotone(
        statusBarColor: AppColors.primary,
        navigationBarColor: Colors.white,
      ),
      child: AuthGuard(
        requiredPermissions: const ['employee'],
        child: Scaffold(
          backgroundColor: AppColors.primary,
          floatingActionButton: FloatingActionButton(
            onPressed: () => _navigateToForm(),
            backgroundColor: AppColors.primary,
            child: const Icon(Icons.add),
          ),
          appBar: AppBar(
            title: const Text('Karyawan'),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          body: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    decoration: const InputDecoration(
                      hintText: 'Cari karyawan',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                Expanded(
                  child: Consumer<EmployeeProvider>(
                    builder: (context, provider, child) {
                      if (provider.isLoading) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        );
                      }

                      if (provider.error != null) {
                        return Center(
                          child: Text(provider.error!),
                        );
                      }

                      if (provider.employees.isEmpty) {
                        return const Center(
                          child: Text('Belum ada karyawan'),
                        );
                      }

                      return RefreshIndicator(
                        onRefresh: () => provider.refresh(),
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          itemCount: provider.employees.length,
                          itemBuilder: (context, index) {
                            final employee = provider.employees[index];
                            return Card(
                              elevation: 0,
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                title: Text(employee.name),
                                subtitle: Text(employee.username ?? ''),
                                trailing: const Icon(Icons.more_vert,
                                    color: Colors.grey),
                                onTap: () => _showDetail(employee),
                                onLongPress: () => _showActionBottomSheet(employee),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}