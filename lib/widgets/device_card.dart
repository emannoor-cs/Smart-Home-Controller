// Visual card for each device with ON/OFF toggle

import 'package:flutter/material.dart';
import '../models/device_model.dart';

class DeviceCard extends StatelessWidget {
  final DeviceModel device;
  final VoidCallback onToggle;  // VoidCallback = function with no args, no return

  const DeviceCard({super.key, required this.device, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    // Colors change based on device state
    final activeColor = const Color(0xFF6C63FF);
    final bgColor = device.isOn
        ? activeColor.withOpacity(0.2)
        : Colors.grey.withOpacity(0.1);

    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),  // Smooth color transition
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: device.isOn ? activeColor.withOpacity(0.5) : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Icon + status indicator row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(device.icon, style: const TextStyle(fontSize: 28)),
                // Small ON/OFF badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: device.isOn ? Colors.green : Colors.grey,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    device.isOn ? 'ON' : 'OFF',
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),

            // Device name + toggle switch
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(device.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    maxLines: 2),
                const SizedBox(height: 4),
                Text(device.topic,
                    style: TextStyle(fontSize: 11, color: Colors.grey[500])),
              ],
            ),
          ],
        ),
      ),
    );
  }
}