import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(TemperatureConverterApp());
}

class TemperatureConverterApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Temperature Converter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TemperatureConverterScreen(),
    );
  }
}

class TemperatureConverterScreen extends StatefulWidget {
  @override
  _TemperatureConverterScreenState createState() => _TemperatureConverterScreenState();
}

class _TemperatureConverterScreenState extends State<TemperatureConverterScreen> {
  final TextEditingController _controller = TextEditingController();
  String _result = "";
  List<String> _lastConversions = [];
  bool _isCelsius = true;

  @override
  void initState() {
    super.initState();
    _loadLastConversions();
  }

  // Load the last 5 conversions from SharedPreferences
  _loadLastConversions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _lastConversions = prefs.getStringList('lastConversions') ?? [];
    });
  }

  // Save the last 5 conversions to SharedPreferences
  _saveLastConversions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('lastConversions', _lastConversions);
  }

  // Convert temperature
  void _convertTemperature() {
    double input = double.tryParse(_controller.text) ?? 0;
    String convertedValue;

    if (_isCelsius) {
      double fahrenheit = (input * 9 / 5) + 32;
      convertedValue = "$input °C = ${fahrenheit.toStringAsFixed(2)} °F";
    } else {
      double celsius = (input - 32) * 5 / 9;
      convertedValue = "$input °F = ${celsius.toStringAsFixed(2)} °C";
    }

    setState(() {
      _result = convertedValue;
      _lastConversions.insert(0, convertedValue); // Add the new conversion to the top of the list
      if (_lastConversions.length > 5) {
        _lastConversions.removeLast(); // Remove the oldest conversion if there are more than 5
      }
      _saveLastConversions(); // Save the updated list to SharedPreferences
    });
  }

  // Toggle between Celsius and Fahrenheit
  void _toggleConversion() {
    setState(() {
      _isCelsius = !_isCelsius;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Temperature Converter'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Enter temperature in ${_isCelsius ? 'Celsius' : 'Fahrenheit'}',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _convertTemperature,
              child: Text('Convert'),
            ),
            SizedBox(height: 16),
            Text(
              _result,
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _toggleConversion,
              child: Text('Switch to ${_isCelsius ? 'Fahrenheit to Celsius' : 'Celsius to Fahrenheit'}'),
            ),
            SizedBox(height: 16),
            Divider(),
            Text(
              'Last 5 Conversions:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: _lastConversions.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      _lastConversions[index],
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
