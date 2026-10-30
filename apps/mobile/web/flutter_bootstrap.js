// Flutter template tokens must keep their double braces intact.
{{flutter_js}}
{{flutter_build_config}}

_flutter.loader.load({
  config: {
    // Use Flutter's bundled renderer so startup does not depend on Google's CDN.
    canvasKitBaseUrl: new URL('canvaskit/', document.baseURI).href,
  },
});
