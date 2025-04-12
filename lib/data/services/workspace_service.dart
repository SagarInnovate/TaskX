// lib/data/services/workspace_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/workspace_model.dart';
import '../models/user_model.dart';

class WorkspaceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  // Collection reference
  CollectionReference get _workspacesCollection =>
      _firestore.collection('workspaces');

  // Create workspace
  Future<WorkspaceModel?> createWorkspace({
    required String name,
    required String description,
    required UserModel creator,
  }) async {
    try {
      final String workspaceId = _uuid.v4();
      final now = DateTime.now();

      // Create workspace member with owner role
      final member = WorkspaceMember(
        user: creator,
        role: WorkspaceRole.owner,
        joinedAt: now,
      );

      // Create workspace
      final workspace = WorkspaceModel(
        id: workspaceId,
        name: name,
        description: description,
        members: [member],
        createdAt: now,
        createdBy: creator.id,
      );

      // Save to Firestore
      await _workspacesCollection.doc(workspaceId).set(workspace.toJson());

      return workspace;
    } catch (e) {
      print('Error creating workspace: $e');
      return null;
    }
  }

  // Get workspace by ID
  Future<WorkspaceModel?> getWorkspace(String workspaceId) async {
    try {
      final DocumentSnapshot doc =
          await _workspacesCollection.doc(workspaceId).get();

      if (!doc.exists) return null;

      return WorkspaceModel.fromJson(doc.data() as Map<String, dynamic>);
    } catch (e) {
      print('Error getting workspace: $e');
      return null;
    }
  }

  // Get workspaces for user
  Stream<List<WorkspaceModel>> getUserWorkspaces(String userId) {
    return _workspacesCollection
        .where('members', arrayContains: {'user.id': userId})
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return WorkspaceModel.fromJson(doc.data() as Map<String, dynamic>);
          }).toList();
        });
  }

  // Update workspace
  Future<bool> updateWorkspace(WorkspaceModel workspace) async {
    try {
      await _workspacesCollection.doc(workspace.id).update(workspace.toJson());
      return true;
    } catch (e) {
      print('Error updating workspace: $e');
      return false;
    }
  }

  // Add member to workspace
  Future<bool> addMember({
    required String workspaceId,
    required UserModel user,
    required WorkspaceRole role,
  }) async {
    try {
      final member = WorkspaceMember(
        user: user,
        role: role,
        joinedAt: DateTime.now(),
      );

      await _workspacesCollection.doc(workspaceId).update({
        'members': FieldValue.arrayUnion([member.toJson()]),
      });

      return true;
    } catch (e) {
      print('Error adding member: $e');
      return false;
    }
  }

  // Remove member from workspace
  Future<bool> removeMember({
    required String workspaceId,
    required String userId,
  }) async {
    try {
      final workspace = await getWorkspace(workspaceId);
      if (workspace == null) return false;

      final updatedMembers = workspace.members
          .where((member) => member.user.id != userId)
          .toList();

      if (updatedMembers.isEmpty) {
        // Delete workspace if no members left
        await _workspacesCollection.doc(workspaceId).delete();
      } else {
        await _workspacesCollection.doc(workspaceId).update({
          'members': updatedMembers.map((m) => m.toJson()).toList(),
        });
      }

      return true;
    } catch (e) {
      print('Error removing member: $e');
      return false;
    }
  }

  // Delete workspace
  Future<bool> deleteWorkspace(String workspaceId) async {
    try {
      await _workspacesCollection.doc(workspaceId).delete();
      return true;
    } catch (e) {
      print('Error deleting workspace: $e');
      return false;
    }
  }
}
