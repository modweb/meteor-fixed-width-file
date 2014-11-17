Package.describe({
  name: 'riley:meteor-fixed-width-file',
  summary: 'Saves a fixed width file based on ',
  version: '1.0.0',
  git: 'https://github.com/CreativeFuse/meteor-fixed-width-file.git'
});

Package.onUse(function(api) {
  api.versionsFrom('1.0');
  api.addFiles('riley:fixed-width-file.coffee');
});

Package.onTest(function(api) {
  api.use('tinytest');
  api.use('riley:meteor-fixed-width-file');
  api.addFiles('riley:fixed-width-file-tests.coffee');
});
