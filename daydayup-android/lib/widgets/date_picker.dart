import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:todo_list/json/task_bean.dart';
import 'package:todo_list/lunar_calendar/GetLunar.dart';
import 'package:todo_list/model/all_model.dart';
import 'package:todo_list/utils/date_picker_util.dart';

class TableComplexExample extends StatefulWidget {
  final MainPageModel model;
  TableComplexExample(this.model);
  @override
  _TableComplexExampleState createState() => _TableComplexExampleState();
}

class _TableComplexExampleState extends State<TableComplexExample> {
  PageController _pageController;
  ValueNotifier<List<TaskBean>> _selectedEvents; //需要局部刷新的量
  final ValueNotifier<DateTime> _focusedDay = ValueNotifier(DateTime.now());

  //一个set集合 被选择的天
  /*
  * 也就是把所有的被选择的放在一个集合里面
  * 然后把对应的日程放入下面
  * 是否相同的判断原则   LinkedHashSet
  * equals:放在同一个链下的元素
  * hashCode:每格格子的放入的序号的计算方式
  * */
  final Set<DateTime> _selectedDays = LinkedHashSet<DateTime>(
    equals: isSameDay,
    hashCode: getHashCode,
  );

  //枚举  月
  CalendarFormat _calendarFormat = CalendarFormat.month;
  //
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOff;
  DateTime _rangeStart;
  DateTime _rangeEnd;

  /*
  * 添加被选择的天（默认当天）
  * 以及当天的日程添加进入
  * */
  @override
  void initState() {
    super.initState();
    _selectedDays.add(_focusedDay.value);
    _selectedEvents = ValueNotifier(_getEventsForDay(_focusedDay.value));
  }

  @override
  void dispose() {
    _focusedDay.dispose();
    _selectedEvents.dispose();
    super.dispose();
  }

  bool get canClearSelection =>
      _selectedDays.isNotEmpty || _rangeStart != null || _rangeEnd != null;

  List<TaskBean> _getEventsForDay(DateTime day) {
    return widget.model.kEvents[day] ?? [];
  }

  List<TaskBean> _getEventsForDays(Iterable<DateTime> days) {
    return [
      for (final d in days) ..._getEventsForDay(d),
    ];
  }
  //
  // List<TaskBean> _getEventsForRange(DateTime start, DateTime end) {
  //   final days = daysInRange(start, end);
  //   return _getEventsForDays(days);
  // }
  //

  /*
  * 选择天
  * */
  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      if (_selectedDays.contains(selectedDay)) {
        _selectedDays.remove(selectedDay);
      } else {
        _selectedDays.add(selectedDay);
      }

