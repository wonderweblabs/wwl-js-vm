_                     = require('underscore')
BackboneEvents        = require('./backbone_events')(_)
BackboneEventsAsClass = class BackboneEventsAsClass

_.extend(BackboneEventsAsClass.prototype, BackboneEvents)

module.exports = BackboneEventsAsClass