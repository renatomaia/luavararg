Vararg Manipulation Library
===========================

`vararg` is a Lua library for manipulation of [vararg expressions](http://www.lua.org/manual/5.3/manual.html#3.4.11).
These functions basically allow you to do things with vararg that
cannot be efficiently done in pure Lua but can be easily done through the C API.

Documentation
-------------

- [Manual](docs/manual.md)
- [License](LICENSE)

History
-------

Version 2.0
:	Lua 5.3 compatibility.
:	Performance improvement in 'vararg.pack'.
:	Removal of limitation of max 255 values to pack using 'vararg.pack'.
: Function `vararg.append` requires a value to be appended.
:	Function `vararg.range` and vararg packs (`vararg.pack`) does not fill the resulting range with `nil` values.
	Therefore `vararg.range(2, 4, 1,2,3)` will return `2,3` instead of `2,3,nil`.
	Likewise, `vararg.pack(1,2,3)(2, 4)` will return `2,3` instead of `2,3,nil`.
:	Function `vararg.remove` does not raise out of bound errors.
:	Function `vararg.concat` now only takes a single function which results are appended to the additional arguments.
:	New function `vararg.len`.
:	Reference manual.
:	No more a pure Lua alternative implementation.

Version 1.1:
:	New operation 'vararg.map'.

Version 1.0:
:	First release.
