import 'package:flutter/material.dart';

class TerminalLogWidget extends StatefulWidget {
  final List<String> logs;
  final VoidCallback onClear;
  final bool isRunning;

  const TerminalLogWidget({
    super.key,
    required this.logs,
    required this.onClear,
    this.isRunning = false,
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
            duration: const Duration(milliseconds: 150),
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
        color: const Color(0xFF0D1117), // GitHub Dark Terminal Theme
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Terminal Header Toolbar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(
              color: Color(0xFF161B22),
              borderRadius: BorderRadius.vertical(top: Radius.circular(11)),
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
                    if (widget.isRunning) ...[
                      const SizedBox(width: 10),
                      const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.greenAccent),
                      ),
                    ],
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
          // Terminal Output Stream Area
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: widget.logs.isEmpty
                  ? const Center(
                      child: Text(
                        "Menunggu berkas biner dimuat untuk dianalisis...",
                        style: TextStyle(color: Colors.white30, fontFamily: 'monospace', fontSize: 12),
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      itemCount: widget.logs.length,
                      itemBuilder: (context, index) {
                        final log = widget.logs[index];
                        Color textColor = Colors.greenAccent;
                        if (log.contains("[ERROR]")) textColor = Colors.redAccent;
                        if (log.contains("[WARN]")) textColor = Colors.amberAccent;
                        if (log.contains("[INFO]")) textColor = Colors.lightBlueAccent;
                        if (log.contains("[SUCCESS]")) textColor = Colors.greenAccent;

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.5),
                          child: Text(
                            log,
                            style: TextStyle(color: textColor, fontFamily: 'monospace', fontSize: 12, height: 1.3),
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
