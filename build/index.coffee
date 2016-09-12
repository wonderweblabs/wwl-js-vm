domready    = require 'domready'
wwlContext  = require 'wwl-js-app-context'

domready ->

  # View module
  TestViewModule = class TestViewModule extends require('../lib/vm')
    initialize: ->  console.log 'Initialized my VM'
    onStart: ->     console.log 'Started my VM'
    onStop: ->      console.log 'Stopped my VM'


  # Start testing
  tester = new (require('../lib/tester'))({

    config:
      getDefaultVMConfig: ->
        context: new (wwlContext)({ root: true })

    vmConfig:
      vmPrototype: TestViewModule

      afterStart: (viewModule, moduleConfig) ->
        setTimeout(viewModule.stop, 1000)

  })

  tester.registerAttachFunction (view) =>
    domElement = document.getElementById('wwl-js-vm-tester-container')
    domElement.appendChild(view.el)
    view.render()

  tester.run()
