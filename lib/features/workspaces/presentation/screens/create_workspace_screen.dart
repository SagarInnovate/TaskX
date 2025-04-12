// lib/features/workspaces/presentation/screens/create_workspace_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../app/routes.dart';
import '../../../../app/theme.dart';
import '../../../../common/widgets/animated_button.dart';
import '../../../../common/widgets/futuristic_text_field.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../providers/workspace_provider.dart';
import 'dart:math';

class CreateWorkspaceScreen extends StatefulWidget {
  const CreateWorkspaceScreen({Key? key}) : super(key: key);

  @override
  State<CreateWorkspaceScreen> createState() => _CreateWorkspaceScreenState();
}

class _CreateWorkspaceScreenState extends State<CreateWorkspaceScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  bool _isCreating = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _createWorkspace() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isCreating = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final workspaceProvider =
          Provider.of<WorkspaceProvider>(context, listen: false);

      if (authProvider.user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You need to be signed in to create a workspace.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final success = await workspaceProvider.createWorkspace(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        creator: authProvider.user!,
      );

      if (success && mounted) {
        // Show success animation
        _showSuccessAnimation();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                workspaceProvider.errorMessage ?? 'Failed to create workspace'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isCreating = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred: $e'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isCreating = false;
        });
      }
    }
  }

  void _showSuccessAnimation() {
    // Show a success animation and then navigate back
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle,
                  color: AppTheme.successColor,
                  size: 80,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Workspace Created!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Your new workspace "${_nameController.text}" has been created successfully.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    // Delay navigation to show the animation
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pop(); // Close dialog
        Navigator.of(context).pop(); // Go back to workspaces screen
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Workspace'),
        centerTitle: true,
        elevation: 0,
      ),
      body: GestureDetector(
        onTap: () {
          // Dismiss keyboard when tapping outside
          FocusScope.of(context).unfocus();
        },
        child: SafeArea(
          child: SingleChildScrollView(
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: Transform.translate(
                    offset: Offset(0, _slideAnimation.value),
                    child: child,
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Workspace illustration
                      Center(
                        child: _WorkspaceIllustration(),
                      ),
                      const SizedBox(height: 32),

                      // Form title
                      const Text(
                        'Create a New Workspace',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'A workspace is where you and your team will collaborate on tasks.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Workspace name
                      FuturisticTextField(
                        label: 'Workspace Name',
                        hintText:
                            'e.g. Marketing Team, Project X, Friend Group',
                        controller: _nameController,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a workspace name';
                          }
                          if (value.trim().length < 3) {
                            return 'Name should be at least 3 characters';
                          }
                          return null;
                        },
                        prefixIcon: Icons.group_work,
                      ),
                      const SizedBox(height: 24),

                      // Workspace description
                      FuturisticTextField(
                        label: 'Description (Optional)',
                        hintText: 'Describe what this workspace is for',
                        controller: _descriptionController,
                        prefixIcon: Icons.description,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 40),

                      // Create button
                      AnimatedButton(
                        text: 'Create Workspace',
                        onPressed: _createWorkspace,
                        isLoading: _isCreating,
                        isFullWidth: true,
                        icon: Icons.add_circle,
                        height: 56,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WorkspaceIllustration extends StatefulWidget {
  @override
  State<_WorkspaceIllustration> createState() => _WorkspaceIllustrationState();
}

class _WorkspaceIllustrationState extends State<_WorkspaceIllustration>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 10000),
    );

    _rotateAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.linear,
      ),
    );

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _rotateAnimation,
      builder: (context, child) {
        return Container(
          width: 180,
          height: 180,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.05),
            shape: BoxShape.circle,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Orbit
              Transform.rotate(
                angle: _rotateAnimation.value * 2 * 3.1416,
                child: CustomPaint(
                  size: const Size(160, 160),
                  painter: _OrbitPainter(),
                ),
              ),

              // Center node
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.group_work,
                  color: Colors.white,
                  size: 30,
                ),
              ),

              // Orbiting nodes
              ..._buildOrbitingNodes(),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildOrbitingNodes() {
    final List<Widget> nodes = [];
    final double radius = 70;
    final int nodeCount = 4;

    for (int i = 0; i < nodeCount; i++) {
      final double angle =
          _rotateAnimation.value * 2 * 3.1416 + (i * 3.1416 * 2 / nodeCount);
      final double x = radius * cos(angle);
      final double y = radius * sin(angle);

      nodes.add(
        Positioned(
          left: 90 + x - 15,
          top: 90 + y - 15,
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: _getNodeColor(i),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _getNodeColor(i).withOpacity(0.3),
                  blurRadius: 5,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Center(
              child: Icon(
                _getNodeIcon(i),
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ),
      );
    }

    return nodes;
  }

  Color _getNodeColor(int index) {
    final List<Color> colors = [
      AppTheme.accentColor,
      AppTheme.successColor,
      AppTheme.warningColor,
      AppTheme.secondaryColor,
    ];

    return colors[index % colors.length];
  }

  IconData _getNodeIcon(int index) {
    final List<IconData> icons = [
      Icons.task_alt,
      Icons.person,
      Icons.schedule,
      Icons.comment,
    ];

    return icons[index % icons.length];
  }
}

class _OrbitPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = AppTheme.primaryColor.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    // Draw orbit circle
    final double radius = size.width / 2;
    final Offset center = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(center, radius, paint);

    // Draw orbit dots
    final dotPaint = Paint()
      ..color = AppTheme.primaryColor.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    final int dotCount = 24;
    final double dotRadius = 1.5;

    for (int i = 0; i < dotCount; i++) {
      final double angle = (i * 2 * 3.1416) / dotCount;
      final double x = center.dx + radius * cos(angle);
      final double y = center.dy + radius * sin(angle);

      canvas.drawCircle(Offset(x, y), dotRadius, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
