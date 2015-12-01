# gulp-pepper

inserts info dictionaries into coffee-script files like this:

```coffee
```

#### gulpfile.coffee

```coffee
gulp = require 'gulp'
pepper = require 'gulp-pepper'

gulp.task 'default', ->        
    gulp.watch ['**/*.coffee'], (e) -> 
        gulp.src e.path, base: '.'
        .pipe pepper()
        .pipe gulp.dest './peppered'
```

#### default config

```coffee
config
```

This stuff works for me, but I won't guarantee that it works for you as well. 
Use at your own risk!

[npm](https://www.npmjs.com/package/gulp-pepper)
