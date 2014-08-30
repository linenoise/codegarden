package Tinhorn::View::Bread;

use strict;

=head1 NAME

Tinhorn::View::Bread - The Tinhorn /instrument view

=head1 SYNOPSIS

	### Meanwhile, back in Tinhorn::App::Webserver::Router
	use Tinhorn::View::Bread;
	load_routes_from(%Tinhorn::View::Bread::routes);
	
=head1 DESCRIPTION

This view-layer module allows a user to BREAD (Browse, Read, Edit, Add, and Delete) data model objects

=head1 METHODS

=over 4

=cut

use Tinhorn::Model;
use Tinhorn::View qw/render clean_alpha clean_alphanumeric clean_numeric/;
use base qw(Tinhorn::View);

our %routes = (
	'/bread'			 => *index,
	
	### BREAD
	'/bread/browse'		 => *browse,
	'/bread/read'		 => *read,
	'/bread/edit'		 => *edit,
	'/bread/add'		 => *add,
	'/bread/delete'		 => *delete,
	
	### CUR
	'/bread/create'		 => *create,
	'/bread/update'		 => *update,
	'/bread/remove'		 => *remove,
);


our %schema = (
	'Country' => {
		model			 => 'Tinhorn::Model::Country',
		fields			 => ['name', 'code', 'currency_id'],
	},
	'Currency' => {
		model			 => 'Tinhorn::Model::Currency',
		fields			 => ['name', 'code', 'exponent'],
	},
	'Exchange' => {
		model			 => 'Tinhorn::Model::Exchange',
		fields			 => ['name', 'country_id', 'symbol', 'google_symbol', 'reuters_symbol', 'yahoo_symbol'],
		browse_columns	 => ['name', 'country_id', 'symbol'],
	},
	'Instrument' => {
		model			 => 'Tinhorn::Model::Instrument',
		fields			 => ['name', 'instrument_type', 'exchange_id', 'currency_id', 'symbol', 'description', 
							 'home_url', 'wikipedia_url', 'dukascopy_code'],
		browse_columns	 => ['name', 'instrument_type', 'exchange_id', 'symbol'],
	},
);


=item C<index>

/bread - The main breader index 

=cut
sub index {
	my ($cgi) = @_;
	my ($http_code, $content) = ('200', '');
	
	### What can I bread, sir?  Yes, bread is now a verb.
	my @models = sort keys %schema;
	my $vars = {
		models => \@models
	};
	
	$content = render('bread.tt', $vars);
	return {
		home 			=> $http_code,
		content_type	=> 'text/html',
		content 		=> $content,
	};
}


=item C<browse>

/bread/browse - The breader browser

=cut
sub browse {
	my ($cgi) = @_;
	my ($http_code, $content, $vars) = ('200', '', {});

	my $vars->{model} = clean_alpha($cgi->param('m'));
	if ($vars->{model}) {
		
		my $schema = $schema{$vars->{model}};
		if (ref $schema eq 'HASH') {
			
			my @objects = $schema->{model}->retrieve_all();
			
			$vars->{columns} = $schema->{browse_columns} || $schema->{fields};
			$vars->{objects} = \@objects;
			
			$content = render('bread/browse.tt', $vars);

		} else {
			$content = "No schema defined for $vars->{model}";
		}
	} else {
		$content = "No model provided";
	}
	
	return {
		home 			=> $http_code,
		content_type	=> 'text/html',
		content 		=> $content,
	};
}


=item C<read>

/bread/browse - The breader reader

=cut
sub read {
	my ($cgi) = @_;
	my ($http_code, $content, $vars) = ('200', '', {});

	$vars->{model} = clean_alpha($cgi->param('m'));
	if ($vars->{model}) {
		
		$vars->{id} = clean_numeric($cgi->param('id'));
		if ($vars->{id}) {

			my $schema = $schema{$vars->{model}};
			if (ref $schema eq 'HASH') {
			
				$vars->{object} = $schema->{model}->retrieve($vars->{id});			
				$vars->{columns} = $schema->{fields};
			
				$content = render('bread/read.tt', $vars);

			} else {
				use Data::Dumper;
				$content = "No schema defined for $vars->{model}".Dumper($cgi->param);
			}
		} else {
			$content = "No ID provided";
		}
	} else {
		$content = "No model provided";
	}
	
	return {
		home 			=> $http_code,
		content_type	=> 'text/html',
		content 		=> $content,
	};
}


