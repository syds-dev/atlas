/*global describe, beforeEach, it */

var expect  = require('chai-stack').expect,
    trilby  = require('../');

describe('trilby', function() {
    var t, richard, paul, victoria, rachel, bob, frank;
    
    function name() {
        return this.forename + ' ' + this.surname;
    }
    
    function test(actual, expected) {
        expect(actual.length).to.equal(expected.length);
        expect(actual).to.respondTo('__trilby__');
        expect(actual.toArray()).to.eql(expected);
    }
    
    beforeEach(function() {
        richard     = { forename: 'Richard', surname: 'Smith', age: 25, gender: 'male', name: name.bind(richard) };
        paul        = { forename: 'Paul', surname: 'Davis', age: 25, gender: 'male', name: name.bind(paul) };
        victoria    = { forename: 'Victoria', surname: 'Jones', age: 22, gender: 'female', name: name.bind(victoria) };
        rachel      = { forename: 'Rachel', surname: 'Charles', age: 25, gender: 'female', name: name.bind(rachel) };
        bob         = { forename: 'Bob', surname: 'James', age: 30, gender: 'male', name: name.bind(bob) };
        frank       = { forename: 'Frank', surname: 'Martin', age: 35, gender: 'male', name: name.bind(frank) };
        
        t = trilby([richard, paul, victoria, rachel]);
    });
    
    describe('pluck', function() {
        it('should pluck correctly', function() {
            test(t.pluck('forename'), ['Richard', 'Paul', 'Victoria', 'Rachel']);
        });
    });

    describe('unique', function() {
        it('should return unique values', function() {
            test(trilby([1, 1, 2, 3, 3, 3, 4]).unique(), [1, 2, 3, 4]);
        });
        it('should return unique values 2', function() {
            test(t.pluck('age').unique(), [25, 22]);
        });
    });

    describe('filter', function() {
        it('should do a simple filter', function() {
            test(t.filter(function(item) {
                return item.gender === 'male';
            }), [richard, paul]);
        });
        it('should filter based on a key', function() {
            test(t.filter(function(item) {
                return item === 'female';
            }, 'gender'), [victoria, rachel]);
        });
    });

    describe('map', function() {
        it('should map correctly', function() {
            test(t.map(function(item) {
                return item.surname;
            }), ['Smith', 'Davis', 'Jones', 'Charles']);
        });
    });

    describe('add', function() {
        it('should do a simple add', function() {
            test(t.add(bob), [richard, paul, victoria, rachel, bob]);
        });
        it('should do multiple adds', function() {
            test(t.add([bob, frank]), [richard, paul, victoria, rachel, bob, frank]);
        });
        it('should ignore duplicate adds', function() {
            test(t.add([richard, paul, frank]), [richard, paul, victoria, rachel, frank]);
        });
        it('should ignore duplicate adds 2', function() {
            test(t.add([richard, richard, frank]), [richard, paul, victoria, rachel, frank]);
        });
        it('should ignore duplicate adds 2 from arguments', function() {
            test(t.add(richard, richard, frank), [richard, paul, victoria, rachel, frank]);
        });
    });

    describe('remove', function() {
        it('should do a simple remove', function() {
            test(t.remove(paul), [richard, victoria, rachel]);
        });
        it('should do multiple removes', function() {
            test(t.remove([richard, victoria]), [paul, rachel]);
        });
        it('should ignore non-existing removes', function() {
            test(t.remove(frank), [richard, paul, victoria, rachel]);
        });
        it('should ignore non-existing removes 2', function() {
            test(t.remove([rachel, frank]), [richard, paul, victoria]);
        });
        it('should ignore non-existing removes 2 from arguments', function() {
            test(t.remove(rachel, frank), [richard, paul, victoria]);
        });
    });

    describe('contains', function() {
        it('should test contains correctly', function() {
            expect(t.contains(paul));
        });
        it('should test contains correctly 2', function() {
            expect(t.contains(paul, richard));
        });
        it('should test contains correctly 3', function() {
            expect(!t.contains(paul, bob));
        });
        it('should test contains correctly 4', function() {
            expect(!t.contains(frank, bob));
        });
    });

    describe('clone', function() {
        it('should clone correctly', function() {
            test(t.clone(), [richard, paul, victoria, rachel]);
        });
    });

    describe('invoke', function() {
        it('should invoke correctly', function() {
            test(t.invoke('name'), ['Richard Smith', 'Paul Davis', 'Victoria Jones', 'Rachel Charles']);
        });
    });
});