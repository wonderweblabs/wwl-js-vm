_ = require('underscore')
Q = require('q')

#
# A view module defines the small pattern of a prototype with
# following requirements
#
# * They require a valid context object (wwl-js-app-context)
# * They promise to return a view for ```getView``` with the api of
#   Backbone.View, Marionette.View and/or Ampersand.View
# * Providing a ```start``` function which returns a deferred promise (e.g. Q)
# * Providing a ```stop```  function which returns a deferred promise (e.g. Q)
#
# @see wwl-js-app-context
#
module.exports = class ViewModule extends require('../vendor/backbone_events_prototype')

  # Context instance
  # @see wwl-js-app-context
  context: null

  # Options hash passed in via constructor
  options: null

  # Constructor
  constructor: (options = {}) ->
    if options.context is null || options.context is undefined
      throw('ViewModules require a valid Context object.')

    @options = _.extend({}, _.result(@, 'options'), options)
    @context = options.context

    @initialize.apply(@, arguments)

  # You can overwrite the initialize method on your inheriting
  # view module class.
  initialize: (options)->
    null

  # Called for starting the view module.
  # Must return a deferred promise
  start: =>
    @onStart.apply(@, arguments)

  # Starting code of the view module, if necessary.
  # Must return a deferred promise
  onStart: ->
    Q()

  # Called for stopping the view module .
  # Must return a deferred promise
  stop: =>
    @stopListening()
    @resetView()

    @onStop.apply(@, arguments)

  # Stopping code of the view module, if necessary.
  # Must return a deferred promise
  onStop: ->
    Q()

  # Merge `keys` from `options` onto `this`
  mergeOptions: (options, keys) ->
    return unless options

    _.extend(@, _.pick(options, keys))

  # Retrieve an object, function or other value from a this
  # object or its `options`, with `options` taking precedence.
  getOption: (optionName) ->
    return if !optionName

    if @options && @options[optionName] != undefined
      @options[optionName]
    else
      @[optionName]

  # Returns a valid view instance.
  getView: ->
    @_view or= @buildView()

  # Returns the main view class of your vm
  #
  # Overwrite this for loading you custom classe(s).
  getMainViewClass: ->
    require('./views/main_view')

  # Returns the options passed to the main view on creation. By default
  # it contains the context.
  #
  # Overwrite and/or extend it to append you main view's configuration.
  getMainViewOptions: ->
    context: @context
    vm: @

  # Called if there is no view created yet.
  buildView: ->
    view = new (@getMainViewClass())(@getMainViewOptions())
    @listenTo view, 'destroy', => @stopListening(view); @_view = null
    view

  # Resets the view e.g. on stop
  resetView: ->
    @_view.destroy() if @_view && _.isFunction(@_view)
    @_view = null


