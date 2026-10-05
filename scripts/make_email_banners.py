"""Draws the banner that sits at the top of every gabis email.

Run from the repo root:  python3 scripts/make_email_banners.py

Writes web/landing/media/email-banner-{welcome,newsletter,update}.png at
1200x480 (shown at 600 wide, so it stays sharp on high-density screens).
The email template in functions/_lib/email.ts points at these file names.
"""
from PIL import Image, ImageDraw, ImageFont

W, H = 1200, 480
STRIP = 64                 # bottom bar with the logo and address
CREAM = (251, 241, 223)
INDIGO = (59, 52, 201)
INK = (43, 41, 38)
BRAND = (76, 69, 255)

FONT_FILE = "/System/Library/Fonts/Avenir Next.ttc"


def font(size, want):
    """Pick a face out of the .ttc by name, e.g. 'Heavy' or 'Medium'."""
    for i in range(12):
        try:
            f = ImageFont.truetype(FONT_FILE, size, index=i)
        except OSError:
            break
        if want.lower() in " ".join(f.getname()).lower():
            return f
    return ImageFont.truetype(FONT_FILE, size)


def wrap(draw, text, fnt, max_w):
    lines, cur = [], ""
    for word in text.split():
        trial = f"{cur} {word}".strip()
        if draw.textlength(trial, font=fnt) <= max_w:
            cur = trial
        else:
            lines.append(cur)
            cur = word
    lines.append(cur)
    return lines


def make(name, pill, headline, sub, image, focus):
    img = Image.new("RGB", (W, H), CREAM)
    d = ImageDraw.Draw(img)
    body_h = H - STRIP

    # photo, right-hand side
    px, pw_ = 700, W - 700 - 36
    ph_ = body_h - 36
    src = Image.open(image).convert("RGB")
    s = max(pw_ / src.width, ph_ / src.height)
    src = src.resize((int(src.width * s) + 1, int(src.height * s) + 1), Image.LANCZOS)
    fx, fy = focus  # 0..1: which part of the picture stays in frame
    left = int((src.width - pw_) * fx)
    top = int((src.height - ph_) * fy)
    crop = src.crop((left, top, left + pw_, top + ph_))

    # Small radius on three corners, one big sweeping curve top-left.
    big = 200
    mask = Image.new("L", (pw_, ph_), 0)
    md = ImageDraw.Draw(mask)
    md.rounded_rectangle((0, 0, pw_ - 1, ph_ - 1), radius=26, fill=255)
    md.rectangle((0, 0, big, big), fill=0)                       # clear the small corner
    md.pieslice((0, 0, big * 2, big * 2), 180, 270, fill=255)    # the big one
    img.paste(crop, (px, 18), mask)

    # label pill
    pf = font(21, "Demi")
    tw_ = d.textlength(pill, font=pf)
    d.rounded_rectangle((60, 62, 60 + tw_ + 44, 62 + 44), radius=22, fill=(255, 255, 255))
    d.text((60 + 22, 62 + 22), pill, font=pf, fill=INDIGO, anchor="lm")

    # headline
    hf = font(64, "Heavy")
    y = 134
    for line in wrap(d, headline, hf, 600):
        d.text((60, y), line, font=hf, fill=INDIGO)
        y += 76
    # sub line
    sf = font(26, "Regular")
    y += 12
    for line in wrap(d, sub, sf, 580):
        d.text((60, y), line, font=sf, fill=INK)
        y += 36

    # bottom strip: indigo rule, logo, address
    d.rectangle((0, body_h, W, H), fill=(255, 255, 255))
    d.rectangle((0, body_h, W, body_h + 5), fill=BRAND)
    logo = Image.open("assets/images/gabis_logo.png").convert("RGBA")
    bb = logo.split()[3].point(lambda v: 255 if v > 20 else 0).getbbox()
    logo = logo.crop(bb)
    lh = 34
    logo = logo.resize((int(logo.width * lh / logo.height), lh), Image.LANCZOS)
    img.paste(logo, (60, body_h + 5 + (STRIP - 5 - lh) // 2), logo)
    af = font(22, "Medium")
    d.text((W - 60, body_h + 5 + (STRIP - 5) // 2), "www.gabispay.com", font=af, fill=INK, anchor="rm")

    out = f"web/landing/media/email-banner-{name}.png"
    img.save(out, optimize=True)
    print("wrote", out)


make("welcome", "WELCOME TO GABIS", "Your account is ready.",
     "One account, every currency, built for how you actually get paid.",
     "assets/images/african_person_mockup.jpg", (0.5, 0.36))
make("newsletter", "YOU'RE ON THE LIST", "Thanks for joining us.",
     "Product updates and new currency corridors. No noise.",
     "assets/images/banner_collections.jpg", (0.5, 0.12))
make("update", "A NOTE FROM GABIS", "Something good is coming.",
     "Thank you for registering with gabis. Here is what happens next.",
     "assets/images/usecase_creators.jpg", (0.55, 0.15))
