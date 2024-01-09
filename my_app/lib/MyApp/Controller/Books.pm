package MyApp::Controller::Books;
use Mojo::Base 'Mojolicious::Controller', -signatures;
use Mojo::URL;
use DBI; 
use utf8;
use Data::Dumper;

#my $dsn = "DBI:mysql:books_db:localhost;charset=utf8";
#my $mysqluser = "books_user";
#my $pass = "WWW123";
  
my $config_file = '/var/mojolicious/my_app/connect.cfg';
# my $dbh  = DBI->connect($dsn,$mysqluser,$pass);
# my $dbh = DBI->connect("dbi:mysql:mysql_read_default_file=$config_file;mysql_read_default_group=$group",undef,undef,{});
my $dbh = DBI->connect("dbi:mysql:mysql_read_default_file=$config_file;mysql_read_default_group=general",undef,undef,{});
$dbh->{'mysql_enable_utf8'} = 1;


# This action will render a template
sub my_index ($self) {
  # $self->{_dbh} = $dbh;
  my $sql_1 = "select * from books_table";
  my $sth = $dbh->prepare($sql_1);
  $sth->execute();
 
  my @books = ();
  while(my @row = $sth->fetchrow_array) {
    push @books, \@row;
  };
  
  # Render template "example/welcome.html.ep" with message
  $self->stash({books => \@books});
  $self->render(message => 'База данных книг', txt => 'This is my text!');
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

  # пишем логику по редактированию
  my $time = localtime;
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
    
    # заново делаем запрос и рисуем таблицу, так как мы обновили данныеы
    my $sql_1 = "select * from books_table where id = ? ";
    $sth = $dbh->prepare($sql_1);
    $sth->execute($id);

    my @books = ();
    while(my @row = $sth->fetchrow_array) {
      push @books, \@row;
      };
    $self->stash({books => \@books});
    $self->render(message => "Книга id = $id обновлена!", time => $time, txt => 'This is my text on page Edit!', c0 =>$id);
    # отрисуем и выйдем
    last;
  }
  $self->render(message => 'Отредактируйте книгу', message2 => '', txt => 'This is my text on page Edit!', time => $time, c0 =>$id);

}

# добавляем книгу
sub add ($self) {
  my $books_action1 = $self->param('books_action1');
  
  if($books_action1 eq 'Сохранить книгу') {
    #print "<b>$book</b>";
    my $id = $self->param("id");
    my $isbn = $self->param("isbn");
    my $author = $self->param("author");
    my $book_name = $self->param("book_name");
    my $book_text = $self->param("book_text");
    my $sth = $dbh->prepare("INSERT INTO books_table VALUES(?,?,?,?,?);");
    $sth->execute($id, $isbn, $book_name,$author, $book_text);
 }
  my $id = $self->param("id"); 
  $self->flash(message_add => "Новая книга $id успешно добавлена");
  $self->redirect_to('/');
}

# удаляем книгу
sub delete ($self) {
  my $sub_delete = $self->param('sub_delete');

  if ($sub_delete eq 'Delete' ) {
      my $delete_button = $self->param('delete_button');
      my $sth = $dbh->prepare("DELETE FROM books_table WHERE id=?;");
      $sth->execute($delete_button);
  }
  my $id = $self->param('delete_button');
  $self->flash(message_add => "Книга $id удалена");
  $self->redirect_to('/');
}

1;