      _focusedDay.value = focusedDay;
      _rangeStart = null;
      _rangeEnd = null;
      _rangeSelectionMode = RangeSelectionMode.toggledOff;
    });

    _selectedEvents.value = _getEventsForDays(_selectedDays);
  }

  // void _onRangeSelected(DateTime start, DateTime end, DateTime focusedDay) {
  //   setState(() {
  //     _focusedDay.value = focusedDay;
  //     _rangeStart = start;
  //     _rangeEnd = end;
  //     _selectedDays.clear();
  //     _rangeSelectionMode = RangeSelectionMode.toggledOn;
  //   });
  //
  //   if (start != null && end != null) {
  //     _selectedEvents.value = _getEventsForRange(start, end);
  //   } else if (start != null) {
  //     _selectedEvents.value = _getEventsForDay(start);
  //   } else if (end != null) {
  //     _selectedEvents.value = _getEventsForDay(end);
  //   }
  // }
  //

  @override
  Widget build(BuildContext context) {
    CalendarStyle calendarStyle = CalendarStyle();
    final margin = calendarStyle.cellMargin;
    final padding = calendarStyle.cellPadding;
    final alignment = calendarStyle.cellAlignment;
    final duration = const Duration(milliseconds: 250);

    print(GetLunar.getLunar(2022, 2, 1));

    return Column(children: [
      ValueListenableBuilder<DateTime>(
        valueListenable: _focusedDay, //监听对象
        builder: (context, value, _) {
          return _CalendarHeader(
            //日历头部
            focusedDay: value,
            clearButtonVisible: canClearSelection,

            //点击今天按钮   focusedDay赋值DateTime.now()
            onTodayButtonTap: () {
              setState(() => _focusedDay.value = DateTime.now());
            },

            //清除按钮
            onClearButtonTap: () {
              setState(() {
                _rangeStart = null;
                _rangeEnd = null;
                _selectedDays.clear();
                _selectedEvents.value = [];
              });
            },

            onLeftArrowTap: () {
              _pageController.previousPage(
                duration: Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            },

            onRightArrowTap: () {
              _pageController.nextPage(
                duration: Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            },
          );
        },
      ),

      TableCalendar<TaskBean>(
        /****************新添************************/
        daysOfWeekHeight: 30,
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: TextStyle(fontSize: 18, color: Colors.black54
              // color:Theme.of(context).primaryColor
              ),
          weekendStyle: TextStyle(color: Colors.grey, fontSize: 18),
        ),

        calendarBuilders: CalendarBuilders(
          selectedBuilder: (_ctx, _day, _focusDay) {
            return AnimatedContainer(
                duration: duration,
                margin: margin,
                padding: padding,
                decoration: const BoxDecoration(
                  color: const Color(0xFF1E60E0),
                  shape: BoxShape.circle,
                ),
                alignment: alignment,
                child: Column(
                  children: [
                    Text(
                        _day.day < 10
                            ? "0" + _day.day.toString()
                            : _day.day.toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          // fontWeight: FontWeight.bold
                        )),
                    Text(GetLunar.getLunar(_day.year, _day.month, _day.day),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize:
                              GetLunar.getLunar(_day.year, _day.month, _day.day)
                                          .length >
                                      3
                                  ? 36 /
                                      GetLunar.getLunar(
                                              _day.year, _day.month, _day.day)
                                          .length
                                  : 12,
                          // fontWeight: FontWeight.bold
                        )),
                  ],
                ));
          },
          outsideBuilder: (_ctx, _day, _focusDay) {
            return AnimatedContainer(
                duration: duration,
                margin: margin,
                padding: padding,
                decoration: calendarStyle.outsideDecoration,
                alignment: alignment,
                child: Column(
                  children: [
                    Text(
                        _day.day < 10
                            ? "0" + _day.day.toString()
                            : _day.day.toString(),
                        style: TextStyle(
                            color: const Color(0xffB7B7B7),
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    Text(GetLunar.getLunar(_day.year, _day.month, _day.day),
                        style: TextStyle(
                          color: const Color(0xffB7B7B7),
                          overflow: TextOverflow.ellipsis,
                          fontSize: 12,
                          // fontWeight: FontWeight.bold
                        )),
                  ],
                ));
          },
          // 禁用
          disabledBuilder: (_ctx, _day, _focusDay) {
            return AnimatedContainer(
              duration: duration,
              margin: margin,
              padding: padding,
              decoration: calendarStyle.disabledDecoration,
              alignment: alignment,
              child: Column(
                children: [
                  Text(
                      _day.day < 10
                          ? "0" + _day.day.toString()
                          : _day.day.toString(),
                      style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFB7B7B7))),
                  Text(GetLunar.getLunar(_day.year, _day.month, _day.day),
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 12,
                          // fontWeight: FontWeight.bold,
                          color: const Color(0xFFB7B7B7))),
                ],
              ),
            );
          },
          todayBuilder: (_ctx, _day, _focusDay) {
            return AnimatedContainer(
                duration: duration,
                margin: margin,
                padding: padding,
                decoration: const BoxDecoration(
                    color: const Color(0xFF88CBFC), shape: BoxShape.circle),
                alignment: alignment,
                child: Column(
                  children: [
                    Text(
                      _day.day < 10
                          ? "0" + _day.day.toString()
                          : _day.day.toString(),
                      style: const TextStyle(
                        color: const Color(0xFFFAFAFA),
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        // fontWeight: FontWeight.bold
                      ),
                    ),
                    Text(
                      GetLunar.getLunar(_day.year, _day.month, _day.day),
                      style: TextStyle(
                        color: const Color(0xFFDFE9EF),
                        fontSize:
                            GetLunar.getLunar(_day.year, _day.month, _day.day)
                                        .length >
                                    3
                                ? 36 /
                                    GetLunar.getLunar(
                                            _day.year, _day.month, _day.day)
                                        .length
                                : 12,
                        // fontWeight: FontWeight.bold
                      ),
                    ),
                  ],
                ));
          },

          defaultBuilder: (_ctx, _day, _focusDay) {
            return AnimatedContainer(
                // margin: EdgeInsets.all(1),
                duration: const Duration(milliseconds: 250),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _day.day < 10
                          ? "0" + _day.day.toString()
                          : _day.day.toString(),
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      GetLunar.getLunar(_day.year, _day.month, _day.day),
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: const Color(0xffDFE9EF),
                        fontSize: 12,
                        // fontWeight: FontWeight.bold
                      ),
                    ),
                  ],
                ));
          },
        ),
        /****************以上新添************************/

        firstDay: kFirstDay,
        lastDay: kLastDay,
        focusedDay: _focusedDay.value,
        headerVisible: false,
        selectedDayPredicate: (day) => _selectedDays.contains(day),
        // rangeStartDay: _rangeStart,
        // rangeEndDay: _rangeEnd,
        calendarFormat: _calendarFormat,
        rangeSelectionMode: _rangeSelectionMode,
        eventLoader: _getEventsForDay,
        // holidayPredicate: (day) {
        //   //设置假期
        //   // Every 20th day of the month will be treated as a holiday
        //   return day.day == 20;
        // },
        onDaySelected: _onDaySelected,
        // onRangeSelected: _onRangeSelected,
        onCalendarCreated: (controller) => _pageController = controller,
        onPageChanged: (focusedDay) => _focusedDay.value = focusedDay,
        onFormatChanged: (format) {
          if (_calendarFormat != format) {
            setState(() => _calendarFormat = format);
          }
        },
      ),
      const SizedBox(height: 8.0),

      //事件列表
      /*
      * 事件列表
      * */

      Expanded(
        child: Container(
            padding: EdgeInsets.only(top: 20, left: 15, right: 10),

            /*
              * 按照日程的数目进行高度自适应
              * */
            height:
                _selectedEvents == null ? _selectedEvents.value.length * 30 : 0,
            decoration: BoxDecoration(
              // image: DecorationImage(
              //   image: AssetImage("images/task_list_bg.png"),
              //   fit: BoxFit.fill,
              // ),
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50), topRight: Radius.circular(50)),
            ),
            child: ValueListenableBuilder<List<TaskBean>>(
              valueListenable: _selectedEvents, //监听被选中的事件列表
              builder: (context, value, _) {
                return ListView(
                    children: widget.model.logic
                        .getCards(context, _selectedEvents.value));
              },
            )),
      )
    ]);

    //             },
    //           );
    //         },
    //       ),
    //     ),
    //   ],
    // );
  }
}

