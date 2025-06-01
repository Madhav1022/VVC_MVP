import 'package:flutter/material.dart';

showMsg(BuildContext context, String msg) =>
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));


Future<void> logLatency(String operation, int durationMs, {String? source}) async {
  final timestamp = DateTime.now().toIso8601String();
  final logMessage = '[$timestamp] $operation (Source: ${source ?? 'Unknown'}) took $durationMs ms';

  // Log to console
  print(logMessage);
}