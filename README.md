<p align="center">
  <img src="web/landing/media/gabis-logo.png" alt="gabis" width="260">
</p>

# ElumoPay

> **Get paid. Stay organized. Know your money.**
>
> *ElumoPay is an AI-powered payment + receipt + refund + installment + reconciliation operating system designed for African sellers and service businesses. From payment to proof, Elumo keeps your business on track.*

---

## The Pan-African Business Problem
African micro, small, and medium enterprises (MSMEs) face severe operational friction when dealing with payment collections, credit sales (installments), client refund tracking, tax compliance, and manual bookkeeping. Chasing outstanding debts manually damages customer relationships and consumes valuable business hours.

**ElumoPay** eliminates the chase by automating the entire transaction lifecycle — managing collections, issuing instant receipts, calculating refund deadlines, tracking installment balance milestones, and automatically reconciling ledger entries.

---

## The AI Layer (Google Africa Applied AI Lab Alignment)
ElumoPay is built with an **AI-first architecture**, utilizing semantic parsing and LLMs to assist business owners:

*   **Gemini Reconciliation Engine:** Automatically maps unstructured interbank statement feeds (e.g., Access Bank NIP transfers) to draft invoices in real-time, matching transaction details semantically even with fuzzy names or mismatched descriptions.
*   **AI Voice Reminders (Robot Calls):** Automatically drafts custom, localized scripts and triggers automated voice reminders to debtors (e.g., *"Hello Sarah Okafor, this is an automated voice reminder from Adebayo Retail..."*), freeing business owners from manually chasing debt.
*   **AI Invoice Assistant:** Allows sellers to draft complex multi-currency invoices using natural language (e.g., *"Bill Sarah 150k for brand design"*).
*   **Semantic Financial Search:** Sellers can ask natural language questions (e.g., *"Who has overdue installments?"* or *"Income from photography this month?"*) to get instant intelligence from their transaction history.

---

## Features & Functionality

### 1. Payment Lifecycle Operations
*   **Digital Receipts:** Generates and securely logs a compliant digital proof of payment immediately upon settlement.
*   **Installment Milestone Tracking:** Tracks paid amounts, remaining balances, next payment dates, and service cut-off boundaries for credit transactions.
*   **Refund Policy Countdown:** Configures policy periods (e.g., 7-day or 14-day windows) and counts down deadlines to warn sellers before a customer's refund period closes.

### 2. Multi-Jurisdictional Tax Compliance
*   Supports automated tax calculation and compliance reporting across four major African economic corridors:
    *   **Nigeria (FIRS):** 7.5% VAT, 2.5% - 10% Withholding Tax (WHT).
    *   **Kenya (KRA):** 16% VAT, 3% - 10% WHT.
    *   **Ghana (GRA):** 15% VAT, 3% - 7.5% WHT.
    *   **South Africa (SARS):** 15% VAT, 5% - 15% WHT.
*   **Remit to Treasury:** Simple one-click simulated remittance interface to dispatch calculated taxes directly to regional tax authority accounts.

---

## Tech Stack
*   **Frontend Framework:** Flutter (Web & Mobile cross-platform support).
*   **State Management:** Riverpod.
*   **AI Engine:** Google Gemini API.
*   **Design Paradigm:** Material 3 Dark/Light Adaptive interfaces.

---

## Getting Started

### Prerequisites
*   [Flutter SDK](https://flutter.dev/docs/get-started/install) (Stable Channel)
*   [Dart SDK](https://dart.dev/get-dart)

### Installation & Run
1.  Clone the repository:
    \`\`\`bash
    git clone https://github.com/raphgm/elumopay.git
    cd elumopay
    \`\`\`
2.  Install dependencies:
    \`\`\`bash
    flutter pub get
    \`\`\`
3.  Run the application locally in the browser (or on a device):
    \`\`\`bash
    flutter run -d chrome
    \`\`\`

---

## Licensing & Compliance
ElumoPay operates in partnership with licensed commercial banks and remittance networks.
*   **Nigeria:** NDIC Insured Partner Banks & CBN Licensed Remittances.
*   **Kenya/Ghana/South Africa:** Local partner banking rails and licensed clearing houses.
