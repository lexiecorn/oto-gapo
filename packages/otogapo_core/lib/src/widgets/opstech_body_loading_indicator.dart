import 'package:flutter/material.dart';

///
class BodyLoadingIndicator extends StatelessWidget {
  ///
  const BodyLoadingIndicator({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 50,
          height: 50,
          child: CircularProgressIndicator.adaptive(
            strokeWidth: 3,
            backgroundColor: Colors.amber,
          ),
        ),
      ],
    );
  }
}
