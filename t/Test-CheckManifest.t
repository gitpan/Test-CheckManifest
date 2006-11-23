#!/usr/bin/perl -T

use strict;
use warnings;
use File::Spec;
use File::Basename;
use Test::More tests => 10;

use_ok('Test::CheckManifest');
ok_manifest();

# create a directory and a file 
my $home = dirname(File::Spec->rel2abs($0));

# untaint
if ($home =~ /^([-\@\w.\/\\]+)$/) {
    $home = $1;
} 
else {
    die "Bad data in $home"; 
}

my $dir  = $home . '/.svn/';
my $dir2 = $home . '/test/';

mkdir $dir;

my $fh;
my ($file1,$file2,$file3) = ($dir.'test.txt', $home . '/test.svn', $dir2.'hallo.txt');
open $fh ,'>',$file1 and close $fh;
open $fh ,'>',$file2 and close $fh;

Test::CheckManifest::_not_ok_manifest('expected: Manifest not ok');
ok_manifest({filter => [qr/\.svn/]},'Filter: \.svn');
Test::CheckManifest::_not_ok_manifest({exclude => ['/t/.svn/']},'expected: Manifest not ok (Exclude /t/.svn/)');

mkdir $dir2;
open $fh ,'>',$file3 and close $fh;
Test::CheckManifest::_not_ok_manifest({filter => [qr/\.svn/]},'Filter: \.svn');
Test::CheckManifest::_not_ok_manifest({exclude => ['/t/.svn/']},'expected: Manifest not ok (Exclude /t/.svn/) [2]');
Test::CheckManifest::_not_ok_manifest({filter => [qr/\.svn/], exclude => ['/t/.svn/']},'expected: Manifest not ok (exclude OR filter)');
Test::CheckManifest::_not_ok_manifest({filter  => [qr/\.svn/],
                                       bool    => 'and',
                                       exclude => ['/test']}, 'filter AND exclude');
ok_manifest({filter  => [qr/\.svn/],
             exclude => ['/test']}, 'filter OR exclude');

unlink $file1, $file2, $file3;
rmdir  $dir;
rmdir  $dir2;


