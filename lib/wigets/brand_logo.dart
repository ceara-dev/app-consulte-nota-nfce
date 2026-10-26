// wigets/brand_logo.dart
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class BrandMark extends StatelessWidget {
  final double size;
  final bool elevated;

  const BrandMark({
    Key? key,
    this.size = 44,
    this.elevated = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final image = ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.28),
      child: Image.asset(
        'assets/images/app_icon.png',
        width: size,
        height: size,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.high,
      ),
    );

    if (!elevated) return image;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.3),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDeep.withValues(alpha: 0.35),
            blurRadius: size * 0.35,
            offset: Offset(0, size * 0.12),
          ),
        ],
      ),
      child: image,
    );
  }
}

class BrandWordmark extends StatelessWidget {
  final double markSize;
  final bool showTagline;
  final Color titleColor;
  final Color subtitleColor;

  const BrandWordmark({
    Key? key,
    this.markSize = 40,
    this.showTagline = true,
    this.titleColor = AppColors.ink,
    this.subtitleColor = AppColors.muted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        BrandMark(size: markSize),
        SizedBox(width: markSize * 0.3),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nota Clara',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: markSize * 0.44,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.6,
                height: 1.05,
                color: titleColor,
              ),
            ),
            if (showTagline) ...[
              SizedBox(height: markSize * 0.08),
              Text(
                'CONSULTA NFC-E',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: markSize * 0.17,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                  height: 1.1,
                  color: subtitleColor,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
