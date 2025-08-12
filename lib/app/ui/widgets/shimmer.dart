import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class MyShimmer extends StatelessWidget {
  const MyShimmer({
    super.key,
    required this.hight,
    this.edgeInsetsMargin,
    this.width = double.infinity,
  });
  final double hight;
  final double? width;
  final EdgeInsets? edgeInsetsMargin;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: context.theme.cardColor,
      highlightColor: context.theme.primaryColor,
      child: Card(
        margin: edgeInsetsMargin,
        child: SizedBox(height: hight, width: width),
      ),
    );
  }
}
