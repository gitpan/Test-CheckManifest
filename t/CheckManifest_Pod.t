# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Test-TestCoverage.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test::More;
use FindBin ();

SKIP:{
    eval "use Test::Pod 1.00";
    skip "Test::Pod 1.00 required",1 if $@;
    my $path_to_pods = $FindBin::Bin . '/../blib/lib/Test/';
    my @poddirs = ($path_to_pods);
    all_pod_files_ok(all_pod_files(@poddirs));
}


#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

