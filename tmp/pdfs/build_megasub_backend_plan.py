from reportlab.lib import colors
from reportlab.lib.colors import HexColor
from reportlab.lib.enums import TA_LEFT, TA_CENTER, TA_RIGHT
from reportlab.lib.pagesizes import letter
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.units import inch
from reportlab.platypus import (
    SimpleDocTemplate, Paragraph, Spacer, PageBreak, Table, TableStyle,
    KeepTogether, HRFlowable
)
from xml.sax.saxutils import escape
from datetime import date
from pathlib import Path

OUT = Path("/Users/samuel/Downloads/Megasub_Backend_Implementation_Plan.pdf")

NAVY = HexColor("#10233F")
INK = HexColor("#17263C")
MUTED = HexColor("#5B6B7F")
BRAND = HexColor("#4A55DD")
TEAL = HexColor("#12A594")
PALE = HexColor("#F3F6FB")
PALE_BLUE = HexColor("#EEF1FF")
PALE_GREEN = HexColor("#EAF7F4")
PALE_AMBER = HexColor("#FFF5DF")
LINE = HexColor("#D9E1EC")
WHITE = colors.white
CRITICAL = HexColor("#A52A36")
HIGH = HexColor("#A35E09")
MEDIUM = HexColor("#356A9A")

PAGE_W, PAGE_H = letter
LEFT = RIGHT = 0.62 * inch
TOP = 0.70 * inch
BOTTOM = 0.62 * inch

styles = getSampleStyleSheet()
styles.add(ParagraphStyle(
    name="CoverKicker", fontName="Helvetica-Bold", fontSize=9, leading=12,
    textColor=HexColor("#BFCBFF"), spaceAfter=14, tracking=1.1
))
styles.add(ParagraphStyle(
    name="CoverTitle", fontName="Helvetica-Bold", fontSize=30, leading=34,
    textColor=WHITE, spaceAfter=14
))
styles.add(ParagraphStyle(
    name="CoverSubtitle", fontName="Helvetica", fontSize=13, leading=19,
    textColor=HexColor("#E2E9F5"), spaceAfter=10
))
styles.add(ParagraphStyle(
    name="CoverNote", fontName="Helvetica", fontSize=9.5, leading=14,
    textColor=HexColor("#E2E9F5")
))
styles.add(ParagraphStyle(
    name="SectionTitle", fontName="Helvetica-Bold", fontSize=18, leading=22,
    textColor=NAVY, spaceBefore=2, spaceAfter=10, keepWithNext=True
))
styles.add(ParagraphStyle(
    name="SubTitle", fontName="Helvetica-Bold", fontSize=12, leading=15,
    textColor=NAVY, spaceBefore=8, spaceAfter=5, keepWithNext=True
))
styles.add(ParagraphStyle(
    name="BodyCustom", fontName="Helvetica", fontSize=9.2, leading=13.2,
    textColor=INK, spaceAfter=4
))
styles.add(ParagraphStyle(
    name="SmallCustom", fontName="Helvetica", fontSize=8, leading=10.5,
    textColor=MUTED, spaceAfter=2
))
styles.add(ParagraphStyle(
    name="LabelCustom", fontName="Helvetica-Bold", fontSize=8, leading=10,
    textColor=BRAND, spaceBefore=3, spaceAfter=2, keepWithNext=True
))
styles.add(ParagraphStyle(
    name="CardTitle", fontName="Helvetica-Bold", fontSize=11.1, leading=14,
    textColor=WHITE
))
styles.add(ParagraphStyle(
    name="CardId", fontName="Helvetica-Bold", fontSize=8.8, leading=11,
    textColor=WHITE
))
styles.add(ParagraphStyle(
    name="TableHead", fontName="Helvetica-Bold", fontSize=8.1, leading=10,
    textColor=WHITE
))
styles.add(ParagraphStyle(
    name="TableCell", fontName="Helvetica", fontSize=7.8, leading=10.3,
    textColor=INK
))
styles.add(ParagraphStyle(
    name="TableCellBold", fontName="Helvetica-Bold", fontSize=7.8, leading=10.3,
    textColor=NAVY
))
styles.add(ParagraphStyle(
    name="CalloutTitle", fontName="Helvetica-Bold", fontSize=9.4, leading=12,
    textColor=NAVY, spaceAfter=3
))
styles.add(ParagraphStyle(
    name="FooterCustom", fontName="Helvetica", fontSize=7, leading=8,
    textColor=MUTED
))
styles.add(ParagraphStyle(
    name="CenterSmall", fontName="Helvetica", fontSize=8, leading=11,
    textColor=MUTED, alignment=TA_CENTER
))

def P(text, style="BodyCustom"):
    return Paragraph(text, styles[style])

def plain(text, style="BodyCustom"):
    return P(escape(text), style)

def label(text):
    return P(escape(text.upper()), "LabelCustom")

def bullet(text):
    return P("- " + escape(text), "BodyCustom")

def callout(title, body, bg=PALE_BLUE, border=BRAND):
    table = Table(
        [[P(escape(title), "CalloutTitle")],
         [P(escape(body), "BodyCustom")]],
        colWidths=[7.1 * inch]
    )
    table.setStyle(TableStyle([
        ("BACKGROUND", (0, 0), (-1, -1), bg),
        ("BOX", (0, 0), (-1, -1), 0.8, border),
        ("LEFTPADDING", (0, 0), (-1, -1), 11),
        ("RIGHTPADDING", (0, 0), (-1, -1), 11),
        ("TOPPADDING", (0, 0), (-1, 0), 9),
        ("BOTTOMPADDING", (0, 0), (-1, 0), 2),
        ("TOPPADDING", (0, 1), (-1, 1), 1),
        ("BOTTOMPADDING", (0, 1), (-1, 1), 8),
    ]))
    return table

def section_heading(number, title, intro=None):
    out = [P(f"{escape(number)}  {escape(title)}", "SectionTitle")]
    if intro:
        out.append(plain(intro))
        out.append(Spacer(1, 5))
    return out

