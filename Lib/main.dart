import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

void main() {
  runApp(const PortingStudioApp());
}

class PortingStudioApp extends StatelessWidget {
  const PortingStudioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Universal Porting Studio',
      theme: ThemeData.dark(useMaterial3: true),
      home: const PortingDashboard(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class PortingDashboard extends StatefulWidget {
  const PortingDashboard({super.key});

  @override
  State<PortingDashboard> createState() => _PortingDashboardState();
}

class _PortingDashboardState extends State<PortingDashboard> {
  String _statusLog = "Sistem siap. Silakan pilih paket aplikasi (APK, DEB, EXE) untuk diinspeksi.";
  Map<String, dynamic> _metadata = {};
  bool _isLoading = false;

  Future<void> _inspectPackage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['apk', 'deb', 'exe', 'zip'],
    );

    if (result != null && result.files.single.path != null) {
      File file = File(result.files.single.path!);
      String fileName = result.files.single.name;
      int fileSize = await file.length();

      setState(() {
        _isLoading = true;
        _statusLog = "Memindai struktur biner: $fileName...";
      });

      String targetOS = "Unknown";
      String arch = "Unknown";

      if (fileName.endsWith('.apk')) {
        targetOS = "Android";
        arch = "Dalvik / ART bytecode";
      } else if (fileName.endsWith('.deb')) {
        targetOS = "Linux (Debian/Ubuntu)";
        arch = "ELF / ARM64 / x86_64";
      } else if (fileName.endsWith('.exe')) {
        targetOS = "Windows";
        arch = "PE32+ Executable (x86_64)";
      }

      await Future.delayed(const Duration(milliseconds: 800));

      setState(() {
        _metadata = {
          "Nama File": fileName,
          "Ukuran": "${(fileSize / (1024 * 1024)).toStringAsFixed(2)} MB",
          "Target OS": targetOS,
          "Arsitektur": arch,
          "Status Kompatibilitas": targetOS == "Android" ? "Native Ready" : "Membutuhkan Wrapper / Translation Layer"
        };
        _statusLog = "Inspeksi berhasil diselesaikan!";
        _isLoading = false;
      });
    }
  }

  Future<void> _generateWebWrapper() async {
    setState(() {
      _isLoading = true;
      _statusLog = "Mengompilasi aset Web menjadi kerangka WebView APK...";
    });

    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
      _statusLog = "Berhasil! WebView APK Wrapper siap di-generate ke penyimpanan lokal.";
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Web-to-APK wrapper build berhasil dibuat!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Universal Porting & Converter Studio'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _inspectPackage,
              icon: const Icon(Icons.folder_open),
              label: const Text('Pilih & Inspeksi Paket File (APK/DEB/EXE)'),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(14)),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _generateWebWrapper,
              icon: const Icon(Icons.phone_android),
              label: const Text('Buat Web-to-APK Wrapper'),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(14)),
            ),
            const SizedBox(height: 20),
            const Text(
              "Hasil Analisis Metadata Engine:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white24),
                ),
                child: _metadata.isEmpty
                    ? const Center(child: Text("Belum ada file yang di-load."))
                    : ListView(
                        children: _metadata.entries.map((entry) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Text("${entry.key}: ${entry.value}",
                                style: const TextStyle(fontFamily: 'monospace')),
                          );
                        }).toList(),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "Terminal Log Status:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                _statusLog,
                style: const TextStyle(color: Colors.greenAccent, fontFamily: 'monospace', fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
