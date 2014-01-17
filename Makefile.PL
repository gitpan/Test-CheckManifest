
use strict;
use warnings;



use ExtUtils::MakeMaker 6.30;



my %WriteMakefileArgs = (
  "ABSTRACT" => "Check if your Manifest matches your distro",
  "AUTHOR" => "Renee Baecker <reneeb\@cpan.org>",
  "BUILD_REQUIRES" => {},
  "CONFIGURE_REQUIRES" => {
    "ExtUtils::MakeMaker" => "6.30"
  },
  "DISTNAME" => "Test-CheckManifest",
  "EXE_FILES" => [],
  "LICENSE" => "artistic_2",
  "NAME" => "Test::CheckManifest",
  "PREREQ_PM" => {
    "Carp" => 0,
    "Cwd" => 0,
    "File::Basename" => 0,
    "File::Find" => 0,
    "File::Spec" => 0,
    "Test::Builder" => 0
  },
  "TEST_REQUIRES" => {},
  "VERSION" => "1.27",
  "test" => {
    "TESTS" => "t/*.t t/extra/*.t t/xt/*.t"
  }
);


unless ( eval { ExtUtils::MakeMaker->VERSION(6.63_03) } ) {
  my $tr = delete $WriteMakefileArgs{TEST_REQUIRES};
  my $br = $WriteMakefileArgs{BUILD_REQUIRES};
  for my $mod ( keys %$tr ) {
    if ( exists $br->{$mod} ) {
      $br->{$mod} = $tr->{$mod} if $tr->{$mod} > $br->{$mod};
    }
    else {
      $br->{$mod} = $tr->{$mod};
    }
  }
}

unless ( eval { ExtUtils::MakeMaker->VERSION(6.56) } ) {
  my $br = delete $WriteMakefileArgs{BUILD_REQUIRES};
  my $pp = $WriteMakefileArgs{PREREQ_PM};
  for my $mod ( keys %$br ) {
    if ( exists $pp->{$mod} ) {
      $pp->{$mod} = $br->{$mod} if $br->{$mod} > $pp->{$mod};
    }
    else {
      $pp->{$mod} = $br->{$mod};
    }
  }
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);



