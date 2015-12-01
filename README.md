# gulp-pepper

inserts info dictionaries into coffee-script logs like this:

```coffee

class AClass
    
    do: (foo) ->
        log 'something'

    # the log line gets replaced by 

        log {"file":".../file.coffee","class":"AClass","line":5,"args":["foo"],"method":"do","type":"."}, "something"
```

### gulpfile.coffee

```coffee
gulp = require 'gulp'
pepper = require 'gulp-pepper'

gulp.task 'pepper', ->        
    gulp.src "*.coffee"
        .pipe pepper {...config...}
        .pipe gulp.dest './peppered'
```

#### default config

```coffee
stringify: JSON.stringify
      #
      # this lets you change the ouput format or enhance the info, 
      # eg. instead of dumping the whole info dictionary you could 
      # just prefix the logs with class name and method name like this: 
      # 
      # stringify: (i) -> '"' + i.class + i.type + i.method + ' ► "'
      # 
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
paprikaPrefix:  ''
paprikaPostfix: ':'
```

This stuff works for me, but I won't guarantee that it works for you as well. 
Use at your own risk!

[npm](https://www.npmjs.com/package/gulp-pepper)
