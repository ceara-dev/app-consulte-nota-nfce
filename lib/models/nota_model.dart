// models/nota_model.dart
import 'dart:convert';

import 'package:intl/intl.dart';

class NotaModel {
  int id;
  String url;
  String codigo;
  String uf;
  String disponivel;
  String dataLeitura;
  String horaLeitura;

  NotaModel({
    required this.id,
    required this.url,
    required this.codigo,
    required this.uf,
    required this.disponivel,
    required this.dataLeitura,
    required this.horaLeitura,
  });

  @override
  String toString() {
    return 'NotaModel(id: $id, url: $url, codigo: $codigo, uf: $uf, disponivel: $disponivel, dataLeitura: $dataLeitura, horaLeitura: $horaLeitura)';
  }

  String get dataBr {
    try {
      final data = DateTime.parse(dataLeitura);
      return DateFormat('dd/MM/yyyy').format(data);
    } catch (e) {
      return dataLeitura;
    }
  }

  NotaModel copyWith({
    int? id,
    String? url,
    String? codigo,
    String? uf,
    String? disponivel,
    String? dataLeitura,
    String? horaLeitura,
  }) {
    return NotaModel(
      id: id ?? this.id,
      url: url ?? this.url,
      codigo: codigo ?? this.codigo,
      uf: uf ?? this.uf,
      disponivel: disponivel ?? this.disponivel,
      dataLeitura: dataLeitura ?? this.dataLeitura,
      horaLeitura: horaLeitura ?? this.horaLeitura,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'url': url,
      'codigo': codigo,
      'uf': uf,
      'disponivel': disponivel,
      'dataLeitura': dataLeitura,
      'horaLeitura': horaLeitura,
    };
  }

  factory NotaModel.fromMap(Map<String, dynamic> map) {
    return NotaModel(
      id: map['id'] as int,
      url: map['url'] as String,
      codigo: map['codigo'] as String,
      uf: map['uf'] as String,
      disponivel: map['disponivel'] as String,
      dataLeitura: map['dataLeitura'] as String,
      horaLeitura: map['horaLeitura'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory NotaModel.fromJson(String source) =>
      NotaModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool operator ==(covariant NotaModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.url == url &&
        other.codigo == codigo &&
        other.uf == uf &&
        other.disponivel == disponivel &&
        other.dataLeitura == dataLeitura &&
        other.horaLeitura == horaLeitura;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        url.hashCode ^
        codigo.hashCode ^
        uf.hashCode ^
        disponivel.hashCode ^
        dataLeitura.hashCode ^
        horaLeitura.hashCode;
  }
}
