domready    = require 'domready'
wwlContext  = require 'wwl-js-app-context'

domready ->

  # View module
  TestViewModule = class TestViewModule extends require('../lib/vm')
    initialize: ->  console.log 'Initialized my VM'
    onStart: ->     console.log 'Started my VM'
    onStop: ->      console.log 'Stopped my VM'


  # Start testing
  new (require('../lib/tester'))({

    domElementId: 'wwl-js-vm-tester-container'

    config:
      getDefaultVMConfig: ->
        context: new (wwlContext)({ root: true })

    vmConfig:
      vmPrototype: TestViewModule

      afterStart: (viewModule, moduleConfig) ->
        setTimeout(viewModule.stop, 1000)

  }).run()
