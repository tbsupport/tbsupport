if (!Function.prototype.bind) {
  Function.prototype.bind = function (oThis) {
    if (typeof this !== "function") {
      // closest thing possible to the ECMAScript 5 internal IsCallable function
      throw new TypeError("Function.prototype.bind - what is trying to be bound is not callable");
    }

    var aArgs = Array.prototype.slice.call(arguments, 1),
    fToBind = this,
    fNOP = function () {},
    fBound = function () {
      return fToBind.apply(this instanceof fNOP && oThis
      ? this
      : oThis,
      aArgs.concat(Array.prototype.slice.call(arguments)));
    };

    fNOP.prototype = this.prototype;
    fBound.prototype = new fNOP();

    return fBound;
  };
}

if ( !Array.prototype.forEach ) {
  Array.prototype.forEach = function(fn, scope) {
    for(var i = 0, len = this.length; i < len; ++i) {
      fn.call(scope, this[i], i, this);
    }
  };
}


/*
 * classList.js: Cross-browser full element.classList implementation.
 * 2012-11-15
 *
 * By Eli Grey, http://eligrey.com
 * Public Domain.
 * NO WARRANTY EXPRESSED OR IMPLIED. USE AT YOUR OWN RISK.
 */

/*global self, document, DOMException */

/*! @source http://purl.eligrey.com/github/classList.js/blob/master/classList.js*/

if (typeof document !== "undefined" && !("classList" in document.createElement("a"))) {

  (function (view) {

    "use strict";

if (!('HTMLElement' in view) && !('Element' in view)) return;

   var
   classListProp = "classList"
   , protoProp = "prototype"
   , elemCtrProto = (view.HTMLElement || view.Element)[protoProp]
   , objCtr = Object
   , strTrim = String[protoProp].trim || function () {
     return this.replace(/^\s+|\s+$/g, "");
   }
   , arrIndexOf = Array[protoProp].indexOf || function (item) {
     var
     i = 0
     , len = this.length
     ;
     for (; i < len; i++) {
       if (i in this && this[i] === item) {
         return i;
       }
     }
     return -1;
   }
   // Vendors: please allow content code to instantiate DOMExceptions
   , DOMEx = function (type, message) {
     this.name = type;
     this.code = DOMException[type];
     this.message = message;
   }
   , checkTokenAndGetIndex = function (classList, token) {
     if (token === "") {
       throw new DOMEx(
         "SYNTAX_ERR"
         , "An invalid or illegal string was specified"
       );
     }
     if (/\s/.test(token)) {
        throw new DOMEx(
          "INVALID_CHARACTER_ERR"
          , "String contains an invalid character"
        );
     }
     return arrIndexOf.call(classList, token);
   }
   , ClassList = function (elem) {
     var
     trimmedClasses = strTrim.call(elem.className)
     , classes = trimmedClasses ? trimmedClasses.split(/\s+/) : []
     , i = 0
     , len = classes.length
     ;
     for (; i < len; i++) {
       this.push(classes[i]);
     }
     this._updateClassName = function () {
       elem.className = this.toString();
     };
   }
   , classListProto = ClassList[protoProp] = []
   , classListGetter = function () {
     return new ClassList(this);
   }
   ;
   // Most DOMException implementations don't allow calling DOMException's toString()
   // on non-DOMExceptions. Error's toString() is sufficient here.
   DOMEx[protoProp] = Error[protoProp];
   classListProto.item = function (i) {
     return this[i] || null;
   };
   classListProto.contains = function (token) {
     token += "";
     return checkTokenAndGetIndex(this, token) !== -1;
   };
   classListProto.add = function () {
     var
     tokens = arguments
     , i = 0
     , l = tokens.length
     , token
     , updated = false
     ;
     do {
       token = tokens[i] + "";
       if (checkTokenAndGetIndex(this, token) === -1) {
         this.push(token);
         updated = true;
       }
     }
     while (++i < l);

                                                       if (updated) {
                                                         this._updateClassName();
                                                       }
   };
   classListProto.remove = function () {
     var
     tokens = arguments
     , i = 0
     , l = tokens.length
     , token
     , updated = false
     ;
     do {
       token = tokens[i] + "";
       var index = checkTokenAndGetIndex(this, token);
       if (index !== -1) {
         this.splice(index, 1);
         updated = true;
       }
     }
     while (++i < l);

                                                       if (updated) {
                                                         this._updateClassName();
                                                       }
   };
   classListProto.toggle = function (token, forse) {
     token += "";

     var
     result = this.contains(token)
     , method = result ?
     forse !== true && "remove"
       :
       forse !== false && "add"
         ;

       if (method) {
         this[method](token);
       }

       return !result;
   };
   classListProto.toString = function () {
     return this.join(" ");
   };

   if (objCtr.defineProperty) {
     var classListPropDesc = {
       get: classListGetter
       , enumerable: true
       , configurable: true
     };
     try {
       objCtr.defineProperty(elemCtrProto, classListProp, classListPropDesc);
     } catch (ex) { // IE 8 doesn't support enumerable:true
       if (ex.number === -0x7FF5EC54) {
         classListPropDesc.enumerable = false;
         objCtr.defineProperty(elemCtrProto, classListProp, classListPropDesc);
       }
   }
  } else if (objCtr[protoProp].__defineGetter__) {
    elemCtrProto.__defineGetter__(classListProp, classListGetter);
  }

}(self));

}



