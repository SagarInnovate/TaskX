// lib/core/analytics/analytics_service.dart
import 'package:firebase_analytics/firebase_analytics.dart';
import '../../data/models/user_model.dart';
import '../../data/models/workspace_model.dart';
import '../../data/models/task_model.dart';

class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  // Singleton pattern
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  // Get analytics instance
  FirebaseAnalytics get analytics => _analytics;

  // Set user properties
  Future<void> setUserProperties(UserModel user) async {
    await _analytics.setUserId(id: user.id);
    await _analytics.setUserProperty(name: 'user_email', value: user.email);
    await _analytics.setUserProperty(name: 'user_name', value: user.name);
  }

  // Log user sign in event
  Future<void> logUserSignIn(String method) async {
    await _analytics.logLogin(loginMethod: method);
  }

  // Log user sign out event
  Future<void> logUserSignOut() async {
    await _analytics.logEvent(name: 'user_sign_out');
  }

  // Log workspace creation
  Future<void> logWorkspaceCreated(WorkspaceModel workspace) async {
    await _analytics.logEvent(
      name: 'workspace_created',
      parameters: {
        'workspace_id': workspace.id,
        'workspace_name': workspace.name,
        'member_count': workspace.members.length,
      },
    );
  }

  // Log workspace viewed
  Future<void> logWorkspaceViewed(WorkspaceModel workspace) async {
    await _analytics.logEvent(
      name: 'workspace_viewed',
      parameters: {
        'workspace_id': workspace.id,
        'workspace_name': workspace.name,
      },
    );
  }

  // Log task created
  Future<void> logTaskCreated(TaskModel task) async {
    await _analytics.logEvent(
      name: 'task_created',
      parameters: {
        'task_id': task.id,
        'workspace_id': task.workspaceId,
        'has_due_date': task.dueDate != null,
        'priority': task.priority.toString().split('.').last,
      },
    );
  }

  // Log task updated
  Future<void> logTaskUpdated(TaskModel task, String updateType) async {
    await _analytics.logEvent(
      name: 'task_updated',
      parameters: {
        'task_id': task.id,
        'workspace_id': task.workspaceId,
        'update_type': updateType, // status, description, assignee, etc.
        'status': task.status.toString().split('.').last,
      },
    );
  }

  // Log task status changed
  Future<void> logTaskStatusChanged(
    TaskModel task,
    TaskStatus oldStatus,
    TaskStatus newStatus,
  ) async {
    await _analytics.logEvent(
      name: 'task_status_changed',
      parameters: {
        'task_id': task.id,
        'workspace_id': task.workspaceId,
        'old_status': oldStatus.toString().split('.').last,
        'new_status': newStatus.toString().split('.').last,
      },
    );
  }

  // Log comment added
  Future<void> logCommentAdded(TaskModel task) async {
    await _analytics.logEvent(
      name: 'comment_added',
      parameters: {
        'task_id': task.id,
        'workspace_id': task.workspaceId,
        'comment_count': task.comments.length,
      },
    );
  }

  // Log attachment added
  Future<void> logAttachmentAdded(TaskModel task, String attachmentType) async {
    await _analytics.logEvent(
      name: 'attachment_added',
      parameters: {
        'task_id': task.id,
        'workspace_id': task.workspaceId,
        'attachment_type': attachmentType, // file, voice, etc.
        'attachment_count': task.attachments.length,
      },
    );
  }

  // Log screen view
  Future<void> logScreenView(String screenName) async {
    await _analytics.logScreenView(screenName: screenName);
  }

  // Log app open
  Future<void> logAppOpen() async {
    await _analytics.logAppOpen();
  }

  // Log search
  Future<void> logSearch(String searchTerm) async {
    await _analytics.logSearch(searchTerm: searchTerm);
  }

  // Log error
  Future<void> logError(String errorName, String errorMessage) async {
    await _analytics.logEvent(
      name: 'app_error',
      parameters: {
        'error_name': errorName,
        'error_message': errorMessage,
      },
    );
  }

  // Log performance metric
  Future<void> logPerformanceMetric(String metricName, int valueMs) async {
    await _analytics.logEvent(
      name: 'performance_metric',
      parameters: {
        'metric_name': metricName,
        'value_ms': valueMs,
      },
    );
  }

  // Log feature usage
  Future<void> logFeatureUsage(String featureName) async {
    await _analytics.logEvent(
      name: 'feature_used',
      parameters: {
        'feature_name': featureName,
      },
    );
  }

  // Log task completion time
  Future<void> logTaskCompletionTime(
      TaskModel task, int durationMinutes) async {
    await _analytics.logEvent(
      name: 'task_completion_time',
      parameters: {
        'task_id': task.id,
        'workspace_id': task.workspaceId,
        'duration_minutes': durationMinutes,
        'priority': task.priority.toString().split('.').last,
      },
    );
  }

  // Log user engagement
  Future<void> logUserEngagement(
      String engagementType, int durationSeconds) async {
    await _analytics.logEvent(
      name: 'user_engagement',
      parameters: {
        'engagement_type': engagementType,
        'duration_seconds': durationSeconds,
      },
    );
  }
}
