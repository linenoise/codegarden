use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Tabular::Format',
    AUTHOR              => q{Danne Stayskal <danne@stayskal.com>},
    VERSION_FROM        => 'lib/Tabular/Format.pm',
    ABSTRACT_FROM       => 'lib/Tabular/Format.pm',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Tabular-Format-*' },
);
