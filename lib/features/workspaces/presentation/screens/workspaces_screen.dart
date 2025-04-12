// lib/features/workspaces/presentation/screens/workspaces_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../app/routes.dart';
import '../../../../app/theme.dart';
import '../../../../common/widgets/animated_card.dart';
import '../../../../common/widgets/shimmer_loading.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../providers/workspace_provider.dart';
import '../widgets/workspace_card.dart';
import '../widgets/empty_workspaces.dart';

class WorkspacesScreen extends StatefulWidget {
  const WorkspacesScreen({Key? key}) : super(key: key);

  @override
  State<WorkspacesScreen> createState() => _WorkspacesScreenState();
}

class _WorkspacesScreenState extends State<WorkspacesScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );

    _animationController.forward();

    // Load workspaces
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadWorkspaces();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _loadWorkspaces() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final workspaceProvider =
        Provider.of<WorkspaceProvider>(context, listen: false);

    if (authProvider.user != null) {
      workspaceProvider.loadUserWorkspaces(authProvider.user!.id);
    }
  }

  void _navigateToCreateWorkspace() {
    AppRoutes.navigateTo(context, AppRoutes.createWorkspace);
  }

  void _navigateToWorkspaceDetail(String workspaceId) {
    AppRoutes.navigateTo(
      context,
      AppRoutes.workspaceDetail,
      arguments: {'workspaceId': workspaceId},
    );
  }

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _signOut();
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  Future<void> _signOut() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.signOut();
    if (mounted) {
      AppRoutes.navigateAndRemoveUntil(context, AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final workspaceProvider = Provider.of<WorkspaceProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FadeTransition(
                        opacity: _animation,
                        child: const Text(
                          'Your Workspaces',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      FadeTransition(
                        opacity: _animation,
                        child: Text(
                          'Welcome back, ${authProvider.user?.name.split(' ').first ?? 'User'}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage:
                        authProvider.user?.photoUrl.isNotEmpty == true
                            ? NetworkImage(authProvider.user!.photoUrl)
                            : null,
                    child: authProvider.user?.photoUrl.isNotEmpty != true
                        ? Text(
                            authProvider.user?.name.isNotEmpty == true
                                ? authProvider.user!.name[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          )
                        : null,
                    onForegroundImageError: (_, __) {
                      // Handle image loading error
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Search and filter
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.2),
                  end: Offset.zero,
                ).animate(_animation),
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 12),
                      Icon(
                        Icons.search,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search workspaces',
                            hintStyle: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 16,
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      Container(
                        height: 30,
                        width: 1,
                        color: Colors.grey.shade300,
                      ),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _showSignOutDialog,
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Icon(
                              Icons.logout,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Workspaces list
            Expanded(
              child: _buildWorkspacesList(workspaceProvider),
            ),
          ],
        ),
      ),
      floatingActionButton: ScaleTransition(
        scale: _animation,
        child: FloatingActionButton.extended(
          onPressed: _navigateToCreateWorkspace,
          icon: const Icon(Icons.add),
          label: const Text('New Workspace'),
          elevation: 2,
        ),
      ),
    );
  }

  Widget _buildWorkspacesList(WorkspaceProvider workspaceProvider) {
    switch (workspaceProvider.status) {
      case WorkspaceStatus.initial:
      case WorkspaceStatus.loading:
        return _buildLoadingState();
      case WorkspaceStatus.loaded:
        return workspaceProvider.workspaces.isEmpty
            ? const EmptyWorkspaces()
            : _buildWorkspaces(workspaceProvider);
      case WorkspaceStatus.error:
        return Center(
          child: Text(
            workspaceProvider.errorMessage ?? 'An error occurred',
            style: const TextStyle(color: Colors.red),
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: 5,
      itemBuilder: (context, index) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: Offset(0, 0.1 * (index + 1)),
            end: Offset.zero,
          ).animate(_animation),
          child: ShimmerLoading(
            isLoading: true,
            child: AnimatedCard(
              margin: const EdgeInsets.only(bottom: 16),
              padding: EdgeInsets.zero,
              child: Container(
                height: 120,
                width: double.infinity,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWorkspaces(WorkspaceProvider workspaceProvider) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: workspaceProvider.workspaces.length,
      itemBuilder: (context, index) {
        final workspace = workspaceProvider.workspaces[index];
        return SlideTransition(
          position: Tween<Offset>(
            begin: Offset(0, 0.1 * (index + 1)),
            end: Offset.zero,
          ).animate(_animation),
          child: FadeTransition(
            opacity: _animation,
            child: WorkspaceCard(
              workspace: workspace,
              onTap: () => _navigateToWorkspaceDetail(workspace.id),
            ),
          ),
        );
      },
    );
  }
}
