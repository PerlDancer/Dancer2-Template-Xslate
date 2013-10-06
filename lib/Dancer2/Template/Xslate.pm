package Dancer2::Template::Xslate;

use v5.10;
use strict;
use warnings FATAL => "all";
use utf8;

use Carp qw(croak);
use Moo;
use Dancer2::Core::Types;
use Text::Xslate;
use File::Spec::Functions qw(abs2rel file_name_is_absolute);

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

    # Dancer2 inject a couple options without asking; Text::Xslate protests:
    delete $config{environment};
    if ( my $dancer_path = delete $config{location} ) {
        $config{path} //= [$dancer_path];
    }

    return Text::Xslate->new(%config);
}

sub render {
    my ($self, $tmpl, $vars) = @_;

    my $xslate = $self->engine;
    my $content = eval {
        if ( ref($tmpl) eq "SCALAR" ) {
            $xslate->render_string($$tmpl, $vars)
        }
        else {
            my $rel_path = file_name_is_absolute($tmpl)
                ? abs2rel($tmpl)
                : $tmpl;
            $xslate->render($rel_path, $vars);
        }
    };

    if ( my $error = $@ ) { croak $error }

    return $content;
}

1;
