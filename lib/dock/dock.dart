import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ui';
import 'package:mac_doc/dock/dock_controller.dart';
import 'package:mac_doc/utils/colors.dart';
import 'package:mac_doc/utils/sizes.dart';

/// Dock widget that allows draggable and reorderable icons.
class Dock extends StatelessWidget {
  // Controller for managing dock behavior.
  final DockController controller = Get.put(DockController());

  // List of icons to display in the dock.
  final List<IconData> items;

  // Constructor to initialize the dock with list of icons.
  Dock({super.key, required this.items}) {
    controller.initializeItems(items);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: dockPaddingVertical),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(dockBorderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: dockBlurSigma, sigmaY: dockBlurSigma),
          child: Container(
            height: dockHeight,
            decoration: BoxDecoration(
              color: white.withOpacity(dockBackgroundOpacity),
              borderRadius: BorderRadius.circular(dockBorderRadius),
              border: Border.all(color: white.withOpacity(dockBorderOpacity)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Obx(
              () => Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  controller.items.length,
                  (index) => Draggable<IconData>(
                    data: controller.items[index],
                    feedback: _buildDockItem(
                      icon: controller.items[index],
                      size: dockItemDraggingSize,
                      isDragging: true,
                    ),
                    childWhenDragging: const SizedBox.shrink(),
                    onDragStarted: () => controller.startDrag(index),
                    onDragCompleted: controller.completeDrag,
                    onDraggableCanceled: (_, __) => controller.cancelDrag(),
                    child: DragTarget<IconData>(
                      onWillAcceptWithDetails: (data) {
                        controller.updateHoverIndex(index);
                        return true;
                      },
                      // ignore: deprecated_member_use
                      onAccept: (data) {
                        int oldIndex = controller.items.indexOf(data);
                        controller.reorderItems(oldIndex, index);
                      },
                      onLeave: (_) => controller.resetHoverIndex(),
                      builder: (context, candidateItems, rejectedItems) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOutCubic,
                          margin: _getMargin(index),
                          transform: _getTransform(index),
                          child: MouseRegion(
                            onEnter: (_) {
                              if (!controller.isDragging.value) {
                                controller.updateHoverIndex(index);
                              }
                            },
                            onExit: (_) {
                              if (!controller.isDragging.value) {
                                controller.resetHoverIndex();
                              }
                            },
                            child: GestureDetector(
                              onTap: controller.resetHoverIndex,
                              child: _buildDockItem(
                                icon: controller.items[index],
                                size: _getIconSize(index),
                                isDragging: false,
                              ),
                            ),
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
      ),
    );
  }

  /// Returns tooltip message based on the icon type.
  String _getTooltipMessage(IconData icon) {
    if (icon == Icons.person) return "Profile";
    if (icon == Icons.message) return "Message";
    if (icon == Icons.call) return "Call";
    if (icon == Icons.camera) return "Camera";
    if (icon == Icons.photo) return "Gallery";
    return "App";
  }

  /// Returns the icon size based on hover state.
  double _getIconSize(int index) {
    return controller.isDragging.value
        ? dockItemBaseSize
        : (controller.hoveredIndex.value == index ? dockItemHoverSize : dockItemBaseSize);
  }

  /// Returns transformation for hover effect.
  Matrix4 _getTransform(int index) {
    return controller.isDragging.value
        ? Matrix4.identity()
        : (controller.hoveredIndex.value == index
            ? Matrix4.translationValues(0, dockItemHoverTranslationY, 0)
            : Matrix4.identity());
  }

  /// Builds a dock item with animation effects.
  Widget _buildDockItem({
    required IconData icon,
    required double size,
    required bool isDragging,
  }) {
    return Tooltip(
      message: _getTooltipMessage(icon),
      preferBelow: false,
      verticalOffset: tooltipOffset,
      decoration: BoxDecoration(
        color: tooltip,
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: const TextStyle(
        color: white,
        fontSize: tooltipFontSize,
        fontWeight: FontWeight.w500,
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        width: size,
        height: size,
        margin: EdgeInsets.symmetric(horizontal: _getHorizontalMargin(icon, isDragging)),
        decoration: BoxDecoration(
          color: Colors.primaries[icon.hashCode % Colors.primaries.length],
          borderRadius: BorderRadius.circular(12),
          boxShadow: isDragging
              ? [
                  const BoxShadow(
                    color: shadow,
                    blurRadius: dockItemShadowBlur,
                    spreadRadius: dockItemShadowSpread,
                    offset: Offset(0, dockItemShadowOffsetY),
                  ),
                ]
              : [],
        ),
        child: Center(child: Icon(icon, color: white, size: size * 0.5)),
      ),
    );
  }

  /// Returns horizontal margin for dock items.
  double _getHorizontalMargin(IconData icon, bool isDragging) {
    return isDragging
        ? dockItemDraggingMargin
        : (controller.hoveredIndex.value == controller.items.indexOf(icon)
            ? dockItemHoverMargin
            : dockItemHorizontalMargin);
  }

  /// Returns margin for dock items based on dragging state.
  EdgeInsets _getMargin(int index) {
    return const EdgeInsets.symmetric(
        horizontal: dockItemHorizontalMargin);
  }
}
