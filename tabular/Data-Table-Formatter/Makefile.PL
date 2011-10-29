use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Data::Table::Formatter',
    AUTHOR              => q{Dann Stayskal <dann@stayskal.com>},
    VERSION_FROM        => 'lib/Data/Table/Formatter.pm',
    ABSTRACT_FROM       => 'lib/Data/Table/Formatter.pm',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Data-Table-Formatter-*' },
);
