l
=
[![Build
Status](https://travis-ci.org/pzel/l.svg?branch=master)](https://travis-ci.org/pzel/l)

Implementing Haskell's [Data.List](http://hackage.haskell.org/package/base-4.6.0.1/docs/Data-List.html) in Erlang.

Current status
--------------

The following functions are implemented:

         append/2,
         head/1,
         last/1,
         tail/1,
         init/1,
         null/1,
         length/1,

         map/2,
         reverse/1,
         intersperse/2,
         intercalate/2,
         transpose/1,
         subsequences/1,
         permutations/1,

         foldr/3,
         foldr/2,  (known as foldr1 in Data.List)
         foldl/3,
         foldl/2,  (known as foldl1 in Data.List)

         concat/1,
         concat_map/2,
         and_/1,
         or_/1,
         any_/1,
         all/2,
         sum/1,
         product/1,
         maximum/1,
         minimum/1,

         replicate/2,

         filter/2,

         delete/2

Project roadmap
---------------

###0.1 – All Data.List functions implemented

Functions dealing specifically with eager vs. lazy evaluation (i.e `foldl'` &
friends) will be omitted. Functions generating infinite lists (`iterate`,
`repeat`, `replicate` and `cycle`) will be dealt with case-by case: dropped
entirely or fitted with an extra parameter specifying the length of the desired
output.

At this stage, no calls to the `lists:` module will be made. The idea is to
bootstrap this library using only on its own functions.

Unit tests and [proper](https://github.com/manopapad/proper) properties are
written before the functions are actually implemented, but may be incomplete.

Code coverage doesn't drop below 100%.


###0.2 – All functions typed, documented, and exhaustively tested 

At this stage, the module should be verfifed correct to a great
extent. The source will be annotated, and generated documentation available.


###0.3 – Computational complexity reduction

This version will make the code more suitable for production by optimizing
computationally wasteful implementations. Calls to `lists:` functions may appear
at this point.



