
package Text::Yeti::Table;

# ABSTRACT: Render a table like "docker ps" does

use Mojo::Base -strict;

use Exporter 'import';
our @EXPORT_OK = qw(render_table);

# default stringification
my $TO_S = sub { defined $_[0] ? "$_[0]" : "<none>" };

sub _render_table {
    my ( $items, $spec, $io ) = ( shift, shift, shift );

    my ( @rows, @len );
    my @spec = map { ref $_ ? $_ : [$_] } @$spec;
    my @c = map { $_->[0] } @spec;

    # Compute table headers
    my @h = map {
        $_->[2] // do { local $_ = $_->[0]; s/([a-z])([A-Z])/$1 $2/g; uc }
    } @spec;
    @len = map { length $_ } @h;
    push @rows, \@h;

    # Compute table rows, keep track of max length
    my @to_s = map { $_->[1] // $TO_S } @spec;
    for my $item (@$items) {
        my @v = map { $to_s[$_]->( $item->{ $c[$_] }, $item ) } 0 .. $#c;
        $len[$_] = max( $len[$_], length $v[$_] ) for 0 .. $#c;
        push @rows, \@v;
    }

    # Compute the table format
    my $fmt = join( " " x 3, map {"%-${_}s"} @len ) . "\n";

    # Render the table
    printf {$io} $fmt, @$_ for @rows;
}

# render_table($items, $table_spec);
# render_table($items, $table_spec, $io);
sub render_table {
    _render_table( shift, shift, shift // \*STDOUT );
}

sub max { $_[0] >= $_[1] ? $_[0] : $_[1] }

1;

__END__

=head1 SYNOPSIS

    use Text::Yeti::Table qw(render_table);

    render_table( $list, $spec );

=head1 DESCRIPTION

    TODO

    $list is an arrayref of hashrefs

    $spec examples:

    [ 'key1', 'key2', 'key3' ]

    [ 'name', 'id', 'node', 'address', [ 'tags', sub {"@{$_[0]}"} ] ]

    [ 'ServiceName', 'ServiceID', 'Node', [ 'Datacenter', undef, 'DC' ] ]
