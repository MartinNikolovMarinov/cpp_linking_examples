# Libraries

A library is exactly like an executable, except instead of running directly, the library functions are invoked from another executable that has a main function.

# Static linking libraries

This means that you directly link the library into the final executable at **compiletime**. It's called **static**, because the library can NOT change unless the program is recompiled.

The Benefit is that:

* <span style="text-decoration: underline">The final product is a simple executable with no external dependencies. So you can make code that "just works".</span>
* Static libraries don't need to be included and searched for when you distribute your executable.
* At compile time, linking to a static library is generally faster than linking to individual source files.

The Drawbacks are that:

* The distributed binaries are larger in size.
* It's possible to "double link" different versions of the same library, which can lead to build failures.
* Some libraries don't work with static builds.
* You can't link static libs to other static libs. You can merge them using a library manager.
* The other "drawbacks", absolutely, don't matter to me..

# Dynamic linking libraries

This means that the library is loaded **dynamically** at **runtime**.

The Benefit is that:

* Only a single copy of the library is loaded in memory.
* The generated executable is smaller.

The Drawbacks are that:

* <span style="text-decoration: underline">If the dynamic library is updated with a bug, or has a bug in an older version, that the user hasn't or can't update, you get to have that bug for free...</span>
* Slower to link and can't be optimized at **linktime**.