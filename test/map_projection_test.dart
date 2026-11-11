import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:mapdefog/geo/grid.dart';

/// FogLayer paints inside [MobileLayerTransformer], which uses layer space
/// ([MapCamera.getOffsetFromOrigin] / [MapCamera.pixelOrigin]).
/// [MapCamera.latLngToScreenOffset] is for widgets *outside* that space and
/// diverges as soon as the map is rotated (common during pinch-zoom).
void main() {
  test('layer-space and screen-space projections match at rotation 0', () {
    final cam = MapCamera(
      crs: const Epsg3857(),
      center: const LatLng(50.087, 14.421),
      zoom: 16,
      rotation: 0,
      nonRotatedSize: const Size(390, 844),
    );
    const pin = LatLng(50.088, 14.422);
    expect(cam.getOffsetFromOrigin(pin), cam.latLngToScreenOffset(pin));
  });

  test('layer-space and screen-space projections diverge when rotated', () {
    final cam = MapCamera(
      crs: const Epsg3857(),
      center: const LatLng(50.087, 14.421),
      zoom: 16,
      rotation: 30,
      nonRotatedSize: const Size(390, 844),
    );
    const pin = LatLng(50.088, 14.422);
    expect(cam.getOffsetFromOrigin(pin), isNot(cam.latLngToScreenOffset(pin)));
  });

  test('layer-space pin matches tile math after rotated pan', () {
    const pin = LatLng(50.088, 14.422);
    final cam = MapCamera(
      crs: const Epsg3857(),
      center: const LatLng(50.089, 14.424),
      zoom: 16.5,
      rotation: 18,
      nonRotatedSize: const Size(390, 844),
    );
    // Same formula TileLayer uses: project(pos) - pixelOrigin.
    expect(cam.getOffsetFromOrigin(pin), cam.projectAtZoom(pin) - cam.pixelOrigin);
    // Screen-space API would place the pin wrong inside MobileLayerTransformer.
    expect(cam.latLngToScreenOffset(pin), isNot(cam.projectAtZoom(pin) - cam.pixelOrigin));
  });

  test('base fog cells keep stable geography across zoom (no LOD reparenting)', () {
    // Clears must always use Grid.z cells. Parent centers at coarser levels
    // are not the same point as explored children — that caused zoom jumps.
    final key = Grid.cell(50.087, 14.421);
    final x = Grid.xOf(key);
    final y = Grid.yOf(key);
    final west = Grid.lon(x / Grid.n);
    final east = Grid.lon((x + 1) / Grid.n);
    final north = Grid.lat(y / Grid.n);
    final south = Grid.lat((y + 1) / Grid.n);
    expect(Grid.centerLon(key), closeTo((west + east) / 2, 1e-9));
    expect(Grid.centerLat(key), closeTo((north + south) / 2, 1e-9));
    // Parent at level 16 covers this cell but its center differs.
    final parent = Grid.parent(key, 16);
    expect(Grid.centerLat(parent, 16) == Grid.centerLat(key), isFalse);
    expect(Grid.centerLon(parent, 16) == Grid.centerLon(key), isFalse);
  });

  test('low-res fog buffer scale must use bw/width not 1/scale', () {
    const scale = 3;
    const width = 412.0; // not divisible by 3
    final bw = (width / scale).ceil();
    expect(bw / width, isNot(closeTo(1 / scale, 1e-9)));
  });
}
