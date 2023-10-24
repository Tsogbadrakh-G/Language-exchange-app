import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SomniAlerts {
  static Future<void> alertBoxVertical({
    required Widget textWidget,
    required Widget titleWidget,
    required Function() button1,
    required Function() button2,
    Function()? onClose,
    String imgAsset = '',
    String button1Text = '',
    String button2Text = '',
  }) async {
    return await Get.dialog(
      AlertDialog(
        contentPadding: EdgeInsets.zero,
        backgroundColor: Colors.transparent,
        content: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: const Color(0xffffffff),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      'assets/images/$imgAsset.png',
                    ),
                  ),
                  Positioned.fill(
                    right: 10,
                    top: 10,
                    child: Align(
                      alignment: Alignment.topRight,
                      child: InkWell(
                        onTap: onClose ?? Get.back,
                        child: Image.asset(
                          'assets/images/alert/alert_back.png',
                          width: 20,
                          height: 20,
                        ),
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 5.0),
              titleWidget,
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: textWidget,
              ),
              const SizedBox(height: 15.0),
              LimeTextButton(
                onTap: button1,
                text: button1Text,
                textColor: Color(0xffd0ff14),
                margin: EdgeInsets.symmetric(horizontal: 22),
              ),
              const SizedBox(height: 4),
              LimeTextButton(
                onTap: button2,
                text: button2Text,
                textColor: Color(0xffd0ff14),
                margin: EdgeInsets.symmetric(horizontal: 22),
              ),
              const SizedBox(height: 19),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }
}

class LimeTextButton extends StatelessWidget {
  final Color? color;
  final double? height;
  final EdgeInsets margin;
  final EdgeInsets? padding;
  final Function()? onTap;
  final String text;
  final Color? textColor;
  final double? width;
  final double? elevation;
  const LimeTextButton({
    required this.text,
    required this.margin,
    this.padding,
    this.onTap,
    this.color,
    this.height,
    this.width,
    this.elevation,
    this.textColor,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      height: height ?? 50,
      margin: margin,
      child: TextButton(
        onPressed: onTap,
        style: ButtonStyle(
          visualDensity: VisualDensity.compact,
          foregroundColor: MaterialStateProperty.all(textColor ?? Colors.white),
          backgroundColor: MaterialStateProperty.resolveWith(
            (states) {
              if (states.contains(MaterialState.disabled))
                return Color(0xffcccccc);

              return color ?? Color(0xff000000);
            },
          ),
          elevation: MaterialStateProperty.all(elevation ?? 0),
          padding: MaterialStateProperty.all(
            padding ?? const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
          ),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          //  style: LimeStyles.rubikMedium16x18.copyWith(color: textColor ?? Colors.white),
        ),
      ),
    );
  }
}
