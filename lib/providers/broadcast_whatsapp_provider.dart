import 'package:wifiber/exceptions/validation_exceptions.dart';
import 'package:wifiber/models/broadcast_customer.dart';
import 'package:wifiber/services/broadcast_service.dart';
import 'package:wifiber/utils/safe_change_notifier.dart';

enum BroadcastSendType { reminder, manual }

class BroadcastWhatsappProvider extends SafeChangeNotifier {
  final BroadcastService _service;

  BroadcastWhatsappProvider(this._service);

  List<BroadcastCustomer> _customers = [];
  bool _isLoading = false;
  bool _isSending = false;
  BroadcastSendType? _activeSendType;
  String? _error;
  Map<String, dynamic>? _validationErrors;

  List<BroadcastCustomer> get customers => _customers;
  bool get isLoading => _isLoading;
  bool get isSending => _isSending;
  BroadcastSendType? get activeSendType => _activeSendType;
  String? get error => _error;
  Map<String, dynamic>? get validationErrors => _validationErrors;

  Future<bool> fetchCustomers({
    List<int>? selectedAreaIds,
    String customerStatus = 'all',
  }) async {
    _isLoading = true;
    _error = null;
    _validationErrors = null;
    notifyListeners();

    try {
      _customers = await _service.getFilteredCustomers(
        selectedAreaIds: selectedAreaIds,
        customerStatus: customerStatus,
      );
      return true;
    } catch (e) {
      _customers = [];
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> sendUnpaidReminder({List<int>? customerIds}) async {
    _isSending = true;
    _activeSendType = BroadcastSendType.reminder;
    _error = null;
    _validationErrors = null;
    notifyListeners();

    try {
      await _service.sendUnpaidReminder(customerIds: customerIds);
      return true;
    } on ValidationException catch (e) {
      _error = e.message;
      _validationErrors = e.errors;
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isSending = false;
      _activeSendType = null;
      notifyListeners();
    }
  }

  Future<bool> sendManualMessage({
    required String message,
    List<int>? customerIds,
  }) async {
    _isSending = true;
    _activeSendType = BroadcastSendType.manual;
    _error = null;
    _validationErrors = null;
    notifyListeners();

    try {
      await _service.sendManualMessage(
        message: message,
        customerIds: customerIds,
      );
      return true;
    } on ValidationException catch (e) {
      _error = e.message;
      _validationErrors = e.errors;
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isSending = false;
      _activeSendType = null;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    _validationErrors = null;
    notifyListeners();
  }
}
