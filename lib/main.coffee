{Emitter} = require 'atom'

Jekyll = require './jekyll/jekyll'
Utils = require './jekyll/utils'

module.exports =
  disposables: []
  Emitter: new Emitter()

  config:
    postsDir:
      type: 'string'
      default: '_posts/'
    postsType:
      type: 'string'
      default: '.markdown'
    draftByDefault:
      type: 'boolean'
      default: false
    draftsDir:
      type: 'string'
      default: '_drafts/'
    serverPort:
      type: 'integer'
      default: 3000
    buildCommand:
      type: 'array'
      default: ['jekyll', 'build']
      items:
        type: 'string'

  activate: ->
    process.jekyllAtom = {
      buildCommand: atom.config.get('jekyll.buildCommand')
    }

    atom.commands.add 'atom-workspace', "jekyll:open-layout", => @handleCommand('openLayout', true, true)
    atom.commands.add 'atom-workspace', "jekyll:open-config", => @handleCommand('openConfig', false, false)
    atom.commands.add 'atom-workspace', "jekyll:open-include", => @handleCommand('openInclude', true, true)
    atom.commands.add 'atom-workspace', "jekyll:open-data", => @handleCommand('openData', true, true)
    atom.commands.add 'atom-workspace', "jekyll:toolbar", => @handleCommand('toolbar', false, false)
    atom.commands.add 'atom-workspace', "jekyll:toggle-server", => @handleCommand('toggleServer', true, false)
    atom.commands.add 'atom-workspace', 'jekyll:new-post', => @handleCommand('newPost', false, false)
    atom.commands.add 'atom-workspace', 'jekyll:build-site', => @handleCommand('buildSite', true, false)
    atom.commands.add 'atom-workspace', 'jekyll:publish-draft', => @handleCommand('publishDraft', true, true)

    Jekyll.createNewPostView()
    Jekyll.createToolbarView(@Emitter)

    Utils.setMainModule(this)
    Utils.getConfigFromSite()

    @Emitter.emit 'loaded'
    @Emitter.on 'config-loaded', => @dispose

  deactivate: ->
    @dispose()
    Jekyll.Server?.stop()

  dispose: ->
    for disposeable in @disposables
      disposeable.dispose()

  handleCommand: (name, waitForConfig, needsEditor) ->
    run = true
    if needsEditor
      unless atom.workspace.getActiveTextEditor()
        atom.notifications.addWarning('Could not see Active Editor, do you have an editor open?')
        run = false

    if run
      if waitForConfig
        Utils.waitForConfig (config) ->
          Jekyll[name](config)
      else
        Jekyll[name]()
