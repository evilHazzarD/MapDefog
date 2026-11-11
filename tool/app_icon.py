"""Renders the app icon variants from assets/images/logo.svg.

The logo is only circles, triangles and one radial gradient, so it is drawn
here directly (4x supersampled) instead of depending on an SVG renderer.

    python3 tool/app_icon.py && dart run flutter_launcher_icons

Outputs (assets/icon/):
  icon.png             full-bleed square: iOS and older Android launchers
  adaptive_fg.png      the compass alone, inside the adaptive icon safe zone
  adaptive_bg.png      the green background
  adaptive_mono.png    white silhouette for Android 13+ themed icons

and android/.../drawable-*/ic_notification.png, the status bar icon (Android
draws only its alpha, so it must be a silhouette).
"""

import math
import re
import sys
from pathlib import Path

from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parent.parent
SVG = ROOT / "assets/images/logo.svg"
OUT = ROOT / "assets/icon"
SIZE = 1024
SS = 4  # supersampling
VIEW = 96.0  # the logo's viewBox


def parse(svg: str):
    stops = re.findall(r'<stop offset="([\d.]+)" stop-color="(#[0-9A-Fa-f]{6})"', svg)
    circles = [
        dict(
            cx=float(m["cx"]),
            cy=float(m["cy"]),
            r=float(m["r"]),
            fill=m["fill"],
            stroke=m["stroke"],
            width=float(m["width"] or 0),
            opacity=float(m["op"] or 1),
        )
        for m in re.finditer(
            r'<circle cx="(?P<cx>[\d.]+)" cy="(?P<cy>[\d.]+)" r="(?P<r>[\d.]+)" fill="(?P<fill>[^"]+)"'
            r'(?: stroke="(?P<stroke>[^"]+)")?(?: stroke-opacity="(?P<op>[\d.]+)")?'
            r'(?: stroke-width="(?P<width>[\d.]+)")?',
            svg,
        )
    ]
    triangles = [
        (m[1], [tuple(map(float, p)) for p in re.findall(r"([\d.]+) ([\d.]+)", m[2])])
        for m in re.finditer(r'<path fill="(#[0-9A-Fa-f]{6})" d="([^"]+)"', svg)
    ]
    return stops, circles, triangles


def rgb(h: str):
    return tuple(int(h[i : i + 2], 16) for i in (1, 3, 5))


def gradient(stops, size):
    """The logo's radial background: centre (50%, 45%), radius 70%."""
    (o0, c0), (o1, c1) = [(float(o), rgb(c)) for o, c in stops]
    small = 256
    img = Image.new("RGB", (small, small))
    px = img.load()
    cx, cy, r = 0.5 * small, 0.45 * small, 0.7 * small
    for y in range(small):
        for x in range(small):
            t = min(1.0, math.hypot(x - cx, y - cy) / r)
            t = (t - o0) / (o1 - o0)
            px[x, y] = tuple(round(a + (b - a) * t) for a, b in zip(c0, c1))
    return img.resize((size, size), Image.BICUBIC)


def compass(circles, triangles, size, scale, mono=False):
    """The disc and rose, centred, with logo units scaled by [scale] px."""
    big = size * SS
    img = Image.new("RGBA", (big, big), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    k = scale * SS
    off = big / 2 - 48 * k

    def at(x, y):
        return (off + x * k, off + y * k)

    white = (255, 255, 255, 255)
    for i, c in enumerate(circles):
        x0, y0 = at(c["cx"] - c["r"], c["cy"] - c["r"])
        x1, y1 = at(c["cx"] + c["r"], c["cy"] + c["r"])
        if c["fill"] != "none":
            if mono:
                # A ring and the centre: the disc's face stays empty.
                fill = white if i == 0 or c["r"] < 5 else (0, 0, 0, 0)
            else:
                fill = rgb(c["fill"]) + (255,)
            d.ellipse([x0, y0, x1, y1], fill=fill)
        elif not mono:
            a = round(255 * c["opacity"])
            d.ellipse([x0, y0, x1, y1], outline=rgb(c["stroke"]) + (a,), width=round(c["width"] * k))
    for fill, pts in triangles:
        d.polygon([at(*p) for p in pts], fill=white if mono else rgb(fill) + (255,))
    return img.resize((size, size), Image.LANCZOS)


def main():
    stops, circles, triangles = parse(SVG.read_text())
    if len(stops) != 2 or not circles or not triangles:
        sys.exit("logo.svg no longer has the expected shapes; update tool/app_icon.py")
    OUT.mkdir(parents=True, exist_ok=True)

    bg = gradient(stops, SIZE)
    bg.save(OUT / "adaptive_bg.png")

    # Full-bleed: iOS masks the corners itself (transparent corners turn black).
    full = bg.convert("RGBA")
    full.alpha_composite(compass(circles, triangles, SIZE, SIZE / VIEW))
    full.convert("RGB").save(OUT / "icon.png")

    # Adaptive icons show the middle 66 of 108 dp at most, and
    # flutter_launcher_icons insets the foreground by 16% on each side (to
    # 68% of 108 dp); keep the disc (radius 40 of the logo) within the 66.
    safe = SIZE * 66 / (108 * 0.68) / 2
    k = safe / 40 * 0.92
    compass(circles, triangles, SIZE, k).save(OUT / "adaptive_fg.png")
    compass(circles, triangles, SIZE, k, mono=True).save(OUT / "adaptive_mono.png")
    # Status bar icon: 24 dp, the silhouette almost to the edges.
    for dpi, px in {"mdpi": 24, "hdpi": 36, "xhdpi": 48, "xxhdpi": 72, "xxxhdpi": 96}.items():
        res = ROOT / f"android/app/src/main/res/drawable-{dpi}"
        res.mkdir(exist_ok=True)
        icon = compass(circles, triangles, SIZE, SIZE / 2 / 40 * 0.96, mono=True)
        icon.resize((px, px), Image.LANCZOS).save(res / "ic_notification.png")

    print("wrote", ", ".join(sorted(p.name for p in OUT.glob("*.png"))))


if __name__ == "__main__":
    main()
