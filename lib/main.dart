import 'dart:async';

import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      title: 'Totem Timer',
      home: HomePageView(),
    );
  }
}

class HomePageView extends StatefulWidget {
  HomePageView({
    super.key,
  });

  @override
  State<HomePageView> createState() => _HomePageViewState();
}

class _HomePageViewState extends State<HomePageView> {
  double _cafe = 20;
  double _agua = 300;
  double _ratio = 15;

  final cafeController = TextEditingController.fromValue(TextEditingValue(text: '20'));
  final aguaController = TextEditingController.fromValue(TextEditingValue(text: '300'));
  final ratioController = TextEditingController.fromValue(TextEditingValue(text: '15'));

  void _actualizarCampos() {
    double cafe, agua, ratio;
    try {
      cafe = double.parse(cafeController.text);
      agua = double.parse(aguaController.text);
      ratio = double.parse(ratioController.text);
    } on FormatException {
      return;
    }
    setState(() {
      if (cafe != _cafe) {
        _cafe = cafe;
        _agua = _cafe * _ratio;
        aguaController.text = _agua.toString();
      } else if (agua != _agua) {
        _agua = agua;
        _cafe = _agua / _ratio;
        cafeController.text = _cafe.toString();
      } else if (ratio != _ratio) {
        _ratio = ratio;
        _agua = _cafe * _ratio;
        aguaController.text = _agua.toString();
      }
    });
  }

@override
void initState() {
  super.initState();

  cafeController.addListener(_actualizarCampos);
  aguaController.addListener(_actualizarCampos);
  ratioController.addListener(_actualizarCampos);
}

  @override
  void dispose() {
    cafeController.dispose();
    aguaController.dispose();
    ratioController.dispose();
    super.dispose();
  }

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Totem Timer', style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        childAspectRatio: 1.5,
        children: <Widget>[
          PanelWidget(
            titulo: 'Café (g)',
            controlador: cafeController,
          ),
          PanelWidget(
            titulo: 'Agua (ml)',
            controlador: aguaController,
          ),
          PanelWidget(
            titulo: 'Ratio (1:)',
            controlador: ratioController,
          ),
          TimerWidget(),
        ],
      ),
    );
  }
}

class PanelWidget extends StatelessWidget {
  PanelWidget({
    super.key, required this.titulo, required this.controlador,
  });

  final String titulo;
  final TextEditingController controlador;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Center(
        child: TextField(
          controller: controlador,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: titulo,
            labelStyle: TextStyle(fontSize: 24),
          ),
          /*inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
              ],*/
          keyboardType: TextInputType.number,
          onTap: () => controlador.selection = TextSelection(baseOffset: 0, extentOffset: controlador.value.text.length),
          style:TextStyle(fontSize: 24),
        ),
      )
    );
  }
}

class TimerWidget extends StatefulWidget {
  const TimerWidget({
    super.key,
  });

  @override
  State<TimerWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> {
  final Stopwatch _stopwatch = Stopwatch();
  late Duration _elapsedTime;
  late String _elapsedTimeString;
  late Timer timer;

  @override
  void initState() {
    super.initState();

    _elapsedTime = Duration.zero;
    _elapsedTimeString = _formatElapsedTime(_elapsedTime);

    timer = Timer.periodic(const Duration(milliseconds: 100), (Timer timer) {
      setState(() {
        if (_stopwatch.isRunning) {
          _updateElapsedTime();
        }
      });
    });
  }

  void _startStopwatch() {
    if (!_stopwatch.isRunning) {
      _stopwatch.start();
      _updateElapsedTime();
    } else {
      _stopwatch.stop();
    }
  }

  void _resetStopwatch() {
    _stopwatch.reset();
    _updateElapsedTime();
  }

  void _updateElapsedTime() {
    setState(() {
      _elapsedTime = _stopwatch.elapsed;
      _elapsedTimeString = _formatElapsedTime(_elapsedTime);
    });
  }

  String _formatElapsedTime(Duration time) {
    return '${time.inMinutes.remainder(60).toString().padLeft(2, '0')}:${(time.inSeconds.remainder(60)).toString().padLeft(2, '0')}.${(time.inMilliseconds % 1000 ~/ 100).toString()}';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _elapsedTimeString,
          style: TextStyle(fontSize: 32),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _startStopwatch, 
              child: Text(_stopwatch.isRunning ? 'Stop' : 'Start'),
            ),
            SizedBox(width: 8),
            ElevatedButton(
              onPressed: _resetStopwatch,
              child: Text('Reset'),
            ),
          ],
        )
      ]
    );
  }
}