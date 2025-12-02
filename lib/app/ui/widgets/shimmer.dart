import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class MyShimmer extends StatelessWidget {
  const MyShimmer({super.key, required this.height, this.width, this.margin});

  final double height;
  final double? width;
  final EdgeInsets? margin;

  @override
  Widget build(BuildContext context) => Shimmer.fromColors(
    baseColor: context.theme.cardColor,
    highlightColor: context.theme.primaryColor,
    child: _buildShimmerCard(),
  );

  Widget _buildShimmerCard() => Card(
    margin: margin,
    child: SizedBox(height: height, width: width),
  );
}
