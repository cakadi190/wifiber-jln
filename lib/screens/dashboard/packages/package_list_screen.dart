import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wifiber/models/package.dart';
import 'package:wifiber/providers/package_provider.dart';
import 'package:wifiber/screens/dashboard/packages/package_form_screen.dart';

class PackageListScreen extends StatefulWidget {
  const PackageListScreen({super.key});

  @override
  State<PackageListScreen> createState() => _PackageListScreenState();
}

class _PackageListScreenState extends State<PackageListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<PackageProvider>().loadPackages();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paket')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(context),
        child: const Icon(Icons.add),
      ),
      body: Consumer<PackageProvider>(
        builder: (context, provider, child) {
          if (provider.state == PackageState.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.state == PackageState.error) {
            return Center(child: Text(provider.error ?? 'Error'));
          }
          final packages = provider.packages;
          if (packages.isEmpty) {
            return const Center(child: Text('Tidak ada data'));
          }
          return ListView.builder(
            itemCount: packages.length,
            itemBuilder: (context, index) {
              final PackageModel pkg = packages[index];
              return ListTile(
                title: Text(pkg.name),
                subtitle: Text('Rp ${pkg.price}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _openForm(context, package: pkg),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _delete(context, pkg.id),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _openForm(BuildContext context, {PackageModel? package}) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => PackageFormScreen(package: package),
          ),
        )
        .then((_) => context.read<PackageProvider>().loadPackages());
  }

  Future<void> _delete(BuildContext context, String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Paket'),
        content: const Text('Yakin ingin menghapus paket ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await context.read<PackageProvider>().deletePackage(id);
    }
  }
}
