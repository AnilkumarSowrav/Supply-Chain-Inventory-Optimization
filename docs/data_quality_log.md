# Data Quality Log

| # | Issue found | Evidence | Decision |
|---|---|---|---|
| 1 | File isn't UTF-8 | Default `read_csv` fails | Read with `encoding='ISO-8859-1'` |
| 2 | `Product Description` 100% empty | 180,519 / 180,519 null | Dropped |
| 3 | `Order Zipcode` 86% empty | 155,679 null | Dropped |
| 4 | Customer email/password masked; names and street are PII | All values `XXXXXXXXX` | Dropped (customer kept by `customer_id`) |
| 5 | Six duplicate column pairs | Verified identical with `np.allclose` | Kept one of each |
| 6 | `Product Status` constant (all 0); `Product Image` is a URL | value_counts | Dropped |
| 7 | Float noise in money fields (e.g. 9.989999771) | Raw values | Rounded to 4 decimals |
| 8 | Trailing spaces in text (e.g. `'Smart watch '`) | String check | Stripped |
| 9 | Catalog break from Oct 2017: 13 of 100 products continue, volume halves | Monthly product counts | Flag `in_model_window`; demand modelling uses Jan 2015 – Sep 2017 |
| 10 | CANCELED and SUSPECTED_FRAUD orders never ship | Late risk = 0 for both | Flag `is_cancelled`; excluded from demand and delivery analysis |
| 11 | No on-hand inventory or supplier lead-time fields | Schema review | Inventory policy derived from demand; lead-time assumptions documented in notebook 03 |

## Validation
- Sales = unit price × quantity (max difference 0.00)
- Order item total = sales − discount (max difference 0.01, rounding)
- `order_item_id` unique; no nulls in the clean table
- Clean table: 180,519 rows × 39 columns; 164,572 rows in model window and not cancelled
