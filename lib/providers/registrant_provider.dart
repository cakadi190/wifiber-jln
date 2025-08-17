import 'package:flutter/foundation.dart';
import 'package:wifiber/models/registrant.dart';
import 'package:wifiber/services/registrant_service.dart';

class RegistrantProvider extends ChangeNotifier {
  final RegistrantService _registrantService;

  RegistrantProvider(this._registrantService);

  List<Registrant> _registrants = [];
  Registrant? _selectedRegistrant;
  bool _isLoading = false;
  String? _error;
  RegistrantStatus? _currentStatus;
  int? _currentRouterId;
  int? _currentAreaId;

  List<Registrant> get registrants => _registrants;

  Registrant? get selectedRegistrant => _selectedRegistrant;

  bool get isLoading => _isLoading;

  String? get error => _error;

  RegistrantStatus? get currentStatus => _currentStatus;

  int? get currentRouterId => _currentRouterId;

  int? get currentAreaId => _currentAreaId;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadRegistrants({
    RegistrantStatus? status,
    int? routerId,
    int? areaId,
  }) async {
    _setLoading(true);
    _currentStatus = status;
    _currentRouterId = routerId;
    _currentAreaId = areaId;

    try {
      final response = await _registrantService.getAllRegistrants(
        status,
        routerId,
        areaId,
      );
      _registrants = response.data;
      _error = null;
    } catch (e) {
      _setError(e.toString());
      _registrants = [];
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadRegistrantById(String id) async {
    _setLoading(true);

    try {
      _selectedRegistrant = await _registrantService.getRegistrantById(id);
      _error = null;
    } catch (e) {
      _setError(e.toString());
      _selectedRegistrant = null;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createRegistrant(Map<String, dynamic> registrantData) async {
    _setLoading(true);

    try {
      final validationErrors = _validateRegistrantData(registrantData);
      if (validationErrors.isNotEmpty) {
        _setError('Validation failed: ${validationErrors.join(', ')}');
        return false;
      }

      await _registrantService.createRegistrant(registrantData);
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateRegistrant(
    String id,
    Map<String, dynamic> registrantData,
  ) async {
    _setLoading(true);

    try {
      final validationErrors = _validateRegistrantData(registrantData);
      if (validationErrors.isNotEmpty) {
        _setError('Validation failed: ${validationErrors.join(', ')}');
        return false;
      }

      final updatedRegistrant = await _registrantService.updateRegistrant(
        id,
        registrantData,
      );

      final index = _registrants.indexWhere((registrant) => registrant.id == id);
      if (index != -1) {
        _registrants[index] = updatedRegistrant;
      }

      if (_selectedRegistrant?.id == id) {
        _selectedRegistrant = updatedRegistrant;
      }

      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  List<String> _validateRegistrantData(Map<String, dynamic> registrantData) {
    List<String> errors = [];

    if (registrantData['name'] == null ||
        registrantData['name'].toString().trim().isEmpty) {
      errors.add('Nama wajib diisi');
    }

    if (registrantData['phone'] == null ||
        registrantData['phone'].toString().trim().isEmpty) {
      errors.add('Nomor telepon wajib diisi');
    }

    if (registrantData['identity-number'] == null ||
        registrantData['identity-number'].toString().trim().isEmpty) {
      errors.add('Nomor KTP wajib diisi (atau isi dengan "-")');
    }

    if (registrantData['address'] == null ||
        registrantData['address'].toString().trim().isEmpty) {
      errors.add('Alamat wajib diisi');
    }

    if (registrantData['package'] == null) {
      errors.add('Paket internet wajib dipilih');
    }

    if (registrantData['area'] == null ||
        registrantData['area'].toString().trim().isEmpty) {
      errors.add('Area wajib dipilih');
    }

    if (registrantData['router'] == null) {
      errors.add('Router wajib dipilih');
    }

    if (registrantData['pppoe_secret'] == null ||
        registrantData['pppoe_secret'].toString().trim().isEmpty) {
      errors.add('PPPoE Secret wajib diisi');
    }

    if (registrantData['due-date'] == null ||
        registrantData['due-date'].toString().trim().isEmpty) {
      errors.add('Tanggal jatuh tempo wajib diisi');
    }

    if (registrantData['odp'] == null) {
      errors.add('ODP wajib dipilih');
    }

    final hasCoordinate = registrantData.containsKey('coordinate');
    if (!hasCoordinate) {
      errors.add('Koordinat lokasi wajib diisi');
    }

    return errors;
  }

  Future<bool> deleteRegistrant(String id) async {
    _setLoading(true);

    try {
      final success = await _registrantService.deleteRegistrant(id);

      if (success) {
        _registrants.removeWhere((registrant) => registrant.id == id);

        if (_selectedRegistrant?.id == id) {
          _selectedRegistrant = null;
        }

        _error = null;
        notifyListeners();
      }

      return success;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> searchRegistrants(String query) async {
    _setLoading(true);

    try {
      final response = await _registrantService.searchRegistrants(query);
      _registrants = response.data;
      _error = null;
    } catch (e) {
      _setError(e.toString());
      _registrants = [];
    } finally {
      _setLoading(false);
    }
  }

  Future<void> getRegistrantsByStatus(String status) async {
    _setLoading(true);

    try {
      final response = await _registrantService.getRegistrantsByStatus(status);
      _registrants = response.data;
      _error = null;
    } catch (e) {
      _setError(e.toString());
      _registrants = [];
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refresh() async {
    await loadRegistrants(
      status: _currentStatus,
      routerId: _currentRouterId,
      areaId: _currentAreaId,
    );
  }

  void clearSelectedRegistrant() {
    _selectedRegistrant = null;
    notifyListeners();
  }

  void clearData() {
    _registrants = [];
    _selectedRegistrant = null;
    _error = null;
    _currentStatus = null;
    _currentRouterId = null;
    _currentAreaId = null;
    notifyListeners();
  }
}
