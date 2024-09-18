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
  List<GlobalKey> _tabKeys = [];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _selectedIndex);
    _scrollController = ScrollController();
    _tabKeys = List.generate(widget.tabs.length, (_) => GlobalKey());
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
      final RenderBox? renderBox =
          _tabKeys[index].currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        final scrollbarWidth = _scrollController.position.viewportDimension;
        final tabWidth = renderBox.size.width;

        // Calculate the target scroll position to center the tab
        double targetScroll = _scrollController.position.pixels +
            renderBox.localToGlobal(Offset.zero).dx +
            (tabWidth / 2) -
            (scrollbarWidth / 2);

        // Ensure the target scroll position is within bounds
        targetScroll = targetScroll.clamp(
          0.0,
          _scrollController.position.maxScrollExtent,
        );

        _scrollController.animateTo(
          targetScroll,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
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
                  key: _tabKeys[index],
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
