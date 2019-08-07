/**
 * trilby.js
 *
 * @author      Richard Butler <rich@smartcasual.io>
 * @license     MIT <https://github.com/richardbutler/trilby/blob/master/LICENSE>
 * @version     0.1.0
 */

/*global module */
(function(root, factory) {
    if (typeof define === 'function' && define.amd) {
        // AMD. Register as an anonymous module.
        define([], factory);
    } else if (typeof exports === 'object') {
        // Node. Does not work with strict CommonJS, but
        // only CommonJS-like environments that support module.exports,
        // like Node.
        module.exports = factory();
    } else {
        // Browser globals (root is window)
        root.trilby = factory();
    }
}(this, function() {
    'use strict';

    var ap = Array.prototype;

    /**
     * A chainable convenience mixin for arrays - think Underscore/Lodash,
     * but chainable out-of-the-box.
     *
     * @class   trilby
     * @param   {Array|trilby}  [arr]   Array to wrap
     * @return  {trilby}
     */
    function trilby(arr) {
        if (arr && typeof arr.__trilby__ === 'function') {
            return arr;
        }

        arr = toArray(arr);

        Object.keys(proto).forEach(function(key) {
            arr[key] = proto[key].bind(arr);
        });

        return arr;
    }
    
    //------------------------------------------------------------------------------
    //
    //  Mixin methods
    //
    //------------------------------------------------------------------------------

    /**
     * @lends trilby.prototype
     */
    var proto = {

        /**
         * Returns an array of mapped values based on a key.
         *
         * ```
         * trilby([{shape: 'rectangle'}, {shape: 'triangle'}]); // => ['rectangle', 'triangle']
         * ```
         *
         * @param   {String}    key     The property to map on
         * @return  {trilby}            A new trilby
         */
        pluck: function(key) {
            return this.map(function(item) {
                return item[key];
            });
        },

        /**
         * Returns a clone of this trilby without duplicates.
         *
         * @param   {String}    [primaryKey]    Optional primary key for comparison
         * @return  {trilby}                    A new trilby
         */
        unique: function(primaryKey) {
            var map = {};

            return this.filter(function(item) {
                var key = (typeof primaryKey === 'undefined') ? item : item[primaryKey];
                if (key in map) return false;
                map[key] = item;
                return true;
            });
        },

        /**
         * Filters the collection and returns a new trilby.
         *
         * @param   {Function}  fn      Filter function
         * @param   {String}    [key]   Optional key to use for filtering
         * @return  {trilby}            A new trilby
         */
        filter: function(fn, key) {
            return trilby(ap.filter.call(this, function(item) {
                return fn(key ? item[key] : item);
            }));
        },

        /**
         * Wrapper function for `Array.prototype.map` that returns a new
         * trilby for the results.
         *
         * @see     Array.prototype.map
         * @return  {trilby}            A new trilby
         */
        map: function() {
            return trilby(ap.map.apply(this, arguments));
        },

        /**
         * Convenience additive method - accepts single items and arrays,
         * and ignores anything that already exists in the collection.
         *
         * @param   {Object|Array}  items   Item, or array of items, to add
         * @return  {trilby}                The current trilby
         */
        add: function(items) {
            toArray(arguments.length > 1 ? arguments : items)
                .forEach(function(item) {
                    if (!this.contains(item)) {
                        this.push(item);
                    }
                }, this);
            
            return this;
        },

        /**
         * Convenience subtractive method - accepts single items and arrays.
         *
         * @param   {Object|Array}  items   Item, or array of items, to remove
         * @return  {trilby}                The current trilby
         */
        remove: function(items) {
            toArray(arguments.length > 1 ? arguments : items)
                .forEach(function(item) {
                    var index = this.indexOf(item);
                    
                    if (index >= 0) {
                        this.splice(index, 1);
                    }
                }, this);
            
            return this;
        },

        /**
         * Whether a given item, or any of the items in a given array,
         * exist within this collection.
         *
         * @param   {Array}     items   Item, or array of items, to check
         * @return  {Boolean}
         */
        contains: function(items) {
            items = toArray(items);

            while (items.length) {
                if (this.indexOf(items.shift()) === -1) {
                    return false;
                }
            }

            return true;
        },

        /**
         * Clones this collection
         *
         * @return  {trilby}    A new trilby
         */
        clone: function() {
            return trilby(ap.slice.call(this));
        },

        /**
         * Calls a given method on each item in the collection, and applies
         * the results to a return trilby.
         *
         * @param   {String}    key     The key pertaining to the method to call
         * @return  {trilby}            A new trilby
         */
        invoke: function(key) {
            return this.map(function(item) {
                return (typeof item[key] === 'function') ? item[key].call(this, item) : undefined;
            }, this);
        },

        /**
         * Return a naked array that represents the items in this collection.
         *
         * @return  {Array}
         */
        toArray: function() {
            return ap.slice.call(this);
        },

        /**
         * Used for duck type checking.
         *
         * @private
         */
        __trilby__: function() {
            return true;
        }
    };
    
    //------------------------------------------------------------------------------
    //
    //  Misc utilities
    //
    //------------------------------------------------------------------------------

    function isArray(arr) {
        return Array.isArray(arr);
    }
    
    function isArguments(o) {
        return o && o.hasOwnProperty('callee');
    }

    function toArray(o) {
        if (typeof o === 'undefined') {
            return [];
        }

        if (isArguments(o)) {
            return ap.slice.call(o);
        }
        
        return isArray(o) ? o.slice() : [o];
    }
    
    return trilby;
}));