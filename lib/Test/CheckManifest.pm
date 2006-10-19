package Test::CheckManifest;

use strict;
use warnings;
use FindBin ();
use Test::Builder;
use File::Find;
use Cwd;
use base qw(Exporter);

our @EXPORT = qw(ok_manifest);
our $VERSION = '0.4';

my $test = Test::Builder->new();

sub ok_manifest{
    my ($msg)    = @_;
    
    my $bool     = 1;
    my $home     = Cwd::realpath($FindBin::Bin . '/..');    
    my $manifest = Cwd::realpath($home . '/MANIFEST');
    
    my @missing_files = ();
    
    unless( open(my $fh,'<',$manifest) ){
        $bool = 0;
        $msg  = "can't open $manifest";
    }
    else{
        my @files = <$fh>;
        close $fh;
    
        chomp @files;
    
        {
            local $/ = "\r";
            chomp @files;
        }
    
        for my $tfile(@files){
            $tfile = (split(/\s{2,}/,$tfile,2))[0];
            $tfile = Cwd::realpath($home . '/' . $tfile);
        }
    
        my @dir_files;
        find(sub{push(@dir_files,Cwd::realpath($File::Find::name)) if -f $File::Find::name 
                                                                     and $File::Find::name !~ m!/blib/!
                                                                     and !_is_excluded($_)},$home);

        #print STDERR Dumper(\@files,\@dir_files);
        CHECK: for my $file(@dir_files){
            for my $check(@files){
                next CHECK if $file eq $check;
            }
            push(@missing_files,$file);
            $bool = 0;
        }
    }
    
    my $diag = 'The following files are not named in the MANIFEST file: '.
               join(', ',@missing_files);
    
    $test->cmp_ok($bool,'==',1,$msg);
    $test->diag($diag) if scalar(@missing_files) >= 1;
}

sub _is_excluded{
    my ($file) = @_;
    my @excluded_files = qw(pm_to_blib Makefile META.yml);
    
    return scalar grep{$_ eq $file}@excluded_files;
}

1;
__END__

=head1 NAME

Test::CheckManifest - Check if your Manifest matches your distro

=head1 SYNOPSIS

  use Test::CheckManifest;
  ok_manifest();

=head1 DESCRIPTION

C<Test::CheckManifest>

=head2 EXPORT

There is only one method exported: C<ok_manifest>

=head1 METHODS

=head2 ok_manifest [$msg]

checks whether the Manifest file matches the distro or not. To match a distro
the Manifest has to name all files that come along with the distribution.

To check the Manifest file, this module searches for a file named C<MANIFEST>.

=head1 AUTHOR

Renee Baecker, E<lt>module@renee-baecker.deE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2006 by Renee Baecker

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.6 or,
at your option, any later version of Perl 5 you may have available.


=cut
