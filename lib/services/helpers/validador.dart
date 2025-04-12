// helps/validador.dart
class Validador {
  // Método para validar email
  static String? validarEmail(String? value) {
    if (value == null || value.isEmpty) {
      return "O campo email é obrigatório.";
    } else if (!value.contains('@')) {
      return "Por favor, insira um email válido.";
    }
    return null;
  }
 
  static String? validarSenha(String? value) {
    if (value == null || value.isEmpty) {
      return "O campo senha é obrigatório.";
    } else if (value.length < 8) {
      return "A senha deve ter pelo menos 8 caracteres.";
    }
    return null;
  }

  // Método para validar campos genéricos (opcional)
  static String? validarCampoGenerico(String? value, String nomeCampo) {
    if (value == null || value.isEmpty) {
      return "O campo $nomeCampo é obrigatório.";
    }
    return null;
  }
}