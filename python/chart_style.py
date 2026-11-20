"""Shared chart styling so every figure in the project looks consistent."""
import matplotlib.pyplot as plt
from matplotlib.ticker import FuncFormatter

# Colour roles (colour-blind-checked categorical order)
BLUE, ORANGE, AQUA = "#2a78d6", "#eb6834", "#1baf7a"
GREY = "#c3c2b7"           # de-emphasised marks
INK, INK_2 = "#0b0b0b", "#52514e"
SURFACE = "#fcfcfb"
GRID = "#e6e5e0"
BLUE_RAMP = ["#cde2fb", "#9ec5f4", "#6da7ec", "#3987e5", "#256abf", "#184f95", "#0d366b"]


def apply():
    plt.rcParams.update({
        "figure.facecolor": SURFACE, "axes.facecolor": SURFACE, "savefig.facecolor": SURFACE,
        "font.family": "DejaVu Sans", "font.size": 11, "text.parse_math": False,
        "axes.edgecolor": GRID, "axes.labelcolor": INK_2, "axes.titlecolor": INK,
        "axes.titlesize": 14, "axes.titleweight": "bold", "axes.titlelocation": "left", "axes.titlepad": 14,
        "axes.spines.top": False, "axes.spines.right": False,
        "axes.grid": True, "grid.color": GRID, "grid.linewidth": 0.8,
        "xtick.color": INK_2, "ytick.color": INK_2, "xtick.major.size": 0, "ytick.major.size": 0,
        "legend.frameon": False, "legend.fontsize": 10,
        "figure.dpi": 110, "savefig.dpi": 160, "savefig.bbox": "tight",
    })


def titles(ax, title, sub=None):
    """Left-aligned bold title with an optional grey subtitle underneath."""
    ax.text(0, 1.11 if sub else 1.04, title, transform=ax.transAxes, color=INK,
            fontsize=14, fontweight="bold", va="bottom")
    if sub:
        ax.text(0, 1.04, sub, transform=ax.transAxes, color=INK_2, fontsize=10.5, va="bottom")


def money(x, _=None):
    if abs(x) >= 1e6:
        return f"${x/1e6:.1f}M"
    if abs(x) >= 1e3:
        return f"${x/1e3:.0f}K"
    return f"${x:.0f}"


money_fmt = FuncFormatter(money)
pct_fmt = FuncFormatter(lambda x, _: f"{x:.0%}")
