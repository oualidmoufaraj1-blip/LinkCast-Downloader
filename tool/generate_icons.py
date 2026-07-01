#!/usr/bin/env python3
"""Generate App Store-ready iOS app icons for Downloader."""

from pathlib import Path

from PIL import Image, ImageDraw

ORANGE = (255, 107, 0)
WHITE = (255, 255, 255)
OUT = Path(__file__).resolve().parent.parent / "ios/Runner/Assets.xcassets/AppIcon.appiconset"

SIZES = {
    "Icon-App-20x20@1x.png": 20,
    "Icon-App-20x20@2x.png": 40,
    "Icon-App-20x20@3x.png": 60,
    "Icon-App-29x29@1x.png": 29,
    "Icon-App-29x29@2x.png": 58,
    "Icon-App-29x29@3x.png": 87,
    "Icon-App-40x40@1x.png": 40,
    "Icon-App-40x40@2x.png": 80,
    "Icon-App-40x40@3x.png": 120,
    "Icon-App-60x60@2x.png": 120,
    "Icon-App-60x60@3x.png": 180,
    "Icon-App-76x76@1x.png": 76,
    "Icon-App-76x76@2x.png": 152,
    "Icon-App-83.5x83.5@2x.png": 167,
    "Icon-App-1024x1024@1x.png": 1024,
}


def draw_arrow(draw: ImageDraw.ImageDraw, size: int) -> None:
    s = size
    stroke = max(2, int(s * 0.07))
    cx = s // 2

    tray_y1 = int(s * 0.62)
    tray_y2 = int(s * 0.82)
    tray_x1 = int(s * 0.22)
    tray_x2 = int(s * 0.78)

    draw.line([(tray_x1, tray_y1), (tray_x1, tray_y2)], fill=WHITE, width=stroke)
    draw.line([(tray_x1, tray_y2), (tray_x2, tray_y2)], fill=WHITE, width=stroke)
    draw.line([(tray_x2, tray_y2), (tray_x2, tray_y1)], fill=WHITE, width=stroke)

    arrow_top = int(s * 0.18)
    arrow_mid = int(s * 0.52)
    arrow_w = int(s * 0.22)

    draw.line([(cx, arrow_top), (cx, arrow_mid)], fill=WHITE, width=stroke)
    draw.line([(cx - arrow_w, arrow_mid - arrow_w), (cx, arrow_mid)], fill=WHITE, width=stroke)
    draw.line([(cx, arrow_mid), (cx + arrow_w, arrow_mid - arrow_w)], fill=WHITE, width=stroke)


def render_icon(size: int) -> Image.Image:
    img = Image.new("RGB", (size, size), ORANGE)
    draw = ImageDraw.Draw(img)
    if size >= 1024:
        radius = int(size * 0.223)
        mask = Image.new("L", (size, size), 0)
        ImageDraw.Draw(mask).rounded_rectangle((0, 0, size, size), radius=radius, fill=255)
        rounded = Image.new("RGB", (size, size), ORANGE)
        rounded.putalpha(mask)
        img = rounded.convert("RGB")
        draw = ImageDraw.Draw(img)
    draw_arrow(draw, size)
    return img


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    for name, px in SIZES.items():
        render_icon(px).save(OUT / name, "PNG")
        print(f"Wrote {name} ({px}px)")


if __name__ == "__main__":
    main()
