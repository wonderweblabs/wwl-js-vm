# wwl-js-vm

| Current Version |
|-----------------|
| [![npm version](https://badge.fury.io/js/wwl-js-vm.svg)](https://badge.fury.io/js/wwl-js-vm) |

---

A design pattern to implement encapsuled and separately developable view components
in scope of Backbone.View, Marionette.View and/or Ampersand.View (**note** with version 1.0.0, there is a dependency to marionette 3+).

Mainly, the idea comes from concepts like Webcomponents or React, where a piece of
view functionality is implemented behind a clearly defined facade. From the outside,
you cannot estimate how much is going on inside the module. There is just the definition
of how to use this component (view module, vm).


### Why not using e.g. a marionette view directly?

There are several reasons to capsule view logic behind a "not view"-construct and still
promising the return a "view"-construct:

* The certain view needs to be prepared before it's creation
* Which or what kind of view is returned is dynamic
* If the view is destroyed from the outside world, you still again want to provide the same (or similar) one
* The "user" of the view just want to use it in an easy way but you want to provide a large and mighty api


### Why not using react or webcomponents etc?

Webcomponents might be the future. But the current state of browser support is not enough to build
production apps.

React got awesome patterns. But those are often completely different to ways other frameworks are
solving problems.

We at wwl already got a lot of (older and newer) marionette apps. Some of them are not very clean, especially older ones. The concept of the view modules is pretty independend so that we can implement new features with that pattern without destroy our old code.




## Examples to view modules:

TODO




## Implementation Pattern

A view module needs to implement five features

1. It needs to be a prototype
2. It requires a context object ([see wwl-js-app-context](https://github.com/wonderweblabs/wwl-js-app-context))
3. It has a ```getView``` which will **always** return a valid view (Backbone.View compatible api)
4. It has a ```start``` function which returns a deferred promise (e.g. [Q](https://github.com/kriskowal/q))
4. It has a ```stop``` function which returns a deferred promise (e.g. [Q](https://github.com/kriskowal/q))

*Of course, you're view module might have a larger api than described above. The basic set of features gives a very good development workflow (see below at the Tester).*



## Usage Pattern

If you're using a view module:

1. You must pass in a context object as option ```{ context: yourContextObject }``` ([see wwl-js-app-context](https://github.com/wonderweblabs/wwl-js-app-context))
2. You must call ```start``` once
3. If necessary, you can call ```stop``` once (afterwards you can call ```start``` again)

*As described above, a view module might have additional requirements and apis. So this should be documented at least inside your vm file.*




## View Module - Example implementation

The libraries VM class already provides a full qualified api implementation. You just need to inherit.

```coffeescript
class MyVM extends require('wwl-js-vm').VM

  # (optionally) Called after start, must return a deferred promise
  onStart: ->
    # do your starting logic here
    Q()

  # (optionally) Called after stop, must return a deferred promise
  onStop: ->
    # do your stopping logic here
    Q()

  # Overwrite view class getter
  getMainViewClass: ->
    Backbone.View.extend({ template: '<h1>Test</h1>' })

```

Using it:

```coffeescript
context = new (require('wwl-js-app-context'))({ root: true })
vm      = new MyVM({ context: context })

vm.getView().render()
$('body').append(vm.getView().$el)

vm.start()
```




## View Module - Backbone.Events

The ```require('wwl-js-vm').VM``` includes the [Backbone.Events](http://backbonejs.org/#Events)
API. Since we don't want to load the whole backbone library, we're including it as little
extraction directly in this repo (see vendor folder).

So you can use features like ```listenTo```, ```on``` or ```trigger```.




## View Module - API

When inheriting from ```require('wwl-js-vm').VM``` you can overwrite the following methods:


#### initialize
```coffeescript
  # default:
  initialize: (options)->
    null
```
> Called from constructor at the end. So don't overwrite the constructor itself. Get's all parameters passed in which you call on ```new```.


#### onStart
```coffeescript
  # default:
  onStart: ->
    Q()
```
> Called on starting the view module.
>
> **It must return a deferred promise**


#### onStop
```coffeescript
  # default:
  onStop: ->
    Q()
```
> Called on stopping the view module.
>
> **It must return a deferred promise**


#### getView
```coffeescript
  # default:
  getView: ->
    @_view or= @buildView()
```
> Returns a valid view instance. You might overwrite this to implement
> e.g. a dynamic way to return view(s).


#### getMainViewClass
```coffeescript
  # default:
  getMainViewClass: ->
    require('./views/main_view')
```
> You should return you own main view class here.


#### getMainViewOptions
```coffeescript
  # example overwriting
  getMainViewOptions: ->
    _.extend(super(), {
      my: 'value'
    })
```
> Returns the options passed to the main view on creation. By default
> it contains the context and the vm.
> Overwrite and/or extend it to append you main view's configuration.


#### buildView
```coffeescript
  # default:
  buildView: ->
    view = new (@getMainViewClass())(@getMainViewOptions())
    @listenTo view, 'destroy', => @stopListening(view); @_view = null
    view
```


#### resetView
```coffeescript
  # default:
  resetView: ->
    @_view.destroy() if @_view && _.isFunction(@_view.destroy)
    @_view = null
```
> Resets the view e.g. on stop


---

You might not overwrite those but use them:


#### start
> To start the view module

#### stop
> To stop the view module

#### mergeOptions(options, keys)
> Merge `keys` from `options` onto `this`

#### getOption(optionName)
> Retrieve an object, function or other value from the
> object or its `options`, with `options` taking precedence.



---



## View Module Tester

Additionally to the default implementation of a view module, the package delivers a little helper
tool to provide a convenient way to test view modules while developing them.

> The motivation for this starts at the point, where you've got an large application with a lot of
> logic build in javascript. There are many points, where the feature you're implementing might
> only be accessible through a certain click path. So everytime you change something in your
> code, you need to reload the browser and go through the click path again
>
> Additionally, the loading time might be long due to pre-fetching data etc.
>
> The idea of the tester is to show just one view module and provide a certain
> configuration for it.



### View Module Tester - API

You need to register an attach callback (`tester.registerAttachFunction`) to the tester. When
running it, the tester will call that function and will pass the view instance. You'll need to
take care on your own to attach and render it. Have a look at the example below.

```html
<div id="wwl-node-vm-tester-container"></div>
```

```coffeescript
tester = new (require('wwl-js-vm').Tester)({
  config =
    getDefaultVMConfig: ->
      context: new (require('wwl-js-app-context'))({ root: true })
  vmConfig =
    vmPrototype: require('./vms/example/vm')
})

tester.registerAttachFunction (view) =>
  domElement = document.getElementById('wwl-js-vm-tester-container')
  domElement.appendChild(view.el)
  view.render()

tester.run()

```


#### config

The tester provides you some callbacks for general purposes and to create a general view module configuration, that will be passed to every view module on creation.

| key | params | return | desc |
|---|---|---|---|
| getDefaultVMConfig  |  | plain object | **required** - function - Must contain ```context``` at least. |
| before              | | promise | function
| after               | vm, moduleConfig | promise | function


#### vmConfig

Additionally to the general config, the tester provides you a config (```vmConfig```) that you can set specifically for your current view module to develop/test.

> See "Usage recommendation" for a good example of using both configurations.

| key | params | return | desc |
|---|---|---|---|
| vmPrototype       |  | prototype | The prototype of the vm to test. |
| beforeInititalize | moduleConfig | promise | function |
| afterInititalize  | vm, moduleConfig | promise | function |
| beforeStart       | vm, moduleConfig | promise | function |
| afterStart        | vm, moduleConfig | promise | function |


#### Call chain:

The tester executes the different callbacks on you configuration (tests for each not required function if it exists). The whole chain is implemented blocking. That's why you need to return a promise for each callback function.

Since it is blocking, you can implement logic like fetching data from the server before the tester creates the vm instance.

Calling order:

1. ```config.before()```
2. ```config.getDefaultVMConfig()```
3. ```vmConfig.beforeInititalize(moduleConfig)```
4. **Initializes vm with moduleConfig** ```new VM(moduleConfig)```
5. ```vmConfig.afterInititalize(viewModule, moduleConfig)```
6. **Calls the registerAttachFunction function with vm.getView() passed**
7. ```vmConfig.beforeStart(viewModule, moduleConfig)```
8. **Runs vm.start()**
9. ```vmConfig.afterStart(viewModule, moduleConfig)```
10. ```config.after(viewModule, moduleConfig)```





## Usage recommendation

To have a clean workflow in you project, you should implement a little folder/file structure with the following pattern:

> tests/ [coffee files here]
>
> tests_custom/.keep
>
> tests_examples/ [coffee files here]
>
> app.coffee
>
> main.example.coffee
>
> main_vm.example.coffee

Files that should be ignored by git:

> tests_custom/\*\*/\*.coffee
>
> main.coffee
>
> main_vm.coffee


#### tests, tests_custom, tests_examples

Each coffee file in here should ```module.exports``` an object in pattern of the ```vmConfig```.


#### tests

General configs that are not related to user based configurations.

**Right**: Displaying an index action (list) of categories - since that might be the same for each developer.

**Wrong**: Displaying the show view for one category - since you need to fetch one category by id and every developer got different database entries.


#### tests_custom

Every coffee file in here should be gitignored. So each developer can implement his/her own files here without pushing them into the repo.


#### tests_examples

Those might be example configs with are like the "**wrong**" definition above but where you want to show somebody how you tested something.

Normally everybody would copy those examples into the tests_custom folder and adjust them for their own purposes.


#### app.coffee

Should require the tester, main.coffee and main_vm.coffee like so:

```coffeescript
domready    = require 'domready'

domready ->
  tester          = new (require('wwl-js-vm').Tester)({ domElementId: 'wwl-node-vm-tester-container' })
  tester.config   = require('path/to/main.coffee')
  tester.vmConfig = require('path/to/main_vm.coffee')
  tester.run()

```

#### main.example.coffee and main.coffee

Put you global configuration (```config```) into the the ```main.coffee``` file. To share a working default implementation, setup and check in the example file.

Example:

```coffeescript
module.exports =
  getDefaultVMConfig: ->
    context: new (require('wwl-js-app-context'))({ root: true })

```

#### main_vm.example.coffee and main_vm.coffee

Now here is your switch to choose the module you want currently to test.

Again - the example file should reference some default modules like those in ```tests``` - but comment them.

Everytime you want to develop a certain view module, you would un-comment the export line therefore, compile and then run the page that executes the tester.

Example:

```coffeescript

# module.exports = require('tests/example')
# module.exports = require('tests/modals')
module.exports = require('tests_custom/my_module')

```

In the example above, i would run the configuration for implemented in ```tests_custom/my_module.coffee```.

Since that file is not checked in, changing and jumping around in here does not have any effect for other developers.

## How to contribute

  1. ```npm install```
  2. ```npm run build``` - to build the example files
  3. open ```build/index.html``` in your browser
  4. start working

Please check if the tests working ```npm run test``` before you creating a pull-request

