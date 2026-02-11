import 'dart:convert';

class MBiodata {
  String? id;
  String? nama;
  String? email;
  String? alamat;
  String? tplahir; 
  String? tglahir; 
  String? kelamin; 
  String? agama;

  MBiodata({
    this.id,
    this.nama,
    this.email,
    this.alamat,
    this.tplahir,
    this.tglahir,
    this.kelamin,
    this.agama,
  });

  factory MBiodata.fromJson(Map<String, dynamic> json) {
    return MBiodata(
      id: json['id'].toString(),
      nama: json['nama'],
      email: json['email'],
      alamat: json['alamat'],
      tplahir: json['tplahir'],
      tglahir: json['tglahir'],
      kelamin: json['kelamin'],
      agama: json['agama'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "nama": nama,
      "email": email,
      "alamat": alamat,
      "tplahir": tplahir,
      "tglahir": tglahir,
      "kelamin": kelamin,
      "agama": agama,
    };
  }
}

List<MBiodata> mBiodataFromJson(String str) =>
    List<MBiodata>.from(json.decode(str).map((x) => MBiodata.fromJson(x)));

String mBiodataToJson(List<MBiodata> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));