// wigets/custom_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/nota_model.dart';

class CustomCard extends StatelessWidget {
  final NotaModel nota;

  const CustomCard({Key? key, required this.nota}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                Row(
                  children: [
                    Text('#'),
                    SizedBox(
                      width: 4.0,
                    ),
                    Text(
                      nota.id.toString(),
                    ),
                  ],
                ),
                Spacer(),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_month,
                      size: 16.0,
                    ),
                    SizedBox(
                      width: 4.0,
                    ),
                    Text(nota.dataBr),
                  ],
                ),
              ],
            ),
            Row(
              children: [
                Text('código:'.toUpperCase()),
                SizedBox(
                  width: 4.0,
                ),
                Text(nota.codigo),
              ],
            ),
            Row(
              children: [
                Text('url:'.toUpperCase()),
                SizedBox(
                  width: 4.0,
                ),
                Text(nota.url),
              ],
            ),
            Row(
              children: [
                Text('UF:'),
                SizedBox(
                  width: 4.0,
                ),
                Text(nota.uf),
              ],
            ),
            Row(
              children: [
                Text('status'.toUpperCase()),
                SizedBox(
                  width: 4.0,
                ),
                Text('NFC-e'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
