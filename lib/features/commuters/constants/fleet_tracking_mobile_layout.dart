/// CSS/JS overrides so Fleet Edge tracking renders in mobile layout inside WebView.
///
/// The site only stacks vertically below 430px viewport width. Many Android WebViews
/// (including MIUI) report a wider layout width, which triggers the broken side-by-side
/// desktop-style layout.
class FleetTrackingMobileLayout {
  const FleetTrackingMobileLayout._();

  static const mobileLayoutScript = '''
(function() {
  var styleId = 'cts-fleet-mobile-layout';
  if (!document.getElementById(styleId)) {
    var style = document.createElement('style');
    style.id = styleId;
    style.textContent = [
      '.sec-cont {',
      '  flex-direction: column !important;',
      '  gap: 1rem !important;',
      '}',
      '.accordion-wrap {',
      '  margin: 0 !important;',
      '}',
      '.accordion-wrap.vehicle-details {',
      '  margin: 0 !important;',
      '  width: 100% !important;',
      '}',
      '.map-structure, .map-width, .vehicle-live-location, .cp-section {',
      '  width: 100% !important;',
      '  max-width: 100% !important;',
      '}',
      '.map-width {',
      '  height: 300px !important;',
      '}',
      '.receiver-details {',
      '  flex-direction: column !important;',
      '}',
      '.share-tab, body, html {',
      '  width: 100% !important;',
      '  max-width: 100vw !important;',
      '  overflow-x: hidden !important;',
      '}',
      '.header-section {',
      '  padding: 1rem !important;',
      '}',
      '.details-grid {',
      '  display: flex !important;',
      '  flex-direction: column !important;',
      '}',
      '.owner-data .acc-data {',
      '  width: auto !important;',
      '}',
      'table {',
      '  width: 100% !important;',
      '  table-layout: fixed !important;',
      '}',
    ].join('\\n');
    document.head.appendChild(style);
  }

  var meta = document.querySelector('meta[name="viewport"]');
  if (meta) {
    meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=5.0';
  }

  window.dispatchEvent(new Event('resize'));
})();
''';
}
