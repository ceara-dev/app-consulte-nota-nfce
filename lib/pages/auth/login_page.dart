// pages/auth/login_page.dart
import 'package:flutter/material.dart';

import '../../providers/login_provider.dart';
import '../../services/helpers/validador.dart';
import '../../theme/app_colors.dart';
import '../../wigets/brand_logo.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final LoginProvider _controller = LoginProvider();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? _errorMessage;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _entrar() {
    FocusScope.of(context).unfocus();

    if (_controller.validateForm(_formKey)) {
      setState(() => _errorMessage = null);
      _controller.login(context);
    } else {
      setState(() {
        _errorMessage = 'Confira os dados informados e tente novamente.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppColors.brandGradient),
        child: Stack(
          children: [
            Positioned(
              top: -90,
              right: -70,
              child: _Brilho(
                size: 260,
                color: Colors.white.withValues(alpha: 0.07),
              ),
            ),
            Positioned(
              bottom: -120,
              left: -110,
              child: _Brilho(
                size: 320,
                color: Colors.black.withValues(alpha: 0.10),
              ),
            ),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 440),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                              minHeight: constraints.maxHeight - 56),
                          child: IntrinsicHeight(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const _Cabecalho(),
                                const SizedBox(height: 28),
                                _CartaoFormulario(
                                  formKey: _formKey,
                                  controller: _controller,
                                  obscurePassword: _obscurePassword,
                                  errorMessage: _errorMessage,
                                  onTogglePassword: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                  onEntrar: _entrar,
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  'Seus dados ficam apenas neste dispositivo.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 12,
                                    color: Colors.white.withValues(alpha: 0.65),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Cabecalho extends StatelessWidget {
  const _Cabecalho();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const BrandMark(size: 92, elevated: true),
        const SizedBox(height: 18),
        const Text(
          'Nota Clara',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 32,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.9,
            height: 1.05,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Suas notas fiscais, organizadas.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white.withValues(alpha: 0.78),
          ),
        ),
      ],
    );
  }
}

class _CartaoFormulario extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final LoginProvider controller;
  final bool obscurePassword;
  final String? errorMessage;
  final VoidCallback onTogglePassword;
  final VoidCallback onEntrar;

  const _CartaoFormulario({
    required this.formKey,
    required this.controller,
    required this.obscurePassword,
    required this.errorMessage,
    required this.onTogglePassword,
    required this.onEntrar,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryNight.withValues(alpha: 0.28),
            blurRadius: 40,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Acesse sua conta', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 6),
            Text(
              'Entre para consultar e guardar suas NFC-e.',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 22),
            TextFormField(
              controller: controller.emailController,
              decoration: const InputDecoration(
                labelText: 'E-mail',
                hintText: 'voce@email.com',
                prefixIcon: Icon(Icons.alternate_email_rounded),
              ),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              validator: Validador.validarEmail,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: controller.passwordController,
              decoration: InputDecoration(
                labelText: 'Senha',
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                suffixIcon: IconButton(
                  tooltip: obscurePassword ? 'Mostrar senha' : 'Ocultar senha',
                  icon: Icon(
                    obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                  onPressed: onTogglePassword,
                ),
              ),
              obscureText: obscurePassword,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.password],
              validator: Validador.validarSenha,
              onFieldSubmitted: (_) => onEntrar(),
            ),
            if (errorMessage != null) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      size: 18,
                      color: AppColors.error,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        errorMessage!,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12.5,
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 22),
            FilledButton(
              onPressed: onEntrar,
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 54),
              ),
              child: const Text('Entrar'),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.shield_outlined,
                  size: 15,
                  color: AppColors.muted,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    'Consulta oficial nos portais da SEFAZ.',
                    style: theme.textTheme.bodySmall?.copyWith(fontSize: 11.5),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Brilho extends StatelessWidget {
  final double size;
  final Color color;

  const _Brilho({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}
