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
  my $dsn = "DBI:mysql:books_db:localhost;charset=utf8";
  my $mysqluser = "books_user";
  my $pass = "WWW123";
  
  my $dbh  = DBI->connect($dsn,$mysqluser,$pass);
  $dbh->{'mysql_enable_utf8'} = 1;

  my $sql_1 = "select * from books_table";
  my $sth = $dbh->prepare($sql_1);
  $sth->execute();

  my @books = ();
  while(my @row = $sth->fetchrow_array) {
    push @books, \@row;
    };

  
  
  # Load configuration from config file
  my $config = $self->plugin('NotYAMLConfig');

  # Configure the application
  $self->secrets($config->{secrets});

  # Router
  my $r = $self->routes;
  
  # Normal route to controller
  #$r->get('/')->to('Example#welcome');
  
  $r->get('/' => { books => \@books })->to('Books#my_index');
  $r->get('/edit')->to('Books#edit');
  #$r->post('/add')->to('Books#adding');
  $r->post('/add')
}

1;
