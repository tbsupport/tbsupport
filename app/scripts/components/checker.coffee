 do (context = this) ->
  "use strict"
  # shortcuts
  $ = context.jQuery
  pi = context.pi  = context.pi || {}
  utils = pi.utils



  class pi.RtmpChecker extends pi.SwfPlayer
    initialize: ->
      @one 'as3_event', (e) =>
        if (e.level is 'info') and (e.message is 'initialiazed')
          @_initialized = true
          @trigger 'swf_initialiazed'
      super


    check: (type) ->
      new Promise(
        (resolve,reject) =>
          @one "as3_event", (data) =>
            if data.level is "error"
              reject @prepare_error(data)
            else
              resolve @prepare_success(data)

          @as3_call("check_#{type}")
      )

    prepare_error: (data) ->
      data.message

    prepare_success: (data) ->
      data
      

  class pi.CheckerController extends pi.Base
    initialize: ->
      pi.event.on 'piecified', =>
        @_setup()  
  
    _setup: ->
      @rtmp = $("@rtmp").pi()

    start: ->
     

    check_fp_version: (version) ->
      new Promise(
        (resolve, reject) ->
          {major: maj, minor: min, release: rel} = swfobject.getFlashPlayerVersion()
          if swfobject.hasFlashPlayerVersion(version)
            resolve message: 'fp', version: "#{maj}.#{min}.#{rel}"
          else
            reject message: 'fp_wrong', version: "#{maj}.#{min}.#{rel}"
      )


    check_java_version: ->
      #todo:

    check_rtmp_connection: ->
      @rtmp.check("connection")

