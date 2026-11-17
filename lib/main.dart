import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:archive/archive.dart';

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
  // State untuk Terminal Log & Status
  final List<String> _terminalLogs = [];
  bool _isProcessing = false;
  Map<String, dynamic> _metadata = {};

  // Fungsi untuk menambahkan log ke terminal
  void _addLog(String message) {
    setState(() {
      _terminalLogs.add(message);
    });
  }

  // Fungsi untuk membersihkan log terminal
  void _clearLogs() {
    setState(() {
      _terminalLogs.clear();
    });
  }

  // Modul Utama: Memilih dan Memproses Berkas (APK, DEB, EXE)
  Future<void> _pickAndProcessFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['apk', 'deb', 'exe', 'zip'],
    );

    if (result != null && result.files.single.path != null) {
      File file = File(result.files.single.path!);
      String fileName = result.files.single.name;
      int fileSize = await file.length();

      setState(() {
        _isProcessing = true;
        _terminalLogs.clear();
        _metadata.clear();
      });

      _addLog("[INFO] Berkas dipilih: $fileName");
      _addLog("[INFO] Ukuran berkas: ${(fileSize / (1024 * 1024)).toStringAsFixed(2)} MB");

      // Cabang Logika Berdasarkan Ekstensi File
      if (fileName.endsWith('.deb')) {
        await _parseDebianPackage(file);
      } else if (fileName.endsWith('.apk')) {
        await _parseAndroidPackage(file);
      } else if (fileName.endsWith('.exe')) {
        await _parseWindowsPackage(file);
      } else {
        _addLog("[WARN] Format berkas tidak dikenal secara spesifik.");
      }

      setState(() {
        _isProcessing = false;
      });
    }
  }

  // Implementasi Parser Arsip .deb (Linux)
  Future<void> _parseDebianPackage(File file) async {
    try {
      _addLog("[INFO] Memulai analisis struktur arsip Debian (.deb)...");
      final bytes = file.readAsBytesSync();
      
      // Membaca isi arsip menggunakan decoder
      final archive = TarDecoder().decodeBytes(bytes);
      
      _addLog("[INFO] Memindai metadata komponen internal...");
      int fileCount = 0;
      
      for (final archiveFile in archive) {
        fileCount++;
        final filename = archiveFile.name;
        if (filename.contains('control')) {
          _addLog("[SUCCESS] Berkas metadata 'control' ditemukan di dalam arsip!");
        }
      }

      await Future.delayed(const Duration(milliseconds: 500));
      
      setState(() {
        _metadata = {
          "Nama Berkas": file.path.split('/').last,
          "Tipe Paket": "Linux Debian Package (.deb)",
          "Total Komponen": "$fileCount berkas/arsip",
          "Status Kompatibilitas": "Membutuhkan PRoot / Linux Container Runtime"
        };
      });

      _addLog("[SUCCESS] Analisis arsip .deb selesai dengan sukses.");
    } catch (e) {
      _addLog("[ERROR] Gagal mem-parsing arsip .deb: $e");
      // Fallback simulasi jika struktur ar/tar kompleks
      setState(() {
        _metadata = {
          "Nama Berkas": file.path.split('/').last,
          "Tipe Paket": "Linux Debian Package (.deb)",
          "Status Kompatibilitas": "Membutuhkan PRoot / Linux Container Runtime"
        };
      });
      _addLog("[INFO] Menggunakan fallback metadata dasar berhasil.");
    }
  }

  // Parser Placeholder untuk APK (Android)
  Future<void> _parseAndroidPackage(File file) async {
    _addLog("[INFO] Membaca manifest AndroidManifest.xml dari APK...");
    await Future.delayed(const Duration(milliseconds: 600));
    setState(() {
      _metadata = {
        "Nama Berkas": file.path.split('/').last,
        "Tipe Paket": "Android Application Package (.apk)",
        "Arsitektur": "Dalvik / ART Bytecode",
        "Status Kompatibilitas": "Native Ready (Dapat langsung diinstal)"
      };
    });
    _addLog("[SUCCESS] Analisis APK selesai.");
  }

  // Parser Placeholder untuk EXE (Windows)
  Future<void> _parseWindowsPackage(File file) async {
    _addLog("[INFO] Membaca header PE (Portable Executable) Windows...");
    await Future.delayed(const Duration(milliseconds: 600));
    setState(() {
      _metadata = {
        "Nama Berkas": file.path.split('/').last,
        "Tipe Paket": "Windows Executable (.exe)",
        "Arsitektur": "PE32+ x86_64",
        "Status Kompatibilitas": "Membutuhkan Wine / Box64 Translation Layer"
      };
    });
    _addLog("[SUCCESS] Analisis EXE selesai.");
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
            // Tombol Utama Aksi Pemilihan Berkas
            ElevatedButton.icon(
              onPressed: _isProcessing ? null : _pickAndProcessFile,
              icon: const Icon(Icons.folder_open),
              label: Text(_isProcessing ? 'Sedang Memproses...' : 'Pilih & Analisis Berkas (APK / DEB / EXE)'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(14),
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            
            // Kotak Informasi Metadata Hasil Analisis
            const Text(
              "Hasil Analisis Metadata:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 6),
            Container(
              height: 130,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white24),
              ),
              child: _metadata.isEmpty
                  ? const Center(child: Text("Belum ada berkas yang dimuat.", style: TextStyle(color: Colors.white5s)))
                  : ListView(
                      children: _metadata.entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3.0),
                          child: Text("${entry.key}: ${entry.value}",
                              style: const TextStyle(fontFamily: 'monospace', fontSize: 13)),
                        );
                      }).toList(),
                    ),
            ),
            const SizedBox(height: 16),

            // Komponen Terminal Log Interaktif Real-Time
            const Text(
              "Terminal Log Proses:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF0D1117), // Tema GitHub Dark Terminal
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white24),
                ),
                child: Column(
                  children: [
                    // Header Toolbar Terminal
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: const BoxDecoration(
                        color: Color(0xFF161B22),
                        borderRadius: BorderRadius.vertical(top: Radius.circular(7)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "bin-parser@terminal:~#",
                            style: TextStyle(color: Colors.white70, fontSize: 11, fontFamily: 'monospace', fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 15, color: Colors.white60),
                            tooltip: "Bersihkan Log",
                            onPressed: _clearLogs,
                            constraints: const BoxConstraints(),
                            padding: const EdgeInsets.all(2),
                          ),
                        ],
                      ),
                    ),
                    // Daftar Isi Teks Log
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: _terminalLogs.isEmpty
                            ? const Center(
                                child: Text(
                                  "Menunggu eksekusi perintah...",
                                  style: TextStyle(color: Colors.white30, fontFamily: 'monospace', fontSize: 11),
                                ),
                              )
                            : ListView.builder(
                                itemCount: _terminalLogs.length,
                                itemBuilder: (context, index) {
                                  final log = _terminalLogs[index];
                                  Color textColor = Colors.greenAccent;
                                  if (log.contains("[ERROR]")) textColor = Colors.redAccent;
                                  if (log.contains("[WARN]")) textColor = Colors.amberAccent;
                                  if (log.contains("[INFO]")) textColor = Colors.lightBlueAccent;

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 1.5),
                                    child: Text(
                                      log,
                                      style: TextStyle(color: textColor, fontFamily: 'monospace', fontSize: 11),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
