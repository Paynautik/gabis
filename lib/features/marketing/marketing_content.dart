import 'package:flutter/material.dart';

/// Every footer link resolves to one of these. A page is data, not a bespoke
/// widget, so the set stays consistent and cheap to extend.
class MarketingPage {
  final String route;
  final String eyebrow;
  final String title;
  final String lede;

  /// Short proof points under the hero.
  final List<String> highlights;

  final List<MarketingFeature> features;
  final List<MarketingFaq> faqs;

  /// Long-form prose sections — used by the legal and company pages.
  final List<MarketingSection> sections;

  final String ctaTitle;
  final String ctaBody;

  /// The call-to-action button. By default it opens an account; a page can
  /// point it somewhere else, e.g. a `mailto:` link, and rename it.
  final String ctaLabel;
  final String ctaHref;

  const MarketingPage({
    required this.route,
    required this.eyebrow,
    required this.title,
    required this.lede,
    this.highlights = const [],
    this.features = const [],
    this.faqs = const [],
    this.sections = const [],
    this.ctaTitle = 'Open your account',
    this.ctaBody =
        'It takes a few minutes. Hold the currencies you actually use and move your first payment the same day.',
    this.ctaLabel = 'Open your account',
    this.ctaHref = '/login',
  });
}

class MarketingFeature {
  final IconData icon;
  final String title;
  final String body;
  const MarketingFeature(this.icon, this.title, this.body);
}

class MarketingFaq {
  final String question;
  final String answer;
  const MarketingFaq(this.question, this.answer);
}

class MarketingSection {
  final String heading;
  final String body;
  const MarketingSection(this.heading, this.body);
}