def req_card(item):
    priority_color = {
        "Critical": CRITICAL,
        "High": HIGH,
        "Medium": MEDIUM,
    }[item["priority"]]
    header = Table(
        [[P(escape(item["id"]), "CardId"),
          P(escape(item["title"]), "CardTitle"),
          P(f"<font color='white'><b>{escape(item['priority'].upper())}</b></font>", "CardId")]],
        colWidths=[0.68 * inch, 5.43 * inch, 0.99 * inch],
    )
    header.setStyle(TableStyle([
        ("BACKGROUND", (0, 0), (-1, -1), NAVY),
        ("BACKGROUND", (0, 0), (0, 0), BRAND),
        ("BACKGROUND", (2, 0), (2, 0), priority_color),
        ("VALIGN", (0, 0), (-1, -1), "MIDDLE"),
        ("LEFTPADDING", (0, 0), (-1, -1), 8),
        ("RIGHTPADDING", (0, 0), (-1, -1), 8),
        ("TOPPADDING", (0, 0), (-1, -1), 8),
        ("BOTTOMPADDING", (0, 0), (-1, -1), 8),
    ]))

    body = []
    body.append(label("Feedback link"))
    body.append(plain(item["source"], "SmallCustom"))
    body.append(label("Problem and impact"))
    body.append(plain(item["problem"]))
    body.append(label("Backend work"))
    body.extend(bullet(x) for x in item["work"])
    body.append(label("API and data contract"))
    contract = Table(
        [[P(escape(item["contract"]), "TableCell")]],
        colWidths=[7.1 * inch],
    )
    contract.setStyle(TableStyle([
        ("BACKGROUND", (0, 0), (-1, -1), PALE),
        ("BOX", (0, 0), (-1, -1), 0.5, LINE),
        ("LEFTPADDING", (0, 0), (-1, -1), 8),
        ("RIGHTPADDING", (0, 0), (-1, -1), 8),
        ("TOPPADDING", (0, 0), (-1, -1), 6),
        ("BOTTOMPADDING", (0, 0), (-1, -1), 6),
    ]))
    body.append(contract)
    body.append(label("Acceptance criteria"))
    body.append(plain(item["acceptance"]))

    card = Table([[header], [body]], colWidths=[7.1 * inch])
    card.setStyle(TableStyle([
        ("BOX", (0, 0), (-1, -1), 0.7, LINE),
        ("LEFTPADDING", (0, 0), (-1, -1), 0),
        ("RIGHTPADDING", (0, 0), (-1, -1), 0),
        ("TOPPADDING", (0, 0), (-1, 0), 0),
        ("BOTTOMPADDING", (0, 0), (-1, 0), 0),
        ("TOPPADDING", (0, 1), (-1, 1), 9),
        ("BOTTOMPADDING", (0, 1), (-1, 1), 9),
        ("LEFTPADDING", (0, 1), (-1, 1), 10),
        ("RIGHTPADDING", (0, 1), (-1, 1), 10),
    ]))
    return KeepTogether([card, Spacer(1, 10)])

def table(data, widths, header=True, font_size=7.8, padd=5):
    converted = []
    for ri, row in enumerate(data):
        converted_row = []
        for cell in row:
            if isinstance(cell, Paragraph):
                converted_row.append(cell)
            else:
                converted_row.append(P(escape(str(cell)), "TableHead" if (header and ri == 0) else "TableCell"))
        converted.append(converted_row)
    t = Table(converted, colWidths=widths, repeatRows=1 if header else 0, hAlign="LEFT")
    commands = [
        ("GRID", (0, 0), (-1, -1), 0.45, LINE),
        ("VALIGN", (0, 0), (-1, -1), "TOP"),
        ("LEFTPADDING", (0, 0), (-1, -1), padd),
        ("RIGHTPADDING", (0, 0), (-1, -1), padd),
        ("TOPPADDING", (0, 0), (-1, -1), padd),
        ("BOTTOMPADDING", (0, 0), (-1, -1), padd),
    ]
    if header:
        commands.append(("BACKGROUND", (0, 0), (-1, 0), NAVY))
        for ri in range(1, len(converted)):
            if ri % 2 == 0:
                commands.append(("BACKGROUND", (0, ri), (-1, ri), PALE))
    t.setStyle(TableStyle(commands))
    return t

def on_page(canvas, doc):
    canvas.saveState()
    page = canvas.getPageNumber()
    if page == 1:
        canvas.setFillColor(NAVY)
        canvas.rect(0, 0, PAGE_W, PAGE_H, fill=1, stroke=0)
        canvas.setFillColor(BRAND)
        canvas.rect(0, PAGE_H - 0.16 * inch, PAGE_W, 0.16 * inch, fill=1, stroke=0)
        canvas.setFillColor(TEAL)
        canvas.rect(0, 0, 0.12 * inch, PAGE_H, fill=1, stroke=0)
    else:
        canvas.setFillColor(NAVY)
        canvas.rect(0, PAGE_H - 0.36 * inch, PAGE_W, 0.36 * inch, fill=1, stroke=0)
        canvas.setFillColor(WHITE)
        canvas.setFont("Helvetica-Bold", 7.5)
        canvas.drawString(LEFT, PAGE_H - 0.235 * inch, "MEGASUB  /  BACKEND IMPLEMENTATION PLAN")
        canvas.setStrokeColor(LINE)
        canvas.line(LEFT, 0.43 * inch, PAGE_W - RIGHT, 0.43 * inch)
        canvas.setFont("Helvetica", 7)
        canvas.setFillColor(MUTED)
        canvas.drawString(LEFT, 0.25 * inch, "Requirements from the supplied tester feedback and backend fixes document")
        canvas.drawRightString(PAGE_W - RIGHT, 0.25 * inch, f"Page {page}")
    canvas.restoreState()

