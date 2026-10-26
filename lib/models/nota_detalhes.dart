// models/nota_detalhes.dart

class NotaItem {
  final String codigo;
  final String descricao;
  final String unidade;
  final double quantidade;
  final double valorUnitario;
  final double valorTotal;

  const NotaItem({
    this.codigo = '',
    required this.descricao,
    this.unidade = '',
    this.quantidade = 0,
    this.valorUnitario = 0,
    this.valorTotal = 0,
  });

  @override
  String toString() =>
      'NotaItem(descricao: $descricao, quantidade: $quantidade, valorTotal: $valorTotal)';
}

class NotaDetalhes {
  final String? emitente;
  final String? cnpj;
  final String? endereco;
  final String? numero;
  final String? serie;
  final String? dataEmissao;
  final String? chave;
  final String? formaPagamento;
  final int? quantidadeItens;
  final double? valorTotal;
  final double? descontos;
  final double? valorPagar;
  final List<NotaItem> itens;
  final String? url;

  const NotaDetalhes({
    this.emitente,
    this.cnpj,
    this.endereco,
    this.numero,
    this.serie,
    this.dataEmissao,
    this.chave,
    this.formaPagamento,
    this.quantidadeItens,
    this.valorTotal,
    this.descontos,
    this.valorPagar,
    this.itens = const [],
    this.url,
  });

  bool get temItens => itens.isNotEmpty;

  @override
  String toString() =>
      'NotaDetalhes(emitente: $emitente, valorPagar: $valorPagar, itens: ${itens.length})';
}
