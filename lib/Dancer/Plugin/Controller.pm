package Dancer::Plugin::Controller;

our $VERSION = '0.01';

=head1 NAME

Dancer::Plugin::Controller - interface between a model and view

=cut

=head1 SYNOPSIS

	# YourApp.pm

	use Dancer ':syntax';
	use Dancer::Plugin::Controller;

	get '/' => sub { 
		controller(action => 'Index', template => 'index');
	};


	# YourApp::Action::Index.pm
	
	sub main {
		my ($class, $params) = @_; # $params - contains Dancer::params() and Dancer::vars()

		...

		return $template_params_hashref;
	}


	# config.yml

	plugins:
		"Controller":
			# this is prefiix for module with implementation of action
			action_prefix: 'MyActionPrefix' # default: 'Action'
			# if you have problems with utf8, you may try use this option
			force_utf8: 1 # default: 0

=cut


use strict;
use warnings;
use utf8;

use Dancer ':syntax';
use Dancer::Plugin;


sub _template {
	my ($force_utf8, @params) = @_;

	if ($force_utf8) {
		my $content = Dancer::template(@params);
		utf8::decode($content);
		return $content;
	}
	else {
		return Dancer::template(@params);
	}
}

register controller => sub {
	my ($self, %params) = plugin_args(@_);

	my $template_name = $params{template} || '';
	my $action_name = $params{action} || '';
	
	my $conf = plugin_setting();
	my $action_prefix = $conf->{action_prefix} || 'Action';
	my $force_utf8 = $conf->{force_utf8} || 0;

	my $action_class = sprintf('%s::%s::%s', Dancer::config->{appname}, $action_prefix, $action_name);
	my $action_params = {
		Dancer::params(),
		%{Dancer::vars()}
	};

	# Если задан шаблон - возращаем результат рендера
	# Если шаблона не задан - возвращаем реультат экшена
	if ($template_name) {
		return _template( 
			$force_utf8,
			$template_name,
			$action_name
				? $action_class->main($action_params)
				: {}
		);
	}
	else {
		return $action_class->main($action_params);
	}
};

register_plugin;


1;

=head1 AUTHOR

Mikhail N Bogdanov C<< <mbogdanov at cpan.org> >>

=cut
