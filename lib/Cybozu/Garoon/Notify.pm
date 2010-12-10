package Cybozu::Garoon::Notify;

use strict;
use warnings;

our $VERSION = '0.01';

use LWP::UserAgent;
use XML::Simple;
use Encode;
use DateTime::Format::Strptime;

use Class::Accessor::Lite (
    rw => [ qw(url ua username password) ],
    ro => [ qw(datetime_fmt) ],
);

sub new {
    my $class = shift;
    my $self  = bless {
        @_,
        reminder     => {},
        ua           => LWP::UserAgent->new,
        datetime_fmt => DateTime::Format::Strptime->new(
            pattern =>   '%Y-%m-%d %H:%M:%S',
            locale  =>   'C',
            time_zone => 'Asia/Tokyo',
        ),
    }, $class;
    $self->login;
    return $self;
}

sub login {
    my $self = shift;

    my $res = $self->post( $self->url );

    $self->{reminder}{whatsnew} = $res->header('X-Cybozu-Reminder-Whatsnew');
    $self->{reminder}{schedule} = $res->header('X-Cybozu-Reminder-Schedule');
    $self->{reminder}{mail}     = $res->header('X-Cybozu-Reminder-Mail');
}

sub get_whatsnew {
    my $self = shift;

    my $res = $self->post( $self->{reminder}{whatsnew} );
    my $ref = $self->parse( $res->content );
    my @ret;

    if (my $e = $ref->{entry}) {
        @ret = sort { $a->{updated} cmp $b->{updated} } @$e;
    }
    return @ret;
}

sub get_schedule {
    my $self = shift;

    my $res = $self->post( $self->{reminder}{schedule} );
    my $ref = $self->parse( $res->content );
    my @ret;

    if (my $s = $ref->{schedule}) {
        if (exists $s->{startdate}) {
            @ret = ($s);
        } else {
            @ret = map {
                $s->{$_}
            } sort {
                $s->{$a}{startdate} cmp $s->{$b}{startdate}
            } keys %$s;
        }
    }
    return @ret;
}

sub get_mail {
    my $self = shift;

    my $res = $self->post( $self->{reminder}{mail} );
    return $self->parse( $res->content );
}

sub post {
    my ( $self, $url ) = @_;

    my $form = {
        _system      => 1,
        _account     => $self->username,
        _password    => $self->password,
        _notimecard  => 1,
        _force_login => 1,
    };

    my $res = $self->ua->post( $url, $form );
    if ( my $err = $res->header('X-Cybozu-Error') ) {
        die $err;
    }

    return $res;
}

sub parse {
    my ( $self, $content ) = @_;

    my $xs = XML::Simple->new( SuppressEmpty => undef,ForceArray => [qw/entry/] );
    return $xs->XMLin(encode('utf8', $content));
}

1;
__END__

=head1 NAME

GaroonNotify -

=head1 SYNOPSIS

  use GaroonNotify;

=head1 DESCRIPTION

GaroonNotify is

=head1 AUTHOR

Hideo Kimura E<lt>hide@hide-k.netE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
