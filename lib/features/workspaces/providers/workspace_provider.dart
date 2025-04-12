// lib/features/workspaces/providers/workspace_provider.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../data/services/workspace_service.dart';
import '../../../data/models/workspace_model.dart';
import '../../../data/models/user_model.dart';

enum WorkspaceStatus {
  initial,
  loading,
  loaded,
  creating,
  updating,
  error,
}

class WorkspaceProvider with ChangeNotifier {
  final WorkspaceService _workspaceService = WorkspaceService();

  List<WorkspaceModel> _workspaces = [];
  WorkspaceModel? _currentWorkspace;
  WorkspaceStatus _status = WorkspaceStatus.initial;
  String? _errorMessage;
  StreamSubscription<List<WorkspaceModel>>? _workspacesSubscription;

  List<WorkspaceModel> get workspaces => _workspaces;
  WorkspaceModel? get currentWorkspace => _currentWorkspace;
  WorkspaceStatus get status => _status;
  String? get errorMessage => _errorMessage;

  void loadUserWorkspaces(String userId) {
    _status = WorkspaceStatus.loading;
    notifyListeners();

    // Cancel previous subscription if exists
    _workspacesSubscription?.cancel();

    // Subscribe to workspace updates
    _workspacesSubscription =
        _workspaceService.getUserWorkspaces(userId).listen(
      (workspaces) {
        _workspaces = workspaces;
        _status = WorkspaceStatus.loaded;

        // If current workspace is in the list, update it
        if (_currentWorkspace != null) {
          final updatedWorkspace = _workspaces.firstWhere(
            (workspace) => workspace.id == _currentWorkspace!.id,
            orElse: () => _currentWorkspace!,
          );
          _currentWorkspace = updatedWorkspace;
        }

        notifyListeners();
      },
      onError: (error) {
        _status = WorkspaceStatus.error;
        _errorMessage = error.toString();
        notifyListeners();
      },
    );
  }

  Future<bool> createWorkspace({
    required String name,
    required String description,
    required UserModel creator,
  }) async {
    try {
      _status = WorkspaceStatus.creating;
      notifyListeners();

      final workspace = await _workspaceService.createWorkspace(
        name: name,
        description: description,
        creator: creator,
      );

      if (workspace != null) {
        _currentWorkspace = workspace;
        _status = WorkspaceStatus.loaded;
        notifyListeners();
        return true;
      } else {
        _status = WorkspaceStatus.error;
        _errorMessage = 'Failed to create workspace';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _status = WorkspaceStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> getWorkspaceById(String workspaceId) async {
    try {
      _status = WorkspaceStatus.loading;
      notifyListeners();

      final workspace = await _workspaceService.getWorkspace(workspaceId);

      if (workspace != null) {
        _currentWorkspace = workspace;
        _status = WorkspaceStatus.loaded;
        notifyListeners();
        return true;
      } else {
        _status = WorkspaceStatus.error;
        _errorMessage = 'Workspace not found';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _status = WorkspaceStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  void selectWorkspace(WorkspaceModel workspace) {
    _currentWorkspace = workspace;
    notifyListeners();
  }

  Future<bool> updateWorkspace(WorkspaceModel workspace) async {
    try {
      _status = WorkspaceStatus.updating;
      notifyListeners();

      final success = await _workspaceService.updateWorkspace(workspace);

      if (success) {
        _currentWorkspace = workspace;
        _status = WorkspaceStatus.loaded;
        notifyListeners();
        return true;
      } else {
        _status = WorkspaceStatus.error;
        _errorMessage = 'Failed to update workspace';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _status = WorkspaceStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> addMember({
    required String workspaceId,
    required UserModel user,
    required WorkspaceRole role,
  }) async {
    try {
      _status = WorkspaceStatus.updating;
      notifyListeners();

      final success = await _workspaceService.addMember(
        workspaceId: workspaceId,
        user: user,
        role: role,
      );

      if (success) {
        _status = WorkspaceStatus.loaded;
        notifyListeners();
        return true;
      } else {
        _status = WorkspaceStatus.error;
        _errorMessage = 'Failed to add member';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _status = WorkspaceStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> removeMember({
    required String workspaceId,
    required String userId,
  }) async {
    try {
      _status = WorkspaceStatus.updating;
      notifyListeners();

      final success = await _workspaceService.removeMember(
        workspaceId: workspaceId,
        userId: userId,
      );

      if (success) {
        _status = WorkspaceStatus.loaded;
        notifyListeners();
        return true;
      } else {
        _status = WorkspaceStatus.error;
        _errorMessage = 'Failed to remove member';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _status = WorkspaceStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteWorkspace(String workspaceId) async {
    try {
      _status = WorkspaceStatus.updating;
      notifyListeners();

      final success = await _workspaceService.deleteWorkspace(workspaceId);

      if (success) {
        if (_currentWorkspace?.id == workspaceId) {
          _currentWorkspace = null;
        }
        _status = WorkspaceStatus.loaded;
        notifyListeners();
        return true;
      } else {
        _status = WorkspaceStatus.error;
        _errorMessage = 'Failed to delete workspace';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _status = WorkspaceStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _workspacesSubscription?.cancel();
    super.dispose();
  }
}
