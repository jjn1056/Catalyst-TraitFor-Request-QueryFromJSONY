package Catalyst::TraitFor::Request::QueryFromJSONY;

use Moose::Role;
use JSONY;

our $VERSION = '0.001';

has query_data => (
  is=>'ro',
  lazy=>1,
  predicate=>'has_query_data',
  builder=>'_build_query_data');

  sub _build_query_data {
    return shift->_query_data_from('q');
  }

sub _query_data_from {
  my ($self, $param) = @_;
  my $q = $self->query_parameters;
  if(exists $q->{$param}) {
    return JSONY->new->load($q->{$param});
  } else {
    return;
  }
}

1;

=head1 NAME

Catalyst::TraitFor::Request::QueryFromJSONY - Handle complex query parameters using JSONY

=head1 SYNOPSIS

For L<Catalyst> v5.90090+

    package MyApp;

    use Catalyst;

    MyApp->request_class_traits(['Catalyst::TraitFor::Request::QueryFromJSONY']);
    MyApp->setup;

For L<Catalyst> older than v5.90090

    package MyApp;

    use Catalyst;
    use CatalystX::RoleApplicator;

    MyApp->apply_request_class_roles('Catalyst::TraitFor::Request::QueryFromJSONY');
    MyApp->setup;

In a controller:

    package MyApp::Controller::Example;

    use Moose;
    use MooseX::MethodAttributes;
    use Data::Dumper;

    sub echo :Local {
      my ($self, $c) = @_;
      $c->res->body( Dumper $c->req->query_data );
    }

Example test case:

    ok my $res = request GET "/example/echo?q={'id':100,'age':['>',10]}";
    is_deeply eval $res->content, {
      'id' => 100,
      'age' => [ '>', 10 ]
    };

=head1 DESCRIPTION

This is an early access release of this module.  Experimentation as to the best
approach is ongoing.

There are cases when you'd like to express complex data structures in your URL
query part (tha bit after the '?').  There's been a number of attempts at this,
this module is yet another. In this version we allow for a query parameter 'q'
to be a L<JSONY> serialized string (L<JSONY> is basically JSON relaxed a bit to
reduce a bit of verbosity and smooth over common errors that are more pedantic
that useful).  We deserialize this string and place its value in 'query_data'.

This only happens if you request the query_data attribute, so there's no overhead
to simply having this installed.

You can have other 'classic' query parameters mixed in with the 'q' parameter, but
for no only 'q' is deserialized.  The original value of 'q' is preserved in the
original query_parameter method.

=head1 METHODS

This role defines the following methods.

=head2 query_data

If a query parameter 'q' exists, deserialize that using L<JSONY> and return the
data references (could be a hashref, or arrayref depending on the query construction.

=head2 has_query_data

Returns true if query_data is present in the request.

=head1 AUTHOR
 
John Napiorkowski L<email:jjnapiork@cpan.org>
  
=head1 SEE ALSO
 
L<Catalyst>, L<Catalyst::Request>, L<JSONY>

=head1 COPYRIGHT & LICENSE
 
Copyright 2015, John Napiorkowski L<email:jjnapiork@cpan.org>
 
This library is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