=item C<edit>

/bread/browse - The breader editor

=cut
sub edit {
	my ($cgi) = @_;
	my ($http_code, $content, $vars) = ('200', '', {});

	$vars->{model} = clean_alpha($cgi->param('m'));
	if ($vars->{model}) {
		
		$vars->{id} = clean_numeric($cgi->param('id'));
		if ($vars->{id}) {

			my $schema = $schema{$vars->{model}};
			if (ref $schema eq 'HASH') {
			
				$vars->{object} = $schema->{model}->retrieve($vars->{id});	
				if ($vars->{object}) {
					
					$vars->{columns} = $schema->{fields};

					### Preload $vars->{foreigns}
					foreach my $column (@{$vars->{columns}}) {
						my $model = '';
						if ($column =~ /^(.*)_id$/) {
							$model = ucfirst($1);

							my $foreign_schema = $schema{$model};
							if (ref $foreign_schema eq 'HASH') {

								my @objects = $foreign_schema->{model}->retrieve_all();
								$vars->{foreigns}->{$1} = \@objects;
							}
						}
					}	
					$content = render('bread/edit.tt', $vars);
					
				} else {
					$content = "No $vars->{model} at ID $vars->{id}";
				}
			} else {
				$content = "No schema defined for $vars->{model}";
			}
		} else {
			$content = "No ID provided";
		}
	} else {
		$content = "No model provided";
	}
	
	return {
		home 			=> $http_code,
		content_type	=> 'text/html',
		content 		=> $content,
	};
}


=item C<add>

/bread/browse - The breader adder

=cut
sub add {
	my ($cgi) = @_;
	my ($http_code, $content, $vars) = ('200', '', {});

	$vars->{model} = clean_alpha($cgi->param('m'));
	if ($vars->{model}) {
		
		my $schema = $schema{$vars->{model}};
		if (ref $schema eq 'HASH') {

			$vars->{columns} = $schema->{fields};		

			### Preload $vars->{foreigns}
			foreach my $column (@{$vars->{columns}}) {
				my $model = '';
				if ($column =~ /^(.*)_id$/) {
					$model = ucfirst($1);

					my $foreign_schema = $schema{$model};
					if (ref $foreign_schema eq 'HASH') {

						my @objects = $foreign_schema->{model}->retrieve_all();
						$vars->{foreigns}->{$1} = \@objects;
					}
				}
			}	

			$content = render('bread/add.tt', $vars);
				
		} else {
			$content = "No schema defined for $vars->{model}";
		}
	} else {
		$content = "No model provided ".$cgi->param('m');
	}

	return {
		home 			=> $http_code,
		content_type	=> 'text/html',
		content 		=> $content,
	};
}


=item C<delete>

/bread/delete - The breader deleter

=cut
sub delete {
	my ($cgi) = @_;
	my ($http_code, $content, $vars) = ('200', '', {});

	$vars->{model} = clean_alpha($cgi->param('m'));
	if ($vars->{model}) {
		
		$vars->{id} = clean_numeric($cgi->param('id'));
		if ($vars->{id}) {

			my $schema = $schema{$vars->{model}};
			if (ref $schema eq 'HASH') {
			
				$vars->{object} = $schema->{model}->retrieve($vars->{id});	
				if ($vars->{object}) {
					
					$content = render('bread/delete.tt', $vars);
					
				} else {
					$content = "No $vars->{model} at ID $vars->{id}";
				}
			} else {
				$content = "No schema defined for $vars->{model}";
			}
		} else {
			$content = "No ID provided";
		}
	} else {
		$content = "No model provided";
	}
	
	return {
		home 			=> $http_code,
		content_type	=> 'text/html',
		content 		=> $content,
	};
}


