 do (context = this) ->
  "use strict"
  # shortcuts
  $ = context.jQuery
  pi = context.pi  = context.pi || {}
  utils = pi.utils

  _video_count = 0

  class pi.HlsPlayer extends pi.Base
    initialize: ->
      cont = document.createElement('div')
      @player_id = "hls_player_" + (++_video_count)

      cont.id = @player_id

      @nod.append cont

      @setup_opts = {
        hls_debug : true,
        hls_debug2 : false,
        hls_minbufferlength : 4,
        hls_maxbufferlength : 60,
        hls_startfromlowestlevel : false,
        hls_live_flushurlcache : true,
        primary: "flash"
        flashplayer: "flash/jwplayer.flash.swf",
        wmode: "transparent",
        controlbar: "over",
        debug: 'none',
        width: "100%",
        height: "100%",
        autostart: true
      }

      @_host = @options.host || ""

      (setup_opts.image = @options.image) if @options.image?
      
      @load(@options.url) if @options.url? 

    load: (url) ->
      @setup_opts.playlist = [{file: @_host+url,provider:'flash/HLSProvider6.swf',type: 'hls'}]
      jwplayer(@player_id).setup(@setup_opts)
    
    play: ->
      jwplayer(@player_id).play()

    pause: ->
      jwplayer(@player_id).pause()

    stop: ->
      jwplayer(@player_id).stop()