// services/nota_consulta_service.dart
import 'dart:async';
import 'dart:convert';

import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart' as http;

import '../models/nota_detalhes.dart';
import 'helpers/nfce_qr_parser.dart';

class NotaConsultaException implements Exception {
  final String mensagem;

  const NotaConsultaException(this.mensagem);

  @override
  String toString() => mensagem;
}

/// Consulta os detalhes da nota no portal da SEFAZ indicado pelo QR Code.
///
/// O QR Code aponta para a página pública do DANFE NFC-e. O conteúdo HTML é
/// lido e convertido para [NotaDetalhes] (emitente, itens, totais etc.).
class NotaConsultaService {
  final http.Client _client;

  NotaConsultaService({http.Client? client})
      : _client = client ?? http.Client();

  Future<NotaDetalhes> consultar(NfceQrInfo info) async {
    final url = info.url;

    if (url == null || url.isEmpty) {
      throw const NotaConsultaException(
        'O QR Code não possui uma URL de consulta.',
      );
    }

    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
      throw const NotaConsultaException('URL de consulta inválida.');
    }

    final host = uri.host.toLowerCase();
    if (!host.endsWith('.gov.br')) {
      throw const NotaConsultaException(
        'A URL do QR Code não aponta para um portal da SEFAZ.',
      );
    }

    late final http.Response response;
    try {
      response = await _client.get(
        uri,
        headers: const {
          'User-Agent': 'Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36 '
              '(KHTML, like Gecko) Chrome/120.0 Mobile Safari/537.36',
          'Accept': 'text/html,application/xhtml+xml',
          'Accept-Language': 'pt-BR,pt;q=0.9',
        },
      ).timeout(const Duration(seconds: 25));
    } on TimeoutException {
      throw const NotaConsultaException(
        'O portal da SEFAZ demorou demais para responder.',
      );
    } on Exception {
      throw const NotaConsultaException(
        'Não foi possível conectar ao portal da SEFAZ.',
      );
    }

    if (response.statusCode != 200) {
      throw NotaConsultaException(
        'O portal da SEFAZ retornou o status ${response.statusCode}.',
      );
    }

    final htmlText = _decodificar(response);
    final documento = html_parser.parse(htmlText);