///日历头部
class _CalendarHeader extends StatelessWidget {
  final DateTime focusedDay;
  final VoidCallback onLeftArrowTap;
  final VoidCallback onRightArrowTap;
  final VoidCallback onTodayButtonTap;
  final VoidCallback onClearButtonTap;
  final bool clearButtonVisible;

  const _CalendarHeader({
    this.focusedDay,
    this.onLeftArrowTap,
    this.onRightArrowTap,
    this.onTodayButtonTap,
    this.onClearButtonTap,
    this.clearButtonVisible,
  });

  @override
  Widget build(BuildContext context) {
    // final headerText = DateFormat.yMMM().format(focusedDay);
    final year = DateFormat.y().format(focusedDay);
    final month = DateFormat.M().format(focusedDay);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0.0),
      child: Row(
        children: [
          const SizedBox(width: 10.0),
          Icon(
            Icons.apps,
            color: Colors.white,
            size: 28,
          ),
          const SizedBox(width: 10.0),
          SizedBox(
            width: 150.0,
            child: Text(
              year + " | " + month,
              style: TextStyle(color: Colors.white, fontSize: 20.0),
            ),
          ),
          IconButton(
            icon: Image.asset("images/calendar_today.png"),
            visualDensity: VisualDensity.compact,
            onPressed: onTodayButtonTap,
          ),
          if (clearButtonVisible)
            IconButton(
              icon: Icon(
                Icons.clear,
                size: 20.0,
                color: Colors.white,
              ),
              visualDensity: VisualDensity.compact,
              onPressed: onClearButtonTap,
            ),
          const Spacer(),
          // IconButton(
          //   icon: Icon(Icons.chevron_left),
          //   onPressed: onLeftArrowTap,
          // ),
          // IconButton(
          //   icon: Icon(Icons.chevron_right),
          //   onPressed: onRightArrowTap,
          // ),
        ],
      ),
    );
  }
}
