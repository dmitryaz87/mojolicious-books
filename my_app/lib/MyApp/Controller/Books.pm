package MyApp::Controller::Books;
use Mojo::Base 'Mojolicious::Controller', -signatures;
use Mojo::URL;
use DBI; 
use utf8;
use Data::Dumper;

my $dsn = "DBI:mysql:books_db:localhost;charset=utf8";
my $mysqluser = "books_user";
my $pass = "WWW123";
  
my $dbh  = DBI->connect($dsn,$mysqluser,$pass);
$dbh->{'mysql_enable_utf8'} = 1;


# This action will render a template
sub my_index ($self) {
  #$self->{_dbh} = $dbh;
  my $sql_1 = "select * from books_table";
  my $sth = $dbh->prepare($sql_1);
  $sth->execute();

  my @books = ();
  while(my @row = $sth->fetchrow_array) {
    push @books, \@row;
  };
  # Render template "example/welcome.html.ep" with message
  $self->stash({books => \@books});
  $self->render(message => 'Welcome to my library', txt => 'This is my text!');
}

sub edit ($self) {
  my $id = $self->param('edit_button');
  my $sql_1 = "select * from books_table where id = ? ";
  my $sth = $dbh->prepare($sql_1);
  $sth->execute($id);

  my @books = ();
  while(my @row = $sth->fetchrow_array) {
    push @books, \@row;
  };

  $self->stash({books => \@books});

  #пишем логику по редактированию

  my $indicator = 'not ok';
  my $id_book = $self->param('if_save_press');
  if ($id_book eq 'Save') {
    
    my $id = $self->param('id_book');
    my $c1 = $self->param('isbn_ta');
    my $c2 = $self->param('author_ta');
    my $c3 = $self->param('book_name_ta');
    my $c4 = $self->param('book_text_ta');
    
    my $sql_2 = "UPDATE books_table SET isbn = ?, author = ?, book_name = ?, book_text = ?  WHERE id = ?";
	  my $sth = $dbh->prepare($sql_2);
    $sth->execute($c1, $c2, $c3, $c4, $id);
    $self->stash({books => \@books});
    
    #можно сделать редирект на главную, но пока не нужно
    #$self->redirect_to('/');
    
    $self->render(message => 'Edit library', message2 => 'Данные успешно обновлены!', txt => 'This is my text on page Edit!', c0 =>$id);
    last;
  }
  
  $self->render(message => 'Edit library!', message2 => '', txt => 'This is my text on page Edit!', c0 =>$id);
  
}

sub adding ($self) {

  $self->redirect_to('/');
}

1;