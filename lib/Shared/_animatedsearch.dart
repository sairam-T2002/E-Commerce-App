import 'package:flutter/material.dart';
import 'dart:async';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class AnimatedSearchBar extends StatefulWidget {
  final double width;
  final Function(String) onSearch;
  final List<String>? hints;
  final MaterialColor? accent;

  const AnimatedSearchBar({
    super.key,
    required this.width,
    required this.onSearch,
    this.hints,
    this.accent,
  });

  @override
  AnimatedSearchBarState createState() => AnimatedSearchBarState();
}

class AnimatedSearchBarState extends State<AnimatedSearchBar>
    with SingleTickerProviderStateMixin {
  List<String> _hintTexts = [
    'Search',
    'Find products',
    'Explore categories',
    'Discover deals'
  ];
  int _currentHintIndex = 0;
  late Timer _timer;
  late TextEditingController _controller;
  late AnimationController _animationController;
  late Animation<Offset> _offsetAnimation;

  // Speech to text
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    if (widget.hints != null) {
      setState(() {
        _hintTexts = widget.hints ?? _hintTexts;
      });
    }

    _controller = TextEditingController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, -1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_controller.text.isEmpty) {
        setState(() {
          _currentHintIndex = (_currentHintIndex + 1) % _hintTexts.length;
          _animationController.forward(from: 0.0);
        });
      }
    });

    // Initialize speech recognition
    // _initSpeech();
  }

  @override
  void dispose() {
    _timer.cancel();
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // Initialize speech recognition
  void _initSpeech() async {
    bool available = await _speech.initialize(
      onStatus: (status) => print('onStatus: $status'),
      onError: (errorNotification) => print('onError: $errorNotification'),
    );
    if (!available) {
      print("The user has denied the use of speech recognition.");
    }
  }

  // Listen for speech input
  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (result) {
            setState(() {
              _controller.text = result.recognizedWords;
              widget.onSearch(_controller.text);
            });
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    Color accent = widget.accent ?? const Color.fromARGB(255, 243, 65, 33);
    return Container(
      width: widget.width,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: Colors.white,
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 2.0,
            spreadRadius: 0.0,
            offset: Offset(2.0, 2.0),
          )
        ],
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Icon(
              Icons.search_sharp,
              color: accent,
            ),
          ),
          Expanded(
            child: ClipRect(
              child: Stack(
                children: [
                  AnimatedOpacity(
                    opacity: _controller.text.isEmpty ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: SlideTransition(
                      position: _offsetAnimation,
                      child: Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _hintTexts[_currentHintIndex],
                          key: ValueKey<int>(_currentHintIndex),
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                      ),
                    ),
                  ),
                  TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    onChanged: (value) {
                      setState(() {});
                      widget.onSearch(value);
                    },
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: 1,
            height: 30,
            color: Colors.grey[350],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: GestureDetector(
              onTap: _listen,
              child: Icon(
                _isListening ? Icons.mic : Icons.mic_none_outlined,
                color: _isListening ? Colors.red : accent,
              ),
            ),
          )
        ],
      ),
    );
  }
}
