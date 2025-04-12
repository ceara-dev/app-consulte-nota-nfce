// providers/login_provider.dart
import 'package:flutter/material.dart';
import '../../wigets/scaffold_messenger.dart';

class LoginProvider with ChangeNotifier {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String get email => emailController.text;
  String get password => passwordController.text;

  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  bool validateForm(GlobalKey<FormState> formKey) {
    if (formKey.currentState!.validate()) {
      notifyListeners(); // Notifica listeners sobre validação
      return true;
    }
    return false;
  }

  void login(BuildContext context) {
    if (email.isNotEmpty && password.isNotEmpty) {
      Navigator.pushReplacementNamed(context, '/home');

      ScaffoldMessengerHelper.showSuccess(
        context,
        'Login bem-sucedido!',
      );
      notifyListeners(); // Notifica listeners sobre o login
      return;
    }
    ScaffoldMessengerHelper.showError(
      context,
      'Por favor, preencha todos os campos.',
    );
  }
}