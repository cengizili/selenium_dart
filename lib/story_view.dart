import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:provider/provider.dart';
import 'package:selenium_dart/inappwebview.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

class Stories extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final stories = context.watch<SessionWebView>().stories;

    return Scaffold(
      body: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          color: Colors.pink[100],
          width: MediaQuery.of(context).size.width,
          height: 100,
          child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              itemCount: stories.length,
              itemBuilder: (context, index) {
                String? pp = stories.entries.elementAt(index).value;
                return Row(
                  children: [
                    Container(
                        width: 80,
                        height: 80,
                        child: pp == null
                            ? SleekCircularSlider(
                                appearance: CircularSliderAppearance(
                                  customWidths:
                                      CustomSliderWidths(progressBarWidth: 3),
                                  customColors: CustomSliderColors(
                                      trackColor: Colors.transparent,
                                      progressBarColors: [
                                        Colors.purple,
                                        Colors.red
                                      ]),
                                  spinnerMode: true,
                                ),
                              )
                            : ClipOval(child: Image.network(pp!)),
                        decoration: pp != null
                            ? BoxDecoration(
                                borderRadius: BorderRadius.circular(60.0),
                                border: const GradientBoxBorder(
                                  gradient: LinearGradient(
                                      colors: [Colors.purple, Colors.red]),
                                  width: 4,
                                ),
                              )
                            : null),
                    SizedBox(width: 5)
                  ],
                );
              }),
        ),
      ),
    );
  }
}
