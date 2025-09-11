import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../services/user_service.dart';
import '../models/auth_models.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isOldPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Parolele nu corespund'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await UserService().resetPassword(
        email: _emailController.text.trim(),
        oldPassword: _oldPasswordController.text,
        newPassword: _newPasswordController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Parola a fost resetată cu succes'),
            backgroundColor: AppColors.success,
          ),
        );
        
        Navigator.of(context).pop();
      }
    } on ApiException catch (e) {
      String message;
      switch (e.statusCode) {
        case 400:
          message = 'Date invalide. Verificați informațiile introduse.';
          break;
        case 401:
          message = 'Parola actuală este incorectă.';
          break;
        case 404:
          message = 'Nu există niciun cont cu acest email.';
          break;
        case 429:
          message = 'Prea multe încercări. Încercați din nou mai târziu.';
          break;
        default:
          message = e.message.isNotEmpty ? e.message : 'Eroare la resetarea parolei.';
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
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Resetare Parolă',
          style: TextStyle(
            fontFamily: 'Varela Round',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                
                Text(
                  'Resetați parola',
                  style: TextStyle(
                    fontFamily: 'Varela Round',
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                
                const SizedBox(height: 12),
                
                Text(
                  'Introduceți emailul, parola actuală și noua parolă pentru a vă reseta parola.',
                  style: TextStyle(
                    fontFamily: 'Varela Round',
                    fontSize: 16,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                
                const SizedBox(height: 32),
                
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
                  'Parola Actuală',
                  style: TextStyle(
                    fontFamily: 'Varela Round',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                TextFormField(
                  controller: _oldPasswordController,
                  obscureText: !_isOldPasswordVisible,
                  style: TextStyle(
                    fontFamily: 'Varela Round',
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Parola actuală',
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
                        _isOldPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        color: AppColors.textHint,
                      ),
                      onPressed: () {
                        setState(() {
                          _isOldPasswordVisible = !_isOldPasswordVisible;
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
                      return 'Vă rugăm să introduceți parola actuală';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 24),
                
                Text(
                  'Parola Nouă',
                  style: TextStyle(
                    fontFamily: 'Varela Round',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                TextFormField(
                  controller: _newPasswordController,
                  obscureText: !_isNewPasswordVisible,
                  style: TextStyle(
                    fontFamily: 'Varela Round',
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'min. 6 caractere',
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
                        _isNewPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        color: AppColors.textHint,
                      ),
                      onPressed: () {
                        setState(() {
                          _isNewPasswordVisible = !_isNewPasswordVisible;
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
                      return 'Vă rugăm să introduceți parola nouă';
                    }
                    if (value.length < 6) {
                      return 'Parola trebuie să aibă minim 6 caractere';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 24),
                
                Text(
                  'Confirmați Parola Nouă',
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
                    hintText: 'Confirmați parola nouă',
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
                      return 'Vă rugăm să confirmați parola nouă';
                    }
                    if (value != _newPasswordController.text) {
                      return 'Parolele nu corespund';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 32),
                
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: !_isLoading ? _resetPassword : null,
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
                            'Resetează Parola',
                            style: TextStyle(
                              fontFamily: 'Varela Round',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
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