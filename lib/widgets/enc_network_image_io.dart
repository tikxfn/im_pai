// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/painting.dart' as painting;
import 'package:flutter/foundation.dart';
import 'package:unionchat/common/cache_file.dart';

/// The dart:io implementation of [painting.NetworkImage].
@immutable
class EncNetworkImage extends painting.ImageProvider<painting.NetworkImage>
    implements painting.NetworkImage {
  /// Creates an object that fetches the image at the given URL.
  ///
  /// The arguments [url] and [scale] must not be null.
  const EncNetworkImage(this.url, {this.scale = 1.0, this.headers});

  @override
  final String url;

  @override
  final double scale;

  @override
  final Map<String, String>? headers;

  @override
  Future<EncNetworkImage> obtainKey(painting.ImageConfiguration configuration) {
    return SynchronousFuture<EncNetworkImage>(this);
  }

  @override
  ImageStreamCompleter loadImage(
    painting.NetworkImage key,
    painting.ImageDecoderCallback decode,
  ) {
    // Ownership of this controller is handed off to [_loadAsync]; it is that
    // method's responsibility to close the controller's stream when the image
    // has been loaded or an error is thrown.
    final StreamController<ImageChunkEvent> chunkEvents =
        StreamController<ImageChunkEvent>();

    return MultiFrameImageStreamCompleter(
      codec: _loadAsyncWithRetry(
        key as EncNetworkImage,
        chunkEvents,
        decode: decode,
      ),
      chunkEvents: chunkEvents.stream,
      scale: key.scale,
      debugLabel: key.url,
      informationCollector: () => <DiagnosticsNode>[
        DiagnosticsProperty<painting.ImageProvider>('Image provider', this),
        DiagnosticsProperty<painting.NetworkImage>('Image key', key),
      ],
    );
  }

  Future<ui.Codec> _loadAsyncWithRetry(
    EncNetworkImage key,
    StreamController<ImageChunkEvent> chunkEvents, {
    required painting.ImageDecoderCallback decode,
  }) async {
    for (int i = 0; i < 5; i++) {
      try {
        return await _loadAsync(key, chunkEvents, decode: decode);
      } catch (e) {
        if (i == 4) {
          rethrow;
        }
        await Future.delayed(const Duration(seconds: 1));
      }
    }
    throw 'Failed to load image after 5 retries';
  }

  Future<ui.Codec> _loadAsync(
    EncNetworkImage key,
    StreamController<ImageChunkEvent> chunkEvents, {
    required painting.ImageDecoderCallback decode,
  }) async {
    try {
      assert(key == this);
      final file = await CacheFile.load(url);
      final Uint8List bytes = await file.readAsBytes();

      // final Uint8List bytes = await CacheFile.requestUrl(url);
      // Uint8List bytes = await tempFile.readAsBytes();
      if (bytes.lengthInBytes == 0) {
        throw Exception('NetworkImage is an empty url: $url');
      }

      final ui.ImmutableBuffer buffer =
          await ui.ImmutableBuffer.fromUint8List(bytes);
      return decode(buffer);
    } catch (e) {
      // Depending on where the exception was thrown, the image cache may not
      // have had a chance to track the key in the cache at all.
      // Schedule a microtask to give the cache a chance to add the key.
      scheduleMicrotask(() {
        PaintingBinding.instance.imageCache.evict(key);
      });
      rethrow;
    } finally {
      chunkEvents.close();
    }
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is EncNetworkImage && other.url == url && other.scale == scale;
  }

  @override
  int get hashCode => Object.hash(url, scale);

  @override
  String toString() =>
      '${objectRuntimeType(this, 'NetworkImage')}("$url", scale: $scale)';
}
