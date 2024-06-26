package MyApp::Controller::Books;
use Mojo::Base 'Mojolicious::Controller', -signatures;
use Mojo::URL;
use DBI; 
use utf8;
use Data::Dumper;

# config file for work with database
my $config_file = '/var/mojolicious/my_app/connect.cfg';

my $dbh = DBI->connect("dbi:mysql:mysql_read_default_file=$config_file;mysql_read_default_group=general",undef,undef,{});
$dbh->{'mysql_enable_utf8'} = 1;


# This action will render a template
sub index ($self) {
  # $self->{_dbh} = $dbh;
  my $sql_read_all_db = "select * from books_table";
  my $sth = $dbh->prepare($sql_read_all_db);
  $sth->execute();
 
  my @books = ();
  while(my @row = $sth->fetchrow_array) {
    push @books, \@row;
  };
  
  # Render template "example/welcome.html.ep" with message
  $self->stash({books => \@books});
  $self->render(message => 'База данных книг');
}

# редактируем книгу
sub edit ($self) {
  my $id = $self->param('edit_button');
  my $sql_req_where_id = "select * from books_table where id = ? ";
  my $sth = $dbh->prepare($sql_req_where_id);
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
    my $isbn = $self->param('isbn_ta'); # "_ta" из textarea
    my $author = $self->param('author_ta');
    my $book_name = $self->param('book_name_ta');
    my $book_text = $self->param('book_text_ta');
    
    my $sql_update = "UPDATE books_table SET isbn = ?, author = ?, book_name = ?, book_text = ?  WHERE id = ?";
	  my $sth = $dbh->prepare($sql_update);
    $sth->execute($isbn, $author, $book_name, $book_text, $id);
    
    # заново делаем запрос и рисуем таблицу, так как мы обновили данные
    #my $sql_1 = "select * from books_table where id = ? ";
    $sth = $dbh->prepare($sql_req_where_id);
    $sth->execute($id);

    my @books = ();
    while(my @row = $sth->fetchrow_array) {
      push @books, \@row;
      };
    $self->stash({books => \@books});
    $self->render(message => "Книга id = $id обновлена!", time => $time, id =>$id);
    # отрисуем и выйдем
    last;
  }
  $self->render(message => 'Отредактируйте книгу', time => $time, id =>$id);

}

# добавляем книгу на отдельной странице, для этого sub adding
sub adding ($self) {
  $self->render(message => 'Добавляем новую книгу');
}

# удаляем книгу
sub delete ($self) {
  my $sub_delete = $self->param('sub_delete');

  if ($sub_delete eq 'Удалить' ) {
      my $delete_button = $self->param('delete_button');
      my $sth = $dbh->prepare("DELETE FROM books_table WHERE id=?;");
      $sth->execute($delete_button);
  }
  my $id = $self->param('delete_button');
  $self->flash(message_add => "Книга $id удалена");
  $self->redirect_to('/');
}

# sub add для обработки post-запроса
sub add ($self) {
  my $books_action1 = $self->param('books_action1');
  
  if($books_action1 eq 'Сохранить книгу') {
    #print "<b>$book</b>";
    my $id = $self->param("id");
    if ($id =~ /^\d+$/) {
      my $isbn = $self->param("isbn");
      my $author = $self->param("author");
      my $book_name = $self->param("book_name");
      my $book_text = $self->param("book_text");
      my $sth = $dbh->prepare("INSERT INTO books_table VALUES(?,?,?,?,?);");
      $sth->execute($id, $isbn, $book_name,$author, $book_text);
      #my $id = $self->param("id");
      $self->flash(message_add => "Новая книга $id успешно добавлена");
    }
    else {
      $self->flash(message_add => "Ошибка при добавлении книги. Укажите корректный id в виде целого числа!");
    }
  }
  $self->redirect_to('/adding');
}

1;