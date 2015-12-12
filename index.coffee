'use strict'

_    = require 'lodash'
path = require 'path'
thru = require 'through2'
util = require 'gulp-util'
log  = util.log

module.exports = (options) ->
    
    opts = _.assign
        pepper: ['log']
              # names of functions that get peppered
              #
              # if specified as a map:
              #       key: original function name that gets replaced
              #       value: replacement function that gets called instead
              #
              # if specified as a list:
              #       preserves the original function names
              #
              #  the replacement function receives one additional argument:
              #       an object with keys: file, line, method, type, args
        paprika: 
            'dbg': 'log'
              # names of functions that get paprikaed :-)
              #
              # same as pepper, but the original variable arguments get
              #                 prefixed by their names. eg.:
              #  
              # dbg foo, bar
              # 
              # gets replaced by
              #
              # dbg {...pepper...}, 'foo:', foo, 'bar:', bar
              #
        stringify: JSON.stringify
              #
              # this lets you change the ouput format or enhance the info, 
              # eg. instead of dumping the whole info dictionary you could 
              # just prefix the logs with class name and method name like this: 
              # 
              # stringify: (i) -> '"' + i.class + i.type + i.method + ' ► "'
              # 
        paprikaPrefix:  '"'
        paprikaPostfix: ':"'
    ,
        options
        
    thru.obj (file, enc, cb) ->
        
        if not file.isNull() and not file.isStream()
            peppered = pepper file.path, file.contents.toString('utf8'), opts
            file.contents = new Buffer peppered
            
        cb null, file

pepper = (f, s, options) ->

    lines = s.split '\n'

    info = { file: f, class: path.basename f, '.coffee' }
    
    for li in [0...lines.length]
        info.line = li+1
        line = lines[li]

        if options.pepper or options.paprika
            
            regexp = /(^\s*class\s+)(\w+)(\s?.*$)/
            if m = line.match(regexp)
                info.class = m[2]

            if m = line.match(/^\s{0,6}(\@)?([\_\.\w]+)\s*[\:\=]\s*(\([^)]*\))?\s*[=-]\>/)
                info.args = ( a.trim() for a in m[3].slice(1,-1).split(',') ) if m[3]
                info.method = m[2]
                info.type = m[1] or '.'

            ###
            00000000   00000000  00000000   00000000   00000000  00000000 
            000   000  000       000   000  000   000  000       000   000
            00000000   0000000   00000000   00000000   0000000   0000000  
            000        000       000        000        000       000   000
            000        00000000  000        000        00000000  000   000
            ###

            if options.pepper
                if Array.isArray(options.pepper)
                    map = _.zipObject options.pepper, options.pepper
                else
                    map = options.pepper

                for key of map
                    regexp = new RegExp "(^\s*)(#{key})(\\s+[^ =]+.*$)"
                    if m = line.match(regexp)
                        lines[li] = line.replace regexp, "$1" + map[key] + " " + options.stringify(info) + ", $3"

            ###
            00000000    0000000   00000000   00000000   000  000   000   0000000 
            000   000  000   000  000   000  000   000  000  000  000   000   000
            00000000   000000000  00000000   0000000    000  0000000    000000000
            000        000   000  000        000   000  000  000  000   000   000
            000        000   000  000        000   000  000  000   000  000   000
            ###

            if options.paprika
                                
                if Array.isArray(options.paprika)
                    map = _.zipObject options.paprika, options.paprika
                else
                    map = options.paprika

                for key of map
                    regexp = new RegExp "(^\s*)(#{key})(\\s+[^ =]+.*$)"
                    
                    if m = line.match(regexp)
                        
                        lines[li] = line.replace regexp, "$1" + map[key] + " " + options.stringify(info) + ", $3"
                        arglist = (_.trim(a) for a in m[3].split(','))
                        argreg = new RegExp('^[^\\{\\[\\\'\\\"\\d]*$')
                        for i in [arglist.length-1..0]
                            arg = arglist[i]
                            if arg.match argreg
                                arglist.splice i, 0, options.paprikaPrefix + arg + options.paprikaPostfix
                        lines[li] = lines[li].replace(m[3], arglist.join(', '))


    lines.join '\n'
