import 'dart:ui';

import 'package:day_night_time_picker/lib/ampm.dart';
import 'package:day_night_time_picker/lib/constants.dart';
import 'package:day_night_time_picker/lib/daynight_banner.dart';
import 'package:day_night_time_picker/lib/utils.dart';
import 'package:flutter/material.dart';

/// Default Border radius value in [double]
const _BORDER_RADIUS = BORDER_RADIUS;

/// Default Elevation value in [double]
const _ELEVATION = ELEVATION;

/// Private class. [StatefulWidget] that renders the content of the picker.
class DayNightTimePickerAndroid extends StatefulWidget {
  /// **`Required`** Display value. It takes in [TimeOfDay].
  final TimeOfDay value;

  /// **`Required`** Return the new time the user picked as [TimeOfDay].
  final void Function(TimeOfDay) onChange;

  /// _`Optional`_ Return the new time the user picked as [DateTime].
  final void Function(DateTime) onChangeDateTime;

  /// Show the time in TimePicker in 24 hour format.
  final bool is24HrFormat;

  /// Accent color of the TimePicker.
  final Color accentColor;

  /// Accent color of unselected text.
  final Color unselectedColor;

  /// Text displayed for the Cancel button.
  String cancelText;

  /// Text displayed for the Ok button.
  String okText;

  /// Image asset used for the Sun.
  final Image sunAsset;

  /// Image asset used for the Moon.
  final Image moonAsset;

  /// Whether to blur the background of the [Modal].
  final bool blurredBackground;

  /// Border radius of the [Container] in [double].
  final double borderRadius;

  /// Elevation of the [Modal] in [double].
  final double elevation;

  /// Steps interval while changing [minute].
  final MinuteInterval minuteInterval;

  /// Disable minute picker
  final bool disableMinute;

  /// Disable hour picker
  final bool disableHour;

  /// Selectable maximum hour
  final double maxHour;

  /// Selectable maximum minute
  final double maxMinute;

  /// Selectable minimum hour
  final double minHour;

  /// Selectable minimum minute
  final double minMinute;

  /// Whether the widget is displayed as a popup or inline
  final bool isInlineWidget;

  /// Initialize the picker [Widget]
  DayNightTimePickerAndroid({
    @required this.value,
    @required this.onChange,
    this.onChangeDateTime,
    this.is24HrFormat = false,
    this.accentColor,
    this.unselectedColor,
    this.cancelText = "cancel",
    this.okText = "ok",
    this.sunAsset,
    this.moonAsset,
    this.blurredBackground = false,
    this.borderRadius,
    this.elevation,
    this.minuteInterval,
    this.disableMinute,
    this.disableHour,
    this.maxHour,
    this.maxMinute,
    this.minHour,
    this.minMinute,
    this.isInlineWidget = false,
  }) {
    if (isInlineWidget) {
      this.cancelText = "reset";
      this.okText = "apply";
    }
  }

  @override
  _DayNightTimePickerAndroidState createState() =>
      _DayNightTimePickerAndroidState();
}

/// Picker state class
class _DayNightTimePickerAndroidState extends State<DayNightTimePickerAndroid> {
  /// Current selected hour
  int hour;

  /// Current selected minute
  int minute;

  /// Current selected AM/PM
  String a;

  /// Currently changing the hour section
  bool changingHour = true;

  /// Default Ok/Cancel [TextStyle]
  final okCancelStyle = TextStyle(fontWeight: FontWeight.bold);

  @override
  void initState() {
    setState(() {
      changingHour =
          (!widget.disableHour && !widget.disableMinute) || !widget.disableHour;
    });
    separateHoursAndMinutes();
    super.initState();
  }