    return _extrairDetalhes(documento, info);
  }

  String _decodificar(http.Response response) {
    final contentType = response.headers['content-type']?.toLowerCase() ?? '';

    if (contentType.contains('iso-8859-1') ||
        contentType.contains('windows-1252') ||
        contentType.contains('latin1')) {
      return latin1.decode(response.bodyBytes, allowInvalid: true);
    }

    final texto = utf8.decode(response.bodyBytes, allowMalformed: true);
    if (texto.contains('\uFFFD')) {
      return latin1.decode(response.bodyBytes, allowInvalid: true);
    }
    return texto;
  }

  NotaDetalhes _extrairDetalhes(dom.Document documento, NfceQrInfo info) {
    final texto = _normalizar(documento.body?.text ?? '');

    final textosEmitente = documento
        .querySelectorAll('.txtCenter .text')
        .map((element) => _normalizar(element.text))
        .where((value) => value.isNotEmpty)
        .toList();

    final emitente = _limpar(
      documento.querySelector('.txtTopo')?.text ??
          documento.querySelector('#u20')?.text,
    );

    final cnpj = _primeiroGrupo(
          texto,
          RegExp(r'CNPJ:?\s*([\d./-]{14,18})'),
        ) ??
        info.cnpjFormatado;

    final endereco = textosEmitente.length > 1
        ? textosEmitente[1]
            .split(',')
            .map((parte) => parte.trim())
            .where((parte) => parte.isNotEmpty)
            .join(', ')
        : null;

    final numero =
        _primeiroGrupo(texto, RegExp(r'N[úu]mero:\s*(\d+)')) ?? info.numero;

    final serie =
        _primeiroGrupo(texto, RegExp(r'S[ée]rie:\s*(\d+)')) ?? info.serie;

    final dataEmissao = _primeiroGrupo(
          texto,
          RegExp(
            r'(?:Emiss[ãa]o|Data de Emiss[ãa]o):?\s*'
            r'(\d{2}/\d{2}/\d{4}(?:\s+\d{2}:\d{2}:\d{2})?)',
          ),
        ) ??
        info.dataEmissao;

    final valorTotal = _buscarValor(
      texto,
      const [
        'Valor total',
        'Valor Total',
        'Total dos itens',
        'Total bruto',
        'Total R\$',
      ],
    );

    final descontos = _buscarValor(
      texto,
      const ['Descontos', 'Desconto'],
    );

    final valorPagar = _buscarValor(
      texto,
      const [
        'Valor a pagar',
        'Valor a Pagar',
        'Total a pagar',
        'Valor pago',
      ],
    );

    final quantidadeItens = int.tryParse(
      _primeiroGrupo(
            texto,
            RegExp(r'Qtd\.? total de itens:\s*(\d+)', caseSensitive: false),
          ) ??
          '',
    );

    final formaPagamento = _buscarFormaPagamento(texto);
    final itens = _extrairItens(documento);

    if (itens.isEmpty &&
        emitente == null &&
        valorTotal == null &&
        valorPagar == null) {
      throw const NotaConsultaException(
        'Nota não encontrada ou ainda indisponível no portal da SEFAZ.',
      );
    }

    return NotaDetalhes(
      emitente: emitente,
      cnpj: cnpj,
      endereco: endereco,
      numero: numero,
      serie: serie,
      dataEmissao: dataEmissao,
      chave: info.chave,
      formaPagamento: formaPagamento,
      quantidadeItens: quantidadeItens,
      valorTotal: valorTotal,
      descontos: descontos,
      valorPagar: valorPagar,
      itens: itens,
      url: info.url,
    );
  }

  List<NotaItem> _extrairItens(dom.Document documento) {
    final itens = <NotaItem>[];

    for (final linha in documento.querySelectorAll('#tabResult tr')) {
      final descricao = _limpar(linha.querySelector('.txtTit')?.text);
      if (descricao == null || descricao.isEmpty) continue;

      itens.add(
        NotaItem(
          codigo: _primeiroGrupo(
                linha.querySelector('.RCod')?.text ?? '',
                RegExp(r'C[óo]digo:\s*([^\s)]+)'),
              ) ??
              '',
          descricao: descricao,
          unidade: _primeiroGrupo(
                linha.querySelector('.RUN')?.text ?? '',
                RegExp(r'UN:\s*([^\s]+)'),
              ) ??
              '',
          quantidade: _numero(linha.querySelector('.Rqtd')?.text) ?? 0,
          valorUnitario: _numero(linha.querySelector('.RvlUnit')?.text) ?? 0,
          valorTotal: _numero(
                linha.querySelector('span.valor')?.text ??
                    linha.querySelector('td.valor')?.text,
              ) ??
              0,
        ),
      );
    }

    if (itens.isNotEmpty) return itens;

    for (final linha in documento.querySelectorAll('tr')) {
      final textoLinha = _normalizar(linha.text);
      if (!textoLinha.contains('Qtde') || !textoLinha.contains('Vl. Total')) {
        continue;
      }

      final descricao = _limpar(
        linha.querySelector('.txtTit')?.text ?? linha.querySelector('td')?.text,
      );
      if (descricao == null || descricao.isEmpty) continue;

      itens.add(
        NotaItem(
          descricao: descricao,
          unidade: _primeiroGrupo(
                textoLinha,
                RegExp(r'UN:?\s*([A-Za-z]+)'),
              ) ??
              '',
          quantidade: _numero(
                _primeiroGrupo(textoLinha, RegExp(r'Qtde\.?:\s*([\d.,]+)')),
              ) ??
              0,
          valorUnitario: _numero(
                _primeiroGrupo(
                  textoLinha,
                  RegExp(r'Vl\.?\s*Unit\.?:\s*R?\$?\s*:?\s*([\d.,]+)'),
                ),
              ) ??
              0,
          valorTotal: _numero(
                _primeiroGrupo(
                  textoLinha,
                  RegExp(r'Vl\.?\s*Total:?\s*R?\$?\s*:?\s*([\d.,]+)'),
                ),
              ) ??
              0,
        ),
      );
    }

    return itens;
  }

  String? _buscarFormaPagamento(String texto) {
    const formas = [
      'Cartão de Crédito',
      'Cartão de Débito',
      'Vale Alimentação',
      'Vale Refeição',
      'Transferência Bancária',
      'Pix',
      'Dinheiro',
      'Cheque',
      'Boleto',
      'Crediário',
    ];

    final textoLower = texto.toLowerCase();
    for (final forma in formas) {
      if (textoLower.contains(forma.toLowerCase())) return forma;
    }
    return null;
  }

  double? _buscarValor(String texto, List<String> rotulos) {
    for (final rotulo in rotulos) {
      final padrao = RegExp(
        '${RegExp.escape(rotulo)}\\s*:?\\s*R?\\s*\\\$?\\s*:?\\s*([\\d.,]+)',
        caseSensitive: false,
      );
      final match = padrao.firstMatch(texto);
      if (match != null) {
        final valor = _numero(match.group(1));
        if (valor != null) return valor;
      }
    }
    return null;
  }

  double? _numero(String? texto) {
    if (texto == null) return null;

    final match = RegExp(r'-?\d[\d.,]*').firstMatch(texto);
    if (match == null) return null;

    var valor = match.group(0)!;
    final temVirgula = valor.contains(',');
    final temPonto = valor.contains('.');

    if (temVirgula && temPonto) {
      valor = valor.replaceAll('.', '').replaceAll(',', '.');
    } else if (temVirgula) {
      valor = valor.replaceAll(',', '.');
    }

    return double.tryParse(valor);
  }

  String? _primeiroGrupo(String texto, RegExp padrao) {
    return padrao.firstMatch(texto)?.group(1);
  }

  String _normalizar(String texto) =>
      texto.replaceAll(RegExp(r'\s+'), ' ').trim();

  String? _limpar(String? texto) {
    final valor = texto?.replaceAll(RegExp(r'\s+'), ' ').trim();
    return valor == null || valor.isEmpty ? null : valor;
  }
}
