Found some bugs...

* Clean-up.  If a test fails or is killed or unstub is not call for some reason, plan and run files persist and are picked up/added to next time, causing spurious failures.
* `unstub` (and maybe `stub`) don't work when called from setup/teardown.
* Error reporting.  Stubbing can cause a test to fail in several places, the default error report is not particularly useful.  We can't echo errors at the time they occur because we might be inside a bats `run()` call.  Therefore we should save error reports and print them as part of the unstub.
* The fact that `binstub` is something of a god object is a bit shit, some refactoring of the code could make it easier to follow perhaps.
* Whitespace in expectations causes arguments to not match.  See dot-files/tests/bin/test_dev-push-all.bats; ssh stub doesn't work, perhaps args args are too complex?
* Wildcard argument expectations.  Actually this works?  Add tests for it and add it to the documentation either way.
* No ability to mock out an executable and expect it NOT to be called.  A-la gtest's `.Times(0)` or similar.  Intuatively, `stub prog.exe` without any expectation arguments should do that.  More generally, how about the ability to match an expectation multiple times?
* Fall back execution.  On non-matching call to mocked process, fall back to calling underlying executable.
