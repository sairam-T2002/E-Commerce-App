import 'dart:async';
import 'package:flutter/material.dart';

class AutoSlideshow extends StatefulWidget {
  final List<Widget> children;
  final Duration interval;

  const AutoSlideshow({
    super.key,
    required this.children,
    this.interval = const Duration(seconds: 3),
  });

  @override
  AutoSlideshowState createState() => AutoSlideshowState();
}

class AutoSlideshowState extends State<AutoSlideshow> {
  late PageController _pageController;
  late Timer _timer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(widget.interval, (timer) {
      _nextPage();
    });
  }

  void _nextPage() {
    if (_currentPage < widget.children.length - 1) {
      _currentPage++;
    } else {
      _currentPage = 0;
    }
    _pageController.animateToPage(
      _currentPage,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeIn,
    );
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _currentPage--;
    } else {
      _currentPage = widget.children.length - 1;
    }
    _pageController.animateToPage(
      _currentPage,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeIn,
    );
  }

  void _resetTimer() {
    _timer.cancel();
    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _resetTimer(),
      onLongPressStart: (_) => _resetTimer(),
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity == null) return;

        if (details.primaryVelocity! < 0) {
          // User swiped left to go to the next slide
          _nextPage();
        } else if (details.primaryVelocity! > 0) {
          // User swiped right to go to the previous slide
          _previousPage();
        }
        _resetTimer();
      },
      child: PageView(
        controller: _pageController,
        children: widget.children,
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
          _resetTimer();
        },
      ),
    );
  }
}
