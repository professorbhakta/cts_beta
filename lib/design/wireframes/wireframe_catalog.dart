import 'package:cts/design/wireframes/screens/admin_dashboard_wireframe.dart';
import 'package:cts/design/wireframes/screens/auth_sign_in_wireframe.dart';
import 'package:cts/design/wireframes/screens/commuter_home_wireframe.dart';
import 'package:cts/design/wireframes/screens/crud_form_wireframe.dart';
import 'package:cts/design/wireframes/screens/crud_list_wireframe.dart';
import 'package:cts/design/wireframes/screens/d2d_live_wireframe.dart';
import 'package:cts/design/wireframes/screens/driver_home_wireframe.dart';
import 'package:cts/design/wireframes/screens/offline_home_wireframe.dart';
import 'package:cts/design/wireframes/screens/profile_wireframe.dart';
import 'package:flutter/material.dart';

/// Stable ids for routes and documentation cross-links.
class WireframeCatalog {
  const WireframeCatalog._();

  static const entries = <WireframeEntry>[
    WireframeEntry(
      id: 'auth_sign_in',
      title: 'Sign in',
      subtitle: 'Public auth — mobile + password',
      role: 'All',
      docSection: 'docs/UI_ARCHITECTURE.md §3.1',
      builder: AuthSignInWireframe.new,
    ),
    WireframeEntry(
      id: 'admin_dashboard',
      title: 'Admin dashboard',
      subtitle: 'Stats + quick actions',
      role: 'Admin',
      docSection: 'docs/UI_ARCHITECTURE.md §3.2',
      builder: AdminDashboardWireframe.new,
    ),
    WireframeEntry(
      id: 'crud_list',
      title: 'Admin CRUD list',
      subtitle: 'Search + slidable rows (Routes template)',
      role: 'Admin',
      docSection: 'docs/UI_ARCHITECTURE.md §3.3',
      builder: CrudListWireframe.new,
    ),
    WireframeEntry(
      id: 'crud_form',
      title: 'Admin CRUD form',
      subtitle: 'Create / edit entity',
      role: 'Admin',
      docSection: 'docs/UI_ARCHITECTURE.md §3.4',
      builder: CrudFormWireframe.new,
    ),
    WireframeEntry(
      id: 'driver_home',
      title: 'Driver home',
      subtitle: 'Assignment card + START TRIP',
      role: 'Driver',
      docSection: 'docs/UI_ARCHITECTURE.md §3.5',
      builder: DriverHomeWireframe.new,
    ),
    WireframeEntry(
      id: 'd2d_live',
      title: 'D2D live list',
      subtitle: 'Driver log / admin channel layout',
      role: 'Driver / Admin',
      docSection: 'docs/UI_ARCHITECTURE.md §3.6–3.7',
      builder: D2dLiveWireframe.new,
    ),
    WireframeEntry(
      id: 'commuter_home',
      title: 'Commuter home',
      subtitle: 'Coming today switch',
      role: 'Commuter',
      docSection: 'docs/UI_ARCHITECTURE.md §3.8',
      builder: CommuterHomeWireframe.new,
    ),
    WireframeEntry(
      id: 'offline_home',
      title: 'Offline mode',
      subtitle: 'Bottom tabs + FAB',
      role: 'Admin',
      docSection: 'docs/UI_ARCHITECTURE.md §3.9',
      builder: OfflineHomeWireframe.new,
    ),
    WireframeEntry(
      id: 'profile',
      title: 'Profile',
      subtitle: 'Account info + logout',
      role: 'All logged-in',
      docSection: 'docs/UI_ARCHITECTURE.md §3.10',
      builder: ProfileWireframe.new,
    ),
  ];

  static WireframeEntry? byId(String id) {
    for (final e in entries) {
      if (e.id == id) return e;
    }
    return null;
  }
}

class WireframeEntry {
  const WireframeEntry({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.role,
    required this.docSection,
    required this.builder,
  });

  final String id;
  final String title;
  final String subtitle;
  final String role;
  final String docSection;
  final Widget Function() builder;
}
