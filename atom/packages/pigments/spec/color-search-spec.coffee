require './spec-helper'
ColorSearch = require '../lib/color-search'

describe 'ColorSearch', ->
  [search, pigments, project] = []

  beforeEach ->
    atom.config.set 'pigments.sourceNames', [
      '**/*.styl'
      '**/*.less'
    ]

    waitsForPromise -> atom.packages.activatePackage('pigments').then (pkg) ->
      pigments = pkg.mainModule
      project = pigments.getProject()

    waitsForPromise -> project.initialize()

  describe 'when created with basic options', ->
    beforeEach ->
      search = new ColorSearch
        sourceNames: atom.config.get 'pigments.sourceNames'
        ignoredNames: [
          'project/vendor/**'
        ]
        context: project.getContext()

    it 'dispatches a did-complete-search when finalizing its search', ->
      spy = jasmine.createSpy('did-complete-search')
      search.onDidCompleteSearch(spy)
      search.search()
      waitsFor -> spy.callCount > 0
      runs -> expect(spy.argsForCall[0][0].length).toEqual(22)

    it 'dispatches a did-find-matches event for every files', ->
      completeSpy = jasmine.createSpy('did-complete-search')
      findSpy = jasmine.createSpy('did-find-matches')
      search.onDidCompleteSearch(completeSpy)
      search.onDidFindMatches(findSpy)
      search.search()
      waitsFor -> completeSpy.callCount > 0
      runs ->
        expect(findSpy.callCount).toEqual(5)
        expect(findSpy.argsForCall[0][0].matches.length).toEqual(3)
