// wigets/custom_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/nota_model.dart';
import '../theme/app_colors.dart';

class CustomCard extends StatelessWidget {
  final NotaModel nota;
  final VoidCallback? onTap;

  const CustomCard({
    Key? key,
    required this.nota,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final info = nota.qrInfo;
    final temDetalhes = info.possuiChaveValida;
    final emitente = nota.emitente.isNotEmpty
        ? nota.emitente
        : (temDetalhes ? 'Nota fiscal' : 'NFC-e');
    final numeroSerie = temDetalhes
        ? '${info.modeloDescricao} • Nº ${info.numero ?? '-'} • '
            'Série ${info.serie ?? '-'}'
        : 'Nota fiscal de consumidor';
    final ambiente =
        info.ambiente ?? (nota.disponivel.isNotEmpty ? nota.disponivel : null);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Avatar(emitente: nota.emitente),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            emitente,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        if (nota.valorTotal > 0) ...[
                          const SizedBox(width: 8),
                          Text(
                            NumberFormat.currency(
                              locale: 'pt_BR',
                              symbol: 'R\$',
                            ).format(nota.valorTotal),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      numeroSerie,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 9),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        if (info.uf != null)
                          _Tag(
                            icon: Icons.place_outlined,
                            label: info.uf!,
                            destaque: true,
                          ),
                        _Tag(
                          icon: Icons.event_outlined,
                          label: nota.dataBr,
                        ),
                        if (temDetalhes && ambiente != null)
                          _Tag(
                            icon: Icons.circle,
                            label: ambiente,
                            cor: info.ambienteCodigo == '1' ||
                                    nota.disponivel == 'Produção'
                                ? AppColors.success
                                : AppColors.accent,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(
                  Icons.chevron_right_rounded,
                  size: 21,
                  color:
                      theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String emitente;

  const _Avatar({required this.emitente});

  @override
  Widget build(BuildContext context) {
    final nome = emitente.trim();
    final inicial = nome.isEmpty ? null : nome.substring(0, 1).toUpperCase();

    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(14),
      ),
      alignment: Alignment.center,
      child: inicial == null
          ? const Icon(
              Icons.receipt_long_outlined,
              size: 22,
              color: AppColors.primary,
            )
          : Text(
              inicial,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryDeep,
              ),
            ),
    );
  }
}

class _Tag extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool destaque;
  final Color? cor;

  const _Tag({
    required this.icon,
    required this.label,
    this.destaque = false,
    this.cor,
  });

  @override
  Widget build(BuildContext context) {
    final color = cor ?? (destaque ? AppColors.primary : AppColors.muted);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: destaque ? AppColors.primarySoft : AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11.5, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
