package Dancer2::Template::Xslate;

use v5.10;
use strict;
use warnings FATAL => "all";
use utf8;

use Carp;
use Moo;
use Dancer2::Core::Types;
use Dancer2::FileUtils qw(read_file_content);
use File::Spec::Functions qw(splitpath);
use Text::Xslate;

# VERSION
# ABSTRACT: Text::Xslate template engine for Dancer2

with "Dancer2::Core::Role::Template";

has "+engine" => (
    isa => InstanceOf["Text::Xslate"]
);
has "+default_tmpl_ext" => (
    default => sub {"tx"},
);

sub _build_engine {
    my ($self) = @_;

    my %config = %{ $self->config };
    delete $config{environment}; # Dancer2 inject this var, Text::Xslate complains about it - remove it...
    delete $config{location}; # Dancer2 inject this var, Text::Xslate complains about it - remove it...

    # Set a default path that is overridable by the engine config:
    return Text::Xslate->new(path => ["/"], %config);
}

sub render {
    my ($self, $tmpl, $vars) = @_;

    my $xslate = $self->engine;
    my $content = eval {
        if ( ref($tmpl) eq "SCALAR" ) {
            $xslate->render_string($$tmpl, $vars)
        }
        else {
            $xslate->render($tmpl, $vars);
        }
    };

    if ( my $error = $@ ) { croak $error }

    return $content;
}

1;
