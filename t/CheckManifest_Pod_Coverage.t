# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Test-TestCoverage.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test::More;

SKIP:{
    eval "use Test::Pod::Coverage";
    skip "Test::Pod::Coverage required",1 if $@;
    plan tests => 1;
    pod_coverage_ok("Test::CheckManifest");
}


