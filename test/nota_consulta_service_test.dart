import 'dart:convert';

import 'package:app_nfce/services/helpers/nfce_qr_parser.dart';
import 'package:app_nfce/services/nota_consulta_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

const _chave = '43240612345678000195650010000012341123456788';
const _url =
    'https://www.sefaz.rs.gov.br/NFCE/NFCE-COM.aspx?p=$_chave|2|1|1|HASH';

const _html = '''
<html>
<body>
  <div class="txtCenter">
    <div class="txtTopo">SUPERMERCADO TESTE LTDA</div>
    <div class="text">CNPJ: 12.345.678/0001-95</div>
    <div class="text">
      RUA TESTE , 100 , , CENTRO , PORTO ALEGRE , RS
    </div>
  </div>
  <table id="tabResult">
    <tr id="Item + 1">
      <td>
        <span class="txtTit">TOMATE LONGA VIDA GRANEL</span>
        <span class="RCod">(Código: 2009490000000)</span><br />
        <span class="Rqtd"><strong>Qtde.:</strong>0,804</span>
        <span class="RUN"><strong>UN: </strong>KG</span>
        <span class="RvlUnit"><strong>Vl. Unit.:</strong>6,99</span>
      </td>
      <td class="valor">5,62</td>
    </tr>
    <tr id="Item + 2">
      <td>
        <span class="txtTit">CEBOLA BRANCA GRANEL</span>
        <span class="RCod">(Código: 2005500000008)</span><br />
        <span class="Rqtd"><strong>Qtde.:</strong>0,3653</span>
        <span class="RUN"><strong>UN: </strong>KG</span>
        <span class="RvlUnit"><strong>Vl. Unit.:</strong>4,38</span>
      </td>
      <td class="valor">1,60</td>
    </tr>
  </table>
  <div>
    Qtd. total de itens: 2
    Valor total R\$: 7,22
    Descontos R\$: 0,10
    Valor a pagar R\$: 7,12
    Forma de pagamento: Cartão de Crédito
    Número: 316588 Série: 123 Emissão: 25/01/2021 19:28:17
  </div>
</body>
</html>
''';

void main() {
  NotaConsultaService criarServico(
    Future<http.Response> Function(http.Request) handler,
  ) {
    return NotaConsultaService(client: MockClient(handler));
  }

  test('extrai emitente, itens e totais do portal da SEFAZ', () async {
    final service = criarServico(
      (request) async => http.Response.bytes(
        utf8.encode(_html),
        200,
        headers: {'content-type': 'text/html; charset=utf-8'},
      ),
    );

    final detalhes = await service.consultar(NfceQrInfo.parse(_url));

    expect(detalhes.emitente, 'SUPERMERCADO TESTE LTDA');
    expect(detalhes.cnpj, '12.345.678/0001-95');
    expect(detalhes.endereco, 'RUA TESTE, 100, CENTRO, PORTO ALEGRE, RS');
    expect(detalhes.numero, '316588');
    expect(detalhes.serie, '123');
    expect(detalhes.dataEmissao, '25/01/2021 19:28:17');
    expect(detalhes.quantidadeItens, 2);
    expect(detalhes.valorTotal, 7.22);
    expect(detalhes.descontos, 0.10);
    expect(detalhes.valorPagar, 7.12);
    expect(detalhes.formaPagamento, 'Cartão de Crédito');
    expect(detalhes.itens, hasLength(2));

    final tomate = detalhes.itens.first;
    expect(tomate.descricao, 'TOMATE LONGA VIDA GRANEL');
    expect(tomate.codigo, '2009490000000');
    expect(tomate.unidade, 'KG');
    expect(tomate.quantidade, 0.804);
    expect(tomate.valorUnitario, 6.99);
    expect(tomate.valorTotal, 5.62);
  });

  test('rejeita URL que não é de portal da SEFAZ', () async {
    final service = criarServico(
      (request) async => http.Response('', 200),
    );

    final info = NfceQrInfo.parse(
      'https://site-qualquer.com/consulta?p=$_chave|2|1|1|HASH',
    );

    await expectLater(
      service.consultar(info),
      throwsA(isA<NotaConsultaException>()),
    );
  });

  test('informa erro quando o portal retorna status inesperado', () async {
    final service = criarServico(
      (request) async => http.Response('erro', 500),
    );

    await expectLater(
      service.consultar(NfceQrInfo.parse(_url)),
      throwsA(isA<NotaConsultaException>()),
    );
  });
}
