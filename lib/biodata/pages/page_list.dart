import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:tiaraprojek/models/biodata/mbiodata.dart';
import 'form_biodata.dart'; 

class PageListBiodata extends StatefulWidget {
  const PageListBiodata({super.key});

  @override
  State<PageListBiodata> createState() => _PageListBiodataState();
}

class _PageListBiodataState extends State<PageListBiodata> {
  Future<List<MBiodata>> getBiodata() async {
    try {
      final response = await http.get(Uri.parse('http://localhost/biodata/list.php'));
      if (response.statusCode == 200) {
        return mBiodataFromJson(response.body);
      } else {
        throw Exception('Gagal memuat data');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  void _showDetailBiodata(MBiodata item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: [
            const CircleAvatar(
              radius: 30,
              child: Icon(Icons.person, size: 40),
            ),
            const SizedBox(height: 10),
            Text(item.nama ?? "Detail Biodata", textAlign: TextAlign.center),
          ],
        ),
        content: SingleChildScrollView(
          child: ListBody(
            children: [
              _detailItem(Icons.email, "Email", item.email),
              _detailItem(Icons.location_city, "Tempat Lahir", item.tplahir),
              _detailItem(Icons.calendar_month, "Tanggal Lahir", item.tglahir.toString()),
              _detailItem(Icons.wc, "Jenis Kelamin", item.kelamin),
              _detailItem(Icons.church, "Agama", item.agama),
              _detailItem(Icons.home, "Alamat", item.alamat),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("TUTUP", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _detailItem(IconData icon, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.blue),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                Text(value ?? "-", style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteData(String id) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost/biodata/delete.php'),
        body: {"id": id},
      );
      final data = jsonDecode(response.body);
      if (data['status'] == "success") {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Data berhasil dihapus")),
        );
        setState(() {}); 
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal menghapus: ${data['message']}")),
        );
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  void _confirmDelete(String id, String nama) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Data"),
        content: Text("Apakah Anda yakin ingin menghapus data $nama?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteData(id);
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Daftar Biodata"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}),
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => setState(() {}),
        child: FutureBuilder<List<MBiodata>>(
          future: getBiodata(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("Terjadi kesalahan: ${snapshot.error}"));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("Belum ada data biodata."));
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 10),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                var item = snapshot.data![index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 3,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.blue.shade100,
                      child: const Icon(Icons.person, color: Colors.blue, size: 30),
                    ),
                    title: Text(
                      item.nama ?? "Tanpa Nama",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Text("Email: ${item.email}\nKlik untuk detail..."),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            // PINDAH KE FORM DENGAN MEMBAWA DATA
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BiodataForm(item: item),
                              ),
                            ).then((value) => setState(() {}));
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_sweep, color: Colors.redAccent),
                          onPressed: () => _confirmDelete(item.id.toString(), item.nama!),
                        ),
                      ],
                    ),
                    onTap: () => _showDetailBiodata(item),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pop(context),
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}