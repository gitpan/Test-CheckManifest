#!/usr/bin/perl

use strict;
use warnings;
use FindBin ();
use Test::More;

eval "use Test::Pod 1.00";
plan skip_all => "Test::Pod 1.00 required" if $@;
all_pod_files_ok();