import 'package:flutter/material.dart';

import 'package:my_flutter_starter/frontend/frontend_scope.dart';

import 'map_page_body.dart';
import 'map_page_handler.dart';
import 'map_view_models.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  MapFilter _filter = MapFilter.all;
  MapSort _sort = MapSort.recent;
  MapLayerMode _layerMode = MapLayerMode.city;
  String? _selectedTargetId;

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.controllerOf(context);
    final state = controller.state;
    final routeSelection = state.selectedMapTargetId;

    if (routeSelection != null && routeSelection != _selectedTargetId) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        setState(() {
          _selectedTargetId = routeSelection;
        });
        controller.clearMapSelection();
      });
    }

    final handler = MapPageHandler(
      context: context,
      controller: controller,
      state: state,
      selectedTargetId: routeSelection ?? _selectedTargetId,
      layerMode: _layerMode,
      onLayerModeChanged: (value) => setState(() => _layerMode = value),
      onSelectedTargetChanged: (value) => setState(() => _selectedTargetId = value),
    );

    return MapPageBody(
      state: state,
      filter: _filter,
      sort: _sort,
      layerMode: _layerMode,
      selectedTargetId: routeSelection ?? _selectedTargetId,
      onFilterChanged: (value) => setState(() => _filter = value),
      onSortChanged: (value) => setState(() => _sort = value),
      handler: handler,
    );
  }
}
