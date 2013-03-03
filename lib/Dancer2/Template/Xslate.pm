package Dancer2::Template::Xslate;

use strict;
use warnings FATAL => "all";
use utf8;

use Carp;
use Moo;
use Dancer2::Core::Types;
use Dancer2::FileUtils qw(read_file_content);
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

    # Use only Text::Xslate's path-searching procedure:
    my %config = %{ $self->config };
    if ( my $views = $self->views ) {
        $self->views(".");
        %config = ( path => $views, %config);
    }

    return Text::Xslate->new(%config);
}

sub render {
    my ($self, $tmpl, $vars) = @_;

    my $xslate = $self->engine;
    my $content = eval {
        ref($tmpl) eq "SCALAR"
            ? $xslate->render_string($$tmpl, $vars)
            : $xslate->render($tmpl, $vars)
    };

    if ( my $error = $@ ) { croak $error }

    return $content;
}

1;
