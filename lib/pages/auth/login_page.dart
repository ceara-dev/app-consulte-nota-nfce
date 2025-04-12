// pages/auth/login_page.dart
import 'package:flutter/material.dart';
import '../../providers/login_provider.dart';
import '../../services/helpers/validador.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Instância do controlador
  final LoginProvider _controller = LoginProvider();

  // Chave de formulário para validação
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Estado para exibir mensagens de erro
  String? _errorMessage;

  // Estado para controlar a visibilidade da senha
  bool _obscurePassword = true;

  @override
  void dispose() {
    // Liberando os controladores ao fechar a tela
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _controller.emailController.text = 'teste@gmail.com';
    _controller.passwordController.text = 'lucas:2000';
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Título da página
                    Text(
                      "Login",
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 20),

                    // Formulário de login
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Campo de email
                          TextFormField(
                            controller: _controller.emailController,
                            decoration: const InputDecoration(
                              labelText: "Email",
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.email),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: Validador.validarEmail,
                          ),
                          const SizedBox(height: 16),

                          // Campo de senha com ícone para exibir/esconder
                          TextFormField(
                            controller: _controller.passwordController,
                            decoration: InputDecoration(
                              labelText: "Senha",
                              border: const OutlineInputBorder(),
                              prefixIcon: const Icon(Icons.lock),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                            obscureText: _obscurePassword,
                            validator: Validador.validarSenha,
                          ),
                          const SizedBox(height: 20),

                          // Botão de login
                          ElevatedButton(
                            onPressed: () {
                              if (_controller.validateForm(_formKey)) {
                                _controller.login(context);
                              } else {
                                setState(() {
                                  _errorMessage =
                                      "Por favor, corrija os erros no formulário.";
                                });
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                            ),
                            child: const Text("Entrar"),
                          ),

                          // Mensagem de erro (se houver)
                          if (_errorMessage != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
