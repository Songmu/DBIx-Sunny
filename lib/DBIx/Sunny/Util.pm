package DBIx::Sunny::Util;

use strict;
use warnings;

use Exporter 'import';
use Scalar::Util qw/blessed/;

our @EXPORT_OK = qw/bind_and_execute expand_arrayref_placeholder/;

sub bind_and_execute {
    my ($sth, @bind) = @_;
    my $i = 0;
    for my $bind ( @bind ) {
        if ( blessed($bind) && $bind->can('value_ref') && $bind->can('type') ) {
            # If $bind is an SQL::Maker::SQLType or compatible object, use its type info.
            $sth->bind_param(++$i, ${ $bind->value_ref }, $bind->type);
        } else {
            $sth->bind_param(++$i, $bind);
        }
    }
    return $sth->execute;
}

sub expand_arrayref_placeholder {
    my ($query, @bind) = @_;
    my @bind_param;
    $query =~ s{
        \?
    }{
        my $bind = shift @bind;
        if (ref($bind) && ref($bind) eq 'ARRAY') {
            push @bind_param, @$bind;
            join ',', ('?') x @$bind;
        } else {
            push @bind_param, $bind;
            '?';
        }
    }gex;
    return ( $query, @bind_param );
}

1
