// wigets/nota_qr_sheet.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/nota_detalhes.dart';
import '../services/helpers/nfce_qr_parser.dart';
import '../services/nota_consulta_service.dart';
import '../theme/app_colors.dart';
import 'brand_logo.dart';

class NotaQrSheetResult {
  final bool salvar;
  final NotaDetalhes? detalhes;

  const NotaQrSheetResult({required this.salvar, this.detalhes});
}

Future<NotaQrSheetResult?> showNotaQrSheet({
  required BuildContext context,
  required NfceQrInfo info,
  bool permitirSalvar = true,
}) {
  return showModalBottomSheet<NotaQrSheetResult>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    showDragHandle: false,
    requestFocus: false,
    builder: (_) => _NotaQrSheet(info: info, permitirSalvar: permitirSalvar),
  );
}

class _NotaQrSheet extends StatefulWidget {
  final NfceQrInfo info;
  final bool permitirSalvar;

  const _NotaQrSheet({
    required this.info,
    required this.permitirSalvar,
  });

  @override
  State<_NotaQrSheet> createState() => _NotaQrSheetState();
}

class _NotaQrSheetState extends State<_NotaQrSheet> {
  static final _moeda = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  final _consultaService = NotaConsultaService();

  final _scrollController = ScrollController();

  NotaDetalhes? _detalhes;
  String? _erro;
  bool _carregando = true;

