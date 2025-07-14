import 'package:flutter/foundation.dart';
import 'package:wifiber/models/complaint.dart';
import 'package:wifiber/services/complaint_service.dart';

class ComplaintProvider extends ChangeNotifier {
  final ComplaintService _complaintService;

  ComplaintProvider(this._complaintService);

  List<Complaint> _complaints = [];
  List<Complaint> _allComplaints = [];
  Complaint? _selectedComplaint;
  bool _isLoading = false;
  String? _error;

  ComplaintStatus? _selectedComplaintFilter;
  ComplaintType? _selectedComplaintTypeFilter;

  List<Complaint> get complaints => _complaints;

  Complaint? get selectedComplaint => _selectedComplaint;

  bool get isLoading => _isLoading;

  String? get error => _error;

  ComplaintStatus? get selectedComplaintFilter => _selectedComplaintFilter;

  ComplaintType? get selectedComplaintTypeFilter =>
      _selectedComplaintTypeFilter;

  Future<void> fetchComplaints() async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _complaintService.getAllComplaints();
      if (response.success) {
        _allComplaints = response.data ?? [];
        _applyFilters();
      } else {
        _setError(response.message);
      }
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
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
        if (response.data != null) {
          _allComplaints.addAll(response.data!);
        }
        _applyFilters();
        return true;
      } else {
        _setError(response.message);
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateComplaint(int id, UpdateComplaint complaint) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _complaintService.updateComplaint(id, complaint);
      if (response.success) {
        if (response.data != null && response.data!.isNotEmpty) {
          final index = _allComplaints.indexWhere((c) => c.id == id);
          if (index != -1) {
            _allComplaints[index] = response.data!.first;
            _applyFilters();
          }
        }
        return true;
      } else {
        _setError(response.message);
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteComplaint(int id) async {
    _setLoading(true);
    _setError(null);

    try {
      final success = await _complaintService.deleteComplaint(id);
      if (success) {
        _allComplaints.removeWhere((c) => c.id == id);
        _applyFilters();
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

  void setComplaintFilter(ComplaintStatus? status) {
    _selectedComplaintFilter = status;
    _applyFilters();
    fetchComplaints();
  }

  void setComplaintTypeFilter(ComplaintType? type) {
    _selectedComplaintTypeFilter = type;
    _applyFilters();
  }

  void _applyFilters() {
    List<Complaint> filtered = List.from(_allComplaints);

    if (_selectedComplaintFilter != null) {
      filtered = filtered
          .where(
            (complaint) => complaint.statusEnum == _selectedComplaintFilter,
          )
          .toList();
    }

    if (_selectedComplaintTypeFilter != null) {
      filtered = filtered
          .where(
            (complaint) => complaint.typeEnum == _selectedComplaintTypeFilter,
          )
          .toList();
    }

    _complaints = filtered;
    notifyListeners();
  }

  Future<void> fetchComplaintsByStatus(ComplaintStatus status) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _complaintService.getComplaintsByStatus(status);
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

  Future<void> fetchComplaintsByType(ComplaintType type) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _complaintService.getComplaintsByType(type);
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

  List<Complaint> getComplaintsByStatusLocal(ComplaintStatus status) {
    return _complaints
        .where((complaint) => complaint.statusEnum == status)
        .toList();
  }

  List<Complaint> getComplaintsByTypeLocal(ComplaintType type) {
    return _complaints
        .where((complaint) => complaint.typeEnum == type)
        .toList();
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
