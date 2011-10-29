use Module::Build;

my $b = Module::Build->new (
	module_name => 'Net::Automation',
	dist_author => 'Dann Stayskal <dann@cpan.org>',
	dist_version => '0.01',
	license => 'gpl',
	requires => {
		'Data::Dumper' => '0',
		'YAML',
		'Getopt::Long',
		'Quantum::Superpositions',
	},
	recommends => {
		'Test::Pod' => '1.0',
		'Test::Pod::Coverage' => '1.0',
	},
	build_requires => {
		'Test::More' => '0',
	},
	create_makefile_pl => 'traditional',
	add_to_cleanup => [
		'Makefile', 'blib', 'pm_to_blib', 'blibdirs', 'Build', 'Build.bat', '_build', 'Build.COM', 'BUILD.COM', 'build.com', 'coder_db'
	],
);

$b->create_build_script;
