BEGIN {
  use Test::Most;
  eval "use Catalyst 5.90093; 1" || do {
    plan skip_all => "Need a newer version of Catalyst => $@";
  };
}

{
  package MyApp::Controller::Root;
  use base 'Catalyst::Controller';
  use Data::Dumper;

  sub echo :Local {
    my ($self, $c) = @_;

    my $data = Dumper $c->req->query_data;
    $c->res->body($data);
  }

  $INC{'MyApp/Controller/Root.pm'} = __FILE__;

  package MyApp;
  use Catalyst;
  
  MyApp->request_class_traits(['QueryFromJSONY']);
  MyApp->setup;
}

use HTTP::Request::Common;
use Catalyst::Test 'MyApp';
use utf8;

{
  ok my $res = request GET "/root/echo?q=foo bar baz ♥";
  is_deeply eval $res->content, [qw/foo bar baz ♥/];
}

{
  ok my $res = request GET "/root/echo?q=['foo','bar','baz']";
  is_deeply eval $res->content, [qw/foo bar baz/];
}

{
  ok my $res = request GET "/root/echo?q={'id':100,'age':['>',10]}";
  is_deeply eval $res->content, {
    'id' => 100,
    'age' => [ '>', 10 ]
  };
}

done_testing;