REQS = [
    {
        "id": "BE-01", "title": "Block unverified email accounts", "priority": "Critical",
        "source": "Tester feedback ONB-001, page 2. Backend fixes document, page 2.",
        "problem": "Registration issues a usable token before email confirmation. The tester could leave verification, load the dashboard, and request a funding account.",
        "work": [
            "Keep registration and confirmation endpoints available, but reject protected account actions until confirm_email_verification succeeds.",
            "Enforce the gate in middleware or shared authorization logic, not only in individual screens. Cover dashboard, purchases, funding account generation, card actions, and other account services.",
            "Return HTTP 403 with code EMAIL_NOT_VERIFIED for blocked requests.",
            "Return email_verified and email_verified_at in the user object from login and dashboard so the app can route unfinished accounts correctly.",
        ],
        "contract": "Unverified protected request: HTTP 403, status false, code EMAIL_NOT_VERIFIED, and a readable next step. Login and dashboard user objects expose email_verified and email_verified_at.",
        "acceptance": "An unverified account cannot load protected account data, purchase, or receive a virtual account on any device. The result remains blocked if a modified client skips the verification screen."
    },
    {
        "id": "BE-02", "title": "Enforce phone verification on the server", "priority": "Critical",
        "source": "Tester feedback ONB-002, page 2. Backend fixes document, page 2.",
        "problem": "Phone verification can be bypassed. Some confirmation responses report success even when the OTP is wrong, and some omit data.verified.",
        "work": [
            "Return data.verified as a boolean on every confirm_phone_verification response.",
            "For a wrong or expired code, return HTTP 422 with status false and a specific error. Do not rely on a top-level status true.",
            "Persist verified phone state on the user and expose phone_verified on login and dashboard.",
            "Apply unverified-phone restrictions on every relevant purchase route, including scheduled execution, rather than trusting a client flag.",
        ],
        "contract": "Success has data.verified = true. Rejection has data.verified = false, HTTP 422, status false, and a machine-readable code or field error. Login and dashboard expose phone_verified.",
        "acceptance": "A wrong code never advances signup. A request from an unverified phone cannot bypass server limits by changing the app or calling an endpoint directly."
    },
    {
        "id": "BE-03", "title": "Normalize unique phones and limit OTP abuse", "priority": "Critical",
        "source": "Tester feedback ONB-003, page 2. Backend fixes document, page 2.",
        "problem": "The same temporary phone number was accepted for multiple accounts, and OTP sends can be abused.",
        "work": [
            "Normalize Nigerian numbers before uniqueness checks. Treat 0XXXXXXXXXX, 234XXXXXXXXXX, and +234XXXXXXXXXX as the same phone.",
            "Make the verified phone unique across accounts with a database constraint or equivalent race-safe enforcement.",
            "Rate-limit OTP sends and attempts per phone number, device, and IP. Return a clear wait time.",
            "Assess blocking known virtual or temporary number ranges if product policy requires it.",
        ],
        "contract": "A duplicate verified number returns a clear 422, such as This phone number is already in use. Rate limiting returns HTTP 429 with Retry-After.",
        "acceptance": "Equivalent local and international formats cannot be registered on multiple accounts. Repeated OTP requests are limited and logged."
    },
    {
        "id": "BE-04", "title": "Validate transaction PIN on every protected call", "priority": "Critical",
        "source": "Tester feedback SEC-001, page 27. Backend fixes document, page 3.",
        "problem": "A wrong PIN still opened the Top Up flow and showed funding account details. This is a server authorization defect.",
        "work": [
            "Validate the PIN on fetch_naira_virtual_accounts, fetch_user_naira_funding_transactions, every buy_* endpoint, scheduled_purchases, card funding and other PIN-gated account calls.",
            "Return HTTP 403 with code INVALID_PIN, a plain-language Incorrect PIN message, and attempts remaining.",
            "Throttle PIN attempts and lock PIN use for 30 minutes after five wrong attempts, as specified in the backend checklist.",
            "Ensure no account details, funds, purchases, or card actions are returned before the PIN is validated.",
        ],
        "contract": "Wrong PIN: HTTP 403, status false, code INVALID_PIN, readable message, and remaining attempts. Correct PIN: endpoint proceeds only after server validation.",
        "acceptance": "The wrong PIN is refused on every protected route. Five incorrect tries trigger the temporary lock. No frontend navigation state can unlock server data."
    },
    {
        "id": "BE-05", "title": "Preserve PIN strings and protect PIN changes", "priority": "Critical",
        "source": "Tester feedback PAY-003, page 17. Backend fixes document, page 3.",
        "problem": "Setting a PIN failed with raw validation keys. PIN changes could overwrite an existing PIN without proving the old PIN or completing recovery.",
        "work": [
            "Validate PIN and confirmation as strings with exactly four digits. Never cast to an integer, so leading zeroes remain valid.",
            "Use translated validation messages and return ordinary text rather than validation.integer keys.",
            "When a PIN already exists, require the current PIN or the approved forgot-PIN OTP flow before replacement.",
            "Return pin_set consistently from login and dashboard so the app can distinguish new setup from an existing PIN.",
        ],
        "contract": "PIN setup accepts values such as 0123 and returns pin_set = true after success. A change without current PIN or recovery OTP returns a clear rejection.",
        "acceptance": "Leading-zero PINs can be set and checked. Existing PINs cannot be silently replaced by a session holder. Validation responses contain no untranslated framework keys."
    },
    {
        "id": "BE-06", "title": "Make purchases idempotent on the server", "priority": "Critical",
        "source": "Tester feedback PAY-003, page 17. Backend fixes document, page 3.",
        "problem": "A timeout retry, another device, or a modified client can submit the same purchase twice. The app now sends a client reference, but only the server can prevent duplicate charge and delivery.",
        "work": [
            "Accept a UUID client_reference on every buy_* request, scheduled_purchases creation or execution, and fund_card.",
            "Use a unique user and reference key and persist the original transaction result. A repeat must return that same result rather than create a second charge or provider delivery.",
            "Make wallet debit, transaction record, and provider dispatch safe under concurrency. A database uniqueness rule or transaction lock should protect the idempotency decision.",
            "Also detect the same user, product, recipient, and amount within 60 seconds. Require explicit confirmation for a legitimate repeat when policy allows it.",
            "Keep idempotency records long enough to cover client retries and provider callbacks. Do not depend on the app's in-memory retry cache.",
        ],
        "contract": "The app sends client_reference as a UUID. A repeated reference returns the original transaction identifier and status. The same purchase cannot be charged or delivered twice.",
        "acceptance": "Submit the same request concurrently and sequentially with the same reference. Verify one debit, one transaction, and at most one provider delivery. Retry after a simulated lost response and confirm the original result is returned."
    },
    {
        "id": "BE-07", "title": "Enable production KYC and test all outcomes", "priority": "Critical",
        "source": "Tester feedback KYC-001, page 10, and ONB-004, page 3. Backend fixes document, page 3.",
        "problem": "BVN verification reports that verification is off, while card KYC reports unavailable or cannot be submitted.",
        "work": [
            "Configure and enable the production KYC provider and confirm credentials, callback URLs, allowlists, and environment settings.",
            "Exercise verified, rejected, pending, retryable-provider-error, permanent-provider-error, and disabled states end to end.",
            "Do not report verified unless the provider result meets the configured match policy.",
            "Return a stable response that lets the app distinguish unavailable service from a user rejection or pending review.",
        ],
        "contract": "KYC status and submit responses clearly identify status, verified state, provider availability, attempts, fees, and any next action that the app must show.",
        "acceptance": "A real test account can complete BVN and card KYC in production-like conditions and gets a truthful result for success, failure, pending, retry, and provider outage."
    },
    {
        "id": "BE-08", "title": "Return the actual failure reason", "priority": "High",
        "source": "Tester feedback ONB-006, PAY-007, PAY-008, PAY-009, and UI-005. Backend fixes document, page 4.",
        "problem": "Rate limits, insufficient balance, network mismatch, meter validation, and provider failures were surfaced as generic HTTP 500 errors.",
        "work": [
            "Use HTTP 429 plus Retry-After for OTP or request throttling.",
            "Use HTTP 422 with machine codes such as INSUFFICIENT_BALANCE, NETWORK_MISMATCH, and INVALID_METER for correctable user or validation errors.",
            "Use HTTP 503 with PROVIDER_UNAVAILABLE and the provider name when an upstream service is down.",
            "Reserve HTTP 500 for unexpected server failures. Log technical detail internally while keeping secrets and personal data out of user-visible messages.",
        ],
        "contract": "Every error includes a stable status, code, readable message, and field errors where relevant. The app can show the reason and a useful next step without parsing stack text.",
        "acceptance": "Trigger each listed error and confirm it has the expected HTTP status and code. Confirm actual crashes still return 500 and are logged or alerted."
    },
    {
        "id": "BE-09", "title": "Enforce recipient network validation before charging", "priority": "High",
        "source": "Tester feedback PAY-005, page 19. Backend fixes document, page 4.",
        "problem": "An MTN recharge to a Glo number proceeded as successful. Data mismatch paths also returned a server error.",
        "work": [
            "When validatephonenetwork is 1, determine the recipient's current network using a provider lookup that supports ported numbers.",
            "Compare the current network to the selected network before debiting the wallet or dispatching fulfillment.",
            "Apply the same rule to scheduled purchases when they execute. The mobile app now sends 1 for scheduled airtime and already does so for immediate airtime/data.",
            "If validation cannot be completed, fail safely without charging and return a retryable provider or validation error.",
        ],
        "contract": "A mismatch returns HTTP 422, code NETWORK_MISMATCH, and names the expected or detected network. No wallet debit or provider request occurs.",
        "acceptance": "Test matching, mismatching, and ported numbers for immediate and scheduled airtime/data. A mismatch never moves money."
    },
    {
        "id": "BE-10", "title": "Publish and validate amount limits", "priority": "High",
        "source": "Tester feedback PAY-006, pages 20-21. Backend fixes document, page 4.",
        "problem": "An amount below the allowed minimum failed with a generic validation message. The app currently uses NGN 50 as an airtime fallback until real plan limits arrive.",
        "work": [
            "Return minimum_amount and maximum_amount for applicable plans from fetch_product_plans.",
            "Enforce those limits again on the purchase endpoint. Client-side checks are only a usability aid.",
            "Return a specific errors.amount message that states the actual minimum or maximum for the selected product.",
            "Keep limits consistent across catalog, purchase, scheduled purchase, and any bulk endpoint.",
        ],
        "contract": "Plan data includes minimum_amount and maximum_amount where applicable. Out-of-range purchase returns HTTP 422 and a clear amount field error.",
        "acceptance": "Verify the app displays API-provided values, and direct API requests below or above the limit are rejected without a debit."
    },
    {
        "id": "BE-11", "title": "Support username and normalized phone login", "priority": "High",
        "source": "Tester feedback ONB-008, page 7. Backend fixes document, page 5.",
        "problem": "The mobile app sends the typed identifier, but the service was matching email only.",
        "work": [
            "Match the login identifier against email, username, and normalized phone number.",
            "Normalize phone input using the same rules as BE-03 before lookup.",
            "Keep the response wording equivalent for unknown identifier and wrong password to avoid account enumeration.",
            "Return verification flags and pin_set in the account object without returning unnecessary personal data.",
        ],
        "contract": "The same login endpoint accepts email, username, and phone identifier and returns the same session shape.",
        "acceptance": "Authenticate one test account using each supported identifier and confirm all resolve to that account. Confirm unknown user and wrong password do not reveal which value was incorrect."
    },
    {
        "id": "BE-12", "title": "Include wallet funding in normal transaction history", "priority": "High",
        "source": "Tester feedback WAL-002, page 13. Backend fixes document, page 5.",
        "problem": "Wallet funding credits are available only through fetch_user_naira_funding_transactions, which requires the transaction PIN. This prevents them from appearing in the ordinary Wallet and History feed.",
        "work": [
            "Include funding credits in fetch_transactions with transaction_category = wallet_funding.",
            "Return a stable transaction id, amount, created_at, status, reference, and bank name.",
            "Respect the same user ownership, date range, ordering, and pagination rules as other transaction rows.",
            "Use a consistent amount and status representation so the mobile app can format credits and receipts.",
        ],
        "contract": "A wallet top-up appears in fetch_transactions without a PIN and has category wallet_funding plus amount, date, status, reference, and bank.",
        "acceptance": "Fund a test account, then load Wallet and History using the normal endpoint. Every top-up appears once with the correct amount, date, status, reference, and bank."
    },
    {
        "id": "BE-13", "title": "Never treat demo products as real purchases", "priority": "High",
        "source": "Tester feedback PAY-001, pages 14-15. Backend fixes document, page 5.",
        "problem": "A result-checker purchase returned a successful demo PIN. eSIM purchase also failed for a funded NGN user because the service debited an unclear USD wallet.",
        "work": [
            "If a provider is not live, return HTTP 503 with data.available = false and do not debit the wallet or return demo PINs, serials, cards, or eSIM assets.",
            "For eSIM, either convert from the NGN wallet at checkout using a disclosed rate and charge breakdown, or implement a usable USD funding route.",
            "Explain which wallet is required and why when a purchase cannot proceed.",
            "Return a real provider or transaction status only when it reflects actual fulfillment.",
        ],
        "contract": "Unavailable product: HTTP 503, data.available = false, a clear message, and no debit. Successful result checker and eSIM responses contain real provider-backed results only.",
        "acceptance": "When a product is unavailable, no demo asset is returned and balance is unchanged. A normally funded user can complete eSIM through the documented funding route."
    },
    {
        "id": "BE-14", "title": "Confirm and expose the airtime daily limit", "priority": "High",
        "source": "Tester feedback PAY-002, page 16. Backend fixes document, page 6.",
        "problem": "A first-time tester saw a daily limit message for NGN 5,000 without seeing the limit or remaining allowance beforehand.",
        "work": [
            "Confirm the NGN 5,000 limit with product and document whether it varies by account, verification state, or date.",
            "Expose daily_limit, spent_today, remaining_today, and any unverified-phone cap through dashboard or a dedicated limits endpoint.",
            "Enforce the same limit atomically when processing purchases so simultaneous requests cannot exceed it.",
            "Return a specific machine code and user-readable message when a purchase reaches the cap.",
        ],
        "contract": "The app can fetch the user's applicable limit and remaining amount before payment. A blocked request identifies the limit and current remaining allowance.",
        "acceptance": "Verify the app displays the correct limit before purchase and the server rejects the first request that exceeds it without charging."
    },
    {
        "id": "BE-15", "title": "Measure delivery and report pending status", "priority": "Medium",
        "source": "Tester feedback PAY-011, page 26. Backend fixes document, page 6.",
        "problem": "Some purchased items took several minutes to arrive, and the client had no timing information or reliable pending status.",
        "work": [
            "Measure time from wallet debit to provider confirmation by product and provider.",
            "Move slow provider calls to a queue where appropriate. Return a transaction identifier and pending status promptly after accepting the request.",
            "Expose a status refresh route or push notification when fulfillment completes or fails.",
            "Set and monitor a service target. The source document suggests 95 percent within 30 seconds for airtime/data as an example, subject to product approval.",
        ],
        "contract": "The response distinguishes accepted/pending, successful, and failed. A stable transaction id can be queried, and completion can trigger a notification.",
        "acceptance": "Latency dashboards show provider-level timings. Slow requests remain pending instead of appearing falsely complete, and users receive the final status."
    },
    {
        "id": "BE-16", "title": "Apply coupon network rules and update availability", "priority": "Medium",
        "source": "Tester feedback UI-006, page 32. Backend fixes document, page 7.",
        "problem": "A coupon for one network qualified on another, and its slots_remaining value did not decrease after use.",
        "work": [
            "Return network_id with every active coupon and accept network_id plus product_plan_id in coupon qualification requests.",
            "Validate network, plan, coupon status, eligibility, and remaining slots again during purchase. Do not trust a prior qualification check.",
            "Accept coupon_code on airtime/data purchase requests, calculate the authoritative discount on the server, and return the actual charged amount.",
            "Decrement slots_remaining atomically only when a discounted purchase succeeds. Concurrent purchases must not overuse the last slots.",
        ],
        "contract": "Active coupon includes network context and current slots_remaining. Qualification accepts user_id, coupon_code, network_id, and product_plan_id. Purchase accepts coupon_code and returns authoritative amount/discount fields.",
        "acceptance": "A coupon cannot qualify or apply to a different network/plan. Failed purchases do not consume slots. A successful discounted purchase consumes exactly one slot and the next fetch shows the updated count."
    },
    {
        "id": "BE-17", "title": "Return a stable BVN profile for prefill", "priority": "Medium",
        "source": "Tester feedback ONB-005, page 4. Backend fixes document, page 7.",
        "problem": "The BVN lookup response did not provide a stable, usable shape for the card KYC form. KYC was also reported disabled.",
        "work": [
            "After a successful verified lookup, return first_name, last_name, date_of_birth, and phone in fixed fields.",
            "Expose the verified profile through the response the app reads, including fetch_kyc_status when the profile is already saved.",
            "Define which fields may be corrected and enforce those rules on submit. Do not accept client-provided identity values as authoritative.",
            "Return no verified profile when verification failed or is pending unless product policy explicitly allows a limited review state.",
        ],
        "contract": "A verified KYC response exposes a stable profile object containing first_name, last_name, date_of_birth, and phone, plus a clear verified status.",
        "acceptance": "After a successful BVN lookup, the app pre-fills the eligible card KYC fields. A failed or pending lookup does not display a verified profile, and server-side correction rules are enforced."
    },
]

