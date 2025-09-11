import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'signup_screen.dart';
import 'home_screen.dart';
import 'reset_password_screen.dart';
import '../services/user_service.dart';
import '../models/auth_models.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _rememberMe = false;
  bool _isLoading = false;

  Future<void> _signInWithEmailAndPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await UserService().signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        rememberMe: _rememberMe,
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } on ApiException catch (e) {
      String message;
      switch (e.statusCode) {
        case 400:
          message = 'Date de autentificare invalide.';
          break;
        case 401:
          message = 'Email sau parolă incorectă.';
          break;
        case 404:
          message = 'Nu există niciun cont cu acest email.';
          break;
        case 429:
          message = 'Prea multe încercări. Încercați din nou mai târziu.';
          break;
        default:
          message = e.message.isNotEmpty ? e.message : 'Eroare la autentificare.';
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Eroare neașteptată: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                
                Text(
                  'Francofonie',
                  style: TextStyle(
                    fontFamily: 'Varela Round',
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                
                const SizedBox(height: 60),
                
                Text(
                  'Autentificare',
                  style: TextStyle(
                    fontFamily: 'Varela Round',
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                
                const SizedBox(height: 12),
                
                Text(
                  'Conectați-vă cu datele pe care le-ați introdus în timpul înregistrării.',
                  style: TextStyle(
                    fontFamily: 'Varela Round',
                    fontSize: 16,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                
                const SizedBox(height: 40),
                
                Text(
                  'Email',
                  style: TextStyle(
                    fontFamily: 'Varela Round',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(
                    fontFamily: 'Varela Round',
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'nume@exemplu.com',
                    hintStyle: TextStyle(
                      fontFamily: 'Varela Round',
                      color: AppColors.textHint,
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.primary, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vă rugăm să introduceți emailul';
                    }
                    if (!value.contains('@')) {
                      return 'Vă rugăm să introduceți un email valid';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 24),
                
                Text(
                  'Parolă',
                  style: TextStyle(
                    fontFamily: 'Varela Round',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  style: TextStyle(
                    fontFamily: 'Varela Round',
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'min. 8 caractere',
                    hintStyle: TextStyle(
                      fontFamily: 'Varela Round',
                      color: AppColors.textHint,
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.primary, width: 2),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        color: AppColors.textHint,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vă rugăm să introduceți parola';
                    }
                    if (value.length < 8) {
                      return 'Parola trebuie să aibă minim 8 caractere';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Checkbox(
                      value: _rememberMe,
                      onChanged: (value) {
                        setState(() {
                          _rememberMe = value ?? false;
                        });
                      },
                      activeColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    Text(
                      'Rămâi conectat',
                      style: TextStyle(
                        fontFamily: 'Varela Round',
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: !_isLoading ? _signInWithEmailAndPassword : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            'Autentificare',
                            style: TextStyle(
                              fontFamily: 'Varela Round',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ResetPasswordScreen()),
                      );
                    },
                    child: Text(
                      'Ați uitat parola?',
                      style: TextStyle(
                        fontFamily: 'Varela Round',
                        fontSize: 16,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Nu aveți un cont? ',
                      style: TextStyle(
                        fontFamily: 'Varela Round',
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SignUpScreen()),
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                      ),
                      child: Text(
                        'Înscrie-te',
                        style: TextStyle(
                          fontFamily: 'Varela Round',
                          fontSize: 16,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}