from collections.abc import Iterable
from pathlib import Path

from pygal.graph.box import Box
from pygal.style import DefaultStyle

from benchmarks.libs.utils import slugify


class CustomBox(Box):
    def _box_points(self, serie, _):
        return serie, [serie[0], serie[6]]

    def _value_format(self, x):
        return (
            f"Min: {x[:7][0]:.4f}\n"
            f"Q1-1.5IQR: {x[:7][1]:.4f}\n"
            f"Q1: {x[:7][2]:.4f}\nMedian: {x[:7][3]:.4f}\nQ3: {x[:7][4]:.4f}\n"
            f"Q3+1.5IQR: {x[:7][5]:.4f}\n"
            f"Max: {x[:7][6]:.4f}"
        )

    def _format(self, x, *args):
        sup = super()._format
        if args:
            val = x.values
        else:
            val = x
        if isinstance(val, Iterable):
            return self._value_format(val), val[7]
        else:
            return sup(x, *args)

    def _tooltip_data(self, node, value, x, y, classes=None, xlabel=None):
        super()._tooltip_data(node, value[0], x, y, classes=classes, xlabel=None)
        self.svg.node(node, "desc", class_="x_label").text = value[1]


def make_plot(benchmarks, title, adjustment):
    class Style(DefaultStyle):
        # colors = tuple(
        #     "#000000" if row["path"] else DefaultStyle.colors[1] for row in benchmarks
        # )
        font_family = 'Consolas, "Deja Vu Sans Mono", "Bitstream Vera Sans Mono", "Courier New", monospace'

    minimum = int(min(row["stats"]["min"] * adjustment for row in benchmarks))
    maximum = int(
        max(
            min(row["stats"]["max"], row["stats"]["hd15iqr"]) * adjustment
            for row in benchmarks
        )
        + 1
    )

    try:
        import pygaljs
    except ImportError:
        opts = {}
    else:
        opts = {"js": [pygaljs.uri("2.0.x", "pygal-tooltips.js")]}

    plot = CustomBox(
        x_label_rotation=0,
        x_labels=[f'{row["extra_info"]["build_type"]}' for row in benchmarks],
        show_legend=False,
        title=title,
        x_title="Trial",
        y_title="Duration",
        style=Style,
        min_scale=20,
        max_scale=20,
        truncate_label=50,
        range=(minimum, maximum),
        zero=minimum,
        css=[
            "file://style.css",
            "file://graph.css",
            """inline:
                .tooltip .value {
                    font-size: 1em !important;
                }
                .axis text {
                    font-size: 14px !important;
                }
            """,
        ],
        **opts,
    )

    for row in benchmarks:
        serie = [
            row["stats"][field] * adjustment
            for field in ["min", "ld15iqr", "q1", "median", "q3", "hd15iqr", "max"]
        ]
        serie.append(False)
        plot.add(f'{row["fullname"]} - {row["stats"]["rounds"]} rounds', serie)
    return plot


def make_histogram(
    title,
    output_prefix: Path,
    key: tuple[str, str],
    benchmarks,
    adjustment,
):

    print(f"Generating histogram for {title}")

    path = output_prefix / ("chart_" + slugify(f"{key}") + ".svg")
    output_file = Path(path)
    output_file.parent.mkdir(exist_ok=True, parents=True)

    plot = make_plot(
        benchmarks=benchmarks,
        title=title,
        adjustment=adjustment,
    )
    plot.render_to_file(str(output_file))
    return output_file