story = []

# Cover
story.append(Spacer(1, 1.03 * inch))
story.append(P("MEGASUB  /  ENGINEERING HANDOFF", "CoverKicker"))
story.append(P("Backend<br/>Implementation Plan", "CoverTitle"))
story.append(P(
    "API requirements for the mobile update and tester feedback",
    "CoverSubtitle"
))
story.append(Spacer(1, 0.18 * inch))
story.append(HRFlowable(width="100%", thickness=1, color=HexColor("#536889"), spaceBefore=3, spaceAfter=16))
story.append(P(
    "A detailed, testable checklist for the Megasub API at "
    "mega-sub.com/api/v1/external. It separates frontend work already present "
    "from the server work required for secure and reliable behavior.",
    "CoverSubtitle"
))
story.append(Spacer(1, 0.42 * inch))
cover_info = Table([
    [P("<b>Scope</b><br/>17 backend fixes: 7 critical, 7 high, 3 medium", "CoverNote"),
     P("<b>Prepared</b><br/>9 November 2026", "CoverNote")],
    [P("<b>Based on</b><br/>Tester feedback and backend fixes PDFs", "CoverNote"),
     P("<b>Document status</b><br/>Requirements and acceptance plan", "CoverNote")],
], colWidths=[3.45 * inch, 3.45 * inch])
cover_info.setStyle(TableStyle([
    ("BACKGROUND", (0, 0), (-1, -1), HexColor("#1B3558")),
    ("BOX", (0, 0), (-1, -1), 0.6, HexColor("#526987")),
    ("INNERGRID", (0, 0), (-1, -1), 0.45, HexColor("#526987")),
    ("VALIGN", (0, 0), (-1, -1), "TOP"),
    ("LEFTPADDING", (0, 0), (-1, -1), 12),
    ("RIGHTPADDING", (0, 0), (-1, -1), 12),
    ("TOPPADDING", (0, 0), (-1, -1), 12),
    ("BOTTOMPADDING", (0, 0), (-1, -1), 12),
]))
story.append(cover_info)
story.append(Spacer(1, 0.42 * inch))
story.append(P(
    "Important: this document records backend acceptance requirements. The checked "
    "Megasub checkout contains the mobile app, not the API implementation, so the "
    "items below are not a claim that each production endpoint was re-tested or is "
    "currently failing.",
    "CoverNote"
))
story.append(PageBreak())

