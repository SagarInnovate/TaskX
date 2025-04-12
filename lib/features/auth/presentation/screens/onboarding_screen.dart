// lib/features/auth/presentation/screens/onboarding_screen.dart
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../../../app/routes.dart';
import '../../../../app/theme.dart';
import '../../../../common/widgets/animated_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    const OnboardingPage(
      title: 'Smart Task Management',
      description:
          'Organize and track tasks between friends, teams and startups with ease.',
      lottieAsset:
          'assets/animations/task_management.json', // TODO: Add animations
      backgroundColor: Color(0xFFF0F4FF),
    ),
    const OnboardingPage(
      title: 'Private Workspaces',
      description:
          'Create secure workspaces for your teams, friends, or personal projects.',
      lottieAsset: 'assets/animations/workspace.json', // TODO: Add animations
      backgroundColor: Color(0xFFF2F8FF),
    ),
    const OnboardingPage(
      title: 'Real-time Collaboration',
      description:
          'Collaborate on tasks in real-time with comments, attachments, and reactions.',
      lottieAsset:
          'assets/animations/collaboration.json', // TODO: Add animations
      backgroundColor: Color(0xFFF4F9FF),
    ),
    const OnboardingPage(
      title: 'Voice Notes & Smart Reminders',
      description:
          'Add voice notes to tasks and get smart reminders before deadlines.',
      lottieAsset: 'assets/animations/reminder.json', // TODO: Add animations
      backgroundColor: Color(0xFFF5FAFF),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _goToNextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _finishOnboarding() {
    // TODO: Save that onboarding is complete
    AppRoutes.navigateAndRemoveUntil(context, AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pages[_currentPage].backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _finishOnboarding,
                    child: const Text(
                      'Skip',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: _onPageChanged,
                itemBuilder: (context, index) {
                  return AnimatedOpacity(
                    duration: const Duration(milliseconds: 350),
                    opacity: _currentPage == index ? 1.0 : 0.6,
                    child: _OnboardingPageView(page: _pages[index]),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Page indicators
                  Row(
                    children: List.generate(
                      _pages.length,
                      (index) => _buildPageIndicator(index),
                    ),
                  ),
                  // Next/Get Started button
                  AnimatedButton(
                    text: _currentPage < _pages.length - 1
                        ? 'Next'
                        : 'Get Started',
                    onPressed: _goToNextPage,
                    style: ButtonStyle.primary,
                    width: 150,
                    height: 50,
                    icon: _currentPage < _pages.length - 1
                        ? Icons.arrow_forward_rounded
                        : Icons.rocket_launch_rounded,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageIndicator(int index) {
    bool isActive = _currentPage == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: isActive ? 24 : 8,
      decoration: BoxDecoration(
        color: isActive
            ? AppTheme.primaryColor
            : AppTheme.primaryColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class _OnboardingPageView extends StatelessWidget {
  final OnboardingPage page;

  const _OnboardingPageView({
    Key? key,
    required this.page,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Replace this with Lottie animation when available
        // Lottie.asset(
        //   page.lottieAsset,
        //   width: 300,
        //   height: 300,
        //   fit: BoxFit.contain,
        // ),
        Container(
          width: 300,
          height: 300,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check_circle_outline,
            size: 120,
            color: AppTheme.primaryColor.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 40),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            children: [
              Text(
                page.title,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                page.description,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade700,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final String lottieAsset;
  final Color backgroundColor;

  const OnboardingPage({
    required this.title,
    required this.description,
    required this.lottieAsset,
    required this.backgroundColor,
  });
}
