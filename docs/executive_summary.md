# Executive Summary — Supply Chain Inventory & Delivery Review

**To:** VP Supply Chain & Operations, DataCo Global
**Scope:** 180,519 order lines, 118 products, 5 markets, Jan 2015 – Jan 2018

---

## The situation
- **57% of shipped order lines arrive late.**
- Inventory runs on a **one-size-fits-all rule** (4 weeks of safety stock for every product), even though **7 of 100 products generate 82% of revenue**.

## What the analysis found
1. **Revenue is extremely concentrated, and the top products are very predictable.** All 7 A-class products have stable weekly demand (about 10% variation), so they need far less buffer stock than the blanket rule holds.
2. **Late deliveries are a promise problem, not an execution problem.**
   - First Class promises 1 day and *always* takes 2, so it is 100% late by design.
   - Second Class promises 2 days but has the **same 2–6 day transit as Standard Class** (statistically indistinguishable). Premium customers get standard speed.
   - Market, region, product and customer segment make almost no difference.
3. **No measurable customer churn from lateness in this data** (repeat rate is about 95% either way), so we don't claim lost revenue. The exposure is reputational and contractual: **$4.0M a year of premium-shipping revenue** is sold on a promise that cannot be met.

## Recommendations

| # | Recommendation | Impact | Effort |
|---|---|---|---|
| 1 | **Replace the blanket 4-week rule with ABC-XYZ inventory policies** (98/95/90% service by class, statistical reorder points, EOQ) | Average inventory **$925K → $184K (−80%)**; annual inventory cost **−$188K (−71%)**; back-tested fill rate **99.99%** | Low: parameter change in the ERP |
| 2 | **Reset delivery promises to what each mode actually delivers** (Same Day 1, First 2, Second 4, Standard 5 days) | Late deliveries **57% → 20%**; revenue delivered late **$6.5M → $2.3M a year** | Low: website and SLA text change |
| 3 | **Route Second Class through the First Class lane** (consistent 2-day transit, promised at 3 days), or merge it into Standard and stop charging a premium | Late deliveries **20% → 12%**; restores integrity of **$4.0M a year** of premium-shipping revenue | Medium: carrier and routing change |

**Next step:** negotiate a tighter transit window for Standard Class (currently 2–6 days, evenly spread). It is now the only remaining source of late deliveries.

## Key assumptions
Lead time 2 weeks · weekly review · holding cost 25% a year · $50 per order. The dataset has no supplier, stock-on-hand or cost-parameter data. All assumptions can be changed in `excel/inventory_policy_model.xlsx`.
