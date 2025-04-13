# Testing Tools Survey

A. Broad Overview

 1. Joy of Testing

 1. Who I am

 1. Scope
   
   - Unit tests in.
   - Statistical tests out.

 1. Your expectations

   - From other languages
   - From Julia as symbolic/numeric

 1. What we see in statistics of usage

   * About 70-80 testing-specific packages out of 12,000 projects.
   * Pytest has 1487 plugins out of 625,000 projects.

 1. Principle SOCK

B. Categorical exposition


 1. Ways to use tests

   - Debugging
   - Development - Revise, LiveServer interactive https://github.com/JuliaQuantumControl/GRAPE.jl/blob/46577e855edca6b1f67d6f4007d79a07a8c3505d/test/init.jl#L9
   - Regression
   - Performance - TimerOutputs, BenchmarkTools, PkgBenchmark
   - Documentation - @doc of a function., DocInventories

   Categories from the ISTQB

  - Test generation, finding them, selection, tests of what, tests when.
  - Chosen by hand.


 1. People reuse the test project.toml for interactive tools they don't want in the main repo.

   - For example, calculating coverage or performing peformance regressions. ChairMarks.
   - Weave
   - PackageCompiler to create a system image.


 1. Alternative test interface

  Picture with each inroad, all interactions.

  - ImGuiTestEngine
  - PlutoTest
  - TestFunctionRunner - to include doctests, 2021
  - TerminalRegressionTest
  - VisualStudio plugin

 1. Different places to find the tests

  Picture with each inroad again, all static files.

  - NarrativeTest
  - TestReadme
  - NBInclude


 1. IO options
   Fan-out of all the file types.

   - JLD2, Tables, CSV, JSON, FileIO, Serialization, HDF5, Arrow, BSON, Tar, ZipFile, XLSX, SQLite, EzXML, NetCDF, NPZ
  
   More-detailed info on each way to get artifacts. Maybe all the starting locations.
   - DataDeps, RemoteFiles, Download, Artifacts, DataDrop, AWSS3


 1. Unusual types

   Test your code's generality by throwing oddballs at it from other packages.
   AKA an integration test.

   - Strength in Julia's ability to mix packages through multiple dispatch and duck typing.
   - SparseArrays, OffsetArrays, Unitful, PooledArrays, Strided


 1. Fixtures

   - Scratch.jl scratch space
   - DotEnv load environment variables from a file


 1. Test case generation

   - Faker


 1. Introspection

    - MacroTools
    - Functors
    - InteractiveUtils


 1. Visibility

   - Reexport to see all variables in a module.
   - Accessors to un-immutable, and Setfield, UnPack, BangBang
   - Suppressor to catch warnings, IOCapture, LoggingExtras
   - ArgParse to mock main calls
   - Observers injects subject-observer pattern into a loop

 1. Data handling

   - Accessors to update immutable data.

 1. Expanding test assertions

    - IntervalSets to check containment, DomainSets. Intervals.
    - Hashing
    - DeepDiffs
    - AllocCheck
    - StructEquality
    - BranchTests, 2021-04-17, 2
      * 248 loc
      * Adds to the kinds of @testset.
      * Nice idea to create multiple tests that are branches of a narrative.
  - RandomizedPropertyTest, 2021
    * 286 loc
    * It's quickcheck as a macro in Julia. Outside of tests.

 1. Tests of typing

  - JET
  

 1. Sample data

   - FormatSpecimens
   - TestImages
   - MatrixDepot


 1. Tests of package management

   - Macro introspection with MacroTools.

 1. Tests of coverage

   - By-test coverage difficult to do.

  1. Plugin to Test.jl

  - DotTestSets, 2020-12-13, 1
    * 79 loc
    * Custom TestSet type to work with Test.jl.
    * Nice idea to report test progress with little dots.
  - Maracas, 2020-12-13, 1
    * 401 loc
    * Extends base Test.jl
    * Improves the reporting of test results.
    * Short README as a doc.
  - TestSetExtensions, 2025-03-04, 43
    * 230 loc
    * Nice idea to make output readable with colors, dots, diffs.

 1. Frameworks

  Have to explain first that the usual Test.jl executes tests as they are found.

  - AssociatedTests, 2024-08-12, 2
    * Had a nice idea for defining a test within the code without polluting the namespace.
    * 61 loc
  - Jute, 2023-07-25, 13 - introduces compatibility problem with ArgParse.
    * 2283 loc
    * Collects test cases first, then lets you choose them.
    * Complete framework.
  - NestedTests, 2023-08-05, 1
    * 797 loc
    * Nice idea to put setup and teardown in nested scope.
    * Just a few functions that replace Test.jl
  - Pukeko, 2023-03-01, 15
    * 343 loc
    * Nice idea to use plain old functions and modules as tests.
    * Start names with "test_*".
    * Runs in parallel across test files.
  - ReTestItems, 2025-04-06, 30
    * 5457 loc
    * Uses @testitems but focuses on selecting tests and running them in parallel.
    * Different people from ReTest but in the same "JuliaTesting" group.
  - ReTest, 2025-03-13, 111
    * 4280 loc
    * Tests in source files. Filter testsets with Regex. Shuffle test order.
    * Test again when Revise detects changes.
    * Run tests in parallel.
  - TestItemRunner, 2025-04-04, 81
    * 194 loc
    * Uses JuliaSyntax and TestItemDetection (179 loc)
    * Finds test macros in source and runs them.
    * Nice idea to make a test macro that evaluates to nothing.
  - TestTools, 2025-02-21, 2
    * 2797
    * Works within Test.jl but a lot of added features.
    * Uses Coverage, CoverageTools, JuliaFormatter, TestSetExtensions, SafeTestsets, jlpkg.
    * Installs a separate test runner.
    * Maybe a single person effort?
  - TidyTest, 2024-12-16, 10
    * 212 loc
    * Nice idea expand AbstractTestSet to allow filtering tests.
  - XUnit, 2024-10-31, 47
    * 2910 loc
    * Run tests, shuffled, parallel, distributed, subsetted
    * JUnit reporting.
    * 10 contributers.

  - FactCheck, 9 years ago
  - Jig, nope, 12 years ago
  - JulieTest, 9 years ago
  - PyTest, 7 years ago
  - RunTests, 9 years
  - Saute, 13 years ago

 1. Mathy Stuff

   - Solvers like JuMP, HiGHS, Optim, GLPK
   - ChainRulesTestUtils, Automatic differentiation Zygote
   - Symbolics, DoubleFloats, FixedPointNumbers, IntervalArithmetic, SymPy
   - Measurements uncertainty propagation
   - StatisticalMeasures.jl, OnlineStats.jl, MonteCarloMeasurements.jl
   - PythonCall, RCall, MAT (Matlab), Conda, libdl


C. What everybody knows

 1. Most popular to use


D. What's missing

 1. No counting of test dependencies on package usage.

 1. Hard to see what's popular

   - I had to download every Project.toml and test/Project.toml
   - No sorting on JuliaHub
   - Missing packages on julia packages.com

 1. Where are automated unit test generation tools? Maybe AI?

 1. Python loves...

   - Fixtures
   - Plugins

 1. Agreement on frameworks would be empowering


Last. Broad Conclusion

 1. Limitations

 1. Go forth!
