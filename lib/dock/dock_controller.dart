import 'package:get/get.dart';
import 'package:flutter/material.dart';

/// GetX Controller defines all the logics & functions that
/// we can use in our UI via dependency injection.

class DockController extends GetxController {
  // Reactive variables.
  final RxList<IconData> items = <IconData>[].obs;
  final RxInt hoveredIndex = (-1).obs;
  final Rxn<int> draggedIndex = Rxn<int>();
  final RxBool isDragging = false.obs;
  final RxMap<int, Offset> itemPositions = <int, Offset>{}.obs;

  /// Initializes the dock with a given list of icon items.
  /// 
  /// * [initialItems] - A list of `IconData` to populate the dock.
  void initializeItems(List<IconData> initialItems) {
    items.assignAll(initialItems);
  }

  /// Starts the drag operation for an item at the specified index.
  /// 
  /// * [index] - The index of the item being dragged.
  void startDrag(int index) {
    isDragging.value = true;
    draggedIndex.value = index;
  }

  /// Completes the drag operation by resetting drag-related states.
  void completeDrag() {
    isDragging.value = false;
    draggedIndex.value = null;
  }

  /// Cancels the current drag operation.
  void cancelDrag() {
    isDragging.value = false;
    draggedIndex.value = null;
  }

  /// Updates the hovered index when an item is hovered.
  /// 
  /// * [index] - The index of the hovered item.
  void updateHoverIndex(int index) {
    hoveredIndex.value = index;
  }

  /// Resets the hovered index.
  void resetHoverIndex() {
    hoveredIndex.value = -1;
  }

  /// Reorders items within the dock when dragged and dropped.
  ///
  /// * [oldIndex] - The original index of the dragged item.
  /// * [newIndex] - The new index where the item is dropped.
  void reorderItems(int oldIndex, int newIndex) {
    final item = items.removeAt(oldIndex);
    items.insert(newIndex, item);
    resetHoverIndex();
    completeDrag();
  }
}
