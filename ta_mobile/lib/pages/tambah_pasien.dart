import 'package:flutter/material.dart';
import '../services/api_service.dart';

class TambahPasienPage extends StatefulWidget {
  @override
  _TambahPasienPageState createState() => _TambahPasienPageState();
}

class _TambahPasienPageState extends State<TambahPasienPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _tglLahirController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _noTelpController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();

  List<Map<String, dynamic>> _dokterList = [];
  int? _selectedDokterId;

  @override
  void initState() {
    super.initState();
    _fetchDokter();
  }

  Future<void> _fetchDokter() async {
    final data = await ApiService.getDokter();
    setState(() {
      _dokterList = data;
    });
  }

  Future<void> submitPasien() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedDokterId == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Silakan pilih dokter')));
        return;
      }

      final pasienData = {
        'nama': _namaController.text,
        'tgl_lahir': _tglLahirController.text,
        'gender': _genderController.text,
        'no_telp': _noTelpController.text,
        'alamat': _alamatController.text,
        'id_dokter': _selectedDokterId,
      };

      final success = await ApiService.tambahPasien(pasienData);
      if (success) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Pasien berhasil ditambahkan')));
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal menambahkan pasien')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final greyBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade300, width: 1.2),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tambah Pasien Baru',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
        ),
        backgroundColor: Color(0xFFBDBDBD),
        foregroundColor: Colors.black87,
        elevation: 2,
      ),
      backgroundColor: Color(0xFFF5F5F5),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(
                controller: _namaController,
                label: 'Nama',
                validator: (v) => v!.isEmpty ? 'Nama wajib diisi' : null,
              ),
              _buildTextField(
                controller: _tglLahirController,
                label: 'Tanggal Lahir (YYYY-MM-DD)',
                validator:
                    (v) => v!.isEmpty ? 'Tanggal lahir wajib diisi' : null,
              ),
              _buildTextField(
                controller: _genderController,
                label: 'Gender',
                validator: (v) => v!.isEmpty ? 'Gender wajib diisi' : null,
              ),
              _buildTextField(
                controller: _noTelpController,
                label: 'No. Telepon',
                validator: (v) => v!.isEmpty ? 'No. telepon wajib diisi' : null,
              ),
              _buildTextField(
                controller: _alamatController,
                label: 'Alamat',
                validator: (v) => v!.isEmpty ? 'Alamat wajib diisi' : null,
              ),
              SizedBox(height: 20),
              Text(
                'Pilih Dokter',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 8),
              DropdownButtonFormField<int>(
                value: _selectedDokterId,
                items:
                    _dokterList
                        .where(
                          (dokter) =>
                              dokter['id'] != null && dokter['nama'] != null,
                        )
                        .map((dokter) {
                          return DropdownMenuItem<int>(
                            value: dokter['id'] as int,
                            child: Text(dokter['nama']),
                          );
                        })
                        .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedDokterId = value;
                  });
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: greyBorder,
                  enabledBorder: greyBorder,
                  focusedBorder: greyBorder.copyWith(
                    borderSide: BorderSide(color: Colors.grey.shade600),
                  ),
                ),
                style: TextStyle(color: Colors.black87),
                iconEnabledColor: Colors.grey[700],
                validator:
                    (value) => value == null ? 'ID Dokter wajib diisi' : null,
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: submitPasien,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF9E9E9E),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 4,
                  shadowColor: Colors.grey.shade400,
                ),
                child: Text(
                  'Tambah Pasien',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String? Function(String?) validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey[800]),
          filled: true,
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade600, width: 1.5),
          ),
        ),
      ),
    );
  }
}
