
Note: This should be forked off of the codebase created by base.md

If you want to define more complex tests somewhere other than `tests.u`, just `load my-tests.u` then `add`,
then reference those tests (which should be of type `'{IO,Exception,Tests} ()`, written using calls
to `Tests.check` and `Tests.checkEqual`).

TODO remove md5 alias when base is released
```ucm
.> run tests

  💔💥
  
  I've encountered a call to builtin.bug with the following
  value:
  
    "test suite failed"
  
  
  Stack trace:
    bug
    #nemf56vdul

```



🛑

The transcript failed due to an error in the stanza above. The error is:


  💔💥
  
  I've encountered a call to builtin.bug with the following
  value:
  
    "test suite failed"
  
  
  Stack trace:
    bug
    #nemf56vdul

