class StrukModel {
  final int idStruk;
  final int idPasien;
  final int idObat;
  final int idPeriksa;
  final double totalBiaya;
  final String status;

  StrukModel({
    required this.idStruk,
    required this.idPasien,
    required this.idObat,
    required this.idPeriksa,
    required this.totalBiaya,
    required this.status,
  });

  factory StrukModel.fromJson(Map<String, dynamic> json) {
    return StrukModel(
      idStruk: json['id_struk'],
      idPasien: json['id_pasien'],
      idObat: json['id_obat'],
      idPeriksa: json['id_periksa'],
      totalBiaya: double.parse(json['total_biaya'].toString()),
      status: json['status'],
    );
  }
}
