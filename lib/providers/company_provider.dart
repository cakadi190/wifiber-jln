import 'package:wifiber/models/company_profile.dart';
import 'package:wifiber/services/company_service.dart';
import 'package:wifiber/utils/safe_change_notifier.dart';

enum CompanyState { initial, loading, loaded, error, submitting }

class CompanyProvider extends SafeChangeNotifier {
  final CompanyService _service;

  CompanyProvider(this._service);

  CompanyProfile? _company;
  CompanyState _state = CompanyState.initial;
  String? _error;

  CompanyProfile? get company => _company;

  CompanyState get state => _state;

  String? get error => _error;

  bool get isLoading => _state == CompanyState.loading;

  bool get isSubmitting => _state == CompanyState.submitting;

  Future<void> loadCompany() async {
    _setState(CompanyState.loading);
    try {
      _company = await _service.getCompany();
      _setState(CompanyState.loaded);
    } catch (e) {
      _error = e.toString();
      _setState(CompanyState.error);
    }
  }

  Future<bool> createCompany(Map<String, dynamic> data) async {
    _setState(CompanyState.submitting);
    try {
      _company = await _service.createCompany(data);
      _setState(CompanyState.loaded);
      _error = null;
      return true;
    } catch (e) {
      if (e.toString().contains('Update successful but data is null')) {
        try {
          await loadCompany();
          return true;
        } catch (loadError) {
          _error = 'Update berhasil tapi gagal memuat data terbaru';
          _setState(CompanyState.error);
          return false;
        }
      }

      _error = e.toString();
      _setState(CompanyState.error);
      return false;
    }
  }

  Future<bool> updateCompany(Map<String, dynamic> data) async {
    _setState(CompanyState.submitting);
    try {
      _company = await _service.updateCompany(data);
      _setState(CompanyState.loaded);
      _error = null;
      return true;
    } catch (e) {
      if (e.toString().contains('Update successful but data is null')) {
        try {
          await loadCompany();
          return true;
        } catch (loadError) {
          _error = 'Update berhasil tapi gagal memuat data terbaru';
          _setState(CompanyState.error);
          return false;
        }
      }

      _error = e.toString();
      _setState(CompanyState.error);
      return false;
    }
  }

  Future<bool> saveCompany(Map<String, dynamic> data) async {
    if (_company == null) {
      return await createCompany(data);
    } else {
      return await updateCompany(data);
    }
  }

  void clearError() {
    _error = null;
    if (_state == CompanyState.error) {
      _setState(CompanyState.loaded);
    }
  }

  void _setState(CompanyState newState) {
    _state = newState;
    notifyListeners();
  }
}