# Executive summary
story += section_heading("1.", "Executive summary",
    "The mobile app is prepared to consume the API fields and responses listed here. "
    "The backend remains responsible for authorization, PIN checks, idempotency, "
    "wallet debits, provider fulfillment, and durable KYC and coupon decisions.")
story.append(callout(
    "Release focus",
    "Complete BE-01 through BE-06 first because they protect identity, account access, "
    "PINs, and money movement. Then standardize BE-08 error responses, which resolve "
    "several tester issues at once. Track BE-07 as a release gate if KYC is part of "
    "the launch scope.",
    PALE_AMBER, HIGH
))
story.append(Spacer(1, 10))
story.append(P("What this plan covers", "SubTitle"))
for txt in [
    "All 17 API fixes in the supplied backend fixes document, with the tester issue mapping, implementation tasks, response contract, and a measurable done condition.",
    "The new mobile expectations for client_reference, coupon context and code, pin-free wallet funding history, strict phone verification, and verified BVN profile prefill.",
    "A release test checklist for security, payment correctness, history, KYC, coupons, and delivery status.",
]:
    story.append(bullet(txt))
story.append(Spacer(1, 5))
story.append(P("Verification boundary", "SubTitle"))
story.append(plain(
    "No Megasub backend source or staging credentials were available in the checked app checkout. "
    "The backend fixes PDF reports the server-side work to be done, while the tester feedback PDF "
    "marks its 32 issues Open. Confirm each item against the deployed API before closing it."
))
story.append(Spacer(1, 8))
story.append(P("Priority summary", "SubTitle"))
story.append(table([
    ["Priority", "Backend items", "Count", "Release meaning"],
    ["Critical", "BE-01 to BE-07", "7", "Identity gates, phone uniqueness, PIN security, duplicate charges, and KYC availability."],
    ["High", "BE-08 to BE-14", "7", "Actionable errors, network and amount validation, login, history, product safety, and limits."],
    ["Medium", "BE-15 to BE-17", "3", "Delivery speed/status, coupon correctness, and BVN profile prefill."],
], [0.9*inch, 1.15*inch, 0.5*inch, 4.55*inch]))
story.append(PageBreak())