=item C<create>

/bread/browse - The breader creator

=cut
sub create {
	my ($cgi) = @_;
	my ($http_code, $content, $vars) = ('200', '', {});

	$vars->{model} = clean_alpha($cgi->param('m'));
	if ($vars->{model}) {
		
		my $schema = $schema{$vars->{model}};
		if (ref $schema eq 'HASH') {

			my $properties = {};
			foreach my $param ($cgi->param()) {
				if ($param =~ /^value_(.*)$/) {
					next if $1 eq 'id';
					$properties->{$1} = $cgi->param($param);
				}
			}
			if(my $object = $schema->{model}->insert($properties)) {

				$cgi->param('id', $object->{id});
				return Tinhorn::View::Bread::read($cgi);

			} else {
				$content = "Object could not be inserted into DB:".$DBI::errstr;
			}
		} else {
			$content = "No schema defined for $vars->{model}";
		}
	} else {
		$content = "No model provided ".$cgi->param('m');
	}

	return {
		home 			=> $http_code,
		content_type	=> 'text/html',
		content 		=> $content,
	};
}


=item C<update>

/bread/browse - The breader updater

=cut
sub update {
	my ($cgi) = @_;
	my ($http_code, $content, $vars) = ('200', '', {});

	$vars->{model} = clean_alpha($cgi->param('m'));
	if ($vars->{model}) {
		
		$vars->{id} = clean_numeric($cgi->param('id'));
		if ($vars->{id}) {

			my $schema = $schema{$vars->{model}};
			if (ref $schema eq 'HASH') {
			
				$vars->{object} = $schema->{model}->retrieve($vars->{id});	
				if ($vars->{object}) {
					
					$vars->{columns} = $schema->{fields};
					foreach my $column (@{$vars->{columns}}) {
						if (my $new_value = $cgi->param("value_".$column)) {
							$vars->{object}->set($column => $new_value);
						}
					}
					
					if ($vars->{object}->update){
						return Tinhorn::View::Bread::read($cgi);
						
					} else {
						$content = "Object couldn't be updated: ".$DBI::errstr;
					}
				} else {
					$content = "No $vars->{model} at ID $vars->{id}";
				}
			} else {
				$content = "No schema defined for $vars->{model}";
			}
		} else {
			$content = "No ID provided";
		}
	} else {
		$content = "No model provided ".$cgi->param('m');
	}

	return {
		home 			=> $http_code,
		content_type	=> 'text/html',
		content 		=> $content,
	};
}


=item C<remove>

/bread/browse - The breader remover

=cut
sub remove {
	my ($cgi) = @_;
	my ($http_code, $content, $vars) = ('200', '', {});

	$vars->{model} = clean_alpha($cgi->param('m'));
	if ($vars->{model}) {
		
		$vars->{id} = clean_numeric($cgi->param('id'));
		if ($vars->{id}) {

			my $schema = $schema{$vars->{model}};
			if (ref $schema eq 'HASH') {
			
				$vars->{object} = $schema->{model}->retrieve($vars->{id});	
				if ($vars->{object}) {
					
					if ($vars->{object}->delete) {						
						return Tinhorn::View::Bread::browse($cgi);
						
					} else {
						$content = "Object couldn't be deleted: ".$DBI::errstr;
					}
				} else {
					$content = "No $vars->{model} at ID $vars->{id}";
				}
			} else {
				$content = "No schema defined for $vars->{model}";
			}
		} else {
			$content = "No ID provided";
		}
	} else {
		$content = "No model provided ".$cgi->param('m');
	}

	return {
		home 			=> $http_code,
		content_type	=> 'text/html',
		content 		=> $content,
	};
}




=back

=head1 COPYRIGHT

Copyright 2007-2010 by Danne Stayskal.  All rights reserved.

=cut

1;
__END__