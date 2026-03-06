import 'package:flutter/material.dart';

class Pipe extends StatefulWidget {
  final int gapPosition;
  final int gapMargin;
  final double width;

  const Pipe({
    super.key,
    this.gapPosition = 50,
    this.gapMargin = 20,
    this.width = 50,
  });

  @override
  State<Pipe> createState() => _PipeState();
}

class _PipeState extends State<Pipe> {
  @override
  Widget build(BuildContext context) {
    double topPipeFlex = widget.gapPosition - widget.gapMargin / 2;

    double bottomPipeFlex = (100 - widget.gapPosition) - widget.gapMargin / 2;

    int middlePipeFlex = widget.gapMargin;

    if (topPipeFlex - topPipeFlex.truncate() != 0 ||
        bottomPipeFlex - bottomPipeFlex.truncate() != 0) {
      topPipeFlex = topPipeFlex * 2;
      bottomPipeFlex = bottomPipeFlex * 2;
      middlePipeFlex = middlePipeFlex * 2;
    }

    return Column(
      children: [
        Expanded(
          flex: topPipeFlex.toInt(),
          child: Container(width: widget.width, color: Colors.green),
        ),
        Expanded(
          flex: middlePipeFlex,
          child: Container(width: widget.width),
        ),
        Expanded(
          flex: bottomPipeFlex.toInt(),
          child: Container(width: widget.width, color: Colors.green),
        ),
      ],
    );
  }
}
