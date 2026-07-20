/**
 * CTS interactive wireframe prototype
 * Dual audience: guided product demo + developer design reference
 * Maps to Flutter: RouteName.*, FEATURES.md, UI_ARCHITECTURE.md
 */
(function () {
  "use strict";

  // ---------- Seed data ----------
  const store = {
    routes: [
      { id: 1, name: "Route A — North Corridor" },
      { id: 2, name: "Route B — South Loop" },
      { id: 3, name: "Main Street Express" },
    ],
    pops: [
      { id: 1, name: "Gate 1", sub: "Near main entrance" },
      { id: 2, name: "Tech Park Stop", sub: "Building C" },
      { id: 3, name: "Metro Junction", sub: "Platform 2" },
    ],
    batches: [
      { id: 1, name: "Morning A", sub: "07:30 · Cab MH-12-AB" },
      { id: 2, name: "Evening B", sub: "18:00 · Cab MH-14-XY" },
      { id: 3, name: "Weekend Flex", sub: "09:00 · Cab MH-09-QQ" },
    ],
    cabs: [
      { id: 1, name: "MH-12-AB-1234", sub: "Sedan · 4 seats" },
      { id: 2, name: "MH-14-XY-5678", sub: "SUV · 6 seats" },
    ],
    drivers: [
      { id: 1, name: "Ravi Kumar", sub: "+91 98••••21" },
      { id: 2, name: "Anita Desai", sub: "+91 97••••44" },
    ],
    commuters: [
      { id: 1, name: "Priya Shah", sub: "Coming today" },
      { id: 2, name: "Omar Khan", sub: "Not coming" },
      { id: 3, name: "Lee Chen", sub: "Coming today" },
    ],
    running: [
      { id: 101, name: "Morning A", sub: "Live · 12 on board" },
      { id: 102, name: "Evening B", sub: "Starting · 3 boarded" },
    ],
    returning: [
      { id: 201, name: "Morning A Return", sub: "14:00 window" },
      { id: 202, name: "Evening B Return", sub: "20:30 window" },
    ],
    d2dPeople: [
      { id: 1, name: "Priya Shah", sub: "Waiting · Gate 1" },
      { id: 2, name: "Omar Khan", sub: "Picked up" },
      { id: 3, name: "Lee Chen", sub: "Call pending" },
    ],
    offlineRoutes: [
      { id: 1, name: "Offline Route X", sub: "3 POPs" },
      { id: 2, name: "Offline Route Y", sub: "5 POPs" },
    ],
    offlineBatches: [
      { id: 1, name: "Local Batch 1", sub: "8 commuters" },
    ],
    offlinePeople: [
      { id: 1, name: "Local User A", sub: "unsynced" },
    ],
    nextId: 1000,
  };

  // ---------- Screen metadata (Dev panel) ----------
  const META = {
    landing: null,
    splash: {
      widget: "SplashScreen",
      route: "RouteName.splashScreen",
      path: "/splashScreen",
      file: "lib/features/splash/.../splash_screen.dart",
      provider: "SplashProvider",
      md: "ROUTING_AND_AUTH.md · UI_ARCHITECTURE §1",
      caption: "App launch resolves your session, then sends you to sign-in or your role home.",
    },
    signIn: {
      widget: "SignInScreen",
      route: "RouteName.signIn",
      path: "/signIn",
      file: "lib/features/auth/presentation/screens/sign_in.dart",
      provider: "SignInProvider",
      md: "guides/* · FLOWS_BY_ROLE · TESTING",
      caption: "Enter mobile and password. This demo lets you pick a role instead of a real API login.",
    },
    signUp: {
      widget: "SignUpScreen",
      route: "RouteName.signUp",
      path: "/signUp",
      file: "lib/features/auth/presentation/screens/sign_up.dart",
      provider: "SignUpProvider",
      md: "UI_ARCHITECTURE · ROUTING_AND_AUTH",
      caption: "Create an account (demo only — returns to sign-in).",
    },
    adminHome: {
      widget: "AdminMainScreen",
      route: "RouteName.adminHomeScreen",
      path: "/adminHomeScreen",
      file: "lib/features/admin_home/.../admin_home_screen.dart",
      provider: "AdminProvider",
      shell: "DashboardShell + AppDrawer",
      md: "guides/ADMIN · FLOWS · FEATURES",
      caption: "Admin hub: tap stats or quick actions to open lists and forms. Menu opens the drawer.",
    },
    routes: {
      widget: "RouteScreen",
      route: "RouteName.routeScreen",
      path: "/routeScreen",
      file: "lib/features/routes/presentation/screens/route_screen.dart",
      provider: "RouteController",
      shell: "DashboardShell",
      md: "UI_ARCHITECTURE §3.3 · FEATURES",
      caption: "CRUD list template: search, edit, delete with confirmation, or + to create.",
    },
    routeForm: {
      widget: "RouteForm",
      route: "RouteName.routeForm",
      path: "/routeForm",
      file: "lib/features/routes/presentation/forms/route_form.dart",
      provider: "RouteFormProvider + RouteController",
      shell: "DashboardShell + AdminFormHeader",
      md: "UI_ARCHITECTURE §3.4",
      caption: "Create or edit a route. Save returns to the list with your change applied.",
    },
    pops: {
      widget: "PopScreen",
      route: "RouteName.popScreen",
      path: "/popScreen",
      file: "lib/features/pops/.../pop_screen.dart",
      provider: "PopProvider",
      md: "FEATURES · ADMIN guide",
      caption: "Pick-up points (POPs) — same list CRUD pattern as Routes.",
    },
    popForm: {
      widget: "PopForm",
      route: "RouteName.popForm",
      path: "/popForm",
      file: "lib/features/pops/.../pop_form.dart",
      provider: "PopFormProvider",
      md: "FEATURES",
      caption: "Create or edit a pick-up point.",
    },
    batches: {
      widget: "BatchScreen",
      route: "RouteName.batchScreen",
      path: "/batchScreen",
      file: "lib/features/batches/.../batch_screen.dart",
      provider: "BatchProvider",
      md: "FEATURES · OFFLINE_AND_SYNC (offline-first)",
      caption: "Schedules and assignments. AppBar return icon opens return batches; row opens nested commuters.",
    },
    batchForm: {
      widget: "BatchForm",
      route: "RouteName.batchForm",
      path: "/batchForm",
      file: "lib/features/batches/.../batch_form.dart",
      provider: "BatchFormProvider",
      md: "FEATURES",
      caption: "Create or edit a batch (name, times).",
    },
    running: {
      widget: "RunningBatchScreen",
      route: "RouteName.runningBatchScreen",
      path: "/runningBatchScreen",
      file: "lib/features/batches/.../running_batch_screen.dart",
      provider: "RunningBatchProvider",
      md: "FLOWS · ADMIN guide · SCREENSHOTS",
      caption: "Live trips. Tap a batch card to open the admin D2D Channel.",
    },
    returning: {
      widget: "ReturningBatchScreen",
      route: "RouteName.returnBatchScreen",
      path: "/returnBatchScreen",
      file: "lib/features/batches/.../returning_batch_screen.dart",
      provider: "ReturnBatchProvider",
      md: "FLOWS · ADMIN guide",
      caption: "Return-trip batches. Tap a row for the nested return-commuter list.",
    },
    cabs: {
      widget: "CabScreen",
      route: "RouteName.cabScreen",
      path: "/cabScreen",
      file: "lib/features/cabs/.../cab_screen.dart",
      provider: "CabProvider",
      md: "FEATURES",
      caption: "Vehicles — list CRUD pattern.",
    },
    cabForm: {
      widget: "CabForm",
      route: "RouteName.cabForm",
      path: "/cabForm",
      file: "lib/features/cabs/.../cab_form.dart",
      provider: "CabFormProvider",
      md: "FEATURES",
      caption: "Create or edit a cab.",
    },
    drivers: {
      widget: "DriverScreen",
      route: "RouteName.driverScreen",
      path: "/driverScreen",
      file: "lib/features/drivers/.../driver_screen.dart",
      provider: "DriverProvider",
      md: "FEATURES",
      caption: "Driver accounts managed by admin.",
    },
    driverForm: {
      widget: "DriverForm",
      route: "RouteName.driverForm",
      path: "/driverForm",
      file: "lib/features/drivers/.../driver_form.dart",
      provider: "DriverFormProvider",
      md: "FEATURES",
      caption: "Create or edit a driver.",
    },
    commuters: {
      widget: "CommuterScreen",
      route: "RouteName.commuterScreen",
      path: "/commuterScreen",
      file: "lib/features/commuters/.../commuter_screen.dart",
      provider: "CommuterController",
      md: "FEATURES · ADMIN guide",
      caption: "All commuters — list CRUD pattern.",
    },
    commuterForm: {
      widget: "CommuterForm",
      route: "RouteName.commuterForm",
      path: "/commuterForm",
      file: "lib/features/commuters/.../commuter_form.dart",
      provider: "CommuterFormProvider",
      md: "FEATURES",
      caption: "Create or edit a commuter.",
    },
    commuterList: {
      widget: "CommuterListScreen",
      route: "Navigator.push (nested)",
      path: "(not in GoRouter)",
      file: "lib/features/commuters/.../commuter_list_screen.dart",
      provider: "CommuterController",
      md: "UI_ARCHITECTURE · FLOWS",
      caption: "Commuters assigned to one batch (nested push from Batch list).",
    },
    returnCommuterList: {
      widget: "ReturnCommuterListScreen",
      route: "Navigator.push (nested)",
      path: "(not in GoRouter)",
      file: "lib/features/commuters/.../return_commuter_list_screen.dart",
      provider: "ReturnBatchProvider",
      md: "UI_ARCHITECTURE · FLOWS",
      caption: "Confirm / manage return-trip riders for a batch.",
    },
    d2dChannel: {
      widget: "D2dChannel",
      route: "RouteName.d2dChannel",
      path: "/d2dChannel/:batchId",
      file: "lib/features/d2d/.../d2d_channel.dart",
      provider: "D2dChannelProvider",
      shell: "DashboardShell",
      md: "FLOWS · SCREENSHOTS",
      caption: "Admin live door-to-door channel for one running batch. Close Channel when done.",
    },
    driverHome: {
      widget: "DriverHomePage",
      route: "RouteName.driverHomeScreen",
      path: "/driverHomeScreen",
      file: "lib/features/drivers/.../driver_home_page.dart",
      provider: "DriverHomeProvider",
      shell: "BrandAppBar + AppDrawer",
      md: "guides/DRIVER · FLOWS",
      caption: "Today’s assignment. START TRIP opens the D2D trip log.",
    },
    d2dLog: {
      widget: "D2DLogScreen",
      route: "RouteName.d2dLog",
      path: "/d2dLog/:batchId",
      file: "lib/features/d2d/.../d2d_log_screen.dart",
      provider: "D2dChannelProvider",
      shell: "BrandAppBar",
      md: "guides/DRIVER · TESTING",
      caption: "Live trip log for the driver. Stop trip returns home.",
    },
    commuterHome: {
      widget: "CommuterHomePage",
      route: "RouteName.commuterHomeScreen",
      path: "/commuterHomeScreen",
      file: "lib/features/commuters/.../commuter_home_page.dart",
      provider: "CommuterHomeProvider",
      shell: "BrandAppBar",
      md: "guides/COMMUTER · FLOWS",
      caption: "Toggle Coming today — a confirmation dialog appears before saving.",
    },
    profile: {
      widget: "ProfileScreen",
      route: "RouteName.profileScreen",
      path: "/profileScreen",
      file: "lib/features/profile/.../profile_screen.dart",
      provider: "SignInProvider (logout)",
      md: "ROUTING_AND_AUTH · guides",
      caption: "Your details. Logout clears session and returns to sign-in.",
    },
    offline: {
      widget: "OfflineHomeScreen",
      route: "RouteName.offlineTempHome",
      path: "/offlineTempHome",
      file: "lib/offline_temp/screens/offline_home_screen.dart",
      provider: "OfflineTempProvider",
      md: "OFFLINE_AND_SYNC · UI §3.9",
      caption: "Offline prototype: switch bottom tabs; FAB actions differ per tab.",
    },
    offlineRoutePops: {
      widget: "OfflineRoutePopsScreen",
      route: "RouteName.offlineRoutePops",
      path: "/offlineRoutePops/:routeId",
      file: "lib/offline_temp/screens/...",
      provider: "OfflineTempProvider",
      md: "FEATURES · OFFLINE",
      caption: "POPs for one offline route (drill-down).",
    },
    offlineBatchCommuters: {
      widget: "OfflineBatchCommutersScreen",
      route: "RouteName.offlineBatchCommuters",
      path: "/offlineBatchCommuters/:batchId",
      file: "lib/offline_temp/screens/...",
      provider: "OfflineTempProvider",
      md: "FEATURES · OFFLINE",
      caption: "Commuters for one offline batch (drill-down).",
    },
  };

  const CRUD = {
    routes: {
      key: "routes",
      listId: "routes",
      formId: "routeForm",
      title: "Routes",
      singular: "Route",
      icon: "↗",
      searchHint: "Search routes by name...",
      subtitle: "Manage pickup corridors and keep them updated.",
      fieldLabel: "Route Name",
      fieldHint: "e.g. Route A, Main Street",
      drawerKey: "routes",
    },
    pops: {
      key: "pops",
      listId: "pops",
      formId: "popForm",
      title: "Pick-up Points",
      singular: "POP",
      icon: "📍",
      searchHint: "Search pick-up points...",
      subtitle: "Locations where riders board.",
      fieldLabel: "POP Name",
      fieldHint: "e.g. Gate 1",
      drawerKey: "pops",
    },
    batches: {
      key: "batches",
      listId: "batches",
      formId: "batchForm",
      title: "Batches",
      singular: "Batch",
      icon: "🚌",
      searchHint: "Search batches...",
      subtitle: "Schedules and cab assignments.",
      fieldLabel: "Batch Name",
      fieldHint: "e.g. Morning A",
      drawerKey: "batches",
      extraActions: true,
    },
    cabs: {
      key: "cabs",
      listId: "cabs",
      formId: "cabForm",
      title: "Cabs",
      singular: "Cab",
      icon: "🚗",
      searchHint: "Search cabs...",
      subtitle: "Vehicles in the fleet.",
      fieldLabel: "Registration",
      fieldHint: "e.g. MH-12-AB-1234",
      drawerKey: "cabs",
    },
    drivers: {
      key: "drivers",
      listId: "drivers",
      formId: "driverForm",
      title: "Drivers",
      singular: "Driver",
      icon: "👤",
      searchHint: "Search drivers...",
      subtitle: "Driver accounts.",
      fieldLabel: "Driver Name",
      fieldHint: "Full name",
      drawerKey: "drivers",
    },
    commuters: {
      key: "commuters",
      listId: "commuters",
      formId: "commuterForm",
      title: "Commuters",
      singular: "Commuter",
      icon: "👥",
      searchHint: "Search commuters...",
      subtitle: "Riders in the system.",
      fieldLabel: "Commuter Name",
      fieldHint: "Full name",
      drawerKey: "commuters",
    },
  };

  // ---------- App state ----------
  const state = {
    role: "ADMIN",
    screen: "landing",
    history: [],
    drawerOpen: false,
    search: {},
    form: { entity: null, editId: null, name: "" },
    offlineTab: 0,
    coming: true,
    pendingComing: null,
    batchContext: null,
    tour: null,
    showDev: false,
    showMap: false,
    syncPending: 2,
  };

  // ---------- Tours ----------
  const TOURS = {
    admin: {
      name: "Admin tour",
      steps: [
        { screen: "signIn", text: "Sign in as Admin (or tap Admin below). In production you use mobile + password.", highlight: "[data-tour='login']" },
        { screen: "adminHome", text: "This is the Dashboard. Tap the menu ☰ to open the drawer, or tap a Quick Action.", highlight: "[data-tour='qa-running']" },
        { screen: "running", text: "Running Batches shows live trips. Tap a batch card to open D2D Channel.", highlight: "[data-tour='running-0']" },
        { screen: "d2dChannel", text: "Admin watches the live rider list. Close Channel when finished.", highlight: "[data-tour='close-channel']" },
        { screen: "adminHome", text: "Tour complete. Try Drawer → Routes for full CRUD (search, edit, delete, FAB).", highlight: null },
      ],
    },
    driver: {
      name: "Driver tour",
      steps: [
        { screen: "signIn", text: "Sign in as Driver to reach driver home.", highlight: "[data-tour='login']" },
        { screen: "driverHome", text: "Review today’s batch, time, and cab. Tap START TRIP to begin.", highlight: "[data-tour='start-trip']" },
        { screen: "d2dLog", text: "Trip log: call or update riders. When done, Stop trip.", highlight: "[data-tour='stop-trip']" },
        { screen: "driverHome", text: "You’re back home. Open Profile from the drawer to log out.", highlight: null },
      ],
    },
    commuter: {
      name: "Commuter tour",
      steps: [
        { screen: "signIn", text: "Sign in as Commuter.", highlight: "[data-tour='login']" },
        { screen: "commuterHome", text: "Toggle Coming today — a confirmation dialog will appear.", highlight: "[data-tour='coming-switch']" },
        { screen: "commuterHome", text: "After confirm, a success toast appears. That’s the core daily action.", highlight: null },
      ],
    },
  };

  // ---------- DOM refs ----------
  const $ = (sel, root) => (root || document).querySelector(sel);
  const $$ = (sel, root) => Array.from((root || document).querySelectorAll(sel));

  const els = {
    landing: $("#view-landing"),
    demo: $("#view-demo"),
    phone: $("#phone-root"),
    crumb: $("#breadcrumb"),
    caption: $("#screen-caption"),
    tourBanner: $("#tour-banner"),
    tourText: $("#tour-text"),
    tourStep: $("#tour-step"),
    devPanel: $("#dev-panel"),
    mapOverlay: $("#map-overlay"),
    mapFlow: $("#map-flow"),
    phoneLabel: $("#phone-label"),
  };

  // ---------- Navigation ----------
  function navigate(screenId, opts) {
    opts = opts || {};
    if (!opts.replace && state.screen !== "landing" && state.screen !== screenId) {
      state.history.push(state.screen);
    }
    if (opts.replace) state.history = [];
    state.screen = screenId;
    state.drawerOpen = false;
    if (opts.batchContext !== undefined) state.batchContext = opts.batchContext;
    if (opts.form) state.form = opts.form;
    if (opts.role) state.role = opts.role;
    location.hash = screenId === "landing" ? "" : screenId;
    render();
  }

  function goBack() {
    if (state.drawerOpen) {
      state.drawerOpen = false;
      render();
      return;
    }
    if (state.history.length) {
      state.screen = state.history.pop();
      location.hash = state.screen;
      render();
      return;
    }
    showLanding();
  }

  function showLanding() {
    state.screen = "landing";
    state.history = [];
    state.tour = null;
    location.hash = "";
    els.landing.classList.add("active");
    els.demo.classList.remove("active");
  }

  function enterDemo(screenId, opts) {
    els.landing.classList.remove("active");
    els.demo.classList.add("active");
    navigate(screenId, Object.assign({ replace: true }, opts || {}));
  }

  // ---------- Toast / Modal ----------
  function toast(msg, type) {
    const t = $("#toast");
    t.textContent = msg;
    t.className = "toast show" + (type ? " " + type : "");
    clearTimeout(t._timer);
    t._timer = setTimeout(() => t.classList.remove("show"), 2400);
  }

  function confirmDialog(cfg) {
    return new Promise((resolve) => {
      const root = $("#modal-root");
      root.classList.add("open");
      root.innerHTML =
        '<div class="modal-backdrop" data-act="cancel"></div>' +
        '<div class="modal-card" role="dialog" aria-modal="true">' +
        '<div class="mtitle"><span class="mi">' +
        (cfg.icon || "🗑") +
        "</span>" +
        esc(cfg.title) +
        "</div>" +
        '<div class="mbody">' +
        esc(cfg.message) +
        "</div>" +
        '<div class="modal-actions">' +
        '<button type="button" class="btn btn-ghost" data-act="cancel">' +
        esc(cfg.cancelLabel || "Cancel") +
        "</button>" +
        '<button type="button" class="btn ' +
        (cfg.danger !== false ? "btn-danger" : "btn-primary") +
        '" data-act="ok">' +
        esc(cfg.confirmLabel || "Confirm") +
        "</button>" +
        "</div></div>";
      const done = (v) => {
        root.classList.remove("open");
        root.innerHTML = "";
        resolve(v);
      };
      root.onclick = (e) => {
        const act = e.target.getAttribute("data-act");
        if (act === "cancel") done(false);
        if (act === "ok") done(true);
      };
    });
  }

  function esc(s) {
    return String(s)
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;");
  }

  // ---------- Render helpers ----------
  function appBar(title, opts) {
    opts = opts || {};
    const brand = opts.brand ? " brand" : "";
    let actions = "";
    if (opts.add) {
      actions +=
        '<button type="button" class="icon-btn" data-act="fab-create" aria-label="Add">＋</button>';
    }
    if (opts.returnBatch) {
      actions +=
        '<button type="button" class="icon-btn" data-act="goto" data-to="returning" title="Return batches" aria-label="Return batches">↩</button>';
    }
    if (opts.more) {
      actions +=
        '<button type="button" class="icon-btn" data-act="more" aria-label="More">⋮</button>';
    }
    const menu = opts.noDrawer
      ? ""
      : '<button type="button" class="menu-btn" data-act="drawer" aria-label="Open menu">☰</button>';
    return (
      '<div class="appbar' +
      brand +
      '">' +
      menu +
      '<div class="title">' +
      esc(title) +
      "</div>" +
      '<div class="actions">' +
      actions +
      "</div></div>"
    );
  }

  function drawerHtml() {
    const items = [
      { id: "adminHome", label: "Dashboard", ico: "▦" },
      { id: "profile", label: "Profile", ico: "☺" },
      { sec: "MANAGEMENT" },
      { id: "commuters", label: "Commuters", ico: "👥" },
      { id: "pops", label: "Pick-up Points", ico: "📍" },
      { id: "batches", label: "Batches", ico: "🚌" },
      { id: "cabs", label: "Cabs", ico: "🚗" },
      { id: "drivers", label: "Drivers", ico: "👤" },
      { id: "routes", label: "Routes", ico: "↗" },
      { sec: "OFFLINE" },
      { id: "offline", label: "Offline Mode", ico: "☁" },
    ];
    let html =
      '<div class="drawer-backdrop' +
      (state.drawerOpen ? " open" : "") +
      '" data-act="drawer-close"></div>' +
      '<aside class="drawer' +
      (state.drawerOpen ? " open" : "") +
      '" aria-label="Navigation drawer">' +
      '<div class="drawer-head"><div class="drawer-avatar">👤</div>' +
      '<div class="name">' +
      esc(roleName()) +
      '</div><div class="mobile">+91 98••••00</div></div>';

    if (state.syncPending > 0) {
      html +=
        '<div class="sync-banner">' +
        state.syncPending +
        ' changes waiting to sync' +
        '<button type="button" data-act="sync-now">Sync now</button></div>';
    }

    items.forEach((it) => {
      if (it.sec) {
        html += '<div class="drawer-sec">' + it.sec + "</div>";
        return;
      }
      const active = state.screen === it.id || (CRUD[state.screen] && CRUD[state.screen].drawerKey === it.id);
      html +=
        '<button type="button" class="drawer-item' +
        (active || state.screen === it.id ? " active" : "") +
        '" data-act="goto" data-to="' +
        it.id +
        '"><span class="ico">' +
        it.ico +
        "</span>" +
        it.label +
        "</button>";
    });
    html +=
      '<div style="height:8px"></div><div style="height:1px;background:#2d2d2d;margin:8px 20px"></div>' +
      '<button type="button" class="drawer-item" data-act="goto" data-to="profile"><span class="ico">⎋</span>Logout via Profile</button>' +
      "</aside>";
    return html;
  }

  function roleName() {
    if (state.role === "DRIVER") return "Driver";
    if (state.role === "COMMUTER") return "Commuter";
    return "Admin";
  }

  function statusBar() {
    return (
      '<div class="status-bar"><span>9:41</span><span>c2s</span><span>▮▮▮</span></div>'
    );
  }

  // ---------- Screens ----------
  function renderSplash() {
    setTimeout(() => {
      if (state.screen === "splash") navigate("signIn", { replace: true });
    }, 1200);
    return (
      '<div class="screen-root">' +
      statusBar() +
      '<div class="phone-body no-pad"><div class="splash-body"><div class="logo">c2s</div><div>Commuter Transport</div><div class="spin" aria-label="Loading"></div></div></div></div>'
    );
  }

  function renderSignIn() {
    return (
      '<div class="screen-root">' +
      statusBar() +
      '<div class="phone-body">' +
      '<div class="logo">c2s</div><div class="welcome">Welcome</div>' +
      '<div class="field-label">Mobile</div><input class="field-input" type="tel" placeholder="10-digit mobile" value="9876543210" />' +
      '<div class="field-label">Password</div><div class="password-wrap"><input class="field-input" type="password" value="••••••••" id="pw" /><button type="button" class="eye" data-act="toggle-pw" aria-label="Show password">👁</button></div>' +
      '<button type="button" class="btn-block primary" data-act="show-roles" data-tour="login">LOGIN</button>' +
      '<div class="link-row">Don\'t have account? <button type="button" data-act="goto" data-to="signUp">Sign Up</button></div>' +
      '<div id="role-pick" style="display:none" class="role-picker">' +
      '<button type="button" data-act="login-role" data-role="ADMIN">🛡 Continue as Admin</button>' +
      '<button type="button" data-act="login-role" data-role="DRIVER">🚌 Continue as Driver</button>' +
      '<button type="button" data-act="login-role" data-role="COMMUTER">🚶 Continue as Commuter</button>' +
      "</div>" +
      '<p style="text-align:center;margin-top:20px;font-size:0.75rem;color:var(--muted)">Demo: LOGIN → pick role (no API)</p>' +
      "</div></div>"
    );
  }

  function renderSignUp() {
    return (
      '<div class="screen-root">' +
      statusBar() +
      '<div class="phone-body">' +
      '<div class="logo">c2s</div><div class="welcome">Create account</div>' +
      '<div class="field-label">Name</div><input class="field-input" placeholder="Full name" />' +
      '<div class="field-label">Mobile</div><input class="field-input" type="tel" placeholder="Mobile" />' +
      '<div class="field-label">Password</div><input class="field-input" type="password" placeholder="Password" />' +
      '<button type="button" class="btn-block primary" data-act="signup-done">Sign Up</button>' +
      '<div class="link-row"><button type="button" data-act="goto" data-to="signIn">Back to Sign In</button></div>' +
      "</div></div>"
    );
  }

  function renderAdminHome() {
    return (
      '<div class="screen-root" style="position:relative">' +
      statusBar() +
      appBar("Dashboard") +
      '<div class="phone-body">' +
      '<div class="welcome-card"><div class="text"><div class="greet">Good ' +
      greeting() +
      '</div><div class="title">Welcome Back!</div><div class="sub">Manage your transportation system</div></div><div class="badge-logo">c2s</div></div>' +
      '<div class="stat-row">' +
      '<button type="button" class="stat yellow" data-act="goto" data-to="batches"><div class="t">Batches</div><div class="n">' +
      store.batches.length +
      '</div><div class="s">2 active</div></button>' +
      '<button type="button" class="stat orange" data-act="goto" data-to="commuters"><div class="t">Commuters</div><div class="n">' +
      store.commuters.length +
      '</div><div class="s">2 coming today</div></button></div>' +
      '<div class="compact-grid">' +
      '<button type="button" class="compact" data-act="goto" data-to="routes"><div class="t">Routes</div><div class="n">' +
      store.routes.length +
      '</div></button>' +
      '<button type="button" class="compact orange" data-act="goto" data-to="pops"><div class="t">Pick-up Points</div><div class="n">' +
      store.pops.length +
      '</div></button>' +
      '<button type="button" class="compact" data-act="goto" data-to="cabs"><div class="t">Cabs</div><div class="n">' +
      store.cabs.length +
      '</div></button>' +
      '<button type="button" class="compact orange" data-act="goto" data-to="drivers"><div class="t">Drivers</div><div class="n">' +
      store.drivers.length +
      '</div></button></div>' +
      '<div class="qa-title">Quick Actions</div><div class="qa-grid">' +
      qa("goto-form", "batches", "＋", "Add Batch") +
      qa("goto-form", "commuters", "＋", "Add Commuter") +
      qa("goto-form", "drivers", "＋", "Add Driver") +
      qa("goto-form", "cabs", "＋", "Add Cab") +
      qa("goto-form", "routes", "＋", "Add Route") +
      qa("goto-form", "pops", "＋", "Add POP") +
      '<button type="button" class="qa" data-act="goto" data-to="running" data-tour="qa-running"><div class="ico">▶</div>Running Batches</button>' +
      '<button type="button" class="qa" data-act="goto" data-to="returning"><div class="ico">↩</div>Return Batches</button>' +
      "</div></div>" +
      drawerHtml() +
      "</div>"
    );
  }

  function qa(act, entity, ico, label) {
    return (
      '<button type="button" class="qa" data-act="' +
      act +
      '" data-entity="' +
      entity +
      '"><div class="ico">' +
      ico +
      "</div>" +
      label +
      "</button>"
    );
  }

  function greeting() {
    const h = new Date().getHours();
    if (h < 12) return "Morning";
    if (h < 17) return "Afternoon";
    return "Evening";
  }

  function renderCrudList(cfg) {
    const q = (state.search[cfg.key] || "").toLowerCase();
    let items = store[cfg.key].filter((x) => !q || x.name.toLowerCase().includes(q));
    let rows = items
      .map((item, i) => {
        let extra = "";
        if (cfg.key === "batches") {
          extra =
            '<button type="button" data-act="batch-commuters" data-id="' +
            item.id +
            '" title="Commuters">👥</button>';
        }
        return (
          '<div class="list-row">' +
          '<div class="icon">' +
          cfg.icon +
          '</div><div class="txt"><strong>' +
          esc(item.name) +
          "</strong><small>" +
          esc(item.sub || "Tap edit or delete") +
          '</small></div><div class="row-actions">' +
          extra +
          '<button type="button" data-act="edit-item" data-entity="' +
          cfg.key +
          '" data-id="' +
          item.id +
          '">Edit</button>' +
          '<button type="button" class="del" data-act="delete-item" data-entity="' +
          cfg.key +
          '" data-id="' +
          item.id +
          '">Del</button></div></div>'
        );
      })
      .join("");
    if (!rows) {
      rows =
        '<div class="empty-state"><div class="ico">' +
        cfg.icon +
        "</div>No " +
        cfg.title.toLowerCase() +
        ' match.<br/><button type="button" class="btn btn-primary" style="margin-top:12px" data-act="fab-create">Create</button></div>';
    }
    return (
      '<div class="screen-root" style="position:relative">' +
      statusBar() +
      appBar(cfg.title, { add: true, returnBatch: cfg.key === "batches" }) +
      '<div class="phone-body" style="padding-bottom:72px">' +
      '<div class="list-header"><h2>All ' +
      cfg.title +
      "</h2><p>" +
      esc(cfg.subtitle) +
      "</p></div>" +
      '<div class="search">🔍 <input type="search" placeholder="' +
      esc(cfg.searchHint) +
      '" value="' +
      esc(state.search[cfg.key] || "") +
      '" data-act="search" data-entity="' +
      cfg.key +
      '" /></div>' +
      rows +
      '<button type="button" class="fab" data-act="fab-create" aria-label="Add">＋</button>' +
      "</div>" +
      drawerHtml() +
      "</div>"
    );
  }

  function renderCrudForm(cfg) {
    const editing = state.form.editId != null;
    const title = editing ? "Edit " + cfg.singular : "Create " + cfg.singular;
    return (
      '<div class="screen-root" style="position:relative">' +
      statusBar() +
      appBar(title) +
      '<div class="phone-body">' +
      '<div class="form-header"><span>' +
      cfg.icon +
      "</span> " +
      (editing ? "Edit " + cfg.singular : "Create New " + cfg.singular) +
      "</div>" +
      '<div class="field-label">' +
      esc(cfg.fieldLabel) +
      '</div><input class="field-input" id="form-name" value="' +
      esc(state.form.name || "") +
      '" placeholder="' +
      esc(cfg.fieldHint) +
      '" />' +
      '<div class="btn-row">' +
      '<button type="button" class="btn-block outline" data-act="form-cancel">Cancel</button>' +
      '<button type="button" class="btn-block primary" data-act="form-save">' +
      (editing ? "Update" : "Create") +
      " " +
      cfg.singular +
      "</button></div></div>" +
      drawerHtml() +
      "</div>"
    );
  }

  function renderRunning() {
    const rows = store.running
      .map(
        (b, i) =>
          '<button type="button" class="list-row clickable" style="width:100%;text-align:left;border:1px solid rgba(0,137,123,0.3)" data-act="open-d2d" data-id="' +
          b.id +
          '" data-tour="' +
          (i === 0 ? "running-0" : "") +
          '"><div class="icon" style="background:rgba(0,137,123,0.15);color:var(--ac-live)">▶</div><div class="txt"><strong>' +
          esc(b.name) +
          "</strong><small>" +
          esc(b.sub) +
          "</small></div></button>"
      )
      .join("");
    return (
      '<div class="screen-root" style="position:relative">' +
      statusBar() +
      appBar("Running Batches") +
      '<div class="phone-body"><span class="live-badge">LIVE</span>' +
      rows +
      "</div>" +
      drawerHtml() +
      "</div>"
    );
  }

  function renderReturning() {
    const rows = store.returning
      .map(
        (b) =>
          '<button type="button" class="list-row clickable" style="width:100%;text-align:left" data-act="open-return-list" data-id="' +
          b.id +
          '" data-name="' +
          esc(b.name) +
          '"><div class="icon">↩</div><div class="txt"><strong>' +
          esc(b.name) +
          "</strong><small>" +
          esc(b.sub) +
          "</small></div></button>"
      )
      .join("");
    return (
      '<div class="screen-root" style="position:relative">' +
      statusBar() +
      appBar("Return Batches") +
      '<div class="phone-body">' +
      rows +
      "</div>" +
      drawerHtml() +
      "</div>"
    );
  }

  function renderCommuterList() {
    const title = state.batchContext || "Batch";
    const rows = store.commuters
      .map(
        (c) =>
          '<div class="list-row"><div class="icon">👤</div><div class="txt"><strong>' +
          esc(c.name) +
          "</strong><small>" +
          esc(c.sub) +
          "</small></div></div>"
      )
      .join("");
    return (
      '<div class="screen-root" style="position:relative">' +
      statusBar() +
      appBar("Commuters · " + title) +
      '<div class="phone-body"><p style="font-size:0.8rem;color:var(--muted);margin:0 0 12px">Nested Navigator.push from BatchScreen</p>' +
      rows +
      "</div>" +
      drawerHtml() +
      "</div>"
    );
  }

  function renderReturnCommuterList() {
    const rows = store.commuters
      .map(
        (c) =>
          '<div class="list-row"><div class="icon">↩</div><div class="txt"><strong>' +
          esc(c.name) +
          '</strong><small>Return rider</small></div><button type="button" class="btn btn-ghost" style="padding:6px 10px;font-size:0.7rem" data-act="confirm-return" data-name="' +
          esc(c.name) +
          '">Confirm</button></div>'
      )
      .join("");
    return (
      '<div class="screen-root" style="position:relative">' +
      statusBar() +
      appBar("Return · " + (state.batchContext || "Batch")) +
      '<div class="phone-body">' +
      rows +
      "</div>" +
      drawerHtml() +
      "</div>"
    );
  }

  function renderD2dChannel() {
    const rows = store.d2dPeople
      .map(
        (c) =>
          '<div class="list-row"><div class="icon">👤</div><div class="txt"><strong>' +
          esc(c.name) +
          "</strong><small>" +
          esc(c.sub) +
          '</small></div><button type="button" class="btn btn-ghost" style="padding:6px 8px" data-act="call" data-name="' +
          esc(c.name) +
          '">📞</button></div>'
      )
      .join("");
    return (
      '<div class="screen-root" style="position:relative">' +
      statusBar() +
      appBar("D2D Channel") +
      '<div class="phone-body" style="padding-bottom:72px"><span class="live-badge">LIVE · batch ' +
      esc(String(state.batchContext || "101")) +
      "</span>" +
      rows +
      '<button type="button" class="fab danger" data-act="close-channel" data-tour="close-channel">Close Channel</button></div>' +
      drawerHtml() +
      "</div>"
    );
  }

  function renderDriverHome() {
    return (
      '<div class="screen-root" style="position:relative">' +
      statusBar() +
      appBar("c2s", { brand: true }) +
      '<div class="phone-body">' +
      '<div class="card dark"><div class="switch-row"><strong>' +
      new Date().toLocaleDateString("en-IN", {
        weekday: "short",
        month: "short",
        day: "numeric",
        year: "numeric",
      }) +
      '</strong><button type="button" class="icon-btn" style="color:#fff;border:1px solid var(--ac-yellow-warm);border-radius:8px;width:36px;height:36px" data-act="call-admin" aria-label="Call admin">📞</button></div>' +
      '<div class="info-cols"><div><div class="label">Batch</div><div>Morning A</div></div><div><div class="label">Start Time</div><div>07:30</div></div><div><div class="label">Cab</div><div>MH-12-AB</div></div></div></div>' +
      '<button type="button" class="btn-block primary" style="margin-top:40px;width:78%;margin-left:auto;margin-right:auto" data-act="start-trip" data-tour="start-trip">START TRIP</button>' +
      "</div>" +
      drawerHtml() +
      "</div>"
    );
  }

  function renderD2dLog() {
    const rows = store.d2dPeople
      .map(
        (c) =>
          '<div class="list-row"><div class="icon">👤</div><div class="txt"><strong>' +
          esc(c.name) +
          "</strong><small>" +
          esc(c.sub) +
          '</small></div><button type="button" data-act="call" data-name="' +
          esc(c.name) +
          '">📞</button></div>'
      )
      .join("");
    return (
      '<div class="screen-root" style="position:relative">' +
      statusBar() +
      appBar("c2s", { brand: true }) +
      '<div class="phone-body" style="padding-bottom:72px"><div class="card"><strong>Morning A · live trip</strong><br/><small style="color:var(--muted)">D2D log · batch 101</small></div>' +
      rows +
      '<button type="button" class="fab danger" data-act="stop-trip" data-tour="stop-trip">Stop trip</button></div>' +
      drawerHtml() +
      "</div>"
    );
  }

  function renderCommuterHome() {
    return (
      '<div class="screen-root" style="position:relative">' +
      statusBar() +
      appBar("c2s", { brand: true }) +
      '<div class="phone-body"><h3 style="margin:0 0 12px;font-weight:500">Hey, Priya</h3>' +
      '<div class="card dark"><div class="switch-row"><div><strong>Coming today</strong><div style="font-size:0.75rem;opacity:0.8;margin-top:4px">' +
      new Date().toLocaleDateString() +
      '</div></div><button type="button" class="switch' +
      (state.coming ? " on" : "") +
      '" data-act="toggle-coming" data-tour="coming-switch" aria-label="Coming today" aria-pressed="' +
      state.coming +
      '"></button></div></div>' +
      '<p style="font-size:0.75rem;color:var(--muted);margin-top:16px">Pull to refresh reloads profile (demo: pull not simulated).</p></div>' +
      drawerHtml() +
      "</div>"
    );
  }

  function renderProfile() {
    return (
      '<div class="screen-root" style="position:relative">' +
      statusBar() +
      appBar("Profile") +
      '<div class="phone-body" style="text-align:center"><div class="profile-avatar">👤</div>' +
      '<div class="card profile-rows" style="text-align:left"><div class="row"><div class="k">Name</div><div class="v">' +
      esc(roleName() + " User") +
      '</div></div><div class="row"><div class="k">Mobile</div><div class="v">+91 98••••00</div></div><div class="row"><div class="k">Role</div><div class="v">' +
      esc(state.role) +
      '</div></div></div>' +
      '<button type="button" class="btn-block primary" style="margin-top:24px" data-act="logout">Logout</button></div>' +
      drawerHtml() +
      "</div>"
    );
  }

  function renderOffline() {
    const tabs = ["Routes", "Batches", "People", "Out"];
    const keys = ["offlineRoutes", "offlineBatches", "offlinePeople", null];
    const tab = state.offlineTab;
    let body = "";
    if (tab === 3) {
      body =
        '<div class="card"><strong>Export / Output</strong><p style="font-size:0.8rem;color:var(--muted);margin:8px 0 0">Regenerated filter dump (prototype). Tap FAB to “export”.</p></div>';
    } else {
      const list = store[keys[tab]];
      body = list
        .map((item) => {
          const act =
            tab === 0
              ? "offline-route"
              : tab === 1
                ? "offline-batch"
                : "";
          return (
            '<button type="button" class="list-row clickable" style="width:100%;text-align:left" data-act="' +
            act +
            '" data-id="' +
            item.id +
            '"><div class="icon">📄</div><div class="txt"><strong>' +
            esc(item.name) +
            "</strong><small>" +
            esc(item.sub || "") +
            "</small></div></button>"
          );
        })
        .join("");
    }
    const tabBtns = tabs
      .map(
        (t, i) =>
          '<button type="button" class="tab' +
          (i === tab ? " active" : "") +
          '" data-act="offline-tab" data-tab="' +
          i +
          '"><span class="ti">' +
          ["🗺", "🚌", "👥", "📤"][i] +
          "</span>" +
          t +
          "</button>"
      )
      .join("");
    return (
      '<div class="screen-root" style="position:relative">' +
      statusBar() +
      appBar("Offline Mode", { noDrawer: true, more: true }) +
      '<div class="phone-body" style="padding-bottom:72px">' +
      body +
      '<button type="button" class="fab" data-act="offline-fab">＋</button></div>' +
      '<nav class="bottom-nav" aria-label="Offline tabs">' +
      tabBtns +
      "</nav></div>"
    );
  }

  function renderOfflineDrill(kind) {
    const title = kind === "pops" ? "Offline POPs" : "Offline Commuters";
    const rows =
      kind === "pops"
        ? store.pops
            .slice(0, 2)
            .map(
              (p) =>
                '<div class="list-row"><div class="icon">📍</div><div class="txt"><strong>' +
                esc(p.name) +
                "</strong><small>" +
                esc(p.sub) +
                "</small></div></div>"
            )
            .join("")
        : store.commuters
            .slice(0, 2)
            .map(
              (c) =>
                '<div class="list-row"><div class="icon">👤</div><div class="txt"><strong>' +
                esc(c.name) +
                "</strong></div></div>"
            )
            .join("");
    return (
      '<div class="screen-root">' +
      statusBar() +
      appBar(title, { noDrawer: true }) +
      '<div class="phone-body">' +
      rows +
      '<button type="button" class="btn-block outline" style="margin-top:16px" data-act="goto" data-to="offline">← Back to Offline</button></div></div>'
    );
  }

  // ---------- Main render ----------
  function renderPhone() {
    const s = state.screen;
    if (s === "splash") return renderSplash();
    if (s === "signIn") return renderSignIn();
    if (s === "signUp") return renderSignUp();
    if (s === "adminHome") return renderAdminHome();
    if (CRUD[s]) return renderCrudList(CRUD[s]);
    const formEntity = Object.values(CRUD).find((c) => c.formId === s);
    if (formEntity) return renderCrudForm(formEntity);
    if (s === "running") return renderRunning();
    if (s === "returning") return renderReturning();
    if (s === "commuterList") return renderCommuterList();
    if (s === "returnCommuterList") return renderReturnCommuterList();
    if (s === "d2dChannel") return renderD2dChannel();
    if (s === "driverHome") return renderDriverHome();
    if (s === "d2dLog") return renderD2dLog();
    if (s === "commuterHome") return renderCommuterHome();
    if (s === "profile") return renderProfile();
    if (s === "offline") return renderOffline();
    if (s === "offlineRoutePops") return renderOfflineDrill("pops");
    if (s === "offlineBatchCommuters") return renderOfflineDrill("commuters");
    return renderSignIn();
  }

  function updateSidePanel() {
    const meta = META[state.screen];
    const crumbs = ["Demo"];
    if (state.role) crumbs.push(state.role);
    crumbs.push(meta ? meta.widget : state.screen);
    els.crumb.innerHTML = crumbs
      .map((c, i) =>
        i === crumbs.length - 1
          ? '<span class="here">' + esc(c) + "</span>"
          : "<span>" + esc(c) + '</span><span class="sep">/</span>'
      )
      .join("");

    els.caption.innerHTML = meta
      ? '<div class="label">This screen</div><p>' + esc(meta.caption) + "</p>"
      : '<div class="label">This screen</div><p>—</p>';

    els.phoneLabel.textContent = meta
      ? meta.widget + " · " + meta.path
      : state.screen;

    // Dev panel
    if (state.showDev && meta) {
      els.devPanel.classList.add("open");
      els.devPanel.innerHTML =
        "<h3>DEV PANEL</h3><dl>" +
        "<dt>Widget</dt><dd>" +
        esc(meta.widget) +
        "</dd>" +
        "<dt>RouteName</dt><dd>" +
        esc(meta.route) +
        "</dd>" +
        "<dt>Path</dt><dd>" +
        esc(meta.path) +
        "</dd>" +
        "<dt>File</dt><dd>" +
        esc(meta.file) +
        "</dd>" +
        "<dt>Provider</dt><dd>" +
        esc(meta.provider) +
        "</dd>" +
        (meta.shell
          ? "<dt>Shell</dt><dd>" + esc(meta.shell) + "</dd>"
          : "") +
        "<dt>Docs</dt><dd>" +
        esc(meta.md) +
        "</dd></dl>";
    } else {
      els.devPanel.classList.toggle("open", state.showDev);
      if (state.showDev) {
        els.devPanel.innerHTML = "<h3>DEV PANEL</h3><p style='padding:12px;font-size:0.8rem'>No metadata for this view.</p>";
      }
    }

    // Map
    els.mapOverlay.classList.toggle("open", state.showMap);
    if (state.showMap) {
      const nodes = mapNodesForRole();
      els.mapFlow.innerHTML = nodes
        .map((n, i) => {
          const cur = n.id === state.screen ? " current" : "";
          return (
            (i ? '<span class="flow-arrow">→</span>' : "") +
            '<button type="button" class="flow-node' +
            cur +
            '" data-act="goto" data-to="' +
            n.id +
            '">' +
            esc(n.label) +
            "</button>"
          );
        })
        .join("");
    }

    // Tour banner
    if (state.tour) {
      const t = TOURS[state.tour.id];
      const step = t.steps[state.tour.step];
      els.tourBanner.classList.add("active");
      els.tourStep.textContent =
        t.name + " · Step " + (state.tour.step + 1) + " / " + t.steps.length;
      els.tourText.textContent = step.text;
    } else {
      els.tourBanner.classList.remove("active");
    }

    $("#btn-dev").classList.toggle("on", state.showDev);
    $("#btn-map").classList.toggle("on", state.showMap);
  }

  function mapNodesForRole() {
    if (state.role === "DRIVER") {
      return [
        { id: "signIn", label: "SignIn" },
        { id: "driverHome", label: "DriverHome" },
        { id: "d2dLog", label: "D2DLog" },
        { id: "profile", label: "Profile" },
      ];
    }
    if (state.role === "COMMUTER") {
      return [
        { id: "signIn", label: "SignIn" },
        { id: "commuterHome", label: "CommuterHome" },
        { id: "profile", label: "Profile" },
      ];
    }
    return [
      { id: "signIn", label: "SignIn" },
      { id: "adminHome", label: "Dashboard" },
      { id: "routes", label: "Routes" },
      { id: "running", label: "Running" },
      { id: "d2dChannel", label: "D2D" },
      { id: "offline", label: "Offline" },
      { id: "profile", label: "Profile" },
    ];
  }

  function applyTourHighlight() {
    $$(".tour-highlight").forEach((el) => el.classList.remove("tour-highlight"));
    const old = $(".tour-callout");
    if (old) old.remove();
    if (!state.tour) return;
    const step = TOURS[state.tour.id].steps[state.tour.step];
    if (!step.highlight) return;
    const target = $(step.highlight, els.phone);
    if (!target) return;
    target.classList.add("tour-highlight");
    const call = document.createElement("div");
    call.className = "tour-callout below";
    call.textContent = "Tap here next";
    call.style.top = Math.min(target.offsetTop + target.offsetHeight + 8, 600) + "px";
    call.style.left = "16px";
    els.phone.appendChild(call);
  }

  function render() {
    if (state.screen === "landing") {
      showLanding();
      return;
    }
    els.landing.classList.remove("active");
    els.demo.classList.add("active");
    els.phone.innerHTML = renderPhone();
    updateSidePanel();
    requestAnimationFrame(applyTourHighlight);
  }

  // ---------- CRUD helpers ----------
  function openCreate(entityKey) {
    const cfg = CRUD[entityKey];
    state.form = { entity: entityKey, editId: null, name: "" };
    navigate(cfg.formId);
  }

  function openEdit(entityKey, id) {
    const cfg = CRUD[entityKey];
    const item = store[entityKey].find((x) => x.id === Number(id));
    if (!item) return;
    state.form = { entity: entityKey, editId: item.id, name: item.name };
    navigate(cfg.formId);
  }

  async function deleteItem(entityKey, id) {
    const cfg = CRUD[entityKey];
    const item = store[entityKey].find((x) => x.id === Number(id));
    if (!item) return;
    const ok = await confirmDialog({
      title: "Delete " + cfg.singular + "?",
      message:
        'Are you sure you want to delete "' +
        item.name +
        '"? This action cannot be undone.',
      confirmLabel: "Delete",
      cancelLabel: "Cancel",
      icon: "🗑",
    });
    if (!ok) return;
    store[entityKey] = store[entityKey].filter((x) => x.id !== item.id);
    toast(cfg.singular + " deleted successfully!", "success");
    render();
  }

  function saveForm() {
    const cfg = CRUD[state.form.entity];
    const input = $("#form-name");
    const name = (input && input.value.trim()) || "";
    if (!name) {
      toast("Please enter a " + cfg.fieldLabel.toLowerCase(), "error");
      return;
    }
    if (state.form.editId != null) {
      const item = store[cfg.key].find((x) => x.id === state.form.editId);
      if (item) item.name = name;
      toast(cfg.singular + " updated!", "success");
    } else {
      store[cfg.key].unshift({
        id: ++store.nextId,
        name,
        sub: "Just created",
      });
      toast(cfg.singular + " created!", "success");
    }
    navigate(cfg.listId);
  }

  // ---------- Events ----------
  function onPhoneClick(e) {
    const t = e.target.closest("[data-act]");
    if (!t) return;
    const act = t.getAttribute("data-act");

    if (act === "drawer") {
      state.drawerOpen = !state.drawerOpen;
      render();
      return;
    }
    if (act === "drawer-close") {
      state.drawerOpen = false;
      render();
      return;
    }
    if (act === "goto") {
      navigate(t.getAttribute("data-to"));
      return;
    }
    if (act === "show-roles") {
      const p = $("#role-pick");
      if (p) p.style.display = "grid";
      toast("Pick a role for this demo", "success");
      return;
    }
    if (act === "login-role") {
      const role = t.getAttribute("data-role");
      state.role = role;
      const home =
        role === "ADMIN"
          ? "adminHome"
          : role === "DRIVER"
            ? "driverHome"
            : "commuterHome";
      navigate(home, { replace: true, role });
      toast("Signed in as " + role, "success");
      advanceTourIfOn("signIn");
      return;
    }
    if (act === "signup-done") {
      toast("Account created (demo)", "success");
      navigate("signIn");
      return;
    }
    if (act === "toggle-pw") {
      const pw = $("#pw");
      if (pw) pw.type = pw.type === "password" ? "text" : "password";
      return;
    }
    if (act === "goto-form") {
      openCreate(t.getAttribute("data-entity"));
      return;
    }
    if (act === "fab-create") {
      const cfg = CRUD[state.screen];
      if (cfg) openCreate(cfg.key);
      return;
    }
    if (act === "edit-item") {
      openEdit(t.getAttribute("data-entity"), t.getAttribute("data-id"));
      return;
    }
    if (act === "delete-item") {
      deleteItem(t.getAttribute("data-entity"), t.getAttribute("data-id"));
      return;
    }
    if (act === "form-cancel") {
      const cfg = CRUD[state.form.entity];
      navigate(cfg.listId);
      return;
    }
    if (act === "form-save") {
      saveForm();
      return;
    }
    if (act === "open-d2d") {
      navigate("d2dChannel", { batchContext: t.getAttribute("data-id") });
      advanceTourIfOn("running");
      return;
    }
    if (act === "close-channel") {
      toast("Channel closed", "success");
      navigate("running");
      advanceTourIfOn("d2dChannel");
      return;
    }
    if (act === "open-return-list") {
      navigate("returnCommuterList", {
        batchContext: t.getAttribute("data-name"),
      });
      return;
    }
    if (act === "batch-commuters") {
      const b = store.batches.find((x) => x.id === Number(t.getAttribute("data-id")));
      navigate("commuterList", { batchContext: b ? b.name : "Batch" });
      return;
    }
    if (act === "confirm-return") {
      toast("Return confirmed for " + t.getAttribute("data-name"), "success");
      return;
    }
    if (act === "start-trip") {
      navigate("d2dLog", { batchContext: "101" });
      toast("Trip started", "success");
      advanceTourIfOn("driverHome");
      return;
    }
    if (act === "stop-trip") {
      toast("Trip stopped", "success");
      navigate("driverHome");
      advanceTourIfOn("d2dLog");
      return;
    }
    if (act === "call" || act === "call-admin") {
      toast("Calling… (demo tel: link)", "success");
      return;
    }
    if (act === "toggle-coming") {
      const next = !state.coming;
      confirmDialog({
        title: next ? "Mark as coming?" : "Mark as not coming?",
        message: next
          ? "Confirm you are riding today."
          : "Confirm you are not riding today.",
        confirmLabel: "CONFIRM",
        cancelLabel: "Cancel",
        icon: "✓",
        danger: false,
      }).then((ok) => {
        if (!ok) return;
        state.coming = next;
        toast("Status updated", "success");
        render();
        advanceTourIfOn("commuterHome");
      });
      return;
    }
    if (act === "logout") {
      state.role = "ADMIN";
      state.history = [];
      navigate("signIn", { replace: true });
      toast("Logged out", "success");
      return;
    }
    if (act === "sync-now") {
      state.syncPending = 0;
      toast("Sync complete", "success");
      render();
      return;
    }
    if (act === "offline-tab") {
      state.offlineTab = Number(t.getAttribute("data-tab"));
      render();
      return;
    }
    if (act === "offline-fab") {
      if (state.offlineTab === 3) toast("Export regenerated", "success");
      else if (state.offlineTab === 2) {
        store.offlinePeople.push({
          id: ++store.nextId,
          name: "New offline user",
          sub: "unsynced",
        });
        toast("Commuter form → saved locally", "success");
        render();
      } else toast("Add on this tab (demo)", "success");
      return;
    }
    if (act === "offline-route") {
      navigate("offlineRoutePops");
      return;
    }
    if (act === "offline-batch") {
      navigate("offlineBatchCommuters");
      return;
    }
    if (act === "more") {
      toast("Import seed · Dump all · Refresh (menu demo)", "success");
      return;
    }
  }

  function onPhoneInput(e) {
    const t = e.target;
    if (t.getAttribute("data-act") === "search") {
      state.search[t.getAttribute("data-entity")] = t.value;
      render();
      const inp = $('input[data-act="search"]', els.phone);
      if (inp) {
        inp.focus();
        const len = inp.value.length;
        inp.setSelectionRange(len, len);
      }
    }
  }

  function advanceTourIfOn(screenWhen) {
    if (!state.tour) return;
    const step = TOURS[state.tour.id].steps[state.tour.step];
    if (step && step.screen === screenWhen) {
      setTimeout(tourNext, 400);
    }
  }

  function tourNext() {
    if (!state.tour) return;
    const t = TOURS[state.tour.id];
    if (state.tour.step >= t.steps.length - 1) {
      toast("Tour finished — explore freely!", "success");
      state.tour = null;
      render();
      return;
    }
    state.tour.step++;
    const next = t.steps[state.tour.step];
    if (next.screen !== state.screen) navigate(next.screen);
    else render();
  }

  function tourSkip() {
    state.tour = null;
    toast("Tour skipped", "success");
    render();
  }

  function startTour(role) {
    state.tour = { id: role, step: 0 };
    state.role =
      role === "admin" ? "ADMIN" : role === "driver" ? "DRIVER" : "COMMUTER";
    const first = TOURS[role].steps[0].screen;
    enterDemo(first, { role: state.role });
  }

  // ---------- Wire UI ----------
  function bind() {
    els.phone.addEventListener("click", onPhoneClick);
    els.phone.addEventListener("input", onPhoneInput);

    // Side panel / map jumps (outside phone)
    document.addEventListener("click", (e) => {
      const t = e.target.closest("[data-act]");
      if (!t || els.phone.contains(t)) return;
      if (t.closest("#view-landing")) return;
      const act = t.getAttribute("data-act");
      if (act === "goto" && t.getAttribute("data-to")) {
        navigate(t.getAttribute("data-to"));
      }
    });

    $("#btn-back").addEventListener("click", goBack);
    $("#btn-home").addEventListener("click", showLanding);
    $("#btn-dev").addEventListener("click", () => {
      state.showDev = !state.showDev;
      render();
    });
    $("#btn-map").addEventListener("click", () => {
      state.showMap = !state.showMap;
      render();
    });
    $("#btn-tour-next").addEventListener("click", tourNext);
    $("#btn-tour-skip").addEventListener("click", tourSkip);

    // Landing
    $$("[data-enter]").forEach((btn) => {
      btn.addEventListener("click", () => {
        const role = btn.getAttribute("data-enter");
        state.role =
          role === "admin"
            ? "ADMIN"
            : role === "driver"
              ? "DRIVER"
              : "COMMUTER";
        enterDemo("splash", { role: state.role });
      });
    });
    $$("#view-landing [data-tour]").forEach((btn) => {
      btn.addEventListener("click", () => startTour(btn.getAttribute("data-tour")));
    });

    // Hash routing
    window.addEventListener("hashchange", () => {
      const h = location.hash.replace(/^#/, "");
      if (!h) {
        showLanding();
        return;
      }
      if (META[h] || CRUD[h] || Object.values(CRUD).some((c) => c.formId === h)) {
        if (!els.demo.classList.contains("active")) {
          els.landing.classList.remove("active");
          els.demo.classList.add("active");
        }
        state.screen = h;
        render();
      }
    });
  }

  // Boot
  document.addEventListener("DOMContentLoaded", () => {
    bind();
    const h = location.hash.replace(/^#/, "");
    if (h && (META[h] || CRUD[h])) {
      els.landing.classList.remove("active");
      els.demo.classList.add("active");
      state.screen = h;
      render();
    } else {
      showLanding();
    }
  });
})();
