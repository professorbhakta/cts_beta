import 'package:cts/widgets/skeleton_loader.dart';
import 'package:flutter/material.dart';

/// Skeleton list specifically for commuter screen
class CommuterSkeletonList extends StatelessWidget {
  final int itemCount;

  const CommuterSkeletonList({super.key, this.itemCount = 8});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: itemCount,
      separatorBuilder: (_, _) => const SizedBox(height: 2),
      itemBuilder: (context, index) {
        return const CommuterListItemSkeleton();
      },
    );
  }
}

/// Skeleton list specifically for driver screen
class DriverSkeletonList extends StatelessWidget {
  final int itemCount;

  const DriverSkeletonList({super.key, this.itemCount = 8});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return const DriverListItemSkeleton();
      },
    );
  }
}

/// Skeleton list specifically for batch screen
class BatchSkeletonList extends StatelessWidget {
  final int itemCount;

  const BatchSkeletonList({super.key, this.itemCount = 8});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: itemCount,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return const BatchListItemSkeleton();
      },
    );
  }
}

/// Skeleton list specifically for cab screen
class CabSkeletonList extends StatelessWidget {
  final int itemCount;

  const CabSkeletonList({super.key, this.itemCount = 8});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      separatorBuilder: (_, _) => const SizedBox(height: 5),
      itemBuilder: (context, index) {
        return const CabListItemSkeleton();
      },
    );
  }
}

/// Skeleton list specifically for route screen
class RouteSkeletonList extends StatelessWidget {
  final int itemCount;

  const RouteSkeletonList({super.key, this.itemCount = 8});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return const RouteListItemSkeleton();
      },
    );
  }
}

/// Skeleton list specifically for POP screen
class PopSkeletonList extends StatelessWidget {
  final int itemCount;

  const PopSkeletonList({super.key, this.itemCount = 8});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: itemCount,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return const PopListItemSkeleton();
      },
    );
  }
}

