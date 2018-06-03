#!/usr/bin/env perl
use Mojolicious::Lite;

use DBI;

helper 'lala'      => sub { return 'lalal'; };

## DB connection
helper 'db'        => sub { DBI->connect('DBI:mysql:database='.shift->param("db").';host=127.0.0.1', 'root', 'xyz789'); };

## DB databases
helper 'db_show'   => sub { $_[0]->db->selectcol_arrayref('show databases'); };

## DB database tables
helper 'db_desc'   => sub { $_[0]->db->selectcol_arrayref('show tables');    };

## DB database table rows
helper 'db_list'   => sub { my $h = $_[0]->db->prepare("select * from ".$_[0]->param('tbl') ); $h->execute(); $h->fetchall_aref('id'); };

## DB database taleb row by key
helper 'db_load'   => sub { my $h = $_[0]->db->prepare("select * from ".$_[0]->param('tbl')." where id = ?"); $h->execute( $_[1] ); $h->fetchrow_hashref; };

## DB database table row save by key
helper 'db_save'   => sub {
    my $a = $_[0]->req->json;

    my (@bind, @key, @key_val);

    foreach ( @{ $_[0]->db_desc } ) {
        next unless defined $a->{$_};
        next     if $_ eq 'id';
        push @key,     $_;
        push @key_val, '?';
        push @bind,    $a->{$_};
    }

    my $q = '';

    if ( $a->{id} ) {
        $q = 'UPDATE      ' . $_[0]->param("tbl") . ' ( ' . join( ',', @key ) . ' ) VALUES ( ' . join( ',', @key_val ) . ' ) WHERE id = ?'; push @bind, $self->{id};

    } else {
        $q = 'INSERT INTO ' . $_[0]->param("tbl") . ' ( ' . join( ',', @key ) . ' ) VALUES ( ' . join( ',', @key_val ) . ' ) ';

    }

    my $h = $_[0]->db->prepare($q); $h->execute(@bind);
};

helper 'db_delete' => sub {};

# ------------------------------------------------------------------------------------------------------------------------------------------------------------------- #
get  '/'              => sub { $_[0]->render( json => $_[0]->db_show ); };
get  '/:db'           => sub { $_[0]->render( json => $_[0]->db_desc ); };
get  '/:db/:tbl'      => sub { $_[0]->render( json => $_[0]->db_list ); };
get  '/:db/:tbl/:id'  => sub { $_[0]->render( json => $_[0]->db_load( $_[0]->param('id') ) ); };
post '/:db/:tbl/:id'  => sub { $_[0]->render( json => $_[0]->db_save ); };
post '/:db/:tbl'      => sub { $_[0]->render( json => $_[0]->db_save ); };
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------ #

# post '/:tbl' => sub {
    # my $c = shift;
    # $c->render( json => \@a );
# };

# /select/join=shop.id:shop.id,shop.id:shop.id,shop.id:shop.id&where=&group=

# post '/:tbl/:id' => sub {
    # my $c = shift;
    # $c->render( json => \@a );
# };
#
# delete '/:tbl/:id' => sub {
    # my $c = shift;
    # $c->render( json => \@a );
# };

# ---------------------------------------------------------------------------------- #

app->start;