# Frontend update
story += section_heading("2.", "Frontend work delivered",
    "These changes are in the Megasub mobile checkout. They prepare the client for the documented API behavior, but do not replace server-side validation.")
story.append(P("Changes from the latest update", "SubTitle"))
for txt in [
    "Phone confirmation is fail-closed. Signup proceeds only when confirm_phone_verification explicitly returns data.verified = true.",
    "Money-moving POSTs send client_reference UUIDs. The same purchase retries reuse the reference for a short in-memory window, while identical in-flight taps still share one request. The server must remain authoritative and durable.",
    "Scheduled airtime sends validatephonenetwork = 1, matching the immediate airtime and data flows.",
    "Coupon qualification sends network_id and product_plan_id. Active coupon lookup sends network_id. Airtime and data purchase requests include coupon_code, and purchase success views use the amount returned by the API.",
    "Wallet, Home Recent Activity, History, and receipts can render transaction_category = wallet_funding, show a positive credit, and display bank/reference fields. PIN-based funding history remains as a compatibility fallback while the backend feed is missing.",
    "Card KYC pre-fills name, date of birth, email, and phone when fetch_kyc_status provides a verified BVN profile. BVN details are displayed only for verified status. KYC Back uses the previous-screen stack.",
]:
    story.append(bullet(txt))
story.append(Spacer(1, 5))
story.append(P("Frontend work already present from the earlier app audit", "SubTitle"))
for txt in [
    "Signup records its progress and can resume at email verification, phone verification, or PIN setup. Login/dashboard verification flags are consumed when the API returns them.",
    "Login submits the typed identifier, and Google sign-in resets the provider session so the account chooser can appear.",
    "OTP entry supports paste/autofill through a single input. PIN/OTP entry uses the same pattern for typing and deletion.",
    "API errors show Retry-After waits, field validation messages, and specific backend messages when supplied. Sensitive PIN and identity values are redacted from request logs.",
    "In-flight duplicate purchase taps are suppressed. Airtime shows an NGN 50 fallback minimum and uses plan limits when the API supplies them.",
    "Phone/network mismatch warnings appear before confirmation, and current purchase payloads request network validation.",
    "Amount fields use thousands separators. Bulk entry accepts multiple lines. Balance visibility persists securely. Profile navigation and the scheduled-purchase PIN step are present.",
    "Unavailable products are presented as unavailable rather than as real demo purchases when the API provides the availability flag.",
]:
    story.append(bullet(txt))
