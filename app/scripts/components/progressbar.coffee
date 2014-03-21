do (context = this) ->
  "use strict"
  # shortcuts
  $ = context.jQuery
  pi = context.pi  = context.pi || {}
  utils = pi.utils

  class pi.Progressbar extends pi.Base
    set: (value) ->
      @value = value
      @nod.css(width: "#{value}%")

    reset: ->
      @nod.css(width: 0)