import 'package:wifiber/models/package.dart';
import 'package:wifiber/services/package_service.dart';
import 'package:wifiber/utils/safe_change_notifier.dart';

enum PackageState { initial, loading, loaded, error }

class PackageProvider extends SafeChangeNotifier {
  final PackageService _service;

  PackageProvider(this._service);

  PackageState _state = PackageState.initial;
  String? _error;
  List<PackageModel> _packages = [];

  PackageState get state => _state;
  String? get error => _error;
  List<PackageModel> get packages => _packages;

  Future<void> loadPackages() async {
    _state = PackageState.loading;
    notifyListeners();
    try {
      _packages = await _service.getPackages();
      _state = PackageState.loaded;
    } catch (e) {
      _error = e.toString();
      _state = PackageState.error;
    }
    notifyListeners();
  }

  Future<bool> addPackage(Map<String, String> data) async {
    try {
      await _service.createPackage(data);
      await loadPackages();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updatePackage(String id, Map<String, String> data) async {
    try {
      await _service.updatePackage(id, data);
      await loadPackages();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deletePackage(String id) async {
    try {
      await _service.deletePackage(id);
      _packages.removeWhere((p) => p.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