  @override
  void didUpdateWidget(DayNightTimePickerAndroid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.is24HrFormat != widget.is24HrFormat ||
        oldWidget.value != widget.value) {
      separateHoursAndMinutes();
    }
  }

  /// Separate out the hour and minute from a string
  void separateHoursAndMinutes() {
    int _h = widget.value.hour;
    int _m = widget.value.minute;
    String _a = "am";

    if (!widget.is24HrFormat && _h >= 12) {
      _a = "pm";
      _h -= 12;
    }
    setState(() {
      hour = _h;
      minute = _m;
      a = _a;
    });
  }

  /// Change handler for picker
  onChangeTime(double value) {
    if (changingHour) {
      setState(() {
        hour = value.round();
      });
    } else {
      setState(() {
        minute = value.ceil();
      });
    }
  }

  /// Hnadle should change hour or minute
  changeCurrentSelector(bool isHour) {
    setState(() {
      changingHour = isHour;
    });
  }

  /// [onChange] handler. Return [TimeOfDay]
  onOk() {
    var time = TimeOfDay(
      hour: getHours(hour, a, widget.is24HrFormat),
      minute: minute,
    );
    widget.onChange(time);
    if (widget.onChangeDateTime != null) {
      final now = DateTime.now();
      final dateTime =
          DateTime(now.year, now.month, now.day, time.hour, time.minute);
      widget.onChangeDateTime(dateTime);
    }
    onCancel();
  }

  /// Handler to close the picker
  onCancel() {
    if (!widget.isInlineWidget) {
      Navigator.of(context).pop();
    } else {
      separateHoursAndMinutes();
    }
  }

  @override
  Widget build(BuildContext context) {
    final _commonTimeStyles = Theme.of(context).textTheme.headline2.copyWith(
          fontSize: 62,
          fontWeight: FontWeight.bold,
        );

    double min = getMinMinute(widget.minMinute, widget.minuteInterval);
    double max = getMaxMinute(widget.maxMinute, widget.minuteInterval);

    int minDiff = (max - min).round();
    int divisions = getMinuteDivisions(minDiff, widget.minuteInterval);

    double hourMinValue = 0;
    double hourMaxValue = widget.is24HrFormat ? 23 : 11;

    if (changingHour) {
      min = widget.minHour;
      max = widget.maxHour;
      divisions = (max - min).round();
    }

    final height = widget.is24HrFormat ? 200.0 : 240.0;

    final color = widget.accentColor ?? Theme.of(context).accentColor;
    final unselectedColor = widget.unselectedColor ?? Colors.grey;
    final unselectedOpacity = 1.0;

    final double blurAmount = widget.blurredBackground ?? false ? 5 : 0;

    final borderRadius = widget.borderRadius ?? _BORDER_RADIUS;
    final elevation = widget.elevation ?? _ELEVATION;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: blurAmount, sigmaY: blurAmount),
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        elevation: elevation,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              DayNightBanner(
                hour: getHours(hour, a, widget.is24HrFormat),
                displace: mapRange(hour * 1.0, hourMinValue, hourMaxValue),
                sunAsset: widget.sunAsset,
                moonAsset: widget.moonAsset,
              ),
              Container(
                height: height,
                color: Theme.of(context).cardColor,
                padding:
                    const EdgeInsets.only(left: 12.0, top: 12.0, right: 12.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    if (!widget.is24HrFormat)
                      AmPm(
                        accentColor: color,
                        unselectedColor: unselectedColor,
                        selected: a,
                        onChange: (e) {
                          setState(() {
                            a = e;
                          });
                        },
                      ),
                    Expanded(
                      child: Row(
                        textDirection: TextDirection.ltr,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Material(
                            color: Colors.transparent,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 3.0),
                              child: InkWell(
                                onTap: widget.disableHour
                                    ? null
                                    : () {
                                        changeCurrentSelector(true);
                                      },
                                child: Opacity(
                                  opacity: changingHour ? 1 : unselectedOpacity,
                                  child: Text(
                                    "${getHourForPrint(hour, widget.is24HrFormat)}",
                                    style: _commonTimeStyles.copyWith(
                                        color: changingHour
                                            ? color
                                            : unselectedColor),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Text(":", style: _commonTimeStyles),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: widget.disableMinute
                                  ? null
                                  : () {
                                      changeCurrentSelector(false);
                                    },
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 3.0),
                                child: Opacity(
                                  opacity:
                                      !changingHour ? 1 : unselectedOpacity,
                                  child: Text(
                                    "${padNumber(minute)}",
                                    style: _commonTimeStyles.copyWith(
                                        color: !changingHour
                                            ? color
                                            : unselectedColor),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Slider(
                      value: changingHour
                          ? hour.roundToDouble()
                          : minute.roundToDouble(),
                      onChanged: onChangeTime,
                      min: min,
                      max: max,
                      divisions: divisions,
                      activeColor: color,
                      inactiveColor: color.withAlpha(55),
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          FlatButton(
                            onPressed: onCancel,
                            child: Text(
                              widget.cancelText.toUpperCase(),
                              style: okCancelStyle,
                            ),
                            textColor: color,
                          ),
                          FlatButton(
                            onPressed: onOk,
                            child: Text(
                              widget.okText.toUpperCase(),
                              style: okCancelStyle,
                            ),
                            textColor: color,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
