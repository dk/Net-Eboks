use strict;
use warnings;
use ExtUtils::MakeMaker;
WriteMakefile(
	NAME           => 'Net::Eboks',
	AUTHOR         => 'Dmitry Karasik <dmitry@karasik.eu.org>',
	ABSTRACT_FROM  => 'Eboks.pm',
	VERSION_FROM   => 'Eboks.pm',
	EXE_FILES         => ['bin/eboks2pop'],
	PREREQ_PM      => { 
		'LWP'          => 0,
		'DateTime'     => 0,
		'IO::Lambda'   => 1.26,
		'MIME::Entity' => 0,
		'XML::Simple'  => 0,
		'Getopt::Long' => 0,
		'Digest::SHA'  => 0,
	},
	META_MERGE     => {
		resources => {
			repository => 'http://github.com/dk/Net-Eboks'
		},
	},
);
