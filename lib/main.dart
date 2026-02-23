import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rocket Launch Controller',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CounterWidget(),
    );
  }
}

class CounterWidget extends StatefulWidget {
  @override
  _CounterWidgetState createState() => _CounterWidgetState();
}

class _CounterWidgetState extends State<CounterWidget> {
  int _counter = 0;

  static const int _maxFuel = 100;
  static const int _minFuel = 0;

  // Bonus: prevents dialog spam while staying at 100
  bool _dialogShownAt100 = false;

  void _maybeShowLiftoffDialog() {
    if (_counter == _maxFuel && !_dialogShownAt100) {
      _dialogShownAt100 = true;

      // Show after the frame to avoid build/setState conflicts
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('🚀 LIFTOFF!'),
            content: const Text('Launch Successful — fuel reached 100.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      });
    }
  }

  void _ignite() {
    setState(() {
      if (_counter < _maxFuel) {
        _counter++;
      }
      if (_counter != _maxFuel) {
        _dialogShownAt100 = false; // allow later if we move away (safety)
      }
    });
    _maybeShowLiftoffDialog();
  }

  void _decrement() {
    setState(() {
      if (_counter > _minFuel) {
        _counter--;
      }
      if (_counter != _maxFuel) {
        _dialogShownAt100 = false; // allow dialog again next time we hit 100
      }
    });
  }

  void _reset() {
    setState(() {
      _counter = 0;
      _dialogShownAt100 = false;
    });
  }

  Color _statusColor() {
    if (_counter == 0) return Colors.red;
    if (_counter <= 50) return Colors.orange;
    return Colors.green;
  }

  void _setFromSlider(double value) {
    setState(() {
      _counter = value.toInt().clamp(_minFuel, _maxFuel);
      if (_counter != _maxFuel) {
        _dialogShownAt100 = false; // if user slides away, re-arm dialog
      }
    });
    _maybeShowLiftoffDialog();
  }

  @override
  Widget build(BuildContext context) {
    final Color status = _statusColor();
    final bool isLiftoff = _counter == _maxFuel;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rocket Launch Controller'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Container(
              color: status,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 22),
              child: Text(
                isLiftoff ? 'LIFTOFF!' : '$_counter',
                style: const TextStyle(fontSize: 50.0, color: Colors.white),
              ),
            ),
          ),
          Slider(
            min: 0,
            max: 100,
            value: _counter.toDouble(),
            onChanged: _setFromSlider,
            activeColor: Colors.blue,
            inactiveColor: Colors.red,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _ignite,
                child: const Text('Ignite'),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _decrement,
                child: const Text('Decrement'),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _reset,
                child: const Text('Reset'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}