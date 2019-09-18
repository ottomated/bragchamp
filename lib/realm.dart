import 'package:flutter/material.dart';

class RealmGrid extends StatefulWidget {
  @override
  _RealmGridState createState() => _RealmGridState();
}

class _RealmGridState extends State<RealmGrid>
    with SingleTickerProviderStateMixin {
  List<Widget> realms;
  Realm scalingRealm;
  int selectedIndex;
  AnimationController _controller;
  Animation<double> _shrinkProfile;

  @override
  void initState() {
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 250));
    _shrinkProfile = Tween<double>(begin: 1.0, end: 0.0).animate(_controller);
    realms = [
      Realm(
        this,
        0,
        name: 'Popular Bets',
        background: Colors.orange,
        icon: Icons.playlist_add,
      ),
      Realm(
        this,
        1,
        name: 'Search',
        background: Colors.yellow,
        icon: Icons.search,
      ),
      Realm(
        this,
        2,
        name: 'Leaderboard',
        background: Colors.green,
        icon: Icons.format_list_numbered,
      ),
      Realm(
        this,
        3,
        name: 'Group Activity',
        background: Colors.blue,
        icon: Icons.people,
      ),
    ];
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void selectRealm(int index) {
    print('selected $index');
    setState(() {
      if (selectedIndex != null) realms[selectedIndex] = scalingRealm;
      selectedIndex = index;
      scalingRealm = realms[selectedIndex];
      realms[selectedIndex] = Container();
    });
  }

  void shrinkProfile() {
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, size) {
      print(realms);
      print(scalingRealm);
      return Stack(
        children: <Widget>[
          ...realms
              .asMap()
              .map(
                (i, r) => MapEntry(
                      i,
                      Align(
                        alignment: [
                          Alignment.topLeft,
                          Alignment.topRight,
                          Alignment.bottomLeft,
                          Alignment.bottomRight,
                        ][i],
                        child: Container(
                            width: size.maxWidth / 2,
                            height: size.maxHeight / 2,
                            child: r),
                      ),
                    ),
              )
              .values,
          if (scalingRealm != null)
            Align(
              alignment: [
                Alignment.topLeft,
                Alignment.topRight,
                Alignment.bottomLeft,
                Alignment.bottomRight,
              ][scalingRealm.index],
              child: Container(
                width: size.maxWidth / 2,
                height: size.maxHeight / 2,
                child: scalingRealm,
              ),
            ),
          Center(
              child: AnimatedBuilder(
            animation: _shrinkProfile,
            builder: (context, widget) => Transform.scale(
                  scale: _shrinkProfile.value,
                  child: ClipOval(
                    child: Container(
                      height: 150.0,
                      width: 150.0,
                      color: Colors.pink,
                      child: Center(
                        child: Icon(Icons.person),
                      ),
                    ),
                  ),
                ),
          )),
        ],
      );
    });
  }
}

class Realm extends StatefulWidget {
  Realm(this.parent, this.index, {this.name, this.background, this.icon});

  final String name;
  final int index;
  final Color background;
  final IconData icon;
  final _RealmGridState parent;
  @override
  _RealmState createState() => _RealmState();

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.debug}) {
    return 'Realm[$index]';
  }
}

class _RealmState extends State<Realm> with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> _flingAnimation;
  double _scale = 1.0;

  @override
  void initState() {
    _scale = 1.0;
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200))
          ..addListener(_handleFlingAnimation);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleFlingAnimation() {
    setState(() {
      //print('anim ${_flingAnimation.value}');
      _scale = _flingAnimation.value;
    });
  }

  void onDown(d) {
    print('down');
    widget.parent.selectRealm(widget.index);
    _flingAnimation = _controller.drive(Tween<double>(
      begin: 1.0,
      end: 1.05,
    ));
    _controller..forward();
  }

  @override
  Widget build(BuildContext context) {
    //print('build ${widget.index} $_scale');
    return GestureDetector(
      onTapDown: onDown,
      onVerticalDragDown: onDown,
      onTapUp: (d) async {
        print('u');
        await Future.delayed(Duration(milliseconds: 150), () {
          if (mounted) _controller..reverse();
        });
      },
      onVerticalDragUpdate: (d) {
        setState(() {
          _scale += d.delta.distance / 1000.0;
        });
      },
      onVerticalDragEnd: (details) {
        final double magnitude = details.velocity.pixelsPerSecond.distance;
        double end = (magnitude < 800.0) ? 1.0 : 2.0;
        _flingAnimation = _controller.drive(Tween<double>(
          begin: _scale,
          end: end,
        ));
        _controller
          ..value = 0.0
          ..fling(velocity: magnitude / 1000.0);
        widget.parent.shrinkProfile();
      },
      child: Transform.scale(
        scale: _scale,
        alignment: [
          Alignment.topLeft,
          Alignment.topRight,
          Alignment.bottomLeft,
          Alignment.bottomRight,
        ][widget.index],
        child: Container(
          decoration: BoxDecoration(color: widget.background),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  widget.icon,
                  size: 64.0,
                ),
                Text(widget.name, style: TextStyle(fontSize: 32.0)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