  NfceQrInfo get info => widget.info;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
    });
    _consultar();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _consultar() async {
    if (!info.possuiChaveValida) {
      _carregando = false;
      return;
    }

    if (info.url == null) {
      _carregando = false;
      _erro = 'Não há URL de consulta disponível para esta nota.';
      return;
    }

    try {
      final detalhes = await _consultaService.consultar(info);
      if (!mounted) return;
      setState(() {
        _detalhes = detalhes;
        _carregando = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(0);
        }
      });
    } on NotaConsultaException catch (e) {
      if (!mounted) return;
      setState(() {
        _erro = e.mensagem;
        _carregando = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _erro = 'Não foi possível consultar os detalhes da nota.';
        _carregando = false;
      });
    }
  }

  void _fechar() {
    Navigator.pop(
      context,
      const NotaQrSheetResult(salvar: false),
    );
  }

  void _salvar() {
    Navigator.pop(
      context,
      NotaQrSheetResult(salvar: true, detalhes: _detalhes),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cnpj = _detalhes?.cnpj ?? info.cnpjFormatado;
    final emitente = _detalhes?.emitente;

    return Container(
      height: MediaQuery.sizeOf(context).height * 0.92,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: ListView(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                children: [
                  Row(
                    children: [
                      const BrandMark(size: 34),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Nota fiscal detectada',
                          style: theme.textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        onPressed: _fechar,
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (info.possuiChaveValida) ...[
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        Chip(
                          label: Text(info.modeloDescricao),
                          visualDensity: VisualDensity.compact,
                        ),
                        if (info.ambiente != null)
                          Chip(
                            label: Text(info.ambiente!),
                            visualDensity: VisualDensity.compact,
                            backgroundColor: info.ambienteCodigo == '1'
                                ? AppColors.primarySoft
                                : AppColors.accentSoft,
                          ),
                        if (!info.digitoVerificadorValido)
                          const Chip(
                            label: Text('DV inválido'),
                            visualDensity: VisualDensity.compact,
                            backgroundColor: Color(0xFFFFCDD2),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (emitente != null) ...[
                      _InfoRow(
                        icon: Icons.storefront_outlined,
                        label: 'Emitente',
                        value: emitente,
                      ),
                      if (_detalhes?.endereco != null)
                        _InfoRow(
                          icon: Icons.location_on_outlined,
                          label: 'Endereço',
                          value: _detalhes!.endereco!,
                        ),
                    ],
                    _InfoRow(
                      icon: Icons.numbers,
                      label: 'Número',
                      value: _detalhes?.numero ?? info.numero ?? '-',
                    ),
                    _InfoRow(
                      icon: Icons.confirmation_number_outlined,
                      label: 'Série',
                      value: _detalhes?.serie ?? info.serie ?? '-',
                    ),
                    _InfoRow(
                      icon: Icons.business_outlined,
                      label: 'CNPJ emitente',
                      value: cnpj ?? '-',
                    ),
                    _InfoRow(
                      icon: Icons.place_outlined,
                      label: 'UF',
                      value: info.uf ?? '-',
                    ),
                    _InfoRow(
                      icon: Icons.event_outlined,
                      label: 'Emissão',
                      value: _detalhes?.dataEmissao ?? info.dataEmissao ?? '-',
                    ),
                    _InfoRow(
                      icon: Icons.local_shipping_outlined,
                      label: 'Tipo de emissão',
                      value: info.tipoEmissao ?? '-',
                    ),
                    if (_detalhes?.formaPagamento != null)
                      _InfoRow(
                        icon: Icons.payments_outlined,
                        label: 'Pagamento',
                        value: _detalhes!.formaPagamento!,
                      ),
                    const SizedBox(height: 12),
                    _buildItens(context, theme),
                    const SizedBox(height: 12),
                    Text('Chave de acesso', style: theme.textTheme.labelLarge),
                    const SizedBox(height: 4),
                    SelectableText(
                      info.chaveFormatada,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontFamily: 'monospace',
                        letterSpacing: 1.1,
                      ),
                    ),
                    if (info.url != null) ...[
                      const SizedBox(height: 12),
                      Text('URL do QR Code', style: theme.textTheme.labelLarge),
                      const SizedBox(height: 4),
                      SelectableText(
                        info.url!,
                        maxLines: 3,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.accentSoft,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Este QR Code não foi reconhecido como uma NF-e/NFC-e. '
                        'Verifique se é o código impresso no cupom fiscal.',
                      ),
                    ),
                    const SizedBox(height: 12),
                    SelectableText(
                      info.rawContent,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                  const SizedBox(height: 20),
                  if (widget.permitirSalvar)
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _fechar,
                            child: const Text('Escanear novamente'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: info.possuiChaveValida ? _salvar : null,
                            icon: const Icon(Icons.save_outlined),
                            label: const Text('Salvar nota'),
                          ),
                        ),
                      ],
                    )
                  else
                    FilledButton(
                      onPressed: _fechar,
                      child: const Text('Fechar'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItens(BuildContext context, ThemeData theme) {
    if (_carregando) {
      return Row(
        children: [
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 12),
          Text(
            'Consultando detalhes no portal da SEFAZ...',
            style: theme.textTheme.bodySmall,
          ),
        ],
      );
    }

    if (_detalhes == null) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.accentSoft,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _erro ?? 'Detalhes da nota indisponíveis.',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            Text(
              'Os dados acima foram obtidos do próprio QR Code. '
              'Os itens e valores só aparecem quando o portal da SEFAZ '
              'permite a consulta automática.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    final detalhes = _detalhes!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(
              'Itens da nota',
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            if (detalhes.quantidadeItens != null)
              Text(
                '${detalhes.quantidadeItens} itens',
                style: theme.textTheme.bodySmall,
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (detalhes.itens.isEmpty)
          Text(
            'Nenhum item encontrado no portal.',
            style: theme.textTheme.bodySmall,
          )
        else
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: theme.dividerColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                for (var i = 0; i < detalhes.itens.length; i++) ...[
                  if (i > 0) const Divider(height: 1),
                  _ItemTile(item: detalhes.itens[i]),
                ],
              ],
            ),
          ),
        const SizedBox(height: 12),
        if (detalhes.valorTotal != null)
          _TotalRow(
            label: 'Valor total',
            value: _moeda.format(detalhes.valorTotal),
          ),
        if (detalhes.descontos != null && detalhes.descontos! > 0)
          _TotalRow(
            label: 'Descontos',
            value: '- ${_moeda.format(detalhes.descontos!)}',
          ),
        if (detalhes.valorPagar != null)
          _TotalRow(
            label: 'Valor a pagar',
            value: _moeda.format(detalhes.valorPagar),
            destaque: true,
          ),
      ],
    );
  }
}

class _ItemTile extends StatelessWidget {
  final NotaItem item;

  const _ItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final quantidade =
        NumberFormat('#,##0.###', 'pt_BR').format(item.quantidade);
    final unitario = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$')
        .format(item.valorUnitario);
    final total = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$')
        .format(item.valorTotal);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.descricao,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 2),
                Text(
                  '$quantidade ${item.unidade} x $unitario',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            total,
            style: theme.textTheme.bodyMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  final String label;
  final String value;
  final bool destaque;

  const _TotalRow({
    required this.label,
    required this.value,
    this.destaque = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final estilo = destaque
        ? theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
          )
        : theme.textTheme.bodyMedium;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(label, style: estilo),
          const Spacer(),
          Text(value, style: estilo),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
