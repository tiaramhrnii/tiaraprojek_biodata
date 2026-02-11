import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'page_list.dart'; 

class BiodataForm extends StatefulWidget {
  const BiodataForm({super.key});

  @override
  _BiodataFormState createState() => _BiodataFormState();
}

class _BiodataFormState extends State<BiodataForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String _name = '';
  String _email = '';
  String _alamat = '';
  String _tplahir = '';
  String? _kelamin;
  String? _agama; 
  final TextEditingController _dateController = TextEditingController();

  final List<String> _listKelamin = ["Laki-laki", "Perempuan"];
  final List<String> _listAgama = ["Islam", "Katholik", "Protestan", "Hindu", "Budha", "Khonghucu", "Kepercayaan"];

  final String baseUrl = "http://localhost/biodata/create.php";

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      try {
        var response = await http.post(Uri.parse(baseUrl), body: {
          "nama": _name,
          "email": _email,
          "alamat": _alamat,
          "tplahir": _tplahir,
          "tglahir": _dateController.text,
          "kelamin": _kelamin,
          "agama": _agama,
        });

        if (!mounted) return;
        Navigator.pop(context);

        if (response.statusCode == 200) {
          var data = jsonDecode(response.body);
          if (data['status'] == "success") {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Data Berhasil Disimpan!")),
            );
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const PageListBiodata()),
              (route) => false,
            );
          } else {
            _showErrorSnackBar("Gagal: ${data['message']}");
          }
        } else {
          _showErrorSnackBar("Server Error: ${response.statusCode}");
        }
      } catch (e) {
        if (!mounted) return;
        Navigator.pop(context); 
        _showErrorSnackBar("Kesalahan koneksi: Pastikan Apache di XAMPP nyala.");
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Input Biodata Baru'), backgroundColor: Colors.blue, foregroundColor: Colors.white),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              _buildTextField('Nama Lengkap', Icons.person, (val) => _name = val!),
              const SizedBox(height: 15),
              _buildTextField('Tempat Lahir', Icons.location_city, (val) => _tplahir = val!),
              const SizedBox(height: 15),
              _buildDateField(),
              const SizedBox(height: 15),
              _buildDropdown("Agama", _agama, _listAgama, (val) => setState(() => _agama = val)),
              const SizedBox(height: 15),
              _buildDropdown("Jenis Kelamin", _kelamin, _listKelamin, (val) => setState(() => _kelamin = val)),
              const SizedBox(height: 15),
              _buildTextField('Alamat Lengkap', Icons.home, (val) => _alamat = val!, maxLines: 2),
              const SizedBox(height: 15),
              _buildTextField('Email', Icons.email, (val) => _email = val!),
              const SizedBox(height: 30),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, IconData icon, FormFieldSetter<String> onSaved, {int maxLines = 1}) {
    return TextFormField(
      maxLines: maxLines,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon), border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))),
      onSaved: onSaved,
      validator: (val) => val!.isEmpty ? '$label wajib diisi' : null,
    );
  }

  Widget _buildDateField() {
    return TextFormField(
      controller: _dateController,
      readOnly: true,
      decoration: InputDecoration(labelText: 'Tanggal Lahir', prefixIcon: const Icon(Icons.calendar_today), border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))),
      onTap: () async {
        DateTime? picked = await showDatePicker(context: context, initialDate: DateTime(2000), firstDate: DateTime(1950), lastDate: DateTime.now());
        if (picked != null) _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      },
      validator: (val) => val!.isEmpty ? 'Pilih tanggal lahir' : null,
    );
  }

  Widget _buildDropdown(String label, String? val, List<String> items, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(labelText: label, border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))),
      value: val,
      items: items.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
      onChanged: onChanged,
      validator: (v) => v == null ? '$label wajib dipilih' : null,
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
        onPressed: _submitForm,
        child: const Text('SIMPAN BIODATA', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}