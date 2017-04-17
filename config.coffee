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
            {path: "/system", title: "Проверка системных требований"},
            {path: "/checker", title: "Проверка подключения к видеовстрече"},
            {path: "/qmaker", title: "Конвертация тестов в формат GIFT"},
            {path: "/cert", title: "Генерация сертификата"}
          ]
        checker:
          host: "rtmp://er203.teachbase.ru:443/tbcheck"
          ws_host: "inf1.teachbase.ru/ws/mpx"
        qmaker_url: "http://qmaker.teachbase.ru/new"
        cert_url: "http://cert.teachbase.ru"
    autoprefixer:
      browsers: ["last 1 version", "> 1%", "ie 8"]
    static_jade:
      extension: ".jade"
      path:       [ /app/ ] 