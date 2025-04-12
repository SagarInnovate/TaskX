// lib/app/routes.dart
import 'package:flutter/material.dart';
import '../features/auth/presentation/screens/splash_screen.dart';
import '../features/auth/presentation/screens/onboarding_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/workspaces/presentation/screens/workspaces_screen.dart';
import '../features/workspaces/presentation/screens/workspace_detail_screen.dart';
import '../features/workspaces/presentation/screens/create_workspace_screen.dart';
import '../features/tasks/presentation/screens/task_detail_screen.dart';
import '../features/tasks/presentation/screens/create_task_screen.dart';

class AppRoutes {
  // Route names
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String workspaces = '/workspaces';
  static const String workspaceDetail = '/workspace-detail';
  static const String createWorkspace = '/create-workspace';
  static const String taskDetail = '/task-detail';
  static const String createTask = '/create-task';

  // Route generation
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _buildRoute(const SplashScreen(), settings);
      case onboarding:
        return _buildRoute(const OnboardingScreen(), settings);
      case login:
        return _buildRoute(const LoginScreen(), settings);
      case workspaces:
        return _buildRoute(const WorkspacesScreen(), settings);
      case workspaceDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        final workspaceId = args?['workspaceId'] as String?;
        return _buildRoute(
            WorkspaceDetailScreen(workspaceId: workspaceId), settings);
      case createWorkspace:
        return _buildRoute(const CreateWorkspaceScreen(), settings);
      case taskDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        final taskId = args?['taskId'] as String?;
        return _buildRoute(TaskDetailScreen(taskId: taskId), settings);
      case createTask:
        final args = settings.arguments as Map<String, dynamic>?;
        final workspaceId = args?['workspaceId'] as String?;
        return _buildRoute(
            CreateTaskScreen(workspaceId: workspaceId), settings);
      default:
        return _buildRoute(const SplashScreen(), settings);
    }
  }

  // Helper to build page routes with transitions
  static PageRoute _buildRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = const Offset(1.0, 0.0);
        var end = Offset.zero;
        var curve = Curves.easeInOutCubic;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  // Navigate to named route
  static Future<T?> navigateTo<T>(BuildContext context, String routeName,
      {Object? arguments}) {
    return Navigator.of(context).pushNamed(routeName, arguments: arguments);
  }

  // Replace current route
  static Future<T?> navigateAndReplace<T>(
      BuildContext context, String routeName,
      {Object? arguments}) {
    return Navigator.of(context)
        .pushReplacementNamed(routeName, arguments: arguments);
  }

  // Clear all routes and navigate to
  static Future<T?> navigateAndRemoveUntil<T>(
      BuildContext context, String routeName,
      {Object? arguments}) {
    return Navigator.of(context).pushNamedAndRemoveUntil(
      routeName,
      (Route<dynamic> route) => false,
      arguments: arguments,
    );
  }
}
