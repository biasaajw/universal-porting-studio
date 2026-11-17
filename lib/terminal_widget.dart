import 'dart:async';
import 'package:flutter/material.dart';

class TerminalLogWidget extends StatefulWidget {
  final List<String> logs;
  final VoidCallback onClear;

  const TerminalLogWidget({
    super.key,
    required this.logs,
    required this.onClear,
  });

  @override
  State<TerminalLogWidget> createState() => _TerminalLogWidgetState();
}

class _TerminalLogWidgetState extends State<TerminalLogWidget> {
  final ScrollController _scrollController = ScrollController();
  bool _autoScroll = true;

  @override
  void didUpdateWidget(covariant TerminalLogWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_autoScroll && widget.logs.length != oldWidget.logs.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0D1117), // GitHub Dark Terminal style
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white24, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Terminal Toolbar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(
              color: Color(0xFF161B22),
              borderRadius: BorderRadius.vertical(top: Radius.circular(9)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(width: 10, height: 10, decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    Container(width: 10, height: 10, decoration: const BoxDecoration(color: Colors.amber, shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    Container(width: 10, height: 10, decoration: const BoxDecoration(color: Colors.greenAccent, shape: BoxShape.circle)),
                    const SizedBox(width: 12),
                    const Text(
                      "bin-parser@terminal:~#",
                      style: TextStyle(color: Colors.white70, fontSize: 12, fontFamily: 'monospace', fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 16, color: Colors.white60),
                      tooltip: "Bersihkan Log",
                      onPressed: widget.onClear,
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(4),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Area Konten Log
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: widget.logs.isEmpty
                  dataStream:
                  ? const Center(
                      child: Text(
                        "Menunggu proses eksekusi biner...",
                        style: TextStyle(color: Colors.white30, fontFamily: 'monospace', fontSize: 12),
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      itemCount: widget.logs.length,
                      itemBuilder: (context, index) {
                        final log = widget.logs[index];
                        Color textColor = Colors.greenAccent;
                        if (log.startsWith("[ERROR]")) textColor = Colors.redAccent;
                        if (log.startsWith("[WARN]")) textColor = Colors.amberAccent;
                        if (log.startsWith("[INFO]")) textColor = Colors.lightBlueAccent;

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.0),
                          child: Text(
                            log,
                            style: TextStyle(color: textColor, fontFamily: 'monospace', fontSize: 12),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
