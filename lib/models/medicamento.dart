class Medicamento {
  final String id;
  final String nombre;
  final String paraQueSirve;
  final String comoTomar;
  final String advertencias;

  Medicamento({
    required this.id,
    required this.nombre,
    required this.paraQueSirve,
    required this.comoTomar,
    required this.advertencias,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'para_que_sirve': paraQueSirve,
      'como_tomar': comoTomar,
      'advertencias': advertencias,
    };
  }
}
