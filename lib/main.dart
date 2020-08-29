import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    bool flip = true;
    AppBar appBar = AppBar(
      leading: Builder(
        builder: (context) {
          return IconButton(
            icon: Icon(Icons.android),
            onPressed: () =>
                CustomDrawer.of(context).animationController.forward(),
          );
        },
      ),
      title: Text('Demo Flutter'),
    );
    Widget child = MyHomePage(appBar: appBar);

    child = CustomDrawer(child: child);

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: child,
    );
  }
}

class MyHomePage extends StatefulWidget {
  final AppBar appBar;

  MyHomePage({Key key, @required this.appBar}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.appBar,
      body: Center(
        child: Text(
          "Sample Data",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 30,
          ),
        ),
      ),
    );
  }
}

class CustomDrawer extends StatefulWidget {
  final Widget child;

  const CustomDrawer({Key key, @required this.child}) : super(key: key);

  static CustomDrawerState of(BuildContext context) =>
      context.findAncestorStateOfType<CustomDrawerState>();

  @override
  CustomDrawerState createState() => new CustomDrawerState();
}

class CustomDrawerState extends State<CustomDrawer>
    with SingleTickerProviderStateMixin {
  static Duration toggleDuration = Duration(
    milliseconds: 200,
  );
  bool _canBeDragged = false;
  static double maxSlide = 225;
  static double minDragStartEdge = 200;
  static double maxDragStartEdge = maxSlide - 16;
  AnimationController animationController;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: CustomDrawerState.toggleDuration,
    );
  }

  void toggle() => animationController.isDismissed
      ? animationController.forward()
      : animationController.reverse();
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragStart: _onDragStart,
      onHorizontalDragUpdate: _onDragUpdate,
      onHorizontalDragEnd: _onDragEnd,
      child: AnimatedBuilder(
        animation: animationController,
        child: widget.child,
        builder: (context, child) {
          double animValue = animationController.value;
          double slideAmount = maxSlide * animValue;
          double contentScale = 1.0 - (0.3 * animValue);
          return Stack(
            children: <Widget>[
              MyDrawer(),
              Transform(
                transform: Matrix4.identity()
                  ..translate(slideAmount)
                  ..scale(contentScale, contentScale),
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: animationController.isCompleted
                      ? animationController.reverse
                      : null,
                  child: child,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _onDragStart(DragStartDetails details) {
    bool isDragOpenFromLeft = animationController.isDismissed &&
        details.globalPosition.dx < minDragStartEdge;
    bool isDragCloseFromRight = animationController.isCompleted &&
        details.globalPosition.dx > maxDragStartEdge;

    _canBeDragged = isDragOpenFromLeft || isDragCloseFromRight;
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (_canBeDragged) {
      double delta = details.primaryDelta / maxSlide;
      animationController.value += delta;
    }
  }

  void _onDragEnd(DragEndDetails details) {
    if (animationController.isDismissed || animationController.isCompleted) {
      return;
    }
    if (details.velocity.pixelsPerSecond.dx.abs() >= 365.0) {
      double visualVelocity = details.velocity.pixelsPerSecond.dx /
          MediaQuery.of(context).size.width;

      animationController.fling(velocity: visualVelocity);
    } else if (animationController.value < 0.5) {
      animationController.reverse();
    } else {
      animationController.forward();
    }
  }
}

class MyDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.blueAccent,
      child: SafeArea(
        child: Theme(
          data: ThemeData(brightness: Brightness.dark),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              Image.asset(
                'assets/download.png',
                width: 200,
              ),
              ListTile(
                leading: Icon(Icons.alarm),
                title: Text('Ant'),
              ),
              ListTile(
                title: Text('Bat'),
              ),
              ListTile(
                title: Text('Call'),
              ),
              ListTile(
                title: Text('Dog'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
