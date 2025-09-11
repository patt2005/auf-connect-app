import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'home_screen.dart';
import '../services/user_service.dart';
import '../models/auth_models.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _acceptTerms = false;
  bool _isLoading = false;

  Future<void> _signUpWithEmailAndPassword() async {
    if (!_formKey.currentState!.validate() || !_acceptTerms) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await UserService().signUpWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        displayName: _nameController.text.trim(),
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
          if (e.message.toLowerCase().contains('email')) {
            message = e.message.contains('already') ? 'Acest email este deja utilizat.' : 'Email invalid.';
          } else if (e.message.toLowerCase().contains('password')) {
            message = 'Parola este prea slabă.';
          } else {
            message = e.message;
          }
          break;
        case 409:
          message = 'Acest email este deja utilizat.';
          break;
        default:
          message = e.message.isNotEmpty ? e.message : 'Eroare la înregistrare.';
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
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
                  'Înregistrare',
                  style: TextStyle(
                    fontFamily: 'Varela Round',
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                
                const SizedBox(height: 12),
                
                Text(
                  'Creați un cont nou pentru a vă conecta la comunitatea francofonă.',
                  style: TextStyle(
                    fontFamily: 'Varela Round',
                    fontSize: 16,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                
                const SizedBox(height: 40),
                
                Text(
                  'Nume complet',
                  style: TextStyle(
                    fontFamily: 'Varela Round',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                TextFormField(
                  controller: _nameController,
                  style: TextStyle(
                    fontFamily: 'Varela Round',
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Prenume Nume',
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
                      return 'Vă rugăm să introduceți numele complet';
                    }
                    if (value.trim().split(' ').length < 2) {
                      return 'Vă rugăm să introduceți prenumele și numele';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 24),
                
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
                
                const SizedBox(height: 24),
                
                Text(
                  'Confirmă parola',
                  style: TextStyle(
                    fontFamily: 'Varela Round',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: !_isConfirmPasswordVisible,
                  style: TextStyle(
                    fontFamily: 'Varela Round',
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Reintroduceți parola',
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
                        _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        color: AppColors.textHint,
                      ),
                      onPressed: () {
                        setState(() {
                          _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
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
                      return 'Vă rugăm să confirmați parola';
                    }
                    if (value != _passwordController.text) {
                      return 'Parolele nu se potrivesc';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: _acceptTerms,
                      onChanged: (value) {
                        setState(() {
                          _acceptTerms = value ?? false;
                        });
                      },
                      activeColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontFamily: 'Varela Round',
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                            children: [
                              const TextSpan(text: 'Sunt de acord cu '),
                              TextSpan(
                                text: 'Termenii și Condițiile',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const TextSpan(text: ' și '),
                              TextSpan(
                                text: 'Politica de Confidențialitate',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _acceptTerms && !_isLoading ? _signUpWithEmailAndPassword : null,
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
                            'Înregistrare',
                            style: TextStyle(
                              fontFamily: 'Varela Round',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                
                const SizedBox(height: 40),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Aveți deja un cont? ',
                      style: TextStyle(
                        fontFamily: 'Varela Round',
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                      ),
                      child: Text(
                        'Conectează-te',
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