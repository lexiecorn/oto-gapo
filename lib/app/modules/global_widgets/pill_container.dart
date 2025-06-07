import 'package:flutter/widgets.dart';
import 'package:otogapo_core/otogapo_core.dart';

class PillContainer extends StatelessWidget {
  const PillContainer({
    required this.txt,
    this.txtColor,
    this.bgColor,
    super.key,
  });

  final Color? bgColor;
  final Color? txtColor;
  final String txt;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: bgColor ?? OpstechColors.grey300,
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Text(
          txt,
          style: OpstechTextTheme.regular.copyWith(
            color: txtColor ?? OpstechColors.grey600,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
