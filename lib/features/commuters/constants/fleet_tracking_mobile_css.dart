/// Mobile layout overrides for Tata Fleet Edge inside in-app WebView.
///
/// The live site only stacks cards vertically when viewport width is 320–430px.
/// MIUI WebView often reports a wider layout width, so we force that breakpoint.
class FleetTrackingMobileCss {
  const FleetTrackingMobileCss._();

  /// Fixed layout width that falls inside the site's mobile media query.
  static const int mobileViewportWidth = 390;

  /// CSS copied from the site's `@media (max-width: 430px)` block.
  static const String overrideRules = '''
.display-logo {
  display: none !important;
}
.vehicle-row {
  justify-content: space-evenly !important;
}
.sec-cont {
  flex-direction: column !important;
  gap: 1rem !important;
  margin: 0 0.5rem 1rem 0.5rem !important;
}
.receiver-details {
  flex-direction: column !important;
}
.accordion-wrap {
  margin: 0 !important;
}
.accordion-wrap.vehicle-details {
  margin: 0 !important;
  width: 100% !important;
}
.mat-toolbar-row {
  flex-direction: column !important;
  align-items: flex-start !important;
}
.image-section {
  flex-direction: column !important;
  align-items: flex-start !important;
  gap: 0.5rem !important;
}
.vehicle-details table {
  font-size: 0.75rem !important;
}
.paginationRight {
  padding: 1rem 0 !important;
  flex-wrap: wrap !important;
  gap: 0.5rem !important;
}
.data-disclaimer {
  margin-left: 0.8rem !important;
  font-size: 0.9rem !important;
}
.pageActive,
.pageInactive {
  margin: 0 5px 5px 0 !important;
}
.map-structure,
.map-width,
.vehicle-live-location,
.cp-section,
.tabs-in-head,
.share-tab {
  width: 100% !important;
  max-width: 100% !important;
}
.map-width {
  height: 300px !important;
}
.details-grid {
  grid-template-columns: 1fr !important;
  display: flex !important;
  gap: 1rem !important;
  flex-direction: column !important;
}
.accordin-title {
  font-size: 16px !important;
}
.owner-data .acc-data {
  width: auto !important;
}
th,
td {
  font-size: 0.75rem !important;
  padding: 6px !important;
}
html,
body {
  margin: 0 !important;
  padding: 0 !important;
  width: 100% !important;
  overflow-x: hidden !important;
  background-color: #f5f5f5 !important;
}
''';

  static String injectionScript({
    required String cssRules,
    required int viewportWidth,
  }) {
    final escapedCss = cssRules.replaceAll('`', r'\`').replaceAll('\$', r'\$');
    return '''
(function() {
  var viewportWidth = $viewportWidth;
  var styleId = 'cts-fleet-mobile-fix';

  function applyFix() {
    var existing = document.getElementById(styleId);
    if (existing) {
      existing.remove();
    }
    var style = document.createElement('style');
    style.id = styleId;
    style.textContent = `$escapedCss`;
    document.head.appendChild(style);

    var meta = document.querySelector('meta[name="viewport"]');
    if (!meta) {
      meta = document.createElement('meta');
      meta.name = 'viewport';
      document.head.appendChild(meta);
    }
    meta.content = 'width=' + viewportWidth + ', initial-scale=1.0, maximum-scale=5.0';

    if (document.body) {
      document.body.style.margin = '0';
      document.body.style.padding = '0';
      document.body.style.width = '100%';
      document.body.style.overflowX = 'hidden';
    }
  }

  applyFix();

  if (!window.__ctsFleetObserverAttached) {
    window.__ctsFleetObserverAttached = true;
    var observer = new MutationObserver(function() {
      applyFix();
    });
    observer.observe(document.documentElement, {
      childList: true,
      subtree: true,
      attributes: true,
    });
  }
})();
''';
  }
}
