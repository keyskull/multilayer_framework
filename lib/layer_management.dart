import 'dart:collection';

import 'package:cullen_utilities/custom_log_printer.dart';
import 'package:flutter/widgets.dart';
import 'package:logger/logger.dart';

import 'multi_layered_app.dart';

final _logger = Logger(printer: CustomLogPrinter('MultiLayer'));

mixin MultiLayer {
  String get name;

  List<OverlayEntry> Function(BuildContext context, Widget? child)
      get overlayEntryBuilder;

  dynamic createContainer(dynamic identity);

  dynamic destroyContainer(dynamic identity);
}

class NativeLayer implements MultiLayer {
  final String name = 'NativeLayer';
  final List<OverlayEntry> Function(BuildContext context, Widget? child)
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
  final LinkedHashMap<String, MultiLayer Function(BuildContext)>
      _layersBuilder = LinkedHashMap();
  Map<String, MultiLayer>? _layers;
  NativeLayer? _defaultLayer;

  addLayerBuilder(
      {required String name,
      required MultiLayer Function(BuildContext) layerBuilder}) {
    _layersBuilder[name] = layerBuilder;
  }

  List<OverlayEntry> deployLayers(BuildContext context, Widget? child) {
    assert(_defaultLayer != null, "LayerManagement hasn't initialized.");

    _layers = _layersBuilder.map((key, value) => MapEntry(key, value(context)));

    return _defaultLayer!.overlayEntryBuilder(context, child) +
        _layers!.values
            .map((e) => e.overlayEntryBuilder(context, child))
            .reduce((value, element) => value + element);
  }

  void setDefaultLayer(NativeLayer nativeLayer) {
    this._defaultLayer = nativeLayer;
  }

  dynamic createContainer(dynamic identity, {String? layerName}) {
    _logger.i('createContainer executed: ' +
        identity.toString() +
        ', ' +
        (layerName ?? ''));
    if (layerName == null) {
      assert(_layers != null, "LayerManagement hasn't initialized.");
      assert(_defaultLayer != null, "LayerManagement hasn't initialized.");
      return _defaultLayer!.createContainer(identity);
    } else {
      assert(_layers?[layerName] != null, "doesn't include $layerName layer.");
      return _layers![layerName]!.createContainer(identity);
    }
  }

  dynamic destroyContainer(dynamic identity, {String? layerName}) {
    if (layerName == null) {
      assert(_layers != null, "LayerManagement hasn't initialized.");
      assert(_defaultLayer != null, "LayerManagement hasn't initialized.");
      return _defaultLayer!.destroyContainer(identity);
    } else {
      assert(_layers![layerName] != null, "doesn't include $layerName layer.");
      return _layers![layerName]!.destroyContainer(identity);
    }
  }
}
