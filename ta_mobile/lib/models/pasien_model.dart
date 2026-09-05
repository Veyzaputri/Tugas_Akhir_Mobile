class Pasien {
  final int id;
  final String nama;
  final String tglLahir;
  final String gender;
  final String noTelp;
  final String alamat;
  final String namaDokter;

  Pasien({
    required this.id,
    required this.nama,
    required this.tglLahir,
    required this.gender,
    required this.noTelp,
    required this.alamat,
    required this.namaDokter,
  });

  factory Pasien.fromJson(Map<String, dynamic> json) {
    return Pasien(
      id: json['id'],
      nama: json['nama'],
      tglLahir: json['tgl_lahir'],
      gender: json['gender'],
      noTelp: json['no_telp'],
      alamat: json['alamat'],
      namaDokter: json['dokter']?['nama_dokter'] ?? '-',
    );
  }
}
