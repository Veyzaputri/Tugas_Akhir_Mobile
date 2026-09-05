import 'package:flutter/material.dart';
import '../models/pasien_model.dart';
import 'tambah_pasien.dart';
import '../services/api_service.dart';

class AntrianPasienPage extends StatefulWidget {
  @override
  _AntrianPasienPageState createState() => _AntrianPasienPageState();
}

class _AntrianPasienPageState extends State<AntrianPasienPage> {
  late Future<List<Pasien>> _pasienList;
  List<Pasien> allPasien = [];
  List<Pasien> filteredPasien = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _pasienList = fetchPasien();
  }

  Future<List<Pasien>> fetchPasien() async {
    final dataList = await ApiService.getPasienList();
    final pasienList = dataList.map((e) => Pasien.fromJson(e)).toList();
    setState(() {
      allPasien = pasienList;
      filteredPasien = pasienList;
    });
    return pasienList;
  }

  void _filterPasien(String query) {
    final results =
        allPasien.where((pasien) {
          final nameLower = pasien.nama.toLowerCase();
          final queryLower = query.toLowerCase();
          return nameLower.contains(queryLower);
        }).toList();

    setState(() {
      filteredPasien = results;
    });
  }

  void navigateToAddPasien() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TambahPasienPage()),
    ).then((_) {
      setState(() {
        _pasienList = fetchPasien();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.grey[700],
        title: const Text(
          'Antrian Pasien',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Pasien>>(
        future: _pasienList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Belum ada pasien'));
          } else {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Search Field
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Cari nama pasien',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onChanged: _filterPasien,
                  ),
                  const SizedBox(height: 16),

                  // Table
                  Expanded(
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minWidth: MediaQuery.of(context).size.width,
                          ),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: DataTable(
                              headingRowColor: MaterialStateProperty.all(
                                Colors.grey[300],
                              ),
                              dataRowColor: MaterialStateProperty.all(
                                Colors.grey[100],
                              ),
                              columnSpacing: 12,
                              columns: const [
                                DataColumn(
                                  label: Text(
                                    'No',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'Nama Pasien',
                                    softWrap: true,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'Dokter',
                                    softWrap: true,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'No. Telp',
                                    softWrap: true,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                              rows: List.generate(filteredPasien.length, (
                                index,
                              ) {
                                final pasien = filteredPasien[index];
                                return DataRow(
                                  cells: [
                                    DataCell(Text('${index + 1}')),
                                    DataCell(Text(pasien.nama, softWrap: true)),
                                    DataCell(
                                      Text(pasien.namaDokter, softWrap: true),
                                    ),
                                    DataCell(
                                      Text(pasien.noTelp, softWrap: true),
                                    ),
                                  ],
                                );
                              }),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.grey[700],
        icon: const Icon(Icons.person_add),
        label: const Text('Tambah Pasien'),
        onPressed: navigateToAddPasien,
      ),
    );
  }
}
