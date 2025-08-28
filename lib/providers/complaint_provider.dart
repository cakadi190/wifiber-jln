import 'package:wifiber/exceptions/validation_exceptions.dart';
import 'package:wifiber/models/complaint.dart';
import 'package:wifiber/services/complaint_service.dart';
import 'package:wifiber/utils/safe_change_notifier.dart';

class ComplaintProvider extends SafeChangeNotifier {
  final ComplaintService _complaintService;

  ComplaintProvider(this._complaintService);

  List<Complaint> _complaints = [];
  Complaint? _selectedComplaint;
  bool _isLoading = false;
  String? _error;

  ComplaintStatus? _selectedStatus;
  ComplaintType? _selectedType;
  String _searchQuery = '';

  List<Complaint> get complaints => _complaints;

  Complaint? get selectedComplaint => _selectedComplaint;

  bool get isLoading => _isLoading;

  String? get error => _error;

  ComplaintStatus? get selectedComplaintFilter => _selectedStatus;

  ComplaintType? get selectedComplaintTypeFilter => _selectedType;

  String get searchQuery => _searchQuery;

  Future<void> fetchComplaints() async {
    _setLoading(true);
    _setError(null);
    try {
      final response = await _complaintService.getComplaints(
        status: _selectedStatus,
        type: _selectedType,
        search: _searchQuery,
      );

      if (response.success) {
        _complaints = response.data ?? [];
      } else {
        _setError(response.message);
      }
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  void setComplaintFilter(ComplaintStatus? status) {
    _selectedStatus = status;
    fetchComplaints();
  }

  void setComplaintTypeFilter(ComplaintType? type) {
    _selectedType = type;
    fetchComplaints();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    fetchComplaints();
  }

  Future<void> fetchComplaintById(int id) async {
    _setLoading(true);
    _setError(null);
    try {
      _selectedComplaint = await _complaintService.getComplaintById(id);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createComplaint(CreateComplaint complaint) async {
    _setLoading(true);
    _setError(null);
    try {
      final response = await _complaintService.createComplaint(complaint);
      if (response.success) {
        await fetchComplaints();
        return true;
      } else {
        _setError(response.message);
        return false;
      }
    } on ValidationException catch (e) {
      _setError(e.message);
      _setLoading(false);
      rethrow;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      if (_isLoading) _setLoading(false);
    }
  }

  Future<bool> updateComplaint(int id, UpdateComplaint complaint) async {
    _setLoading(true);
    _setError(null);
    try {
      final response = await _complaintService.updateComplaint(id, complaint);
      if (response.success) {
        await fetchComplaints();
        return true;
      } else {
        _setError(response.message);
        return false;
      }
    } on ValidationException catch (e) {
      _setError(e.message);
      _setLoading(false);
      rethrow;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      if (_isLoading) _setLoading(false);
    }
  }

  Future<bool> deleteComplaint(int id) async {
    _setLoading(true);
    _setError(null);
    try {
      final success = await _complaintService.deleteComplaint(id);
      if (success) {
        await fetchComplaints();
        return true;
      } else {
        _setError('Failed to delete complaint');
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void clearSelectedComplaint() {
    _selectedComplaint = null;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }
}
