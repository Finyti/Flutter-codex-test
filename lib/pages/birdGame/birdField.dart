import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/birdGame/bird.dart';
import 'package:flutter_application_1/pages/birdGame/pipe.dart';
import 'package:flutter_application_1/pages/birdGame/pipeData.dart';

class BirdGame extends StatefulWidget {
  const BirdGame({super.key});

  @override
  State<BirdGame> createState() => _BirdGameState();
}

/* 
#DONE 1 - implement pause
          1.1 - switch to AnimationController intead of timer
          1.2 - wire up the button 
#TODO 2 - implement pipe builder
          2.1 - Create a data representation for pipes and their hitboxes
          2.2 - implement builder
#TODO 3 - Create a collision system with player
          3.1 - Add hitbox to the player and ground
          3.2 - Create overlap check function
#TODO 4 - Create loose screen
          4.1 - create a pop up
          4.2 - Create a buttn for reset


*/
class _BirdGameState extends State<BirdGame>
    with SingleTickerProviderStateMixin {
  double screenHeight = 0;
  double screenWidth = 0;

  Rect gameField = Rect.zero;

  List<int> gameUIsizes = [4, 20, 2];

  bool pause = false;

  List<PipeData> pipeList = [];
  int baseGapSize = 30;
  double pipeBaseWidth = 50;
  double pipeBaseX = 1.4;
  double linearPipeSpeed = 0.009;
  double pipeSpawnDistance = 0.8;

  double birdY = -0.1;
  double birdX = -0.5;
  double birdRadius = 40;
  Rect birdHitbox = Rect.zero;

  // Works as a variable on x plane for quadratic graph
  double acceleration = 0;

  // (-inf -> 0) Defines jump strength speed and duration based on x^2 graph (lower bound for x)
  double lowerBound = -0.2;
  // (-inf -> 0) Defines gravity based on x^2 graph (higher bound for x)
  double higherBound = 0.16;

  late final AnimationController _controller;

  // Have no idea how exactly next two functions work
  @override
  void initState() {
    super.initState();
    _controller = AnimationController.unbounded(vsync: this)
      ..addListener(worldTick);

    _controller.repeat(
      min: -1.0,
      max: 1.0,
      period: const Duration(seconds: 1),
    ); // drives callbacks
    // _timer = Timer.periodic(const Duration(milliseconds: 16), (_) {
    //   gravityTick(); // ~60 FPS
    // });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void worldTick() {
    gravityTick();
    pipeTick();
  }

  void gravityTick() {
    // Accelerations base state is positive (down), negative is inverted gravity aka. jump (up) and is temporary
    // Clamp ensures adequate magnitude of jump and gravity
    acceleration = (acceleration + 0.01).clamp(lowerBound, higherBound);

    // Sign of acceleration gives idea of direction of movement

    if (acceleration > 0) {
      setState(() => birdY = (birdY + (pow(acceleration, 2))).clamp(-1.0, 1.0));
    } else if (birdY == -1) {
      // This one prevents sticking for a second to the top when jumping too close to it
      setState(() => acceleration = 0);
    } else {
      setState(() => birdY = (birdY - (pow(acceleration, 2))).clamp(-1.0, 1.0));
    }
    // TODO finish these fuckers
    double birdLeft = ((birdX + 1) / 2) * screenWidth;
    double birdTop = gameField.bottom - ((birdY + 1) / 2) * gameField.height;
    birdHitbox = Rect.fromLTWH(birdLeft, birdTop, birdRadius, birdRadius);
  }

  void pipeTick() {
    // TODO optimize to nor repeat code
    double flexSum = 0;
    for (var i in gameUIsizes) {
      flexSum += i;
    }
    double top = (screenHeight / flexSum) * gameUIsizes[0];
    double height = ((screenHeight / flexSum) * gameUIsizes[0]);
    gameField = Rect.fromLTWH(0, top, screenWidth, height);

    if (pipeList.isEmpty || 1.1 - pipeList.last.xCord > pipeSpawnDistance) {
      var newPipe = PipeData();
      var randGapPosition = Random().nextInt(100);
      newPipe.xCord = pipeBaseX;
      newPipe.gapPosition = randGapPosition;
      newPipe.gapSize = baseGapSize;
      newPipe.width = pipeBaseWidth;

      double newLeft = screenWidth * pipeBaseX;

      double topHeight =
          (randGapPosition - baseGapSize / 2) * (gameField.height / 100);
      // print(
      //   "${(randGapPosition - baseGapSize / 2) * gameField.height} \n ${randGapPosition - baseGapSize / 2} \n ${gameField.height} \n $screenHeight",
      // );
      double bottomHeight =
          ((100 - randGapPosition) - baseGapSize / 2) *
          (gameField.height / 100);
      double bottomTop =
          gameField.bottom -
          ((100 - randGapPosition) - baseGapSize / 2) *
              (gameField.height / 100);

      if (topHeight < 0) {
        topHeight = 0;
      }
      if (bottomHeight < 0) {
        bottomHeight = 0;
      }

      newPipe.topPipe = Rect.fromLTWH(
        newLeft,
        gameField.top,
        pipeBaseWidth,
        topHeight,
      );
      newPipe.bottomPipe = Rect.fromLTWH(
        newLeft,
        bottomTop,
        pipeBaseWidth,
        topHeight,
      );
      pipeList.add(newPipe);
    }
    if (pipeList[0].xCord < -1.6) {
      pipeList.remove(pipeList[0]);
    }

    for (var pipe in pipeList) {
      pipe.xCord -= linearPipeSpeed;
      pipe.bottomPipe = pipe.bottomPipe.translate(-linearPipeSpeed, 0);
      pipe.topPipe = pipe.topPipe.translate(-linearPipeSpeed, 0);

      print(
        "Bird: $birdHitbox BottomPipe: ${pipe.bottomPipe} TopPipe: ${pipe.topPipe}",
      );

      if (pipe.bottomPipe.overlaps(birdHitbox) ||
          pipe.topPipe.overlaps(birdHitbox)) {
        print("Hit!");
      }
    }
  }

  void birdFlap() {
    // Negative sign = inverted gravity
    if (!pause) {
      setState(() => acceleration = lowerBound);
    }
  }

  void worldPause() {
    pause = !pause;
    if (pause) {
      _controller.stop();
    } else {
      _controller.repeat(
        min: -1.0,
        max: 1.0,
        period: const Duration(seconds: 1),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      screenHeight = MediaQuery.of(context).size.height;
      screenWidth = MediaQuery.of(context).size.width;
    });
    return GestureDetector(
      onTap: birdFlap,
      child: Column(
        children: [
          Expanded(
            flex: gameUIsizes[0],
            child: Container(
              color: Colors.white,
              child: Align(
                alignment: Alignment(0.9, 0.3),
                child: FloatingActionButton(
                  onPressed: () {
                    worldPause();
                  },
                  child: const Icon(Icons.pause),
                  elevation: 0,
                  backgroundColor: Colors.blue[100],
                  mini: false,
                  isExtended: false,
                ),
              ),
            ),
          ),
          Expanded(
            flex: gameUIsizes[1],
            child: Container(
              color: Colors.blue[200],
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment(birdX, birdY),
                    child: Bird(radius: birdRadius),
                  ),
                  for (final pipe in pipeList)
                    Align(
                      alignment: Alignment(pipe.xCord, 0),
                      child: Pipe(
                        width: pipe.width,
                        gapPosition: pipe.gapPosition,
                        gapMargin: pipe.gapSize,
                      ),
                    ),
                  

                  // Align(
                  //   alignment: Alignment(1, 0),
                  //   child: Container(
                  //     width: 50,
                  //     child: Pipe(gapPosition: 50, gapMargin: 25),
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: gameUIsizes[2],
            child: Container(color: Colors.brown[400]),
          ),
        ],
      ),
    );
  }
}
