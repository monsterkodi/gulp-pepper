'use strict';
var _, log, path, pepper, thru, util;

_ = require('lodash');

path = require('path');

thru = require('through2');

util = require('gulp-util');

log = util.log;

module.exports = function(options) {
  var opts;
  opts = _.assign({
    pepper: ['log'],
    paprika: {
      'dbg': 'log'
    },
    stringify: JSON.stringify,
    paprikaPrefix: '"',
    paprikaInfix: function(s) {
      return s;
    },
    paprikaPostfix: ':"'
  }, options);
  return thru.obj(function(file, enc, cb) {
    var peppered;
    if (!file.isNull() && !file.isStream()) {
      peppered = pepper(file.path, file.contents.toString('utf8'), opts);
      file.contents = new Buffer(peppered);
    }
    return cb(null, file);
  });
};

pepper = function(f, s, options) {
  var a, arg, arglist, argreg, i, info, j, k, key, li, line, lines, m, map, ref, ref1, regexp;
  lines = s.split('\n');
  info = {
    file: f,
    "class": path.basename(f, '.coffee')
  };
  for (li = j = 0, ref = lines.length; 0 <= ref ? j < ref : j > ref; li = 0 <= ref ? ++j : --j) {
    info.line = li + 1;
    line = lines[li];
    if (options.pepper || options.paprika) {
      regexp = /(^\s*class\s+)(\w+)(\s?.*$)/;
      if (m = line.match(regexp)) {
        info["class"] = m[2];
      }
      if (m = line.match(/^\s{0,6}(\@)?([\_\.\w]+)\s*[\:\=]\s*(\([^)]*\))?\s*[=-]\>/)) {
        if (m[3]) {
          info.args = (function() {
            var k, len, ref1, results;
            ref1 = m[3].slice(1, -1).split(',');
            results = [];
            for (k = 0, len = ref1.length; k < len; k++) {
              a = ref1[k];
              results.push(a.trim());
            }
            return results;
          })();
        }
        info.method = m[2];
        info.type = m[1] || '.';
      }

      /*
      00000000   00000000  00000000   00000000   00000000  00000000 
      000   000  000       000   000  000   000  000       000   000
      00000000   0000000   00000000   00000000   0000000   0000000  
      000        000       000        000        000       000   000
      000        00000000  000        000        00000000  000   000
       */
      if (options.pepper) {
        if (Array.isArray(options.pepper)) {
          map = _.zipObject(options.pepper, options.pepper);
        } else {
          map = options.pepper;
        }
        for (key in map) {
          regexp = new RegExp("(^\\s*)(" + key + ")(\\s+[^ =]+.*$)");
          if (m = line.match(regexp)) {
            lines[li] = line.replace(regexp, "$1" + map[key] + " " + options.stringify(info) + ", $3");
          }
        }
      }

      /*
      00000000    0000000   00000000   00000000   000  000   000   0000000 
      000   000  000   000  000   000  000   000  000  000  000   000   000
      00000000   000000000  00000000   0000000    000  0000000    000000000
      000        000   000  000        000   000  000  000  000   000   000
      000        000   000  000        000   000  000  000   000  000   000
       */
      if (options.paprika) {
        if (Array.isArray(options.paprika)) {
          map = _.zipObject(options.paprika, options.paprika);
        } else {
          map = options.paprika;
        }
        for (key in map) {
          regexp = new RegExp("(^\\s*)(" + key + ")(\\s+[^ =]+.*$)");
          if (m = line.match(regexp)) {
            lines[li] = line.replace(regexp, "$1" + map[key] + " " + options.stringify(info) + ", $3");
            arglist = (function() {
              var k, len, ref1, results;
              ref1 = m[3].split(',');
              results = [];
              for (k = 0, len = ref1.length; k < len; k++) {
                a = ref1[k];
                results.push(_.trim(a));
              }
              return results;
            })();
            argreg = new RegExp('^[^\\{\\[\\\'\\\"\\d]*$');
            for (i = k = ref1 = arglist.length - 1; ref1 <= 0 ? k <= 0 : k >= 0; i = ref1 <= 0 ? ++k : --k) {
              arg = arglist[i];
              if (arg.match(argreg)) {
                arglist.splice(i, 0, options.paprikaPrefix + options.paprikaInfix(arg) + options.paprikaPostfix);
              }
            }
            lines[li] = lines[li].replace(m[3], arglist.join(', '));
          }
        }
      }
    }
  }
  return lines.join('\n');
};
