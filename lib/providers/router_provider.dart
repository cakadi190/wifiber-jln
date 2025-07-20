import 'package:flutter/material.dart';
import 'package:wifiber/models/router.dart';
import 'package:wifiber/services/router_service.dart';

enum RouterState { initial, loading, success, error }

class RouterProvider with ChangeNotifier {
  final RouterService _routerService;

  RouterProvider(this._routerService);

  RouterState _state = RouterState.initial;
  String _errorMessage = '';

  List<RouterModel> _routers = [];
  RouterModel? _selectedRouter;

  RouterState get state => _state;

  String get errorMessage => _errorMessage;

  List<RouterModel> get routers => _routers;

  RouterModel? get selectedRouter => _selectedRouter;

  bool _isAddingRouter = false;
  bool _isUpdatingRouter = false;
  bool _isDeletingRouter = false;
  bool _isTestingConnection = false;

  bool get isAddingRouter => _isAddingRouter;

  bool get isUpdatingRouter => _isUpdatingRouter;

  bool get isDeletingRouter => _isDeletingRouter;

  bool get isTestingConnection => _isTestingConnection;

  Future<void> getAllRouters() async {
    _setState(RouterState.loading);

    try {
      _routers = await _routerService.getAllRouters();
      _setState(RouterState.success);
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> getRouterById(int id) async {
    _setState(RouterState.loading);

    try {
      _selectedRouter = await _routerService.getRouterById(id);
      _setState(RouterState.success);
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<bool> addRouter(AddRouterModel router) async {
    _isAddingRouter = true;
    notifyListeners();

    try {
      await _routerService.addRouter(router);
      _isAddingRouter = false;
      await getAllRouters();
      notifyListeners();
      return true;
    } catch (e) {
      _isAddingRouter = false;
      _setError(e.toString());
      return false;
    }
  }

  Future<bool> updateRouter(int id, UpdateRouterModel router) async {
    _isUpdatingRouter = true;
    notifyListeners();

    try {
      await _routerService.updateRouter(id, router);

      await getAllRouters();

      _isUpdatingRouter = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isUpdatingRouter = false;
      _setError(e.toString());
      return false;
    }
  }

  Future<bool> deleteRouter(int id) async {
    _isDeletingRouter = true;
    notifyListeners();

    try {
      final success = await _routerService.deleteRouter(id);

      if (success) {
        _routers.removeWhere((r) => r.id == id);

        if (_selectedRouter?.id == id) {
          _selectedRouter = null;
        }
      }

      _isDeletingRouter = false;
      notifyListeners();
      return success;
    } catch (e) {
      _isDeletingRouter = false;
      _setError(e.toString());
      return false;
    }
  }

  Future<bool> testRouterConnection(int id) async {
    _isTestingConnection = true;
    notifyListeners();

    try {
      final result = await _routerService.testRouterConnection(id);
      _isTestingConnection = false;
      notifyListeners();
      return result;
    } catch (e) {
      _isTestingConnection = false;
      _setError(e.toString());
      return false;
    }
  }

  Future<bool> toggleAutoIsolate(int id, ToggleRouterModel router) async {
    try {
      final updatedRouter = await _routerService.toggleAutoIsolate(id, router);

      final index = _routers.indexWhere((r) => r.id == id);
      if (index != -1) {
        _routers[index] = updatedRouter;
      }

      if (_selectedRouter?.id == id) {
        _selectedRouter = updatedRouter;
      }

      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  List<RouterModel> searchRouters(String query) {
    if (query.isEmpty) return _routers;

    return _routers
        .where(
          (router) =>
              router.name.toLowerCase().contains(query.toLowerCase()) ||
              router.host.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
  }

  List<RouterModel> filterRoutersByStatus(String status) {
    return _routers.where((router) => router.status == status).toList();
  }

  List<RouterModel> getRoutersByAction(String action) {
    return _routers.where((router) => router.action == action).toList();
  }

  void toggleAllAutoIsolate(String action) {
    try {
      _routerService.toggleAllAutoIsolate(action);
    } catch (e) {
      _setError(e.toString());
    }
  }

  void clearSelectedRouter() {
    _selectedRouter = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = '';
    if (_state == RouterState.error) {
      _state = RouterState.initial;
    }
    notifyListeners();
  }

  Future<void> refresh() async {
    await getAllRouters();
  }

  void _setState(RouterState newState) {
    _state = newState;
    if (newState != RouterState.error) {
      _errorMessage = '';
    }
    notifyListeners();
  }

  void _setError(String error) {
    _state = RouterState.error;
    _errorMessage = error;
    notifyListeners();
  }
}