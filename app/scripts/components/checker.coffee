 do (context = this) ->
  "use strict"
  # shortcuts
  $ = context.jQuery
  pi = context.pi  = context.pi || {}
  utils = pi.utils


  class pi.Checker extends pi.Base

    statuses: ['loading']

    initialize: ->
      @type = @options.type
      @desc = @nod.find('.desc')
      @deps = @options.deps || ""

    loading: (value) ->
      @activate()
      if value
        @nod.addClass 'is-loading'
      else
        @nod.removeClass 'is-loading'

    finished: (status) ->
      @loading false
      @nod.addClass "is-#{status}"

    clear: ->
      @deactivate()
      @nod.removeClass("is-#{status}") for status in @statuses 
      @desc.empty()
      return

    text: (val) ->
      @desc.html(val)



  # add statuses

  for method in ['passed', 'failed', 'warning']
    do (method) ->
      pi.Checker::statuses.push method
      pi.Checker::[method] = -> 
        @finished method 


  class pi.Socket
    messages: 
      timeout:
        status: 0
        message: "Вышло время ожидания подключения"
      error:
        status: 0
        message: "Ошибка подключения через веб-сокеты.
          Возможные причины:
          <ul>
          <li> - отсутствует интернет-соединение;</li>
          <li> - запрещено подключение через порты 80, 443;</li>
          <li> - прокси-сервер не поддерживает соединение через веб-сокеты;</li>
          <li> - домены и IP адреса Teachbase не внесены в белый список файерволла/корпортивного прокси-сервера/другой блокирующей системы <br/>
          (необходимо добавить домены *.teachbase.ru и/или IP адреса 54.77.210.105)</li>
          </ul>"
    # Creates new WebSocket wrapper,
    # connected to _path_.
    constructor: (@path, options ={}) ->
      @ports = [80, 443]
      @retry_count = 0      
      @_retry = options.retry || 1
      @_timeout = options.timeout || 30000

    check: (@resolve, @reject) ->
      @init()

    init: (port) ->
      if @ports.length is 0
        @reject @messages.error

      @port = port ? @ports.pop()
      path = "ws#{ if @port is 443 then 's' else ''}://#{@path}"

      @connected = false
      @state = 'connecting'
      @socket = new WebSocket(path)
      @_add_listeners()
      @_tid = after @_timeout, => @handle_timeout()

    handle_close: ->
      @_hc ||= (e) =>
        @connected = false
        @state = 'close'

        clearTimeout(@__retry_clear_id)
        clearTimeout(@_tid)

        if e.wasClean
          @dispose()
          @init()
        else
          @_try_to_reconnect(e)

    handle_timeout: ->
      @dispose()
      @init()

    handle_open: ->
      @_ho ||= =>
        @state = 'open'
        @connected = true
        clearTimeout(@_tid)
        @__retry_clear_id = utils.after 1000, => @retry_count = 0
        @resolve status: 1, message: "Соединение установлено (порт #{@port})", version: @port
        @dispose()

    _try_to_reconnect: (e) ->
      if @retry_count >= @_retry
        @dispose()
        @init()
      else
        @retry_count+=1
        @_remove_listeners()
        utils.after 1000, =>
          @init(@port)

    _add_listeners: ->
      @socket.addEventListener 'open', @handle_open()
      @socket.addEventListener 'close', @handle_close()

    _remove_listeners: ->
      @socket.removeEventListener 'open', @handle_open() # because 'open' can never occur
      @socket.removeEventListener 'close', @handle_close()

    dispose: ->
      @_remove_listeners()
      @socket.close() if @connected
      @connected = false
      @socket = null

  class pi.RtmpChecker extends pi.SwfPlayer
    messages: 
      "rtmp.connection":
        success: 
          message: "Подключение установлено."
          status: 1
        error: 
          status: 0
          message: "Ошибка подключения RTMP.
          Возможные причины:
          <ul>
          <li> - отсутствует интернет-соединение;</li>
          <li> - запрещено подключение по протоколу RTMP;</li>
          <li> - запрещено подключение через порт 443;</li>
          <li> - домены и IP адреса Teachbase не внесены в белый список файерволла/корпортивного прокси-сервера/другой блокирующей системы <br/>
          (необходимо добавить домены *.teachbase.ru и/или IP адреса 95.213.159.249, 95.213.154.100, 46.182.31.47, 79.125.110.35)</li>
          </ul>"
      "rtmp.disconnected":
        error: 
          message: "Отсутствует подключение. Попробуйте еще раз."
          status: 0
      "rtmp.undefined":
        error: 
          message: "Отсутствует адрес RTMP сервера. Попробуйте еще раз."
          status: 0
      "rtmp.ping":
        success: (data) -> 
          mes = "Пинг (avg, min, max): #{data.avg}s, #{data.min}s, #{data.max}s."
          if parseInt(data.avg) > 1000 
            status: 2, data: data, message: "#{mes}<br/>Слишком большой пинг: #{data.avg}s. Вероятна большая задержка при общении."
          else
            status: 1, data: data, message: mes
        error: 
          message: "Ошибка при проверке пинга. Попробуйте еще раз."
          status: 0
      "rtmp.bw_in":
        success: (data) -> 
          mes = "Входящая скорость (avg, min, max): #{data.avg} KB/s, #{data.min} KB/s, #{data.max} KB/s."
          input = parseInt(data.avg)
          if input < 512 
            status: 2, data: data, message: "#{mes}<br/>Низкая входящая скорость. Возможны обрывы при просмотре видео других участников. <br/> Рекомендуется отключить прием видеосигнала в настройках."
          else 
            status: 1, data: data, message: mes
        error:
          message: "Ошибка при проверке входящей скорости. Попробуйте еще раз"
          status: 0
      "rtmp.bw_out":
        success: (data) -> 
          mes = "Исходящая скорость (avg, min, max): #{data.avg} KB/s, #{data.min} KB/s, #{data.max} KB/s."
          input = parseInt(data.avg)
          if input < 512 
            status: 2, data: data, message: "#{mes}<br/>Низкая исходящая скорость. Не рекомендуется включать трансляцию камеры."
          else if input < 1024
            status: 2, data: data, message: "#{mes}<br/>Средняя исходящая скорость. Трансляция камеры возможна только в низком или среднем качестве."
          else
            status: 1, data: data, message: mes
        error:  
          message: "Ошибка при проверке исходящей скорости. Попробуйте еще раз"
          status: 0


    initialize: ->
      @one 'as3_event', (e) =>
        if (e.data.level is 'info') and (e.data.type is 'initialized')
          @_initialized = true
          @trigger 'swf_initialized'
      super


    check: (type) ->
      new Promise(
        (resolve,reject) =>
          @one "as3_event", (e) =>
            if e.data.level is "error"
              reject @prepare_error(e.data)
            else
              resolve @prepare_success(e.data)

          @as3_call("check_#{type}")
      )

    prepare_error: (data) ->
      @messages[data.type].error

    prepare_success: (data) ->
      if typeof @messages[data.type].success is 'function'
        @messages[data.type].success(data)
      else
        @messages[data.type].success
      

  class pi.CheckerController extends pi.Base
    initialize: ->
      pi.event.on 'piecified', =>
        @_setup()  
  
    _setup: ->
      @rtmp = $("@rtmp").pi()
      @progress = $("@progress").pi()
      @checkers = ($(item).pi() for item in @nod.find('.item'))
      @total = @checkers.length
      @passed = ""
      @report = {}

    resolver: ->
      return @_resolver if @_resolver
      @_resolver = (data) => 
          if data.status is 1 then @checkers[@current].passed() else @checkers[@current].warning()
          @checkers[@current].text data.message
          @passed+="#{@checkers[@current].type};"
          @report[@checkers[@current].type] = data
          utils.debug data
          @next()

    error_handler: ->
      return @_error_handler if @_error_handler
      @_error_handler = (data) => 
          @checkers[@current].failed()
          @checkers[@current].text data.message
          @report[@checkers[@current].type] = data
          utils.debug data
          @next()

    start: ->
      if @current >= 0
        ch.clear() for ch in @checkers
        @passed="" 
        @progress.reset()
        @report = {}
      @current = -1
      @trigger 'start'
      @next()

    finish: ->
      @progress.set 100
      @trigger 'finish'

    next: ->
      @current++

      unless @total > @current
        return @finish()

      @progress.set((((@current+.5*Math.random())/@total)*100)|0)

      if not @passed.match(@checkers[@current].deps)
        @checkers[@current].failed()
        @checkers[@current].text "Пропущена"
        return @next()

      @checkers[@current].loading true
      @["check_#{@checkers[@current].type}"](@checkers[@current].options)
      .then(@resolver())
      .catch(@error_handler())

    # Opera 12+
    # Firefox 10+
    # Chrome 24+
    # Safari 6+
    # IE 9+

    check_browser_version: () ->
      new Promise(
        (resolve, reject) =>
          installed = "#{bowser.name} #{bowser.version}"
          if bowser.msie
            if bowser.version < 9
              return reject(status: 0, message: "Данный браузер не поддерживается", version: installed)

            if bowser.version < 10
              return reject(status: 2, message: "Данный браузер не поддерживает подробный сбор статистики", version: installed)
          else if (bowser.firefox && bowser.version < 10) || (bowser.chrome && bowser.version < 24) || (bowser.opera && bowser.version < 12) || (bowser.safari && bowser.version < 6)
            return reject(status: 0, message: "Данный браузер не поддерживается", version: installed)
          resolve(status: 1, message: "Установленная версия: #{installed}")
      )

    check_ws: () ->
      new Promise(
        (resolve, reject) =>
          socket = new pi.Socket(@options.ws)
          socket.check(resolve, reject)
      )

    check_fp_version: () ->
      new Promise(
        (resolve, reject) =>
          {major: maj, minor: min, release: rel} = swfobject.getFlashPlayerVersion()
          installed = "#{maj}.#{min}.#{rel}"
          if swfobject.hasFlashPlayerVersion(@options.fp_version)
            resolve(status: 1, message: "Установленная версия: #{installed}", version: installed)
          else
            reject(status: 0, message: "Установленная версия: #{installed}. Необходимо установить версию #{@options.fp_version} <a href='http://get.adobe.com/ru/flashplayer/' target='_blank'>установить</a>", version: installed)
          return
      )


    check_rtmp_connection: ->
      if @rtmp._initialized
        @rtmp.check("connection")
      else
        new Promise(
          (resolve, reject) =>
            tid = after 20000, ->
              reject(status: 0, message: "Приложение для проверки подключения не найдено")
            @rtmp.on 'swf_initialized', ->
              clearTimeout tid
              resolve()
        ).then(=> @rtmp.check("connection"))

    check_rtmp_ping: ->
      @rtmp.check("latency")

    check_rtmp_input: ->
      @rtmp.check("inbw")

    check_rtmp_output: ->
      @rtmp.check("outbw")
