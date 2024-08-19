import 'package:flutter/material.dart';

class MediaController extends StatefulWidget {
  final void Function()? action;
  final IconData icon;
  final double? size;
  final Color? color;

  const MediaController({
    super.key,
    required this.action,
    required this.icon,
    required this.color,
    required this.size,
  });

  @override
  State<MediaController> createState() => _MediaControllerState();
}

class _MediaControllerState extends State<MediaController> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: widget.action,
      icon: Icon(widget.icon),
      iconSize: widget.size,
      color: widget.color ?? Theme.of(context).colorScheme.primary,
    );
  }
}
