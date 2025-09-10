import 'package:wifiber/models/area.dart';
import 'package:wifiber/services/area_service.dart';
import 'package:wifiber/utils/safe_change_notifier.dart';

enum AreaState { initial, loading, loaded, error }

class AreaProvider extends SafeChangeNotifier {
  final AreaService _areaService;

  AreaProvider(this._areaService);

  AreaState _state = AreaState.initial;
  String? _error;
  List<AreaModel> _areas = [];

  AreaState get state => _state;
  String? get error => _error;
  List<AreaModel> get areas => _areas;

  Future<void> loadAreas() async {
    _state = AreaState.loading;
    notifyListeners();
    try {
      _areas = await _areaService.getAreas();
      _state = AreaState.loaded;
    } catch (e) {
      _error = e.toString();
      _state = AreaState.error;
    }
    notifyListeners();
  }

  Future<bool> addArea(Map<String, String> data) async {
    try {
      await _areaService.createArea(data);
      await loadAreas();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateArea(String id, Map<String, String> data) async {
    try {
      await _areaService.updateArea(id, data);
      await loadAreas();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteArea(String id) async {
    try {
      await _areaService.deleteArea(id);
      _areas.removeWhere((a) => a.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
