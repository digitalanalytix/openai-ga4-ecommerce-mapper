# OpenAI — GA4 Ecommerce Mapper (GTM Variable Template)

Google Tag Manager variable template that converts GA4 ecommerce data layer events into [OpenAI Measurement Pixel](https://developers.openai.com/ads/measurement-pixel) format.

## What It Does

Reads standard GA4 ecommerce `dataLayer.push()` events and returns a structured object that the OpenAI Measurement Pixel tag can consume directly.

## Built-in Event Mappings

| GA4 Event | OpenAI Event | Data Type |
|-----------|-------------|-----------|
| `page_view` | `page_viewed` | contents |
| `view_item` | `contents_viewed` | contents |
| `view_item_list` | `contents_viewed` | contents |
| `add_to_cart` | `items_added` | contents |
| `begin_checkout` | `checkout_started` | contents |
| `purchase` | `order_created` | contents |
| `generate_lead` | `lead_created` | customer_action |
| `sign_up` | `registration_completed` | customer_action |

## Field Mappings

### Event Level

| GA4 Field | OpenAI Field |
|-----------|-------------|
| `ecommerce.value` | `amount` (× multiplier) |
| `ecommerce.currency` | `currency` |
| `ecommerce.transaction_id` | `_transaction_id` |

### Item Level (`items[]` → `contents[]`)

| GA4 Field | OpenAI Field |
|-----------|-------------|
| `item_id` | `id` |
| `item_name` | `name` |
| `item_category` | `content_type` |
| `quantity` | `quantity` |
| `price` | `amount` (× multiplier) |
| `currency` | `currency` |

## Setup

### 1. Create the Variable

1. In GTM, create a new variable using the **OpenAI — GA4 Ecommerce Mapper** template
2. Set **Output Field** to "Full Object" (default)
3. Set **Currency Multiplier** to `100` for USD/EUR/GBP or `1` for JPY/KRW

### 2. Use with OpenAI Measurement Pixel Tag

In your OpenAI Measurement Pixel event tag:
- Set the event name from `{{GA4 Mapper}}.eventName`
- Set event data fields from `{{GA4 Mapper}}.eventData`

Or use two separate variable instances — one returning "Event Name Only" and another "Event Data Only".

### 3. Custom Mappings

Add custom GA4 → OpenAI event mappings via the optional table. Custom mappings override built-in defaults.

## Currency Handling

GA4 uses decimal values (e.g., `129.99`). OpenAI expects integers in the currency's lowest denomination (e.g., `12999` for $129.99).

The **Currency Multiplier** controls the conversion:
- `100` — for USD, EUR, GBP, and most currencies
- `1` — for zero-decimal currencies (JPY, KRW)
- `1000` — for three-decimal currencies (BHD, KWD)

## License

Apache 2.0 — see [LICENSE](LICENSE).
