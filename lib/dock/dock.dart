// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'dart:ui';

class Dock extends StatefulWidget {
  final List<IconData> items;

  const Dock({super.key, required this.items});

  @override
  State<Dock> createState() => _DockState();
}

class _DockState extends State<Dock> {
  double _hoveredIndex = -1;
  int? _draggedIndex;
  late final List<IconData> _items = widget.items.toList();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                _items.length,
                (index) => Draggable<IconData>(
                  data: _items[index],
                  feedback: _buildDockItem(
                    icon: _items[index],
                    size: 60,
                    isDragging: true,
                  ),
                  childWhenDragging: const SizedBox.shrink(),
                  onDragStarted: () {
                    setState(() {
                      _draggedIndex = index;
                    });
                  },
                  onDragCompleted: () {
                    setState(() {
                      _draggedIndex = null;
                    });
                  },
                  onDraggableCanceled: (_, __) {
                    setState(() {
                      _draggedIndex = null;
                    });
                  },
                  child: DragTarget<IconData>(
                    onWillAccept: (data) {
                      setState(() {
                        _hoveredIndex = index.toDouble();
                      });
                      return true;
                    },
                    onAccept: (data) {
                      setState(() {
                        int oldIndex = _items.indexOf(data);
                        _items.removeAt(oldIndex);
                        _items.insert(index, data);
                        _hoveredIndex = -1;
                        _draggedIndex = null;
                      });
                    },
                    onLeave: (_) {
                      setState(() {
                        _hoveredIndex = -1;
                      });
                    },
                    builder: (context, candidateItems, rejectedItems) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutCubic,
                        margin: _getMargin(index),
                        transform: _getTransform(index),
                        child: _buildDockItem(
                          icon: _items[index],
                          size: _getIconSize(index),
                          isDragging: false,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDockItem(
      {required IconData icon,
      required double size,
      required bool isDragging}) {
    return Container(
      width: size,
      height: size,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.primaries[icon.hashCode % Colors.primaries.length],
        borderRadius: BorderRadius.circular(12),
        boxShadow: isDragging
            ? [
                const BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  spreadRadius: 2,
                  offset: Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: Center(
        child: Icon(icon, color: Colors.white, size: size * 0.5),
      ),
    );
  }

  double _getIconSize(int index) {
    if (_hoveredIndex == -1) return 48;
    double distance = (_hoveredIndex - index).abs();
    return 48 + (1 - (distance / 3)).clamp(0, 1) * 12;
  }

  //
  Matrix4 _getTransform(int index) {
    if (_hoveredIndex == -1) return Matrix4.identity();
    double distance = (_hoveredIndex - index).abs();
    double scale = 1 + (1 - (distance / 3)).clamp(0, 1) * 0.05;
    return Matrix4.diagonal3Values(scale, scale, 1);
  }

  EdgeInsets _getMargin(int index) {
    if (_draggedIndex == null || _hoveredIndex == -1) {
      return const EdgeInsets.symmetric(horizontal: 8);
    }
    if (_hoveredIndex == index) {
      return const EdgeInsets.symmetric(horizontal: 24);
    }
    return const EdgeInsets.symmetric(horizontal: 8);
  }
}
