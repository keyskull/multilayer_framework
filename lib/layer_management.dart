import 'dart:collection';

import 'package:flutter/cupertino.dart';

import 'multi_layered_app.dart';

mixin MultiLayer {
  String get name;
  OverlayEntry Function(BuildContext context, Widget? child)
      get overlayEntryBuilder;

  dynamic createContainer(dynamic identity);

  dynamic destroyContainer(dynamic identity);
}

class NativeLayer implements MultiLayer {
  final String name = 'Native Layer';
  final OverlayEntry Function(BuildContext context, Widget? child)
      overlayEntryBuilder;

  NativeLayer(this.overlayEntryBuilder);

  @override
  dynamic destroyContainer(dynamic identity) {}

  @override
  dynamic createContainer(dynamic identity) {
    MultiLayeredApp.changePath(identity);
    return true;
  }
}

class LayerManagement {
  final LinkedHashMap<String, MultiLayer> _layers = LinkedHashMap();
  NativeLayer? _defaultLayer;

  LayerManagement();

  addLayer(MultiLayer layer) {
    _layers[layer.name] = layer;
  }

  List<OverlayEntry> deployLayers(BuildContext context, Widget? child) {
    assert(_defaultLayer != null, "LayerManagement hasn't initialized.");

    return [_defaultLayer!.overlayEntryBuilder(context, child)] +
        _layers.values
            .map((e) => e.overlayEntryBuilder(context, child))
            .toList();
  }

  void setDefaultLayer(NativeLayer nativeLayer) {
    this._defaultLayer = nativeLayer;
  }

  dynamic createContainer(dynamic identity, {String? layerName}) {
    if (layerName == null) {
      assert(_defaultLayer != null, "LayerManagement hasn't initialized.");
      return _defaultLayer!.createContainer(identity);
    } else {
      assert(_layers[layerName] != null, "doesn't include $layerName layer.");
      return _layers[layerName]!.createContainer(identity);
    }
  }

  dynamic destroyContainer(dynamic identity, {String? layerName}) {
    if (layerName == null) {
      assert(_defaultLayer != null, "LayerManagement hasn't initialized.");
      return _defaultLayer!.destroyContainer(identity);
    } else {
      assert(_layers[layerName] != null, "doesn't include $layerName layer.");
      return _layers[layerName]!.destroyContainer(identity);
    }
  }
}
