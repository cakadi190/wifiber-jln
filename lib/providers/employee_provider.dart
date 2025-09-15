import 'package:wifiber/models/employee.dart';
import 'package:wifiber/services/employee_service.dart';
import 'package:wifiber/utils/safe_change_notifier.dart';

class EmployeeProvider extends SafeChangeNotifier {
  final EmployeeService _employeeService;

  EmployeeProvider(this._employeeService);

  List<Employee> _employees = [];
  bool _isLoading = false;
  String? _error;

  List<Employee> get employees => _employees;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _error = message;
    notifyListeners();
  }

  Future<void> loadEmployees({String? search}) async {
    _setLoading(true);
    try {
      final response = await _employeeService.getEmployees(search: search);
      _employees = response.data;
      _setError(null);
    } catch (e) {
      _employees = [];
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refresh() => loadEmployees();

  Future<bool> createEmployee(Map<String, dynamic> data) async {
    _setLoading(true);
    try {
      final success = await _employeeService.createEmployee(data);
      if (success) {
        await loadEmployees();
      }
      return success;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateEmployee(String id, Map<String, dynamic> data) async {
    _setLoading(true);
    try {
      final employee = await _employeeService.updateEmployee(id, data);
      final index = _employees.indexWhere((e) => e.id == id);
      if (index != -1) {
        _employees[index] = employee;
      }
      _setError(null);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteEmployee(String id) async {
    _setLoading(true);
    try {
      final success = await _employeeService.deleteEmployee(id);
      if (success) {
        _employees.removeWhere((e) => e.id == id);
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
}
