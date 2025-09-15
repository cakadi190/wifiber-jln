import 'package:wifiber/models/company_profile.dart';
import 'package:wifiber/services/company_service.dart';
import 'package:wifiber/utils/safe_change_notifier.dart';

enum CompanyState { initial, loading, loaded, error }

class CompanyProvider extends SafeChangeNotifier {
  final CompanyService _service;
  CompanyProvider(this._service);

  CompanyProfile? _company;
  CompanyState _state = CompanyState.initial;
  String? _error;

  CompanyProfile? get company => _company;
  CompanyState get state => _state;
  String? get error => _error;

  Future<void> loadCompany() async {
    _state = CompanyState.loading;
    notifyListeners();
    try {
      _company = await _service.getCompany();
      _state = CompanyState.loaded;
    } catch (e) {
      _error = e.toString();
      _state = CompanyState.error;
    }
    notifyListeners();
  }

  Future<bool> createCompany(Map<String, dynamic> data) async {
    try {
      _company = await _service.createCompany(data);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateCompany(Map<String, dynamic> data) async {
    try {
      _company = await _service.updateCompany(data);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
