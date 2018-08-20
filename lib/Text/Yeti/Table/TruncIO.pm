
package Text::Yeti::Table::TruncIO;

use Mojo::Base -base;

has 'len';
has 'out';

sub printf {
    my $self = shift;

    my $buf = &CORE::sprintf;
    my $len = $self->len;
    $buf =~ s/^(.{$len}).+$/$1/mg;
    print { $self->out } $buf;
}

1;