story.append(Spacer(1, 7))
story.append(callout(
    "Backend dependencies introduced or made explicit by the mobile update",
    "The API must accept client_reference, coupon_code, network_id and product_plan_id in the specified flows; return data.verified as a boolean; include wallet_funding rows in fetch_transactions; and expose a stable verified BVN profile. If those contracts are absent, the app will fail closed or retain its documented fallback.",
    PALE_GREEN, TEAL
))
story.append(PageBreak())

# Frontend crosswalk
story += section_heading("3.", "Tester report crosswalk",
    "This view distinguishes issues the app can handle from issues that require authoritative backend behavior.")
crosswalk = [
    ["Feedback IDs", "Frontend coverage", "Backend still required"],
    ["ONB-001 to ONB-003", "Signup progress is tracked. Phone verification now requires explicit success.", "Block unverified accounts server-side; make verified phones unique; rate-limit OTP."],
    ["ONB-004, KYC-001, ONB-005", "KYC states are represented. Verified profiles prefill eligible fields when returned.", "Enable providers and return stable, verified BVN fields."],
    ["ONB-006, ONB-007 to ONB-010", "429 waits, Google account chooser, typed login identifier, and paste-ready code inputs.", "Return correct 429/Retry-After and support username/phone matching."],
    ["UI-001, WAL-001, WAL-002", "Profile navigation, persistent hidden balance, and wallet_funding row rendering.", "Include funding rows in ordinary fetch_transactions responses."],
    ["PAY-003, PAY-004, SEC-001", "PIN entry, wrong-PIN UI, schedule PIN step, in-flight guard, and client reference.", "Validate PIN everywhere, protect PIN replacement, and deduplicate durably on the server."],
    ["PAY-005, PAY-006", "Mismatch warning, network validation flag, and airtime minimum display.", "Use provider network lookup and return real minimum/maximum plan limits."],
    ["PAY-007 to PAY-009, UI-005", "Specific API messages and field errors are surfaced when present.", "Return correct status codes and machine-readable reasons instead of generic 500s."],
    ["PAY-001, PAY-002, PAY-011", "Unavailable/demo flags are handled; payment result and receipt views are present.", "Prevent demo fulfillment, expose daily limits, and make delivery fast with reliable pending status."],
    ["UI-002, UI-004, UI-006, UI-007", "KYC back-stack fix, multiline bulk input, coupon context/code, and unified PIN/OTP input.", "Return correct coupon data and decrement slots only after successful use."],
    ["UI-003", "Not conclusively matched to one screen in this update.", "Retest the reported screen on-device and adjust the affected responsive layout if it still reproduces."],
]
story.append(table(crosswalk, [1.42*inch, 2.72*inch, 2.96*inch], padd=4))
story.append(Spacer(1, 9))
story.append(callout(
    "Do not close an issue from frontend behavior alone",
    "A client-side warning, hidden button, or PIN screen is not a security control. Verify that direct API requests and concurrent requests are rejected or deduplicated by the backend.",
    PALE_AMBER, HIGH
))
story.append(PageBreak())

# Backend requirements
story += section_heading("4.", "Backend requirements",
    "Each item includes its source issue, required server changes, contract, and acceptance criteria. Priority is shown on every requirement card.")
for item in REQS:
    story.append(req_card(item))

# API contract matrix
story.append(PageBreak())
story += section_heading("5.", "Mobile and API contract matrix",
    "These are the concrete response and request fields the current mobile implementation expects. Keep field names and meanings stable across releases.")
contract_rows = [
    ["Flow", "Contract to implement or preserve"],
    ["Login and dashboard", "User flags: email_verified, email_verified_at, phone_verified, pin_set. Daily limit data for BE-14 should be added here or exposed through a dedicated limits endpoint."],
    ["Phone OTP confirmation", "Every response includes data.verified as a boolean. Wrong/expired code returns HTTP 422 and status false. The mobile app advances only on true."],
    ["Money POSTs", "Accept client_reference as UUID for buy_*, scheduled purchases, and fund_card. Repeated references return the original transaction result."],
    ["Coupon qualification", "Accept user_id, coupon_code, network_id, and product_plan_id. The app sends context only after a network and plan are selected."],
    ["Airtime/data purchase", "Accept coupon_code where a coupon is applied. Return actual amount and discounted_amount so success UI can report what was charged."],
    ["Active coupons", "Include network_id and current slots_remaining. Return enough plan/category context for the app to filter offers."],
    ["Product plans", "Return minimum_amount and maximum_amount for applicable plans. Purchase endpoints enforce the same values."],
    ["Transaction history", "fetch_transactions returns wallet_funding with stable id, amount, created_at, status, reference, and bank, without a PIN."],
    ["Errors", "Use HTTP status plus machine code, readable message, and errors field map. Include Retry-After on 429."],
    ["KYC", "Expose a verified profile with first_name, last_name, date_of_birth, and phone through the response the app reads."],
    ["Delivery", "Return transaction id plus pending/success/failed state. Provide a refresh or notification path for completion."],
]
story.append(table(contract_rows, [1.42*inch, 5.68*inch], padd=5))
story.append(Spacer(1, 10))
story.append(P("Security and data handling notes", "SubTitle"))
for txt in [
    "Never trust user_id, PIN state, verification state, coupon qualification, amount limits, or network validation merely because the client sent them.",
    "Do not return BVN, PIN, OTP, access tokens, provider credentials, or full payment secrets in logs or ordinary history responses.",
    "Make financial writes transactional and safe under retries, provider callbacks, and simultaneous requests.",
    "Use consistent user ownership checks on every history, KYC, card, and purchase route.",
]:
    story.append(bullet(txt))
