# $Id: Makefile.PL,v 0.1 2004/10/25 10:08:25 dann Exp $
use strict;
use ExtUtils::MakeMaker;

WriteMakefile(
    'NAME'          => 'AI::Memory::Associative::Bidirectional',
    'VERSION_FROM'  => 'lib/AI/Memory/Associative/Bidirectional.pm',
    'DISTNAME'      => 'AI-Memory-Associative-Bidirectional',
    'PREREQ_PM'     => { 'Test::Simple' => 0.41 },
    'dist'          => { COMPRESS => 'gzip --best', SUFFIX => 'gz' },
    ($] >= 5.005 ? (
      'AUTHOR'        => 'Danne Stayskal <dann@doulopolis.net>',
      'ABSTRACT_FROM' => 'lib/AI/Memory/Associative/Bidirectional.pm',
    ) : () )
);