/*jshint
 asi: true,
 unused: true,
 boss: true,
 loopfunc: true,
 eqnull: true
 */


/*!
 * Legacy browser support
 */


// Map array support
if ( ![].map ) {
    Array.prototype.map = function ( callback, self ) {
        var array = this, len = array.length, newArray = new Array( len )
        for ( var i = 0; i < len; i++ ) {
            if ( i in array ) {
                newArray[ i ] = callback.call( self, array[ i ], i, array )
            }
        }
        return newArray
    }
}


// Filter array support
if ( ![].filter ) {
    Array.prototype.filter = function( callback ) {
        if ( this == null ) throw new TypeError()
        var t = Object( this ), len = t.length >>> 0
        if ( typeof callback != 'function' ) throw new TypeError()
        var newArray = [], thisp = arguments[ 1 ]
        for ( var i = 0; i < len; i++ ) {
            if ( i in t ) {
                var val = t[ i ]
                if ( callback.call( thisp, val, i, t ) ) newArray.push( val )
            }
        }
        return newArray
    }
}


// Index of array support
if ( ![].indexOf ) {
    Array.prototype.indexOf = function( searchElement ) {
        if ( this == null ) throw new TypeError()
        var t = Object( this ), len = t.length >>> 0
        if ( len === 0 ) return -1
        var n = 0
        if ( arguments.length > 1 ) {
            n = Number( arguments[ 1 ] )
            if ( n != n ) {
                n = 0
            }
            else if ( n !== 0 && n != Infinity && n != -Infinity ) {
                n = ( n > 0 || -1 ) * Math.floor( Math.abs( n ) )
            }
        }
        if ( n >= len ) return -1
        var k = n >= 0 ? n : Math.max( len - Math.abs( n ), 0 )
        for ( ; k < len; k++ ) {
            if ( k in t && t[ k ] === searchElement ) return k
        }
        return -1
    }
}


/*!
 * Cross-Browser Split 1.1.1
 * Copyright 2007-2012 Steven Levithan <stevenlevithan.com>
 * Available under the MIT License
 * http://blog.stevenlevithan.com/archives/cross-browser-split
 */
var nativeSplit = String.prototype.split, compliantExecNpcg = /()??/.exec('')[1] === undefined
String.prototype.split = function(separator, limit) {
    var str = this
    if (Object.prototype.toString.call(separator) !== '[object RegExp]') {
        return nativeSplit.call(str, separator, limit)
    }
    var output = [],
        flags = (separator.ignoreCase ? 'i' : '') +
            (separator.multiline  ? 'm' : '') +
            (separator.extended   ? 'x' : '') +
            (separator.sticky     ? 'y' : ''),
        lastLastIndex = 0,
        separator2, match, lastIndex, lastLength
    separator = new RegExp(separator.source, flags + 'g')
    str += ''
    if (!compliantExecNpcg) {
        separator2 = new RegExp('^' + separator.source + '$(?!\\s)', flags)
    }
    limit = limit === undefined ? -1 >>> 0 : limit >>> 0
    while (match = separator.exec(str)) {
        lastIndex = match.index + match[0].length
        if (lastIndex > lastLastIndex) {
            output.push(str.slice(lastLastIndex, match.index))
            if (!compliantExecNpcg && match.length > 1) {
                match[0].replace(separator2, function () {
                    for (var i = 1; i < arguments.length - 2; i++) {
                        if (arguments[i] === undefined) {
                            match[i] = undefined
                        }
                    }
                })
            }
            if (match.length > 1 && match.index < str.length) {
                Array.prototype.push.apply(output, match.slice(1))
            }
            lastLength = match[0].length
            lastLastIndex = lastIndex
            if (output.length >= limit) {
                break
            }
        }
        if (separator.lastIndex === match.index) {
            separator.lastIndex++
        }
    }
    if (lastLastIndex === str.length) {
        if (lastLength || !separator.test('')) {
            output.push('')
        }
    } else {
        output.push(str.slice(lastLastIndex))
    }
    return output.length > limit ? output.slice(0, limit) : output
}
