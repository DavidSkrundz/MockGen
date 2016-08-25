MockGen [![Swift Version](https://img.shields.io/badge/Swift-3.0_Beta-orange.svg)](https://swift.org/download/#snapshots)
=======

A tool to generate mock implementations of protocols for testing

_MockGen currently generates Swift 2.2 code._

Building
--------

Building MockGen requires `Xcode 8` (tested with Beta 3 and Beta 6)

```Bash
git clone https://github.com/DavidSkrundz/MockGen
cd MockGen
swift build
cp ./.build/debug/MockGen <target directory>
```

Setup
-----

Before using MockGen, it is important to setup its configuration file `MockGen.plist`. It should be place in the same directory as the MockGen executable.

Keys:
```
ProjectName - The name that should be used in the `@testable import [name]`
RelativeOutputFilePath - The path of the output file relative to the running path (usually `[name]Tests/Mocks/Mock.swift`)
AdditionalImports - An array of strings of any libraries that should be imported
TypeMap - A dictionary of mappings from [Type -> Default Value]
```

Using
-----

To get MockGen to create an implementation of a protocol, add `//@Mockable` above the protocol declaration.

Then run `MockGen` from the directory that was assumed in Setup

Limitations
-----------

MockGen currently only generates implementations for `var` and `func`. `init` is not supported.

Generic functions are not supported because creating the correct default implementation is too difficult. It will instead create a placeholder that doesn't compile asking for an implementation.
