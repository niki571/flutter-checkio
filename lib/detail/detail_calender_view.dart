import 'dart:math';

import 'package:flutter/material.dart';
import 'package:timefly/models/habit.dart';
import 'package:timefly/utils/date_util.dart';
import 'package:timefly/utils/pair.dart';

import '../app_theme.dart';

///详情页面的 月 面板
///
class HabitDetailCalendarView extends StatefulWidget {
  final Color color;
  final Map<String, List<HabitRecord>> records;
  final List<DateTime> days;

  const HabitDetailCalendarView({Key key, this.color, this.records, this.days})
      : super(key: key);

  @override
  _HabitDetailCalendarViewState createState() =>
      _HabitDetailCalendarViewState();
}

class _HabitDetailCalendarViewState extends State<HabitDetailCalendarView> {
  List<DateTime> days;

  @override
  void initState() {
    days = widget.days;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: GridView.builder(
          physics: NeverScrollableScrollPhysics(),
          padding: EdgeInsets.only(left: .3, right: .3),
          itemCount: days.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7, childAspectRatio: 1.5, mainAxisSpacing: 5),
          itemBuilder: (context, index) {
            DateTime day = days[index];
            Pair2<bool, int> contains = containsDay(day);
            if (day == null) {
              if (index < 7) {
                return Container(
                  alignment: Alignment.center,
                  child: Text(
                    '${DateUtil.getWeekendString(index + 1)}',
                    style: AppTheme.appTheme
                        .textStyle(fontWeight: FontWeight.w500, fontSize: 15),
                  ),
                );
              }
              return Container();
            }
            return Container(
              alignment: Alignment.center,
              child: AspectRatio(
                aspectRatio: 1,
                child: CustomPaint(
                  painter: ContainerPainter(
                      contains.s, contains.t, _lineHeight() / 2, widget.color),
                  child: Container(
                    alignment: Alignment.center,
                    child: Text(
                      '${day.day}',
                      style: AppTheme.appTheme
                          .textStyle(
                              textColor:
                                  contains.s ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 15)
                          .copyWith(fontFamily: 'Montserrat'),
                    ),
                  ),
                ),
              ),
            );
          }),
    );
  }

  Pair2<bool, int> containsDay(DateTime date) {
    if (date == null) {
      return Pair2(false, 0);
    }
    bool contain = false;
    int count = 0;
    if (widget.records == null || widget.records.length == 0) {
      contain = false;
    } else if (widget.records
        .containsKey('${date.year}-${date.month}-${date.day}')) {
      contain = true;
      count = widget.records['${date.year}-${date.month}-${date.day}'].length;
    }
    return Pair2(contain, count);
  }

  double _lineHeight() {
    return ((MediaQuery.of(context).size.width - 20 * 2) / 7) / 1.5;
  }
}

class ContainerPainter extends CustomPainter {
  final int count;
  final bool needPaint;
  final double radius;
  final Color color;

  ContainerPainter(this.needPaint, this.count, this.radius, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.center(Offset.zero);
    final Paint paint = Paint()..color = needPaint ? color : Colors.transparent;
    canvas.drawCircle(center, radius - 2, paint);

    for (int i = 0; i < count; i++) {
      canvas.drawCircle(
          center +
              Offset((radius + 3) * cos((-2 + i) * pi / 6),
                  (radius + 3) * sin((-2 + i) * pi / 6)),
          3,
          paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    ContainerPainter oldPinter = oldDelegate as ContainerPainter;
    return oldPinter.needPaint != this.needPaint ||
        oldPinter.count != this.count;
  }
}
