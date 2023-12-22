package MyApp::Controller::Books;
use Mojo::Base 'Mojolicious::Controller', -signatures;
use Mojo::URL;
use DBI; 
use utf8;
use Data::Dumper;



# This action will render a template
sub my_index ($self) {
  # Render template "example/welcome.html.ep" with message
  $self->render(message => 'Welcome to my library', txt => 'This is my text!');
}

sub edit ($self) {
  $self->render(message => 'Edit library', txt => 'This is my text on page Edit!');
}

sub adding ($self) {
  $self->redirect_to('/');
}

1;