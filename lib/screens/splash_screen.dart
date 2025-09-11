import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../constants/app_colors.dart';
import '../services/events_service.dart';
import '../services/projects_service.dart';
import '../services/members_service.dart';
import '../services/partners_service.dart';
import '../services/user_service.dart';
import 'login_screen.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _startAnimation();
  }

  void _startAnimation() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _fadeController.forward();
    
    _initializeAppData();
    
    await Future.delayed(const Duration(milliseconds: 3000));
    if (mounted) {
      _navigateToAppropriateScreen();
    }
  }

  void _navigateToAppropriateScreen() async {
    final userService = UserService();
    
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (!mounted) return;
    
    if (userService.isLoggedIn && userService.userModel != null) {
      print('User is logged in: ${userService.userModel?.email}');
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      print('User not logged in, navigating to login');
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  void _initializeAppData() async {
    try {
      final eventsService = EventsService();
      final projectsService = ProjectsService();
      final membersService = MembersService();
      final partnersService = PartnersService();
      
      await Future.wait([
        eventsService.initializeData(),
        projectsService.initializeData(),
        membersService.initializeData(),
        partnersService.initializeData(),
      ]);
      
      print('Events, projects, members, and partners data initialized successfully');
    } catch (e) {
      print('Failed to initialize app data: $e');
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 2),
            
            AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: Column(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Lottie.asset(
                          'animations/loading_gray.json',
                          width: 80,
                          height: 80,
                          fit: BoxFit.contain,
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      Text(
                        'Auf Connect',
                        style: TextStyle(
                          fontFamily: 'Varela Round',
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                          letterSpacing: 1.2,
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      Text(
                        'Conectează-te cu francofonia',
                        style: TextStyle(
                          fontFamily: 'Varela Round',
                          fontSize: 16,
                          color: AppColors.textSecondary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            
            const Spacer(flex: 2),
            
            AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value * 0.6,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 40),
                    child: Text(
                      'Powered by AUF',
                      style: TextStyle(
                        fontFamily: 'Varela Round',
                        fontSize: 12,
                        color: AppColors.textHint,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}