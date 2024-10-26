import 'package:flutter/material.dart';
import 'dart:async'; // Import for Timer.
import 'package:audioplayers/audioplayers.dart';



class AlarmHomePage extends StatefulWidget {
  const AlarmHomePage({Key? key}) : super(key: key); // Added 'key' parameter.
   
  @override
  State<AlarmHomePage> createState() => _AlarmHomePageState();
}

class _AlarmHomePageState extends State<AlarmHomePage> {
  Timer? _alarmTimer;
  final AudioPlayer _audioPlayer = AudioPlayer(); // Initialize AudioPlayer.
  TimeOfDay? _selectedTime;
  bool _isAlarmSet = false;
  bool _isAlarmRinging = false;

  void _startAlarm() {
    if (_selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a time.')),
      );
      return;
    }

    final now = DateTime.now();
    final alarmTime = DateTime(now.year, now.month, now.day, _selectedTime!.hour, _selectedTime!.minute);
    final durationToAlarm = alarmTime.difference(now);

    if (durationToAlarm.isNegative) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selected time is in the past.')),
      );
      return;
    }

    _alarmTimer = Timer(durationToAlarm, () {
      _isAlarmRinging = true;
      _audioPlayer.play(AssetSource('assets/sound/alarm_sound.mp3')); // Corrected usage of AssetSource.
      setState(() {});
    });

    setState(() {
      _isAlarmSet = true;
    });
  }

  void _stopAlarm() {
    _alarmTimer?.cancel();
    _audioPlayer.stop();
    setState(() {
      _isAlarmSet = false;
      _isAlarmRinging = false;
    });
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  @override
  void dispose() {
    _alarmTimer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(' ALARM'), // Added const for performance.
      ),
      body: Container(
        color: const Color.fromARGB(255, 244, 240, 245),
        child: Center(
          child: Column(
            
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                _selectedTime == null
                    ? 'No alarm set'
                    : 'Alarm set for: ${_selectedTime!.format(context)}',
                style: const TextStyle(fontSize: 24),
              ),
              
              const SizedBox(height: 20),
              if (_isAlarmRinging)
                const Text('Alarm is ringing!', style: TextStyle(color: Colors.red, fontSize: 24)),
        
               
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _selectTime(context),
                child: const Text('Select Time'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _isAlarmSet ? _stopAlarm : _startAlarm,
                child: Text(_isAlarmSet ? 'Stop Alarm' : 'Start Alarm'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
