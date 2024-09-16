import 'package:flutter/material.dart';

class AnimatedTabWidget extends StatefulWidget {
  final List<String> tabs;
  final List<Widget Function()> tabContentBuilders;
  final Function(int) onTabSelected;
  final int initialIndex;

  const AnimatedTabWidget({
    super.key,
    required this.tabs,
    required this.tabContentBuilders,
    required this.onTabSelected,
    this.initialIndex = 0,
  });

  @override
  AnimatedTabWidgetState createState() => AnimatedTabWidgetState();
}

class AnimatedTabWidgetState extends State<AnimatedTabWidget> {
  late int _selectedIndex;
  late PageController _pageController;
  late ScrollController _scrollController;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _selectedIndex);
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedTab(_selectedIndex);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void onTabPressed(int index) {
    if (_isAnimating) return;
    _isAnimating = true;
    setState(() {
      _selectedIndex = index;
    });
    _pageController
        .animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    )
        .then((_) {
      _isAnimating = false;
    });
    _scrollToSelectedTab(index);
    widget.onTabSelected(index);
  }

  void _scrollToSelectedTab(int index) {
    if (_scrollController.hasClients) {
      final RenderBox renderBox = context.findRenderObject() as RenderBox;
      final double tabWidth = renderBox.size.width / widget.tabs.length;
      const double tabPadding = 8.0;
      final double offset = index * (tabWidth + tabPadding);

      // final double screenWidth = renderBox.size.width;
      final double maxOffset = _scrollController.position.maxScrollExtent;
      final double adjustedOffset = offset.clamp(0, maxOffset);

      _scrollController.animateTo(
        adjustedOffset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 50,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            controller: _scrollController,
            child: Row(
              children: List.generate(widget.tabs.length, (index) {
                bool isSelected = index == _selectedIndex;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: GestureDetector(
                    onTap: () => onTabPressed(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.primaries[index % Colors.primaries.length]
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: Colors.primaries[
                                          index % Colors.primaries.length]
                                      .withOpacity(0.5),
                                  spreadRadius: 2,
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : [],
                      ),
                      child: Text(
                        widget.tabs[index],
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              if (!_isAnimating) {
                setState(() {
                  _selectedIndex = index;
                });
                _scrollToSelectedTab(index);
                widget.onTabSelected(index);
              }
            },
            children:
                widget.tabContentBuilders.map((builder) => builder()).toList(),
          ),
        ),
      ],
    );
  }
}
