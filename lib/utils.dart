import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

class CustomButton extends StatefulWidget {
  const CustomButton(
      {super.key,
      required this.title,
      required this.icon,
      required this.onPressed});

  @override
  State<CustomButton> createState() => _CustomButtonState();

  final String title;
  final IconData icon;
  final VoidCallback onPressed;
}

class _CustomButtonState extends State<CustomButton> {
  bool pressed = false;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      height: 150,
      child: Styled.widget(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            widget.icon,
            color:
                Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(.8),
            size: 50,
          ),
          Text(widget.title)
        ],
      )
              .elevation(.1)
              .ripple()
              .gestures(
                onTapChange: (tapStatus) => setState(() => pressed = tapStatus),
                onTap: () {
                  widget.onPressed();
                },
              )
              .clipRRect(all: 15)
              .scale(all: pressed ? 0.95 : 1.0, animate: true)
              .animate(const Duration(milliseconds: 150), Curves.easeOut)),
    );
  }
}
