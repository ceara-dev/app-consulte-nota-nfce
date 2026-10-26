import 'package:app_nfce/services/helpers/nfce_qr_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const chave = '43240612345678000195650010000012341123456788';

  group('NfceQrInfo', () {
    test('extrai os dados da URL do QR Code (versão 2)', () {
      final info = NfceQrInfo.parse(
        'https://www.sefaz.rs.gov.br/NFCE/NFCE-COM.aspx?p=$chave|2|1|1|ABCDEF',
      );

      expect(info.url, isNotNull);
      expect(info.chave, chave);
      expect(info.possuiChaveValida, isTrue);
      expect(info.digitoVerificadorValido, isTrue);
      expect(info.versaoQrCode, '2');
      expect(info.ambienteCodigo, '1');
      expect(info.ambiente, 'Produção');
      expect(info.idCsc, '1');
      expect(info.hash, 'ABCDEF');
      expect(info.uf, 'RS');
      expect(info.dataEmissao, '06/2024');
      expect(info.cnpjFormatado, '12.345.678/0001-95');
      expect(info.modelo, '65');
      expect(info.modeloDescricao, 'NFC-e');
      expect(info.serie, '1');
      expect(info.numero, '1234');
      expect(info.tipoEmissao, 'Normal');
      expect(info.chaveFormatada,
          '4324 0612 3456 7800 0195 6500 1000 0012 3411 2345 6788');
    });

    test('aceita o parâmetro p codificado (%7C)', () {
      final info = NfceQrInfo.parse(
        'https://sefaz.gov.br/consulta?p=$chave%7C2%7C2%7C1%7CHASH',
      );

      expect(info.chave, chave);
      expect(info.ambiente, 'Homologação');
    });

    test('aceita a chave de acesso pura', () {
      final info = NfceQrInfo.parse(chave);

      expect(info.chave, chave);
      expect(info.uf, 'RS');
      expect(info.numero, '1234');
    });

    test('aceita QR Code versão 3', () {
      final info = NfceQrInfo.parse(
        'http://www.fazenda.pr.gov.br/nfce/qrcode?p=$chave|3|1|1',
      );

      expect(info.url, isNotNull);
      expect(info.ambiente, 'Produção');
    });

    test('aceita o formato antigo com chNFe', () {
      final info = NfceQrInfo.parse(
        'https://www.sefaz.rs.gov.br/NFCE/NFCE-COM.aspx'
        '?chNFe=$chave&nVersao=100&tpAmb=2',
      );

      expect(info.chave, chave);
      expect(info.url, isNotNull);
    });

    test('identifica chave com dígito verificador inválido', () {
      final info = NfceQrInfo.parse(chave.replaceRange(43, 44, '0'));

      expect(info.digitoVerificadorValido, isFalse);
    });

    test('não quebra com conteúdo que não é de nota fiscal', () {
      final info = NfceQrInfo.parse('https://example.com/qualquer-coisa');

      expect(info.possuiChaveValida, isFalse);
      expect(info.uf, isNull);
      expect(info.numero, isNull);
    });
  });
}
