import 'package:flutter/material.dart';

class CircularStepIndicator extends StatelessWidget {
  final int totalSteps;
  final int currentStep;
  final Color activeColor;
  final Color inactiveColor;

  const CircularStepIndicator({
    super.key,
    required this.totalSteps,
    required this.currentStep,
    this.activeColor = Colors.blue,
    this.inactiveColor = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalSteps, (index) {
        final stepNumber = index + 1;
        final isActive = stepNumber <= currentStep;
        final isCurrent = stepNumber == currentStep;

        return Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    isActive
                        ? activeColor
                        : inactiveColor.withValues(alpha: 0.3),
                border: Border.all(
                  color: isCurrent ? activeColor : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  stepNumber.toString(),
                  style: TextStyle(
                    color: isActive ? Colors.white : inactiveColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            if (index < totalSteps - 1)
              Container(
                width: 24,
                height: 2,
                color:
                    stepNumber < currentStep
                        ? activeColor
                        : inactiveColor.withValues(alpha: 0.3),
                margin: const EdgeInsets.symmetric(horizontal: 4),
              ),
          ],
        );
      }),
    );
  }
}
