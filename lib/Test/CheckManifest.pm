package Test::CheckManifest;

use strict;
use warnings;

use Cwd;
use Carp;
use File::Spec;
use File::Basename;
use Test::Builder;
use File::Find;

our $VERSION = '0.8';

my $test = Test::Builder->new();
my $test_bool = 1;

sub import {
    my $self = shift;
    my $caller = caller;

    for my $func ( qw( ok_manifest ) ) {
        no strict 'refs';
        *{$caller."::".$func} = \&$func;
    }

    $test->exported_to($caller);
}

sub ok_manifest{
    my ($hashref,$msg)    = @_;
    
    my $is_hashref = 1;
    $is_hashref = 0 unless ref $hashref;
    
    $msg = $hashref unless $is_hashref;
    
    my $bool     = 1;
    my $dir      =
    my $home     = Cwd::realpath(dirname(File::Spec->rel2abs($0)) . '/..');    
    my $manifest = Cwd::realpath($home . '/MANIFEST');
    
    my @missing_files = ();
    my @files_plus    = ();
    my $arref         = ['/blib'];
    my $filter        = $is_hashref ? $hashref->{filter}  : [];
    my $comb          = $is_hashref && 
                        $hashref->{bool} && 
                        $hashref->{bool} =~ m/^and$/i ?
                               'and' :
    			       'or'; 
			       
    push @$arref, @{$hashref->{exclude}} if($is_hashref and
                                            exists $hashref->{exclude} and 
                                            ref $hashref->{exclude} eq 'ARRAY');
    
    for(@$arref){
        croak 'path in excluded array must be "absolut"' unless m!^/!;
	my $path = $home . $_;
        $_ = Cwd::realpath($path);
	croak "invalid path: $path" unless defined;
    }
    
    @$arref = grep { defined }@$arref;
    
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
    
        my (@dir_files,%files_hash,%excluded);
	@files_hash{@files} = ();
	
        find({no_chdir => 1,
          wanted   => sub{ my $file         = $File::Find::name;
	                   my $is_excluded  = _is_excluded($_,$arref,$filter,$comb);
                           push(@dir_files,Cwd::realpath($file)) if -f $File::Find::name 
                                                                    and !$is_excluded;
                           $excluded{$file} = 1 if -f $File::Find::name 
			                           and $is_excluded}},$home);

	
        #print STDERR Dumper(\@files,\@dir_files);
        CHECK: for my $file(@dir_files){
            for my $check(@files){
	        if($file eq $check){
		    delete $files_hash{$check};
                    next CHECK;
		}
            }
            push(@missing_files,$file);
            $bool = 0;
        }
	
	delete $files_hash{$_} for keys %excluded;
	@files_plus = keys %files_hash;
	$bool = 0 if scalar @files_plus > 0;	
    }
    
    my $diag = 'The following files are not named in the MANIFEST file: '.
               join(', ',@missing_files);
    my $plus = 'The following files are not part of distro but named in the MANIFEST file: '.
               join(', ',@files_plus);
    
    $test->is_num($test_bool,$bool,$msg);
    $test->diag($diag) if scalar @missing_files >= 1 and $test_bool == 1;
    $test->diag($plus) if scalar @files_plus    >= 1 and $test_bool == 1;
}

sub _not_ok_manifest{
    $test_bool = 0;
    ok_manifest(@_);
}

sub _is_excluded{
    my ($file,$dirref,$filter,$bool) = @_;
    my @excluded_files = qw(pm_to_blib Makefile META.yml);
        
    my   @matches = grep{$file =~ /$_$/    }@excluded_files;
    
    if($bool eq 'or'){
        push @matches, $file if grep{ref $_ and ref $_ =~ /Regexp/ and $file =~ $_}@$filter;
        push @matches, $file if grep{not ref $_ and $file =~ /^\Q$_\E/}@$dirref;
    }
    else{
        if(grep{$file =~ $_ and ref $_ and ref $_ =~ /Regexp/}@$filter and
	   grep{$file =~ /^\Q$_\E/ and not ref $_}@$dirref){
	    push @matches, $file;
	}
    }
    
    return scalar @matches;
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

=head2 ok_manifest   [{exlude => $arref}][$msg]

checks whether the Manifest file matches the distro or not. To match a distro
the Manifest has to name all files that come along with the distribution.

To check the Manifest file, this module searches for a file named C<MANIFEST>.

To exclude some directories from this test, you can specify these dirs in the
hashref.

  ok_manifest({exclude => ['/var/test/']});

is ok if the files in C</path/to/your/dist/var/test/> are not named in the
C<MANIFEST> file. That means that the paths in the exclude array must be
"pseudo-absolute" (absolute to your distribution).

To use a "filter" you can use the key "filter"

  ok_manifest({filter => [qr/\.svn/]});

With that you can exclude all files with an '.svn' in the filename or in the
path from the test.

These files would be excluded (as examples):

=over 4

=item * /dist/var/.svn/test

=item * /dist/lib/test.svn

=back

You can also combine "filter" and "exclude" with 'and' or 'or' default is 'or':

  ok_manifest({exclude => ['/var/test'], 
               filter  => [qr/\.svn/], 
	       bool    => 'and'});

These files have to be named in the C<MANIFEST>:

=over 4

=item * /var/foo/.svn/any.file

=item * /dist/t/file.svn

=item * /var/test/test.txt

=back

These files not:

=over 4

=item * /var/test/.svn/*

=item * /var/test/file.svn

=back

=head1 AUTHOR

Renee Baecker, E<lt>module@renee-baecker.deE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2006 by Renee Baecker

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.6 or,
at your option, any later version of Perl 5 you may have available.


=cut
