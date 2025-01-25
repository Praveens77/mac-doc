import 'package:flutter/material.dart';

/// Entrypoint of the application.
void main() {
  runApp(const MyApp());
}

/// [Widget] building the [MaterialApp].
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Dock(
            items: const [
              Icons.person,
              Icons.message,
              Icons.call,
              Icons.camera,
              Icons.photo,
            ],
            builder: (e) {
              return DraggableItem(
                icon: e,
              );
            },
          ),
        ),
      ),
    );
  }
}

class Dock extends StatefulWidget {
  const Dock({
    super.key,
    this.items = const [],
    required this.builder,
  });

  /// Initial [IconData] items to put in this [Dock].
  final List<IconData> items;

  /// Builder building the provided [IconData] item.
  final Widget Function(IconData) builder;

  @override
  State<Dock> createState() => _DockState();
}

/// State of the [Dock] used to manipulate the [_items].
class _DockState extends State<Dock> {
  /// [IconData] items being manipulated.
  late List<IconData> _items = widget.items.toList();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.black12,
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: _items.map((item) {
          return DragTarget<IconData>(  // Using IconData directly
            builder: (context, candidateItems, rejectedItems) {
              return widget.builder(item);
            },
            onWillAccept: (data) {
              return true;
            },
            onAccept: (data) {
              setState(() {
                int oldIndex = _items.indexOf(data);
                int newIndex = _items.indexOf(item);
                if (oldIndex != newIndex) {
                  IconData temp = _items[oldIndex];
                  _items[oldIndex] = _items[newIndex];
                  _items[newIndex] = temp;
                }
              });
            },
          );
        }).toList(),
      ),
    );
  }
}

/// DraggableItem widget that represents each item in the dock.
class DraggableItem extends StatelessWidget {
  final IconData icon;

  const DraggableItem({super.key, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Draggable<IconData>(  // Using IconData directly
      data: icon,
      feedback: Material(
        color: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(minWidth: 48),
          height: 48,
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.blue,
          ),
          child: Center(child: Icon(icon, color: Colors.white)),
        ),
      ),
      childWhenDragging: Container(),
      child: Container(
        constraints: const BoxConstraints(minWidth: 48),
        height: 48,
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.primaries[icon.hashCode % Colors.primaries.length],
        ),
        child: Center(child: Icon(icon, color: Colors.white)),
      ),
    );
  }
}