/// Route → page. Also the source of truth for the footer columns, so a link
/// can never point at a route that does not exist.
const marketingPages = <String, MarketingPage>{
  // ── products ──────────────────────────────────────────────────────────
  '/wallet': MarketingPage(
    route: '/wallet',
    eyebrow: 'Multi-currency wallet',
    title: 'Twelve currencies.\nOne account.',
    lede:
        'Hold naira, Kenyan, Ugandan and Tanzanian shillings, cedis, South Sudanese pounds and Liberian dollars alongside US dollars, British pounds, euros, Canadian dollars and yen. Money stays in the currency it arrived in until you decide otherwise, so nobody converts on your behalf at a rate you never saw.',
    highlights: ['NGN · KES · GHS · UGX · TZS · SSP · LRD · USD · GBP · EUR · CAD · JPY', 'No forced conversion', 'One login, one balance sheet'],
    features: [
      MarketingFeature(Icons.account_balance_wallet_outlined, 'Balances that stay put',
          'Get paid in US dollars, keep US dollars. Convert when the rate suits you, not when a settlement job runs.'),
      MarketingFeature(Icons.swap_horiz_rounded, 'Mid-market swaps',
          'Move between your own balances at a rate you can check against the market, with the fee stated before you confirm.'),
      MarketingFeature(Icons.receipt_long_rounded, 'Statements per currency',
          'Every wallet has its own history you can export for your accountant or your own records.'),
      MarketingFeature(Icons.insights_rounded, 'One total that means something',
          'Your combined value in your home currency, recalculated as rates move.'),
    ],
    faqs: [
      MarketingFaq('Which currencies can I hold?',
          'NGN, KES, GHS, UGX, TZS, SSP and LRD, plus USD, GBP, EUR, CAD and JPY today. New currencies are added when the local rails behind them are reliable, not before.'),
      MarketingFaq('Do you convert my money automatically?',
          'No. Funds stay in the currency they arrived in. Conversion only happens when you ask for it.'),
      MarketingFaq('What rate do you use?',
          'The mid-market rate at the moment you confirm, with the fee shown separately rather than buried in a marked-up rate.'),
    ],
  ),
  '/usd-account': MarketingPage(
    route: '/usd-account',
    eyebrow: 'Global USD account',
    title: 'Get paid like\na local.',
    lede:
        'Your own US account number and routing number, plus GBP details. Clients, platforms and marketplaces pay you the way they pay anyone in their own country, and the money lands in your balance.',
    highlights: ['US account + routing number', 'ACH and wire', 'GBP details included'],
    features: [
      MarketingFeature(Icons.south_west_rounded, 'ACH and wire receipts',
          'Payroll, invoices and platform payouts arrive by the same route your client already uses.'),
      MarketingFeature(Icons.public_rounded, 'Works with global platforms',
          'Upwork, Deel, Stripe, YouTube and the rest — the details look like any other US account.'),
      MarketingFeature(Icons.lock_clock_rounded, 'Lands in the currency sent',
          'US dollars stay US dollars until you convert. Nothing is swept into naira on arrival.'),
      MarketingFeature(Icons.description_outlined, 'Proof for your records',
          'Every inbound payment carries the sender reference, so reconciliation is not detective work.'),
    ],
    faqs: [
      MarketingFaq('Is this a real US bank account?',
          'You get US account and routing details issued through licensed partner institutions. gabis is a financial technology company, not a bank.'),
      MarketingFaq('Can I receive from anywhere?',
          'Anywhere that can send ACH or a wire to a US account, plus local GBP transfers to your British pound details.'),
      MarketingFaq('How long do funds take?',
          'ACH typically settles in one to three business days; wires are usually same day once sent.'),
    ],
  ),
  '/virtual-cards': MarketingPage(
    route: '/virtual-cards',
    eyebrow: 'Virtual cards',
    title: 'A card that\nworks abroad.',
    lede:
        'Create a card in seconds and spend from whichever balance makes sense. Subscriptions, ads, flights and shopping — without the decline that means nothing and the call to a bank that cannot help.',
    highlights: ['Visa and Mastercard', 'Spend from any balance', 'Freeze and unfreeze instantly'],
    features: [
      MarketingFeature(Icons.credit_card_rounded, 'Issued instantly',
          'A virtual card is ready before you have finished reading this. Physical cards on request.'),
      MarketingFeature(Icons.ac_unit_rounded, 'Freeze in one tap',
          'Lock the card the moment something looks wrong, unfreeze it when it does not. No support ticket.'),
      MarketingFeature(Icons.tune_rounded, 'Per-card limits',
          'Give one card to a subscription, another to your ads account, and cap each on its own.'),
      MarketingFeature(Icons.autorenew_rounded, 'Rotate the details',
          'New number, same card, same limits — useful when a merchant has been careless with yours.'),
    ],
    faqs: [
      MarketingFaq('Which networks do you issue?',
          'Visa and Mastercard, depending on the card and the region you are spending in.'),
      MarketingFaq('Can I use it for subscriptions and ads?',
          'Yes — streaming, software, hosting, Meta and Google Ads are the most common uses.'),
      MarketingFaq('What happens if a payment is declined?',
          'You see the reason in the app: insufficient balance, a limit you set, or a merchant category block. Not a generic error.'),
    ],
  ),
  '/invoicing': MarketingPage(
    route: '/invoicing',
    eyebrow: 'Smart invoicing',
    title: 'Send it. Get paid.\nStop chasing.',
    lede:
        'Raise an invoice, send it on WhatsApp or email, and let it mark itself paid when the money arrives. Your outstanding figure is the real one, not a spreadsheet you meant to update.',
    highlights: ['WhatsApp, email or link', 'Instalment schedules', 'Reminders before and after due date'],
    features: [
      MarketingFeature(Icons.receipt_long_rounded, 'Invoices in seconds',
          'Client, amount, description, due date. Sent through the channel your customer actually reads.'),
      MarketingFeature(Icons.event_repeat_rounded, 'Instalments that hold',
          'Split a bill into a schedule both sides can see, with reminders ten days ahead of each date.'),
      MarketingFeature(Icons.done_all_rounded, 'Paid means paid',
          'Payment clears the invoice and moves your totals in the same moment. No manual ticking off.'),
      MarketingFeature(Icons.insights_rounded, 'A collection rate you can trust',
          'Billed, collected and outstanding always agree, because they are computed from the same ledger.'),
    ],
    faqs: [
      MarketingFaq('Can customers pay in instalments?',
          'Yes. Set the number of instalments and the dates; everyone sees the same schedule and part payments track against it.'),
      MarketingFaq('How are reminders sent?',
          'WhatsApp, SMS or email — ten days before the due date, on the day, and after it passes.'),
      MarketingFaq('Does this work for schools and tuition?',
          'It is one of the most common uses. See tuition invoicing for how termly fees and parent reminders are handled.'),
    ],
  ),
  '/fx': MarketingPage(
    route: '/fx',
    eyebrow: 'Instant FX swaps',
    title: 'The rate you\ncan check.',
    lede:
        'Convert between your own balances at the mid-market rate, with the fee shown before you confirm and the rate held while you decide.',
    highlights: ['Mid-market rate', 'Fee shown up front', 'Settles against your balance'],
    features: [
      MarketingFeature(Icons.swap_horiz_rounded, 'Any pair you hold',
          'Naira to US dollars, British pounds to naira, yen to anything — in either direction.'),
      MarketingFeature(Icons.timer_outlined, 'Rate locked while you confirm',
          'What you saw is what settles. No slippage between tapping and clearing.'),
      MarketingFeature(Icons.percent_rounded, 'No hidden spread',
          'The fee is a line item. It is not folded into a rounded rate that hides it.'),
      MarketingFeature(Icons.bolt_rounded, 'Instant settlement',
          'The swap clears against your balances immediately — no pending state to babysit.'),
    ],
    faqs: [
      MarketingFaq('Where does your rate come from?',
          'The mid-market rate, which you can verify against any public source at the time of the swap.'),
      MarketingFaq('Are there limits?',
          'Limits depend on your verification level and are shown in the app before you convert.'),
    ],
  ),
  '/bills': MarketingPage(
    route: '/bills',
    eyebrow: 'Bills & airtime',
    title: 'The small things,\nhandled.',
    lede:
        'Airtime, data, electricity tokens and subscriptions from the same balance — with a receipt that arrives when the payment clears, not when it was submitted.',
    highlights: ['Airtime and data', 'Electricity tokens', 'Recurring subscriptions'],
    features: [
      MarketingFeature(Icons.bolt_rounded, 'Tokens that arrive',
          'Electricity tokens are delivered and stored, so you are not screenshotting SMS to find them later.'),
      MarketingFeature(Icons.repeat_rounded, 'Set and forget',
          'Recurring bills run on a schedule you control, and tell you before they go out.'),
      MarketingFeature(Icons.bookmark_border_rounded, 'Saved billers',
          'The ones you repeat are one tap away, with the last amount remembered.'),
      MarketingFeature(Icons.verified_outlined, 'Receipt on clearing',
          'Proof of payment when it is actually done, which is the only time it means anything.'),
    ],
    faqs: [
      MarketingFaq('Which billers are supported?',
          'The major Nigerian networks and discos, with more added as the integrations prove reliable.'),
      MarketingFaq('What if a token does not arrive?',
          'The payment is reversed to your balance automatically if the biller does not confirm delivery.'),
    ],
  ),

  // ── business ──────────────────────────────────────────────────────────
  '/business': MarketingPage(
    route: '/business',
    eyebrow: 'gabis Business',
    title: 'Get paid.\nChase what is owed.',
    lede:
        'The same account, with the tools a small business actually needs: invoices that clear themselves, a collections agent that makes the call, and tax built from money that landed.',
    highlights: ['Invoices and instalments', 'AI debt recovery', 'Multi-currency tax'],
    features: [
      MarketingFeature(Icons.business_center_rounded, 'One account, two modes',
          'Switch between personal and business without a second login or a separate app.'),
      MarketingFeature(Icons.record_voice_over_rounded, 'Collections that run themselves',
          'Reminders, then a conversational call in your customer’s own language, then a payment link.'),
      MarketingFeature(Icons.groups_rounded, 'Customers in one place',
          'Every payer, what they owe, what they have paid and when they next fall due.'),
      MarketingFeature(Icons.account_balance_rounded, 'Filing without the week of work',
          'Tax computed from cleared payments, exportable for your accountant.'),
    ],
    faqs: [
      MarketingFaq('Do I need a registered company?',
          'No. Sole traders, freelancers and informal businesses use it exactly as registered companies do.'),
      MarketingFaq('Can I import my existing debtors?',
          'Yes — name, phone, amount and due date is enough to start collections on day one.'),
    ],
  ),
  '/tuition-invoicing': MarketingPage(
    route: '/tuition-invoicing',
    eyebrow: 'Tuition invoicing',
    title: 'Termly fees,\nwithout the chasing.',
    lede:
        'Built for schools and training providers: issue fees to every parent at once, let them pay in instalments, and see who is short before the term starts rather than after it ends.',
    highlights: ['Bulk fee runs', 'Parent instalment plans', 'Per-class collection view'],
    features: [
      MarketingFeature(Icons.school_rounded, 'Issue a whole term at once',
          'One fee run reaches every parent on the roll, each with their own balance and schedule.'),
      MarketingFeature(Icons.event_repeat_rounded, 'Plans parents can meet',
          'Split fees across the term with reminders that arrive ten days before each date.'),
      MarketingFeature(Icons.fact_check_outlined, 'Know where you stand',
          'Collected, outstanding and overdue by class, so the bursar is not reconciling by hand.'),
      MarketingFeature(Icons.phone_in_talk_rounded, 'Polite follow-up',
          'Overdue balances get a call in the parent’s own language, on the school’s behalf.'),
    ],
    faqs: [
      MarketingFaq('Can parents pay in parts?',
          'Yes. Instalment plans are the default for tuition, and part payments track against the plan.'),
      MarketingFaq('Do parents need the app?',
          'No. They receive a link on WhatsApp or email and can pay without installing anything.'),
    ],
  ),
  '/debt-recovery': MarketingPage(
    route: '/debt-recovery',
    eyebrow: 'AI debt recovery',
    title: 'The chasing\nhappens without you.',
    lede:
        'Load whoever owes you once. Reminders go out on time, a conversational agent makes the call in the customer’s own language, and a one-tap payment link clears the invoice when it lands.',
    highlights: ['English, Pidgin, Yoruba, Hausa, Igbo', 'Transcript for every call', 'Stops the moment it is paid'],
    features: [
      MarketingFeature(Icons.group_add_rounded, 'Add whoever owes you',
          'Name, number, amount, due date. That is enough for collections to start working.'),
      MarketingFeature(Icons.schedule_rounded, 'Reminders on time, every time',
          'Ten days before, on the day, and after. You never have to remember a date again.'),
      MarketingFeature(Icons.record_voice_over_rounded, 'A real conversation',
          'The agent explains the balance, answers the obvious questions and stays polite on your behalf.'),
      MarketingFeature(Icons.task_alt_rounded, 'Payment closes the loop',
          'A WhatsApp link, and when it clears the invoice and your totals update themselves.'),
    ],
    faqs: [
      MarketingFaq('What languages can the agent speak?',
          'English, Nigerian Pidgin, Yoruba, Hausa and Igbo, chosen per customer.'),
      MarketingFaq('Will it keep calling someone who has paid?',
          'No. A cleared payment stops the sequence immediately.'),
      MarketingFaq('Do I see what was said?',
          'Every call has a transcript, an outcome and, where given, a promise-to-pay date.'),
    ],
  ),
  '/connected-payments': MarketingPage(
    route: '/connected-payments',
    eyebrow: 'Connected payments',
    title: 'Collect across\nthree markets.',
    lede:
        'Take payments in Nigeria, Kenya and Ghana and settle into one account, with webhooks pushing every event into your own systems so your ledger is never a guess.',
    highlights: ['NGN, KES, GHS', 'Single settlement account', 'Webhooks on every event'],
    features: [
      MarketingFeature(Icons.public_rounded, 'Local rails, one balance',
          'Bank transfer and mobile money in each market, settling into the account you already use.'),
      MarketingFeature(Icons.webhook_rounded, 'Events you can build on',
          'Created, paid, failed, reversed — delivered to your endpoint with retries and a full log.'),
      MarketingFeature(Icons.link_rounded, 'Links and checkouts',
          'Share a link or embed a checkout; both post the same events to the same place.'),
      MarketingFeature(Icons.rule_folder_rounded, 'Reconciliation that holds',
          'Every payment carries its reference from collection through to settlement.'),
    ],
    faqs: [
      MarketingFaq('Which countries are live?',
          'Nigeria, Kenya and Ghana, with mobile money and bank rails in each.'),
      MarketingFaq('Is there an API?',
          'Yes — collections, payouts and webhooks. Talk to us and we will get you keys.'),
    ],
  ),
  '/bulk-payouts': MarketingPage(
    route: '/bulk-payouts',
    eyebrow: 'Bulk payouts',
    title: 'Pay everyone\nat once.',
    lede:
        'Salaries, contractor payments and supplier runs from one upload, with per-recipient status instead of one number that either worked or did not.',
    highlights: ['Upload once', 'Per-recipient status', 'Retry only what failed'],
    features: [
      MarketingFeature(Icons.upload_file_rounded, 'One file, one run',
          'Upload the list, review the total, approve once. No pasting account numbers.'),
      MarketingFeature(Icons.checklist_rounded, 'Status per person',
          'You see exactly who was paid, who bounced and why — not a batch that silently half-failed.'),
      MarketingFeature(Icons.replay_rounded, 'Retry the failures only',
          'Fix a wrong account and resend that one payment, without touching the rest.'),
      MarketingFeature(Icons.shield_outlined, 'Approval before money moves',
          'Nothing leaves until somebody with the authority confirms the run.'),
    ],
    faqs: [
      MarketingFaq('How many recipients per run?',
          'Runs of several thousand are routine; larger ones are split automatically.'),
      MarketingFaq('Can two people approve?',
          'Yes. Maker-checker approval is available for teams that need it.'),
    ],
  ),

  // ── company ───────────────────────────────────────────────────────────
  '/about': MarketingPage(
    route: '/about',
    eyebrow: 'About gabis',
    title: 'Built for how Africa\nactually moves money.',
    lede:
        'A decade of work made money move across the continent. What sits on top of those rails is still a ledger with a search box. gabis is the layer that reads them and acts.',
    sections: [
      MarketingSection('Why we exist',
          'A Lagos merchant’s money moves across a bank account, mobile money, cash, informal credit and two currencies. Every transaction is recorded somewhere. Almost none of it is ever turned into a decision. We are building the software that closes that gap — not another app that waits to be told what to do.'),
      MarketingSection('What we have shipped',
          'A working multi-currency product: accounts, cards, transfers, FX, invoicing with instalment schedules, bill payments, an AI copilot that reasons over your own transactions, and a collections agent that places real calls. Founder-built, running code, not mockups.'),
      MarketingSection('How we think about your money',
          'The deterministic core computes your financial state on device — categorisation, commitments, burn rate, what is genuinely spare. Numbers that cannot hallucinate. A model only ever phrases and explains them, and nothing moves without your explicit approval.'),
      MarketingSection('Where we are going',
          'Every African business will have a financial brain. gabis starts as the copilot that reads your money and the agent that collects it, and ends as the intelligence layer merchants, freelancers and institutions run their financial lives on.'),
    ],
  ),
  '/careers': MarketingPage(
    route: '/careers',
    eyebrow: 'Careers',
    title: 'Small team.\nReal problems.',
    lede:
        'We are early. That means fewer people, wider scope and work that ships to real users in days rather than quarters. If that is the trade you want, we would like to hear from you.',
    features: [
      MarketingFeature(Icons.code_rounded, 'Engineering',
          'Flutter, Dart and Firebase across mobile, web and functions. You will own features end to end.'),
      MarketingFeature(Icons.psychology_rounded, 'Applied AI',
          'Financial reasoning over messy real-world records, voice agents in African languages, and evaluating reliability where a wrong answer costs someone money.'),
      MarketingFeature(Icons.support_agent_rounded, 'Operations & support',
          'The people who make sure a stuck payment is somebody’s problem within minutes.'),
      MarketingFeature(Icons.handshake_rounded, 'Partnerships',
          'Working with the licensed institutions and rails that make everything else possible.'),
    ],
    sections: [
      MarketingSection('How to apply',
          'There is no formal listing pipeline yet. Write to careers@gabispay.com with what you have built and what you want to work on. Links to real work beat a CV every time. We reply to everyone.'),
    ],
    ctaTitle: 'Work with us',
    ctaBody: 'Send what you have built to careers@gabispay.com. We read everything.',
    ctaLabel: 'Email us',
    ctaHref: 'mailto:careers@gabispay.com?subject=Work%20with%20gabis',
  ),
  '/press': MarketingPage(
    route: '/press',
    eyebrow: 'Press & news',
    title: 'What we have\nsaid publicly.',
    lede:
        'Company news, product milestones and anything we have put on the record. For interviews or comment, write to press@gabispay.com.',
    sections: [
      MarketingSection('Company deck',
          'Our current company deck covers the problem, the product, the architecture and where we are going. It is linked from the footer and free to quote with attribution.'),
      MarketingSection('Product milestones',
          'Multi-currency accounts, virtual cards, invoicing with instalments, the AI copilot over real transaction history, and the autonomous voice collections agent are all live. Multimodal ingestion of receipts and statements is in build.'),
      MarketingSection('Media enquiries',
          'press@gabispay.com for interviews, comment and fact-checking. We will tell you plainly what is shipped and what is not.'),
    ],
    ctaTitle: 'Get in touch',
    ctaBody: 'press@gabispay.com for interviews and comment.',
  ),
  '/brand': MarketingPage(
    route: '/brand',
    eyebrow: 'Brand assets',
    title: 'Use the mark\nproperly.',
    lede:
        'The gabis wordmark, our colours and the rules that keep them recognisable. If you are writing about us or building an integration, this is what you need.',
    features: [
      MarketingFeature(Icons.abc_rounded, 'The wordmark',
          'Always lowercase: gabis. Never Gabis, never GABIS, never with the dot doubled or the mark redrawn.'),
      MarketingFeature(Icons.palette_outlined, 'Core colours',
          'Ink #101010, cream #F4F0E8, electric #4C45FF, lime #D9FF43, coral #FF7657, lilac #D9D0FF.'),
      MarketingFeature(Icons.space_bar_rounded, 'Clear space',
          'Leave at least the height of the g around the mark. Do not crowd it with other logos.'),
      MarketingFeature(Icons.block_rounded, 'What not to do',
          'No stretching, recolouring, outlining, drop shadows, or placing the navy mark on a dark background.'),
    ],
    sections: [
      MarketingSection('Requesting files',
          'Write to brand@gabispay.com for SVG and PNG versions of the wordmark in navy and white. Please do not extract the mark from screenshots.'),
    ],
    ctaTitle: 'Need the files?',
    ctaBody: 'brand@gabispay.com and we will send the full set.',
  ),

  // ── legal ─────────────────────────────────────────────────────────────
  '/terms': MarketingPage(
    route: '/terms',
    eyebrow: 'Legal',
    title: 'Terms of service.',
    lede:
        'The agreement between you and gabis when you use our apps and services. Written to be read, not to be survived.',
    sections: [
      MarketingSection('Who we are',
          'gabis is a financial technology company, not a bank. Money remittance and banking services are provided by our licensed financial institution partners. Where those partners impose their own terms on an account or card, those terms apply alongside these.'),
      MarketingSection('Your account',
          'You must give accurate information when you open an account and keep it current. You are responsible for your credentials and for activity carried out with them. We may ask you to verify your identity before raising limits, and we may limit or suspend an account where we are required to, or where we reasonably suspect fraud.'),
      MarketingSection('Using the services',
          'You agree not to use gabis for anything unlawful, for payments you are not entitled to make, or in a way that puts our partners or other users at risk. We may refuse or reverse a transaction where we are legally required to do so, or where completing it would breach these terms.'),
      MarketingSection('Fees and rates',
          'Fees are shown before you confirm a transaction. Conversion uses the mid-market rate at the moment you confirm, with the fee stated as a separate line rather than folded into the rate. We will tell you before any fee changes take effect.'),
      MarketingSection('Automation and approvals',
          'Features that act on your behalf — payment reminders, collections calls, payday sweeps — only run within limits you set and only after you approve them. Nothing moves money without an explicit confirmation from you.'),
      MarketingSection('Liability',
          'We take responsibility for our own failures and for money we hold incorrectly. We are not liable for losses caused by inaccurate details you supply, by your own device or credentials being compromised, or by events outside our reasonable control.'),
      MarketingSection('Closing your account',
          'You can close your account at any time once your balance is settled. We will give you notice before closing an account ourselves, except where the law requires otherwise.'),
      MarketingSection('Changes and contact',
          'We may update these terms; material changes are notified in the app before they take effect. Questions go to legal@gabispay.com.'),
    ],
    ctaTitle: 'Questions about these terms?',
    ctaBody: 'legal@gabispay.com — a person reads it.',
  ),
  '/privacy': MarketingPage(
    route: '/privacy',
    eyebrow: 'Legal',
    title: 'Privacy policy.',
    lede:
        'What we collect, why we hold it, and what we will never do with it. Your transaction history is the most personal thing you will give us and we treat it that way.',
    sections: [
      MarketingSection('What we collect',
          'Identity and contact details you give us when opening an account; verification documents where regulation requires them; transaction records created by your use of the service; and device and usage data needed to keep accounts secure.'),
      MarketingSection('Why we hold it',
          'To operate your account, to meet anti-money-laundering and know-your-customer obligations, to prevent fraud, and to provide the features you asked for. We do not sell your data, and we do not share it with advertisers.'),
      MarketingSection('On-device reasoning',
          'The copilot computes your financial state on your device wherever it can — categorisation, recurring commitments, burn rate, affordability. That analysis does not require sending your full transaction history anywhere. Where a request needs a model, only the specific context for that question is sent, and never for advertising.'),
      MarketingSection('Who we share with',
          'Our licensed financial institution partners, so payments can actually settle; identity verification providers; and authorities where we are legally compelled. Each receives the minimum needed to do their part.'),
      MarketingSection('How long we keep it',
          'For as long as your account is open, and afterwards for the period financial regulation requires us to retain records. After that it is deleted.'),
      MarketingSection('Your rights',
          'You can ask for a copy of your data, ask us to correct it, or ask for deletion where no legal retention duty applies. Write to privacy@gabispay.com and we will respond within 30 days.'),
    ],
    ctaTitle: 'Exercise your rights',
    ctaBody: 'privacy@gabispay.com — access, correction or deletion requests.',
  ),
  '/security': MarketingPage(
    route: '/security',
    eyebrow: 'Legal',
    title: 'Security.',
    lede:
        'How your money and your data are protected, and what we ask of you. Written plainly, because security advice nobody reads protects nobody.',
    features: [
      MarketingFeature(Icons.lock_rounded, 'Encryption everywhere',
          'Data is encrypted in transit and at rest. Credentials are never stored in plain text.'),
      MarketingFeature(Icons.fingerprint_rounded, 'Device-level access',
          'Biometric unlock and device binding, so a stolen password alone is not enough.'),
      MarketingFeature(Icons.gpp_maybe_outlined, 'Approval before money moves',
          'Every money-moving action is confirmed by you. No automation bypasses that.'),
      MarketingFeature(Icons.visibility_outlined, 'Fraud monitoring',
          'Unusual activity is flagged and, where necessary, held until you confirm it was you.'),
    ],
    sections: [
      MarketingSection('What we will never ask for',
          'We will never ask for your PIN, your password, or a one-time code — not by phone, not on WhatsApp, not by email. Anyone who does is not us. Report it to security@gabispay.com.'),
      MarketingSection('Reporting a vulnerability',
          'If you have found a security issue, write to security@gabispay.com with enough detail to reproduce it. We will acknowledge within two business days, keep you updated, and credit you if you would like us to. Please do not test against other people’s accounts.'),
      MarketingSection('If something goes wrong',
          'Freeze your cards from the app immediately, then contact support. A frozen card cannot be charged, and freezing costs nothing if it turns out to be a false alarm.'),
    ],
    ctaTitle: 'Report a security issue',
    ctaBody: 'security@gabispay.com — acknowledged within two business days.',
  ),
  '/tax-compliance': MarketingPage(
    route: '/tax-compliance',
    eyebrow: 'Legal',
    title: 'Tax compliance.',
    lede:
        'Filing built from money that actually cleared, not from invoices you hoped would land — and a clear line about what we do and do not do for you.',
    features: [
      MarketingFeature(Icons.account_balance_rounded, 'Computed from cleared payments',
          'VAT and income summaries are built from payments that settled, so nothing is counted before it exists.'),
      MarketingFeature(Icons.calendar_month_rounded, 'Period by period',
          'Breakdowns by month, quarter and year, in every currency you were paid in.'),
      MarketingFeature(Icons.download_rounded, 'Export for your accountant',
          'A file your accountant can actually work from, rather than screenshots of a dashboard.'),
      MarketingFeature(Icons.rule_rounded, 'Nothing counted twice',
          'Instalments, refunds and reversals are netted off before a figure is presented.'),
    ],
    sections: [
      MarketingSection('What this is not',
          'gabis is not a tax adviser and these figures are not tax advice. We show you what you collected and what that implies under the rates you select. Filing, and responsibility for what you file, remains yours and your accountant’s.'),
      MarketingSection('Multi-currency income',
          'Income received in foreign currency is reported in that currency and converted at the rate on the date it cleared, so the figures match your bank records rather than today’s rate.'),
    ],
    ctaTitle: 'Talk to us about filing',
    ctaBody: 'support@gabispay.com if your situation is unusual — most are.',
  ),

  // ── support ───────────────────────────────────────────────────────────
  '/help': MarketingPage(
    route: '/help',
    eyebrow: 'Support',
    title: 'Help centre.',
    lede:
        'The questions people actually ask, answered without a maze of articles. If your answer is not here, a person is one message away.',
    faqs: [
      MarketingFaq('How do I open an account?',
          'Download the app or open your account on the web, give your details, and verify your identity. Most people are done in under ten minutes.'),
      MarketingFaq('What do I need to verify my identity?',
          'A government-issued ID and a selfie. Business accounts also need proof the business exists — a registration document or equivalent.'),
      MarketingFaq('How long do transfers take?',
          'Local Nigerian transfers are usually instant. ACH into your USD account settles in one to three business days; wires are typically same day.'),
      MarketingFaq('Why was my card declined?',
          'The app shows the actual reason — balance, a limit you set, or a merchant category. If it says none of those, contact support and we will trace it.'),
      MarketingFaq('How do I freeze a card?',
          'Open the card and tap freeze. It takes effect immediately and you can unfreeze it just as fast.'),
      MarketingFaq('Can I use gabis outside Nigeria?',
          'Yes. The account is built for people who earn in one place and spend in another.'),
      MarketingFaq('How do I get my money out?',
          'Withdraw to any bank account you control, in any currency you hold, from the app.'),
      MarketingFaq('Something went wrong with a payment — what now?',
          'Contact support with the reference. Failed payments are returned to your balance automatically; we will tell you when and why.'),
    ],
    ctaTitle: 'Still stuck?',
    ctaBody: 'support@gabispay.com, or WhatsApp +234 701 888 8303 — both reach a person.',
  ),
  '/contact': MarketingPage(
    route: '/contact',
    eyebrow: 'Support',
    title: 'Contact support.',
    lede:
        'Real people, sensible hours, and no phone tree. WhatsApp +234 701 888 8303, or write to support@gabispay.com — tell us what happened and include a reference if you have one.',
    features: [
      MarketingFeature(Icons.chat_rounded, 'WhatsApp live chat',
          '+234 701 888 8303 — the fastest route for anything urgent, like a stuck payment or a card you need frozen.'),
      MarketingFeature(Icons.mail_outline_rounded, 'Email support',
          'support@gabispay.com for anything that needs a paper trail or a document attached.'),
      MarketingFeature(Icons.business_center_rounded, 'Business enquiries',
          'business@gabispay.com for collections, payouts, API access and partnerships.'),
      MarketingFeature(Icons.gpp_good_outlined, 'Security reports',
          'security@gabispay.com, acknowledged within two business days.'),
    ],
    sections: [
      MarketingSection('What to include',
          'The transaction reference, the amount, the date, and what you expected to happen. That is usually enough for us to find it on the first reply instead of the third.'),
    ],
    ctaTitle: 'Message us',
    ctaBody: 'support@gabispay.com, or WhatsApp +234 701 888 8303.',
  ),
  '/status': MarketingPage(
    route: '/status',
    eyebrow: 'Support',
    title: 'System status.',
    lede:
        'Whether the things that matter are working right now, and what we do when they are not.',
    features: [
      MarketingFeature(Icons.check_circle_outline_rounded, 'Payments and transfers',
          'Local transfers, USD receipts and FX swaps. Operational.'),
      MarketingFeature(Icons.credit_card_rounded, 'Card issuing and spend',
          'Virtual card creation and authorisations. Operational.'),
      MarketingFeature(Icons.receipt_long_rounded, 'Invoicing and collections',
          'Invoice delivery, reminders and collections calls. Operational.'),
      MarketingFeature(Icons.phone_iphone_rounded, 'Apps and web',
          'iOS, Android and the web app. Operational.'),
    ],
    sections: [
      MarketingSection('How we handle incidents',
          'When something breaks we say so in the app rather than waiting for you to notice. You will get what is affected, what is not, and what we are doing — updated as it changes, not once at the end.'),
      MarketingSection('Planned maintenance',
          'Anything that could interrupt payments is announced at least 48 hours ahead and scheduled outside Nigerian business hours.'),
    ],
    ctaTitle: 'Seeing something we are not?',
    ctaBody: 'support@gabispay.com — tell us and we will check immediately.',
  ),
};
