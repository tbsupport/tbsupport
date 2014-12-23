 do (context = this) ->
  "use strict"
  # shortcuts
  $ = context.jQuery
  pi = context.pi  = context.pi || {}
  utils = pi.utils

  _video_count = 0

  videojs.options.flash.swf = "/flash/video-js.swf"

  class pi.HlsPlayer extends pi.Base
    initialize: ->
      super

    load: (url, poster) ->
      @clear()
      @video = document.createElement('video')
      @video.className = 'video-js vjs-default-skin vjs-big-play-centered'
      @nod.append @video

      sources = []
      _techOrder = []

      if videojs.Html5.canPlaySource({type: "application/vnd.apple.mpegURL"})
        sources.push({src: url, type: "application/vnd.apple.mpegURL"})
        _techOrder.push 'html5'
      else
        sources.push({src: url, type: "video/mp4"})
        _techOrder = ['flash'] 

      unless sources.length
        throw Error('VideoPlayerError: Source is undefined')

      @player = videojs @video, preload: 'none', controls: true, width: '100%', height: '100%', techOrder: _techOrder
      @player.poster(poster) if poster

      @player.on 'play', utils.curry(@trigger, ['state', 'playing'], @)
      @player.on 'pause', utils.curry(@trigger, ['state', 'paused'], @)
      @player.on 'ended', utils.curry(@trigger, ['state', 'ended'], @)

      @player.src(sources)

    clear: ->
      @trigger 'state', 'clear'
      @off()
      return unless @player?
      # hack trigger 'cause it fails when tech is Flash
      @player.trigger 'dispose'
      @player.trigger = ->
      @player.dispose()