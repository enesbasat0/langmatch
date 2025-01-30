import 'dart:async';
import 'package:flutter/material.dart';

class MatchAcceptanceDialog extends StatefulWidget {
  final Function() onAccept;
  final Function() onReject;

  const MatchAcceptanceDialog({
    Key? key,
    required this.onAccept,
    required this.onReject,
  }) : super(key: key);

  @override
  State<MatchAcceptanceDialog> createState() => _MatchAcceptanceDialogState();
}

class _MatchAcceptanceDialogState extends State<MatchAcceptanceDialog> {
  int _remainingSeconds = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _timer?.cancel();
          Navigator.of(context).pop();
          widget.onReject();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Eşleşme Bulundu!'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Bir konuşma arkadaşı bulundu.'),
          SizedBox(height: 10),
          Text(
            '$_remainingSeconds saniye içinde kabul etmelisiniz',
            style: TextStyle(color: Colors.orange),
          ),
          SizedBox(height: 20),
          LinearProgressIndicator(
            value: _remainingSeconds / 30,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              _remainingSeconds > 10 ? Colors.green : Colors.orange,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            _timer?.cancel();
            Navigator.of(context).pop();
            widget.onReject();
          },
          child: Text('Reddet'),
          style: TextButton.styleFrom(foregroundColor: Colors.red),
        ),
        ElevatedButton(
          onPressed: () {
            _timer?.cancel();
            Navigator.of(context).pop();
            widget.onAccept();
          },
          child: Text('Kabul Et'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
        ),
      ],
    );
  }
} 