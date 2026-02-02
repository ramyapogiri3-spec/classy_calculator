import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart'; // Add this to pubspec.yaml

void main() => runApp(const PreciseCalculator());

class PreciseCalculator extends StatelessWidget {
  const PreciseCalculator({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: const Color(0xFF121212)),
      home: const CalculatorHome(),
    );
  }
}

class CalculatorHome extends StatefulWidget {
  const CalculatorHome({super.key});

  @override
  _CalculatorHomeState createState() => _CalculatorHomeState();
}

class _CalculatorHomeState extends State<CalculatorHome> {
  String _input = "";      // What the user is typing
  String _output = "";     // The final answer
  bool _isCalculated = false; // Tracks if "=" was pressed

  void _onPressed(String text) {
    setState(() {
      if (text == "C") {
        _input = "";
        _output = "";
        _isCalculated = false;
      } else if (text == "⌫") {
        if (_input.isNotEmpty) _input = _input.substring(0, _input.length - 1);
        _isCalculated = false;
      } else if (text == "=") {
        _calculateResult();
        _isCalculated = true;
      } else {
        // If they start typing after a calculation, reset or append
        if (_isCalculated) {
          _isCalculated = false;
          _input = _output + text; // Continue from last answer
        } else {
          _input += text;
        }
      }
    });
  }

  void _calculateResult() {
    try {
      String finalInput = _input.replaceAll('×', '*').replaceAll('÷', '/');
      Parser p = Parser();
      Expression exp = p.parse(finalInput);
      ContextModel cm = ContextModel();
      double eval = exp.evaluate(EvaluationType.REAL, cm);
      _output = eval.toString().endsWith('.0') ? eval.toInt().toString() : eval.toString();
    } catch (e) {
      _output = "Error";
    }
  }

  // Dynamic sizing logic
  double _getFontSize(String text, bool isHero) {
    if (!isHero) return 24.0; // Small size for background
    if (text.length < 8) return 70.0;
    if (text.length < 12) return 50.0;
    return 35.0; // Shrinks for long input
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(32),
              alignment: Alignment.bottomRight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // UPPER LINE (Smaller)
                  // Shows input after calculation, or empty while typing
                  Text(
                    _isCalculated ? _input : "",
                    style: TextStyle(fontSize: _getFontSize(_input, false), color: Colors.white38),
                  ),
                  const SizedBox(height: 10),
                  // MAIN HERO LINE (Large)
                  // Shows input while typing, shows output after "="
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    reverse: true,
                    child: Text(
                      _isCalculated ? _output : _input,
                      style: TextStyle(
                        fontSize: _getFontSize(_isCalculated ? _output : _input, true),
                        color: Colors.white,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // KEYPAD
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                children: [
                  _buildRow(["C", "±", "⌫", "÷"]),
                  _buildRow(["7", "8", "9", "×"]),
                  _buildRow(["4", "5", "6", "-"]),
                  _buildRow(["1", "2", "3", "+"]),
                  _buildRow(["0", ".", "="]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(List<String> labels) {
    return Expanded(
      child: Row(
        children: labels.map((label) => _buildButton(label)).toList(),
      ),
    );
  }

  Widget _buildButton(String label) {
    bool isOp = ["÷", "×", "-", "+", "="].contains(label);
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: InkWell(
          onTap: () => _onPressed(label),
          borderRadius: BorderRadius.circular(50),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: label == "=" ? Colors.orange[800] : const Color(0xFF1F1F1F),
            ),
            child: Center(
              child: Text(
                label,
                style: TextStyle(fontSize: 26, color: isOp && label != "=" ? Colors.orangeAccent : Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }
}