story.append(PageBreak())

# Acceptance checklist
story += section_heading("6.", "Backend release acceptance checklist",
    "Run these checks in a staging environment with test accounts and provider sandboxes. Never use production funds or real identity records for negative-path testing.")
check_groups = [
    ("Identity and account access", [
        "Unverified email cannot use dashboard, purchase, or generate a virtual funding account.",
        "Wrong and expired phone OTP return 422, status false, and data.verified = false.",
        "A verified phone cannot be attached to a second account using local or international number formatting.",
        "Email, username, and normalized phone login reach the same account without revealing whether an identifier exists.",
    ]),
    ("PIN and money movement", [
        "Wrong PIN returns 403 INVALID_PIN on every PIN-gated route. Five wrong attempts trigger the configured 30-minute lock.",
        "PIN 0123 can be created and verified without integer conversion. Existing PIN cannot be replaced without current PIN or recovery OTP.",
        "Repeat a purchase with the same client_reference concurrently and sequentially. Verify one debit and one provider dispatch.",
        "Simulate a client timeout after commit, then retry with the same reference. Confirm the original result is returned.",
        "Run same product/recipient/amount within 60 seconds with a new reference and verify the duplicate-confirmation policy.",
    ]),
    ("Payment validation and products", [
        "A mismatching current network is refused before debit for immediate and scheduled airtime/data.",
        "Amounts below minimum or above maximum return 422 and do not debit. API plan limits match server validation.",
        "Insufficient balance, invalid meter, OTP rate limit, network mismatch, and provider outage each return the documented code and status.",
        "Unavailable result-checker or eSIM products do not debit and do not return demo assets.",
        "A normally funded NGN user can complete eSIM through the documented NGN conversion or USD funding route.",
    ]),
    ("History, coupons, and KYC", [
        "Wallet funding appears once in fetch_transactions without PIN, with amount, date, status, reference, and bank.",
        "A coupon for a different network or plan is rejected during qualification and again during purchase.",
        "Failed purchases do not consume coupon slots. Successful discounted purchases consume one slot exactly once under concurrency.",
        "Verified BVN response pre-fills the agreed fields. Failed or pending results do not present a verified profile.",
        "Card and BVN KYC are tested for verified, rejected, pending, retryable failure, and provider outage.",
    ]),
    ("Delivery and observability", [
        "Provider latency is measured by product and provider from wallet debit to fulfillment result.",
        "Slow fulfillment returns pending with a transaction id, then updates to final status through refresh or push.",
        "Unexpected 500 responses are logged and alerted. Logs do not include PINs, OTPs, BVNs, or credentials.",
    ]),
]
for group_title, checks in check_groups:
    story.append(P(group_title, "SubTitle"))
    for check in checks:
        story.append(bullet(check))
    story.append(Spacer(1, 4))
story.append(PageBreak())

# Rollout and sources
story += section_heading("7.", "Implementation order and sign-off")
story.append(P("Recommended order", "SubTitle"))
story.append(table([
    ["Stage", "Items", "Exit condition"],
    ["1. Secure account and money paths", "BE-01 to BE-06", "Email, phone, PIN, and duplicate purchase controls are proven server-side."],
    ["2. Standardize failures", "BE-08", "User and provider failures use correct status codes and machine-readable errors."],
    ["3. Complete critical services and high items", "BE-07, BE-09 to BE-14", "KYC, network validation, amount limits, login, funding history, product availability, and daily limits pass."],
    ["4. Improve service quality", "BE-15 to BE-17", "Delivery status, coupon inventory, and BVN prefill are stable and tested."],
], [1.42*inch, 1.45*inch, 4.23*inch], padd=5))
story.append(Spacer(1, 9))
story.append(P("Sign-off evidence to attach", "SubTitle"))
for txt in [
    "Endpoint-level test results with status codes and example response bodies, with secrets and personal data removed.",
    "Concurrency and retry evidence for purchases, scheduled transactions, card funding, and coupon slot updates.",
    "Provider sandbox or production-like evidence for KYC and delivery state transitions.",
    "Confirmation that the deployed API version exposes the contract matrix in Section 5.",
]:
    story.append(bullet(txt))
story.append(Spacer(1, 8))
story.append(callout(
    "Release decision",
    "Do not mark the backend checklist complete until server-side tests prove the acceptance criteria. The current frontend build compiles, but production API completion has not been verified by this document.",
    PALE_BLUE, BRAND
))
story.append(Spacer(1, 10))
story.append(P("Source documents", "SubTitle"))
story.append(plain(
    "1. Megasub_Backend_Fixes (1).pdf, pages 1-7. Defines BE-01 through BE-17, severity, suggested order, API changes, and frontend assumptions."
))
story.append(plain(
    "2. Megasub_Test_Feedback (1).pdf, pages 2-33. Lists 32 tester issues and acceptance criteria. Issue references are repeated in each backend requirement above."
))
story.append(plain(
    "3. Mobile implementation review of /Users/samuel/Downloads/Megasub-main/megasub after the latest frontend update. The review confirms client code only, not deployed API behavior."
))
story.append(Spacer(1, 12))
story.append(P("Document prepared 9 November 2026", "CenterSmall"))

doc = SimpleDocTemplate(
    str(OUT),
    pagesize=letter,
    leftMargin=LEFT,
    rightMargin=RIGHT,
    topMargin=TOP,
    bottomMargin=BOTTOM,
    title="Megasub Backend Implementation Plan",
    author="OpenAI",
    subject="Detailed API requirements and acceptance criteria for Megasub backend fixes",
)
doc.build(story, onFirstPage=on_page, onLaterPages=on_page)

# Basic post-build checks: output exists and text is ASCII punctuation safe.
if not OUT.exists() or OUT.stat().st_size < 10000:
    raise RuntimeError("PDF was not created as expected.")
print(f"Created {OUT} ({OUT.stat().st_size} bytes)")
