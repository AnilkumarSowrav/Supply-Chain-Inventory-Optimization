"""Builds images/00_headline_results.png from the results/ files. Run after notebooks 02–04."""
from pathlib import Path
import pandas as pd
import matplotlib.pyplot as plt
from matplotlib.patches import FancyBboxPatch
import chart_style as cs

ROOT = Path(__file__).resolve().parent.parent   # works from the repo root or from python/

cs.apply()
inv = pd.read_csv(ROOT / 'results/inventory_summary.csv', index_col=0)
dlv = pd.read_csv(ROOT / 'results/delivery_scenarios.csv', index_col=0)

avg_b, avg_o = inv.loc['Average inventory value'].iloc[:2]
cost_b, cost_o = inv.loc['Total annual inventory cost'].iloc[:2]
late_now, late_b = dlv.loc['ALL MODES', 'late_now'], dlv.loc['ALL MODES', 'late_B']

tiles = [
    (f'{avg_o / avg_b - 1:.0%}', 'average inventory value', f'{cs.money(avg_b)} → {cs.money(avg_o)} while keeping a 99.99% fill rate'),
    (cs.money(cost_b - cost_o), 'lower inventory cost per year', f'{cs.money(cost_b)} → {cs.money(cost_o)} holding + ordering cost'),
    (f'{late_now:.0%} → {late_b:.0%}', 'late deliveries', 'reset promises + reroute Second Class'),
]
fig = plt.figure(figsize=(12, 2.6))
for k, (big, label, sub) in enumerate(tiles):
    ax = fig.add_axes([0.01 + k * 0.33, 0.05, 0.31, 0.9]); ax.axis('off')
    ax.add_patch(FancyBboxPatch((0, 0), 1, 1, boxstyle='round,pad=0,rounding_size=0.06', transform=ax.transAxes,
                                facecolor='white', edgecolor=cs.GRID, lw=1.2))
    ax.text(0.07, 0.68, big, fontsize=30, fontweight='bold', color=cs.BLUE if k < 2 else cs.ORANGE, transform=ax.transAxes, va='center')
    ax.text(0.07, 0.38, label, fontsize=13, color=cs.INK, transform=ax.transAxes, va='center')
    ax.text(0.07, 0.17, sub, fontsize=9.5, color=cs.INK_2, transform=ax.transAxes, va='center')
plt.savefig(ROOT / 'images/00_headline_results.png')
print('saved images/00_headline_results.png')
