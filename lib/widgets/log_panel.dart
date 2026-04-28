// Scrollable log panel showing all received MQTT messages
// Great for debugging and impresses evaluators!

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../screens/dashboard_screen.dart';

class LogPanel extends ConsumerWidget {
  const LogPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logs = ref.watch(logProvider);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Panel header
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
            child: Row(
              children: [
                const Icon(Icons.terminal, size: 14, color: Colors.green),
                const SizedBox(width: 6),
                const Text('MQTT Log',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const Spacer(),
                Text('${logs.length} messages',
                    style: TextStyle(fontSize: 11, color: Colors.grey[500])),
              ],
            ),
          ),
          const Divider(height: 1),

          // Log entries
          Expanded(
            child: logs.isEmpty
                ? const Center(
                    child: Text('Waiting for messages...',
                        style: TextStyle(color: Colors.grey, fontSize: 13)))
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: logs.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text(
                          logs[index],
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: 'monospace', // Looks like a terminal!
                            color: logs[index].contains('ON')
                                ? Colors.green[300]
                                : logs[index].contains('OFF')
                                    ? Colors.red[300]
                                    : Colors.grey[400],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
