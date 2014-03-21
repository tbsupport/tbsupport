exports.config =
  conventions:
    assets: /(assets|vendor\/assets|font)/
  paths:
    public: 'public'
  modules:
    definition: false
    wrapper: false
  files:
    javascripts:
      defaultExtension: 'coffee'
      joinTo:
        'js/app.js': /^app\/scripts/
        'js/static.js': /^app\/.*.jade$/
        'js/vendor.js': /^(bower_components|vendor)/
      order:
        before: [
        ]
    stylesheets:
      defaultExtension: 'sass'
      joinTo:
        'css/app.css' : /^(vendor|bower_components|app)/
      order:
        before: [
          'app/styles/reset.css',
          'app/styles/helpers.css'
        ]
    templates:
      joinTo: 
        'js/templates.js': /.+\.jade$/
  plugins:
    jade:
      options:
        pretty: yes
      locals:
        site:
          baseurl: ''
        nav:
          [
            {path: "/checker", title: "Проверка подключения к видеовстрече"}
          ]
        checker:
          host: "rtmp://test2013.teachbase.ru:443/fmle"
    autoprefixer:
      browsers: ["last 1 version", "> 1%", "ie 8"]
    static_jade:
      extension: ".jade"
      path:       [ /app/ ] 