import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Base skeleton loader widget with shimmer effect
class SkeletonLoader extends StatelessWidget {
  final double width;
  final double? height;
  final BorderRadius? borderRadius;
  final Color? baseColor;
  final Color? highlightColor;

  const SkeletonLoader({
    super.key,
    required this.width,
    this.height,
    this.borderRadius,
    this.baseColor,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: baseColor ?? Colors.grey[300]!,
      highlightColor: highlightColor ?? Colors.grey[100]!,
      period: const Duration(milliseconds: 1500),
      child: Container(
        width: width,
        height: height ?? 16.0,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius ?? BorderRadius.circular(4.0),
        ),
      ),
    );
  }
}

/// Skeleton loader specifically for commuter list items
class CommuterListItemSkeleton extends StatelessWidget {
  const CommuterListItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 8.0,
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SkeletonLoader(
              width: 120.0,
              height: 18.0,
              borderRadius: BorderRadius.circular(4.0),
            ),
            SkeletonLoader(
              width: 100.0,
              height: 16.0,
              borderRadius: BorderRadius.circular(4.0),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SkeletonLoader(
                width: 100.0,
                height: 14.0,
                borderRadius: BorderRadius.circular(4.0),
              ),
              SkeletonLoader(
                width: 80.0,
                height: 14.0,
                borderRadius: BorderRadius.circular(4.0),
              ),
            ],
          ),
        ),
        trailing: SkeletonLoader(
          width: 24.0,
          height: 24.0,
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
    );
  }
}

/// Skeleton loader specifically for driver list items
class DriverListItemSkeleton extends StatelessWidget {
  const DriverListItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 9,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: SkeletonLoader(
          width: 40.0,
          height: 40.0,
          borderRadius: BorderRadius.circular(20.0),
        ),
        title: SkeletonLoader(
          width: 150.0,
          height: 18.0,
          borderRadius: BorderRadius.circular(4.0),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SkeletonLoader(
                width: 100.0,
                height: 14.0,
                borderRadius: BorderRadius.circular(4.0),
              ),
              SkeletonLoader(
                width: 100.0,
                height: 14.0,
                borderRadius: BorderRadius.circular(4.0),
              ),
            ],
          ),
        ),
        trailing: SkeletonLoader(
          width: 24.0,
          height: 24.0,
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
    );
  }
}

/// Skeleton loader specifically for batch list items
class BatchListItemSkeleton extends StatelessWidget {
  const BatchListItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        title: SkeletonLoader(
          width: 200.0,
          height: 20.0,
          borderRadius: BorderRadius.circular(4.0),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: SkeletonLoader(
            width: 150.0,
            height: 16.0,
            borderRadius: BorderRadius.circular(4.0),
          ),
        ),
        trailing: SkeletonLoader(
          width: 24.0,
          height: 24.0,
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
    );
  }
}

/// Skeleton loader specifically for cab list items
class CabListItemSkeleton extends StatelessWidget {
  const CabListItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 9,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: SkeletonLoader(
          width: 40.0,
          height: 40.0,
          borderRadius: BorderRadius.circular(20.0),
        ),
        title: SkeletonLoader(
          width: 120.0,
          height: 18.0,
          borderRadius: BorderRadius.circular(4.0),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SkeletonLoader(
                    width: 12.0,
                    height: 12.0,
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                  const SizedBox(width: 4),
                  SkeletonLoader(
                    width: 100.0,
                    height: 14.0,
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  SkeletonLoader(
                    width: 12.0,
                    height: 12.0,
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                  const SizedBox(width: 4),
                  SkeletonLoader(
                    width: 80.0,
                    height: 14.0,
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  const SizedBox(width: 12),
                  SkeletonLoader(
                    width: 12.0,
                    height: 12.0,
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                  const SizedBox(width: 4),
                  SkeletonLoader(
                    width: 60.0,
                    height: 14.0,
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                ],
              ),
            ],
          ),
        ),
        trailing: SkeletonLoader(
          width: 24.0,
          height: 24.0,
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
    );
  }
}

/// Skeleton loader specifically for route list items
class RouteListItemSkeleton extends StatelessWidget {
  const RouteListItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 9,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: SkeletonLoader(
          width: 40.0,
          height: 40.0,
          borderRadius: BorderRadius.circular(20.0),
        ),
        title: SkeletonLoader(
          width: 180.0,
          height: 18.0,
          borderRadius: BorderRadius.circular(4.0),
        ),
        trailing: SkeletonLoader(
          width: 24.0,
          height: 24.0,
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
    );
  }
}

/// Skeleton loader specifically for POP list items
class PopListItemSkeleton extends StatelessWidget {
  const PopListItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 9,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: SkeletonLoader(
          width: 40.0,
          height: 40.0,
          borderRadius: BorderRadius.circular(20.0),
        ),
        title: SkeletonLoader(
          width: 150.0,
          height: 18.0,
          borderRadius: BorderRadius.circular(4.0),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Row(
            children: [
              SkeletonLoader(
                width: 12.0,
                height: 12.0,
                borderRadius: BorderRadius.circular(2.0),
              ),
              const SizedBox(width: 4),
              SkeletonLoader(
                width: 100.0,
                height: 14.0,
                borderRadius: BorderRadius.circular(4.0),
              ),
              const SizedBox(width: 12),
              SkeletonLoader(
                width: 12.0,
                height: 12.0,
                borderRadius: BorderRadius.circular(2.0),
              ),
              const SizedBox(width: 4),
              SkeletonLoader(
                width: 80.0,
                height: 14.0,
                borderRadius: BorderRadius.circular(4.0),
              ),
            ],
          ),
        ),
        trailing: SkeletonLoader(
          width: 24.0,
          height: 24.0,
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
    );
  }
}
