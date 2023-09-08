import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;

class PemFilePage extends StatefulWidget {
  const PemFilePage({Key? key}) : super(key: key);

  @override
  PemFilePageState createState() => PemFilePageState();
}

class PemFilePageState extends State<PemFilePage> {
  File? _file;

  Future<void> _selectFile() async {
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ['pem']);
    if (result != null) {
      setState(() {
        _file = File(result.files.single.path!);
      });
    }
  }

  Future<void> _saveFile() async {
    if (_file == null) return;

    final directory = await getApplicationDocumentsDirectory();
    final filename = path.basename(_file!.path);
    final newFile = File('${directory.path}/certs.pem');

    try {
      await newFile.writeAsBytes(_file!.readAsBytesSync());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'File berhasil disimpan pada ${directory.path}/certs.pem dan silahkan kembali ke halaman Login')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan file')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pilih .pem file'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (_file != null) Text(_file!.path),
            Image.asset(
              'assets/images/certificate.png', // Ganti dengan path gambar asset Anda
              width: 140, // Atur lebar gambar sesuai kebutuhan
              height: 140,
              fit: BoxFit.contain, // Atur tinggi gambar sesuai kebutuhan
            ),
            SizedBox(height: 16),
            Text(
              'Unduh sertifikat yang dikirimkan ke emailmu', // Teks yang ingin ditampilkan
              style: TextStyle(fontSize: 16), // Atur gaya teks sesuai kebutuhan
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _selectFile,
              child: Text('Pilih file'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveFile,
              child: Text('Simpan file'),
            ),
          ],
        ),
      ),
    );
  }
}
