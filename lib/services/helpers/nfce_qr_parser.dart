// services/helpers/nfce_qr_parser.dart

/// Informações obtidas a partir do QR Code de uma NF-e/NFC-e.
///
/// O QR Code (versão 2) segue o formato:
/// `https://.../consulta?p=CHAVE|VERSAO|AMBIENTE|ID_CSC|HASH`
class NfceQrInfo {
  final String rawContent;
  final String? url;
  final String? chave;
  final String? versaoQrCode;
  final String? ambienteCodigo;
  final String? idCsc;
  final String? hash;

  const NfceQrInfo({
    required this.rawContent,
    this.url,
    this.chave,
    this.versaoQrCode,
    this.ambienteCodigo,
    this.idCsc,
    this.hash,
  });

  factory NfceQrInfo.parse(String content) {
    final raw = content.trim();
    String payload = raw;
    String? url;

    final uri = Uri.tryParse(raw);
    if (uri != null && uri.hasScheme && uri.hasQuery) {
      final query = uri.queryParameters;
      final p = query['p'] ?? query['P'] ?? query['chave'];
      if (p != null && p.isNotEmpty) {
        payload = p;
        url = raw;
      }
    }

    if (payload.contains('%7C') || payload.contains('%7c')) {
      try {
        payload = Uri.decodeComponent(payload);
      } catch (_) {
        // mantém o conteúdo original caso a decodificação falhe
      }
    }

    final parts = payload.split('|');
    final chaveText = parts.first.trim();
    final chave = RegExp(r'^\d{44}$').hasMatch(chaveText)
        ? chaveText
        : RegExp(r'\d{44}').firstMatch(payload)?.group(0);

    if (url == null &&
        (raw.startsWith('http://') || raw.startsWith('https://'))) {
      url = raw;
    }

    final versao = parts.length > 1 ? parts[1].trim() : null;
    final isVersao2 = versao == '2';
    final versaoComAmbiente = isVersao2 || versao == '3';

    return NfceQrInfo(
      rawContent: raw,
      url: url,
      chave: chave,
      versaoQrCode: versao,
      ambienteCodigo:
          versaoComAmbiente && parts.length > 2 ? parts[2].trim() : null,
      idCsc: isVersao2 && parts.length > 3 ? parts[3].trim() : null,
      hash: isVersao2 && parts.length > 4 ? parts[4].trim() : null,
    );
  }

  bool get possuiChaveValida => chave != null && chave!.length == 44;

  bool get digitoVerificadorValido {
    if (!possuiChaveValida) return false;
    return _calcularDigitoVerificador(chave!.substring(0, 43)) ==
        chave!.substring(43);
  }

  String? get ufCodigo => _recorte(0, 2);

  String? get uf => ufCodigo == null ? null : _ufs[ufCodigo];

  String? get anoMesEmissao => _recorte(2, 6);

  String? get dataEmissao {
    final aamm = anoMesEmissao;
    if (aamm == null) return null;
    final ano = int.tryParse(aamm.substring(0, 2));
    final mes = int.tryParse(aamm.substring(2));
    if (ano == null || mes == null || mes < 1 || mes > 12) return null;
    return '${mes.toString().padLeft(2, '0')}/20${ano.toString().padLeft(2, '0')}';
  }

  String? get cnpj => _recorte(6, 20);

  String? get cnpjFormatado {
    final value = cnpj;
    if (value == null || value.length != 14) return value;
    return '${value.substring(0, 2)}.${value.substring(2, 5)}.'
        '${value.substring(5, 8)}/${value.substring(8, 12)}-'
        '${value.substring(12)}';
  }

  String? get modelo => _recorte(20, 22);

  String get modeloDescricao => switch (modelo) {
        '55' => 'NF-e',
        '65' => 'NFC-e',
        _ => 'Modelo ${modelo ?? '-'}',
      };

  String? get serie {
    final value = _recorte(22, 25);
    if (value == null) return null;
    return int.tryParse(value)?.toString() ?? value;
  }

  String? get numero {
    final value = _recorte(25, 34);
    if (value == null) return null;
    return int.tryParse(value)?.toString() ?? value;
  }

  String? get tipoEmissaoCodigo => _recorte(34, 35);

  String? get tipoEmissao =>
      tipoEmissaoCodigo == null ? null : _tiposEmissao[tipoEmissaoCodigo];

  String? get codigoNumerico => _recorte(35, 43);

  String? get digitoVerificador => _recorte(43, 44);

  String? get ambiente =>
      ambienteCodigo == null ? null : _ambientes[ambienteCodigo];

  String get chaveFormatada {
    final value = chave;
    if (value == null) return rawContent;
    return [
      for (var i = 0; i < value.length; i += 4)
        value.substring(i, i + 4 > value.length ? value.length : i + 4),
    ].join(' ');
  }

  String? _recorte(int inicio, int fim) {
    final value = chave;
    if (value == null || value.length < fim) return null;
    return value.substring(inicio, fim);
  }

  static String _calcularDigitoVerificador(String base) {
    var peso = 2;
    var soma = 0;
    for (var i = base.length - 1; i >= 0; i--) {
      soma += int.parse(base[i]) * peso;
      peso = peso == 9 ? 2 : peso + 1;
    }
    final resto = soma % 11;
    final dv = resto < 2 ? 0 : 11 - resto;
    return dv.toString();
  }

  static const Map<String, String> _ufs = {
    '11': 'RO',
    '12': 'AC',
    '13': 'AM',
    '14': 'RR',
    '15': 'PA',
    '16': 'AP',
    '17': 'TO',
    '21': 'MA',
    '22': 'PI',
    '23': 'CE',
    '24': 'RN',
    '25': 'PB',
    '26': 'PE',
    '27': 'AL',
    '28': 'SE',
    '29': 'BA',
    '31': 'MG',
    '32': 'ES',
    '33': 'RJ',
    '35': 'SP',
    '41': 'PR',
    '42': 'SC',
    '43': 'RS',
    '50': 'MS',
    '51': 'MT',
    '52': 'GO',
    '53': 'DF',
  };

  static const Map<String, String> _ambientes = {
    '1': 'Produção',
    '2': 'Homologação',
  };

  static const Map<String, String> _tiposEmissao = {
    '1': 'Normal',
    '2': 'Contingência FS-IA',
    '3': 'Contingência SCAN',
    '4': 'Contingência EPEC',
    '5': 'Contingência FS-DA',
    '6': 'Contingência SVC-AN',
    '7': 'Contingência SVC-RS',
    '9': 'Contingência offline NFC-e',
  };
}
