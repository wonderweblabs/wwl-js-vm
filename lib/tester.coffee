Q = require('q')
_ = require('underscore')

#
# Requires following options on initialize:
#   * domElementId    string    Id of the dom element to render the vm to
#   * config          object    The global configuration hash
#   * vmConfig        object    The vm specific configuration hash
#
module.exports = class Tester

  options: null

  constructor: (options = {}) ->
    @options = options

  run: ->
    viewModule    = null
    moduleConfig  = null

    # START
    p = Q()

    # callback - options.config.before
    p = p.then =>
      return Q() if !_.isFunction(@options.config.before)
      @options.config.before()

    # callback - options.config.getDefaultVMConfig
    p = p.then =>
      moduleConfig = @options.config.getDefaultVMConfig()
      Q()

    # callback - options.vmConfig.beforeInititalize
    p = p.then =>
      return Q() if !_.isFunction(@options.vmConfig.beforeInititalize)
      @options.vmConfig.beforeInititalize(moduleConfig)

    # action - init vm
    p = p.then =>
      viewModule = new (@options.vmConfig.vmPrototype)(moduleConfig)
      Q()

    # callback - vmConfig.afterInititalize
    p = p.then =>
      return Q() if !_.isFunction(@options.vmConfig.afterInititalize)
      @options.vmConfig.afterInititalize(viewModule, moduleConfig)

    # action - show vm
    p = p.then =>
      viewModule.getView().render()
      domElement = document.getElementById(@options.domElementId)
      domElement.appendChild(viewModule.getView().el)
      Q()

    # callback - vmConfig.beforeStart
    p = p.then =>
      return Q() if !_.isFunction(@options.vmConfig.beforeStart)
      @options.vmConfig.beforeStart(viewModule, moduleConfig)

    # action - start vm
    p = p.then =>
      viewModule.start()
      Q()

    # callback - vmConfig.afterStart
    p = p.then =>
      return Q() if !_.isFunction(@options.vmConfig.afterStart)
      @options.vmConfig.afterStart(viewModule, moduleConfig)

    # callback - config.after
    p = p.then =>
      return Q() if !_.isFunction(@options.config.after)
      @options.config.after(viewModule, moduleConfig)

    # DONE
    p.done()

