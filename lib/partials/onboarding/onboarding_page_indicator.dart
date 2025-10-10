import 'package:flutter/material.dart';

class OnboardingPageIndicator extends StatelessWidget {
  const OnboardingPageIndicator({
    super.key,
    required this.length,
    required this.currentIndex,
  });

  final int length;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          height: 8.0,
          width: currentIndex == index ? 24.0 : 8.0,
          decoration: BoxDecoration(
            color: currentIndex == index
                ? Theme.of(context).primaryColor
                : Colors.grey.shade400,
            borderRadius: BorderRadius.circular(4.0),
          ),
        ),
      ),
    );
  }
}
