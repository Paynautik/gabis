/**
 * The look shared by every email gabis sends: a banner across the top, a body
 * in plain readable type, and one footer.
 *
 * Mail clients block remote images until the reader allows them, so the banner
 * is built to degrade: it has a solid background colour that matches the image
 * and alt text in the headline's colour, so a blocked banner still reads as a
 * coloured band that says what the email is about, never a broken-image icon.
 */

export type Banner = "welcome" | "newsletter" | "update";

const BANNERS: Record<Banner, { alt: string; fallbackBg: string; fallbackInk: string }> = {
  welcome: { alt: "Welcome to gabis", fallbackBg: "#fbf1df", fallbackInk: "#3b34c9" },
  newsletter: { alt: "Thanks for joining gabis", fallbackBg: "#fbf1df", fallbackInk: "#3b34c9" },
  update: { alt: "Something good is coming to gabis", fallbackBg: "#fbf1df", fallbackInk: "#3b34c9" },
};

export const esc = (v: string) => v.replace(/[&<>"']/g, (c) => `&#${c.charCodeAt(0)};`);

/** A paragraph in the house style. */
export const p = (html: string) =>
  `<p style="margin:0 0 18px;font-size:16px;line-height:1.65;color:#2b2926">${html}</p>`;

/** The one button an email may carry. */
export const button = (href: string, label: string) =>
  `<p style="margin:26px 0 30px"><a href="${href}" style="display:inline-block;background:#4b45f5;color:#ffffff;text-decoration:none;font-weight:700;font-size:15px;letter-spacing:.04em;padding:14px 34px;border-radius:8px">${esc(label)}</a></p>`;

export function layout(opts: {
  siteUrl: string;
  banner: Banner;
  body: string;
  /** Extra footer line above the legal text, such as an unsubscribe link. */
  footerNote?: string;
}): string {
  const b = BANNERS[opts.banner];
  const src = `${opts.siteUrl}/landing/media/email-banner-${opts.banner}.png`;
  return `<!doctype html>
<html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><meta name="color-scheme" content="light"></head>
<body style="margin:0;padding:0;background:#f4f0e8;font-family:Helvetica,Arial,sans-serif;color:#2b2926">
<table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="background:#f4f0e8"><tr><td align="center" style="padding:24px 12px">
<table role="presentation" width="600" cellpadding="0" cellspacing="0" style="width:100%;max-width:600px;background:#ffffff">
<tr><td style="background:${b.fallbackBg};line-height:0;font-size:0"><a href="${opts.siteUrl}" style="text-decoration:none"><img src="${src}" width="600" alt="${esc(b.alt)}" style="display:block;width:100%;max-width:600px;height:auto;border:0;background:${b.fallbackBg};color:${b.fallbackInk};font-family:Helvetica,Arial,sans-serif;font-size:26px;font-weight:700;line-height:1.2;text-align:left"></a></td></tr>
<tr><td style="padding:32px 32px 8px">${opts.body}</td></tr>
<tr><td style="padding:20px 32px 30px;font-size:12px;line-height:1.6;color:#6b6660">
${opts.footerNote ? `${opts.footerNote}<br><br>` : ""}gabis is a financial technology company, not a bank. Money remittance and banking services are provided by our licensed financial institution partners.
</td></tr>
</table></td></tr></table></body></html>`;
}

/** Plain-text twin of an email: clients and spam filters both like having one. */
export function plain(lines: string[], footerNote?: string): string {
  return `${lines.join("\n\n")}

---
${footerNote ? `${footerNote}\n` : ""}gabis is a financial technology company, not a bank. Money remittance and banking services are provided by our licensed financial institution partners.
`;
}
