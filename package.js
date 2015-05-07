Package.describe({
  name: 'modweb:fixed-width-file',
  summary: 'Writes a fixed width file based from JSON and a schema',
  version: '0.1.1',
  git: 'https://github.com/modweb/meteor-fixed-width-file.git'
});

Package.onUse(function(api) {
  api.versionsFrom('1.0');
  api.use(['coffeescript']);
  api.addFiles('namespaces.litcoffee', 'server');
  api.addFiles('fixed-width-file.litcoffee', 'server');
  api.export("FixedWidth", "server");
});

Package.onTest(function(api) {
  api.use(['tinytest', 'test-helpers', 'coffeescript', 'modweb:fixed-width-file']);
  api.addFiles('tests/fixed-width-file-tests.coffee');
  api.export("FixedWidth", ["client", "server"]);
});
