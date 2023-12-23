package MyApp;
use Mojo::Base 'Mojolicious', -signatures;
use Mojolicious::Routes;
use Mojolicious::Routes::Pattern;
use DBI; 
use utf8;
use Data::Dumper;



#my $dbh  = DBI->connect($dsn,$mysqluser,$pass); #or
#die("Ошибка подключения к базе данных: $DBI::errstr\n");
#print "Connection database OK <br>" if $dbh;

# This method will run once at server start
sub startup ($self) {
  
  # Load configuration from config file
  my $config = $self->plugin('NotYAMLConfig');

  # Configure the application
  $self->secrets($config->{secrets});

  # Router
  my $r = $self->routes;
  
  # Normal route to controller
  #$r->get('/')->to('Example#welcome');
  
  #$r->get('/' => { books => \@books })->to('Books#my_index');
  $r->get('/')->to('Books#my_index');
  
  $r->post('/edit')->to('Books#edit');
  
  $r->post('/add');
}

1;
