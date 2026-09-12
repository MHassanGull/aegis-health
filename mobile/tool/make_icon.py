# -*- coding: utf-8 -*-
"""Generate the Aegis Health app icon: a warm shield with a health pulse."""
import os
from PIL import Image, ImageDraw

OUT_DIR = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "assets", "icon")
os.makedirs(OUT_DIR, exist_ok=True)

SZ = 1024
GREEN = (32, 165, 122)      # fresh green
GREEN_D = (22, 130, 96)
CORAL = (255, 122, 99)
WHITE = (255, 255, 255)


def lerp(a, b, t):
    return tuple(int(a[i] + (b[i] - a[i]) * t) for i in range(3))


def make(bg_rounded=True):
    img = Image.new("RGBA", (SZ, SZ), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)

    # background: vertical green gradient
    for y in range(SZ):
        d.line([(0, y), (SZ, y)], fill=lerp(GREEN, GREEN_D, y / SZ))

    # shield shape (centered)
    cx = SZ // 2
    top = int(SZ * 0.16)
    w = int(SZ * 0.30)
    shoulder = int(SZ * 0.30)
    bottom = int(SZ * 0.86)
    pts = [
        (cx, top),
        (cx + w, shoulder),
        (cx + w, int(SZ * 0.55)),
        (cx, bottom),
        (cx - w, int(SZ * 0.55)),
        (cx - w, shoulder),
    ]
    d.polygon(pts, fill=(255, 255, 255, 38))
    # shield outline
    d.line(pts + [pts[0]], fill=WHITE, width=14, joint="curve")

    # heart pulse line inside the shield
    midy = int(SZ * 0.47)
    amp = int(SZ * 0.10)
    pulse = [
        (cx - int(w * 0.78), midy),
        (cx - int(w * 0.40), midy),
        (cx - int(w * 0.22), midy - amp),
        (cx - int(w * 0.02), midy + int(amp * 1.25)),
        (cx + int(w * 0.20), midy - int(amp * 1.6)),
        (cx + int(w * 0.40), midy),
        (cx + int(w * 0.80), midy),
    ]
    d.line(pulse, fill=CORAL, width=22, joint="curve")
    # round the pulse joints
    for p in pulse:
        d.ellipse([p[0]-9, p[1]-9, p[0]+9, p[1]+9], fill=CORAL)

    img.save(os.path.join(OUT_DIR, "icon.png"))
    # foreground (transparent bg) for adaptive icon
    fg = Image.new("RGBA", (SZ, SZ), (0, 0, 0, 0))
    fd = ImageDraw.Draw(fg)
    fd.polygon(pts, fill=(255, 255, 255, 50))
    fd.line(pts + [pts[0]], fill=WHITE, width=14, joint="curve")
    fd.line(pulse, fill=CORAL, width=22, joint="curve")
    for p in pulse:
        fd.ellipse([p[0]-9, p[1]-9, p[0]+9, p[1]+9], fill=CORAL)
    fg.save(os.path.join(OUT_DIR, "icon_fg.png"))
    print("icons written to", OUT_DIR)


if __name__ == "__main__":
    make()
