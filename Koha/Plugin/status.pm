package Koha::Plugin::status;

## It's good practice to use Modern::Perl
use Modern::Perl;

## Required for all plugins
use base qw(Koha::Plugins::Base);

## We will also need to include any Koha libraries we want to access
use C4::Auth;
use C4::Context;

use Koha::Account::Lines;
use Koha::Account;
use Koha::DateUtils;
use Koha::Libraries;
use Koha::Patron::Categories;
use Koha::Patron;

use Cwd qw(abs_path);
use Data::Dumper;
use LWP::UserAgent;
use MARC::Record;
use Mojo::JSON qw(decode_json);;
use URI::Escape qw(uri_unescape);


our $VERSION = "{VERSION}";

our $metadata = {
    name            => 'Status plugin',
    author          => 'Siddharth',
    description     => 'Get Status',
    date_authored   => '2020-12-01',
    date_updated    => "1970-01-01",
    minimum_version => '19.1100000',
    maximum_version => undef,
    version         => $VERSION,
};

sub new {
    my ( $class, $args ) = @_;

    $args->{'metadata'} = $metadata;
    my $self = $class->SUPER::new($args);

    return $self;
}

sub report {
    my ( $self, $args ) = @_;
    
    my $cgi = $self->{'cgi'};
    my $template = $self->get_template({ file => 'tool-step2.tt' });

    $self->output_html($template->output());
}

sub tool {
    
    my ( $self, $args ) = @_;
    my $cgi = $self->{'cgi'};
    
    my $template = $self->get_template({ file => 'tool-step1.tt' });
    my $dbh = C4::Context->dbh;
    my $table = "indentation_list_table";

    # fetch all 'pending' indentations
    my $pending_indentation_query =  qq/
        SELECT DISTINCT indentationid, status
        FROM $table
    /;
    my $sth = $dbh->prepare($pending_indentation_query);
    $sth->execute();
    
    my @indentation_list;
    while ( my $row = $sth->fetchrow_hashref() ) {
        push( @indentation_list, $row );
    }
    $template->param( indentation_list => \@indentation_list);
    $self->output_html($template->output());
}


sub configure {
    my ( $self, $args ) = @_;

    my $cgi = $self->{'cgi'};
}

sub install() {
    my ( $self, $args ) = @_;

    return 1;
}

sub uninstall() {
    my ( $self, $args ) = @_;

    return 1;
}

# sub tool_step1{
#     my ( $self, $args ) = @_;
#     my $cgi = $self->{'cgi'};
#     my $template = $self->get_template({ file => 'tool-step1.tt' });
#     my $dbh = C4::Context->dbh;
#     # my $suggestions_table = $self->get_qualified_table_name('suggestions');

#     # my $words = $dbh->selectcol_arrayref( "SELECT fancy_word FROM $suggestions_table" );
#     $template->param( words => ['demo', 'demo2'] ,);
#     $self->output_html( $template->output() );
# }
