// lib/app/app.dart
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'routes.dart';
import 'theme.dart';
import '../core/analytics/analytics_service.dart';

class TaskXApp extends StatefulWidget {
  const TaskXApp({Key? key}) : super(key: key);

  @override
  State<TaskXApp> createState() => _TaskXAppState();
}

class _TaskXAppState extends State<TaskXApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TaskX',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      navigatorKey: _navigatorKey,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRoutes.onGenerateRoute,
      navigatorObservers: [
        // Add Firebase Analytics observer
        FirebaseAnalyticsObserver(
          analytics: AnalyticsService().analytics,
          nameExtractor: _getRouteName,
        ),
      ],
      builder: (context, child) {
        // Add global error handling UI wrapper
        return _ErrorBoundary(child: child!);
      },
    );
  }

  // Extract route name for analytics
  String _getRouteName(RouteSettings settings) {
    // Strip any IDs or parameters from the route name
    String? routeName = settings.name;
    if (routeName == null) return 'unknown';

    // Log specific screens but remove any sensitive data
    if (routeName.startsWith(AppRoutes.workspaceDetail)) {
      return 'workspace_detail_screen';
    } else if (routeName.startsWith(AppRoutes.taskDetail)) {
      return 'task_detail_screen';
    } else {
      return routeName;
    }
  }
}

class _ErrorBoundary extends StatefulWidget {
  final Widget child;

  const _ErrorBoundary({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<_ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<_ErrorBoundary> {
  bool _hasError = false;
  String _errorDetails = '';

  @override
  void initState() {
    super.initState();
    // Listen for uncaught async errors
    // Note: This doesn't catch all errors, FlutterError.onError is used for others
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      setState(() {
        _hasError = true;
        _errorDetails = details.exception.toString();
      });
      // Log error to analytics
      AnalyticsService().logError(
        'error_boundary',
        details.exception.toString(),
      );
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 64,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Something went wrong',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'An unexpected error occurred. You can try restarting the app.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade700,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (_errorDetails.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _errorDetails,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    // Reset the error state
                    setState(() {
                      _hasError = false;
                      _errorDetails = '';
                    });
                  },
                  child: const Text('Try Again'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return widget.child;
  }
}
