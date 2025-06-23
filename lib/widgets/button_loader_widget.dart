import 'dart:ui';
import 'package:flutter/material.dart';

class ButtonLoader extends StatefulWidget {
  final Widget childTitle;
  final Color loaderColor;
  final VoidCallback? onPressed;
  final double? width;
  final double? height;
  final Color? background;
  final Color? borderColor;
  final double? elevation;
  final double? widthBorder;
  const ButtonLoader({
    super.key,
    required this.childTitle,
    required this.loaderColor,
    this.onPressed,
    this.width,
    this.height,
    this.background,
    this.borderColor,
    this.elevation = 0.0,
    this.widthBorder = 1,
  });
  @override
  State<ButtonLoader> createState() => ButtonLoaderState();
}

class ButtonLoaderState extends State<ButtonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isLoading = false;
  // @override
  // void deactivate() {
  //   Form.maybeOf(context)?.deactivate();
  //   super.deactivate();
  // }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  // void _unregister(ButtonLoaderState field) {
  //   _fields.remove(field);
  // }
  void startLoading() {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });
    _controller.repeat();
    widget.onPressed?.call();
  }

  void stopLoading() {
    if (!_isLoading) return;
    setState(() {
      _isLoading = false;
    });
    _controller.stop();
    _controller.reset();
  }

  @override
  Widget build(BuildContext context) {
    Color? borderColor = widget.borderColor;
    double elevation = widget.elevation!;
    if (widget.background != null) {
      borderColor = widget.background;
      elevation = 0.0;
    }
    return GestureDetector(
      onTap: _isLoading ? null : startLoading,
      child: Center(
        child: SizedBox(
          width: widget.width ?? MediaQuery.of(context).size.width * 0.5,
          height: widget.height ?? 50,
          child: Material(
            color: widget.background ?? Theme.of(context).primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(
                color: widget.elevation == 0.0
                    ? _isLoading
                        ? widget.loaderColor.withOpacity(0)
                        : borderColor ?? Theme.of(context).primaryColor
                    : widget.loaderColor.withOpacity(0),
                width: widget.widthBorder ?? 1,
              ),
            ),
            elevation: elevation,
            child: Stack(
              children: [
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (BuildContext context, Widget? child) {
                      return CustomPaint(
                        painter: BorderPainter(
                            progress: _controller.value,
                            isLoading: _isLoading,
                            colorPaint: _isLoading
                                ? widget.loaderColor
                                : Theme.of(context).primaryColor,
                            strokeWidth: _isLoading
                                ? widget.widthBorder! * 2
                                : widget.widthBorder!),
                      );
                    },
                  ),
                ),
                widget.childTitle
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class BorderPainter extends CustomPainter {
  final double progress;
  final bool isLoading;
  final Color colorPaint;
  final double strokeWidth;
  BorderPainter({
    required this.progress,
    required this.isLoading,
    required this.colorPaint,
    required this.strokeWidth,
  });
  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final Paint paint = Paint()
      ..color = colorPaint
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(10.0),
    );
    final Path path = Path()..addRRect(rrect);
    final PathMetrics pathMetrics = path.computeMetrics();
    final Path extractPath = Path();
    for (PathMetric pathMetric in pathMetrics) {
      double length = 0;
      if (isLoading) {
        length = pathMetric.length * (progress);
      } else {
        length = pathMetric.length * (1 - progress);
      }
      extractPath.addPath(pathMetric.extractPath(0, length), Offset.zero);
    }
    canvas.drawPath(extractPath, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
