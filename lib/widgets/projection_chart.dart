import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../core/format/formatters.dart';
import '../core/theme/app_palette.dart';
import '../services/savings_calculator.dart';

/// Balance vs. contributions over time, with a target line and an optional
/// what-if comparison curve.
class ProjectionChart extends StatelessWidget {
  const ProjectionChart({
    super.key,
    required this.projection,
    required this.money,
    required this.start,
    this.comparison,
    this.height = 220,
  });

  final Projection projection;
  final Projection? comparison;
  final Money money;
  final DateTime start;
  final double height;

  /// Keep the chart light: at most this many points per line.
  static const _maxPoints = 60;

  /// How far to draw when a projection never reaches its target.
  static const _fallbackHorizon = 120;

  int _horizon(Projection p) =>
      p.monthsToTarget ?? math.min(_fallbackHorizon, p.points.length - 1);

  List<FlSpot> _spots(Projection p, int horizon, double Function(ProjectionPoint) y) {
    final last = math.min(horizon, p.points.length - 1);
    final step = math.max(1, (last / _maxPoints).ceil());
    return [
      for (var m = 0; m < last; m += step)
        FlSpot(m.toDouble(), y(p.points[m])),
      FlSpot(last.toDouble(), y(p.points[last])),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final text = Theme.of(context).textTheme;

    final horizon = math.max(
      _horizon(projection),
      comparison == null ? 0 : _horizon(comparison!),
    );
    if (horizon < 1) {
      return SizedBox(
        height: height,
        child: Center(
          child: Text(
            projection.monthsToTarget == 0
                ? 'Target reached — nothing left to project.'
                : 'Add a monthly contribution to see a projection.',
            style: text.bodySmall,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final balance = _spots(projection, horizon, (pt) => pt.balance);
    final contributed = _spots(projection, horizon, (pt) => pt.contributed);
    final whatIf = comparison == null
        ? null
        : _spots(comparison!, horizon, (pt) => pt.balance);

    final peak = [
      projection.target,
      ...balance.map((s) => s.y),
      ...?whatIf?.map((s) => s.y),
    ].reduce(math.max);
    final maxY = _niceCeil(peak * 1.08);
    final xInterval = _xInterval(horizon);

    return SizedBox(
      height: height,
      child: LineChart(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
        LineChartData(
          minX: 0,
          maxX: horizon.toDouble(),
          minY: 0,
          maxY: maxY,
          clipData: const FlClipData.all(),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            drawVerticalLine: false,
            horizontalInterval: maxY / 4,
            getDrawingHorizontalLine: (_) =>
                FlLine(color: p.border, strokeWidth: 1, dashArray: [4, 6]),
          ),
          extraLinesData: ExtraLinesData(
            horizontalLines: [
              HorizontalLine(
                y: projection.target,
                color: p.success.withValues(alpha: 0.8),
                strokeWidth: 1.5,
                dashArray: [6, 4],
                label: HorizontalLineLabel(
                  show: true,
                  alignment: Alignment.topLeft,
                  padding: const EdgeInsets.only(left: 4, bottom: 4),
                  style: TextStyle(
                    color: p.success,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                  labelResolver: (_) => 'Target',
                ),
              ),
            ],
          ),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(),
            rightTitles: const AxisTitles(),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 52,
                interval: maxY / 4,
                getTitlesWidget: (value, meta) {
                  if (value == meta.max) return const SizedBox.shrink();
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(
                      money.compact(value),
                      style: text.labelSmall?.copyWith(color: p.textMuted),
                    ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                interval: xInterval.toDouble(),
                getTitlesWidget: (value, meta) {
                  final month = value.round();
                  // Skip the max label when it would crowd its neighbour.
                  if (month != 0 &&
                      month % xInterval != 0 &&
                      (month % xInterval) < xInterval * 0.6) {
                    return const SizedBox.shrink();
                  }
                  final date = SavingsCalculator.addMonths(start, month);
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(
                      month == 0
                          ? 'Now'
                          : xInterval >= 12
                              ? '${date.year}'
                              : formatMonthYear(date).split(' ').first,
                      style: text.labelSmall?.copyWith(color: p.textMuted),
                    ),
                  );
                },
              ),
            ),
          ),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => p.surfaceRaised,
              tooltipRoundedRadius: 12,
              tooltipPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              fitInsideHorizontally: true,
              fitInsideVertically: true,
              getTooltipItems: (spots) => [
                for (final s in spots)
                  LineTooltipItem(
                    s.barIndex == 0
                        ? '${formatMonthYear(SavingsCalculator.addMonths(start, s.x.round()))}\n'
                        : '',
                    TextStyle(
                      color: p.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                    children: [
                      TextSpan(
                        text: money.format(s.y),
                        style: TextStyle(
                          color: s.bar.color ?? p.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: balance,
              isCurved: true,
              preventCurveOverShooting: true,
              color: p.brand,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    p.brand.withValues(alpha: 0.32),
                    p.brand.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
            LineChartBarData(
              spots: contributed,
              isCurved: true,
              preventCurveOverShooting: true,
              color: p.textMuted,
              barWidth: 2,
              dashArray: [5, 5],
              dotData: const FlDotData(show: false),
            ),
            if (whatIf != null)
              LineChartBarData(
                spots: whatIf,
                isCurved: true,
                preventCurveOverShooting: true,
                color: p.accent,
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: const FlDotData(show: false),
              ),
          ],
        ),
      ),
    );
  }

  static int _xInterval(int horizon) {
    if (horizon <= 12) return 3;
    if (horizon <= 24) return 6;
    // Whole years, aiming for ~4 labels.
    return math.max(12, (horizon / 4 / 12).ceil() * 12);
  }

  /// Rounds up to a "nice" axis maximum (1, 2, 2.5, 5 × 10ⁿ).
  static double _niceCeil(double v) {
    if (v <= 0) return 1;
    final exp = math.pow(10, (math.log(v) / math.ln10).floor()).toDouble();
    for (final m in [1.0, 2.0, 2.5, 5.0, 10.0]) {
      if (m * exp >= v) return m * exp;
    }
    return 10 * exp;
  }
}

class ChartLegend extends StatelessWidget {
  const ChartLegend({super.key, required this.items});

  final List<(String, Color, {bool dashed})> items;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodySmall;
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        for (final (label, color, :dashed) in items)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 16,
                height: 3,
                child: dashed
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          for (var i = 0; i < 3; i++)
                            Container(width: 4, height: 3, color: color),
                        ],
                      )
                    : DecoratedBox(
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
              ),
              const SizedBox(width: 6),
              Text(label, style: style),
            ],
          ),
      ],
    );
  }
}
