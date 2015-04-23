package HTML::Navigation::Item;
# ABSTRACT: Create items (menus) representing web navigation elements, output as data structure

use v5.16;
use Moose;
# use MooseX::ClassAttribute;
use namespace::autoclean;
use MooseX::Types::URI qw(Uri);
use Data::Printer;

# VERSION: generated by DZP::OurPkgVersion

sub BUILD {
    my ($self, $args) = @_;
 	foreach my $kid (@{$args->{children}}) {
		$kid->{no_sorting} = $self->no_sorting;
		my $kid_item = HTML::Navigation::Item->new($kid);
		$kid_item->_set_parent($self);
 		$self->insert_child( $kid_item );
 	}
}


has label => (
	is       => 'rw',
	isa      => 'Str',
	required => 1,
);

has title => (
	is  => 'rw',
	isa => 'Str',
);

has action => (
	is        => 'ro',
	isa       => 'Catalyst::Action',
	predicate => 'has_action',
);

has url => (
	is     => 'rw',
	isa    => Uri,
	coerce => 1,
	default => '',
);
has url_code => (
	is     => 'rw',
	isa    => 'CodeRef',
);

# path to menu item, not url/href path
has path => (
	is       => 'ro',
	isa      => 'Str',
	required => 1,
# 	init_arg => 'path',
);

has parent => (
	is       => 'ro',
	isa      => 'HTML::Navigation::Item',    #|Undef
	weak_ref => 1,
	writer   => '_set_parent',
);

has _children => (
	is      => 'rw',
	isa     => 'ArrayRef[HTML::Navigation::Item]',
	traits  => ['Array'],
	default => sub { [] },
	handles => {
		all_children    => 'elements',
		insert_child    => 'push',
		shift_child     => 'shift',
		get_child      => 'get',
		find_child      => 'first',
		count_children  => 'count',
		has_children    => 'count',
		has_no_children => 'is_empty',
		sort_children   => 'sort_in_place',
		map_children    => 'map',
	},
);

after 'insert_child' => sub { shift->_sort_children };
after 'shift_child'  => sub { shift->_sort_children };
sub _sort_children {
	my $self = shift;
	return unless $self->do_sorting;
	$self->sort_children(
		sub {
			if ( $_[0]->order == $_[1]->order ) {
				# We need to do a name sort on the label then.
				return $_[0]->path cmp $_[1]->path;
			}
			return $_[0]->order <=> $_[1]->order;
		}
	);
	#return; # ignored
}

has no_sorting => (
	is      => 'rw',
	isa     => 'Bool',
	traits  => ['Bool'],
	default => 0,
	handles => {
		dont_sort    => 'set',
		do_sort      => 'unset',
		flip_sorting => 'toggle',
		do_sorting   => 'not',
	},
	trigger => sub {
		my $self = shift;
		foreach my $kid ( $self->all_children ) {
			$kid->no_sorting( $self->no_sorting );
		}
	},
);

has order => (
	is      => 'ro',
	isa     => 'Int',
	default => 0,
);

has is_active => (
	is      => 'rw',
	isa     => 'Bool',
	traits  => ['Bool'],
	default => 0,
	handles => {
		make_active   => 'set',
		make_inactive => 'unset',
		flip_active   => 'toggle',
		is_inactive   => 'not',
	},
	trigger => sub { my $self = shift;
		$self->parent->is_active( $self->is_active ) if defined $self->parent;
	},
);

has css_classes => (
	is      => 'rw',
	isa     => 'ArrayRef[Str]',
	traits  => ['Array'],
	default => sub { [] },
);
has dom_id => (
	isa => 'Str',
	is  => 'rw'
);


has conditions => (
	traits  => ['Array'],
	is      => 'rw',
	isa     => 'ArrayRef[Str|CodeRef]',
	default => sub { [] },
	handles => {
		condition_count => 'count',
		all_conditions  => 'elements',
	},
);

# has required_roles => (
# 	traits => ['Array'],
# 	is => 'ro',
# 	isa => 'ArrayRef[Str]',
# 	default => sub{ [] },
# 	handles => {
# 		count_roles => 'count',
# 		all_roles => 'elements',
# 	},
# );

=head1 METHODS

=head2 contains_path($path)

Returns true if this menu item or any of its children contain the given
path.

=cut

sub contains_path {
	my ( $self, $path ) = @_;

	# If this is the path, we obviously contain the path.
	return 1 if ( $self->path eq $path );

	# Now check all the children:
	if ( $self->has_children ) {
		# For each child element see if it contains the path.
		foreach my $i ( $self->all_children ) {
			return 1 if ( $i->contains_path($path) );
		}
	}

	return 0;
} ## end sub contains_path





sub active_child {
	my $self = shift;
	foreach my $kid ( $self->children ) {
		return $kid if $kid->active;
	}
	return;
}

sub as_data {
	my ($self, $ctx) = @_;
	my $data = {
		path  => $self->path,
		label => $self->label,
		order => $self->order,
		url   => $self->url->as_string,
# 		url   => $self->url_code->()->as_string,
	};
	#$data->{url} = $self->url->as_string if $self->url;
	$data->{children} = [] if $self->has_children;

	ITEM: foreach my $kid ( $self->all_children ) {
		foreach my $condition ( $kid->all_conditions ) {
			next ITEM unless $condition->($ctx);
		}
		my $kid_data = $kid->as_data($ctx);
		push( @{ $data->{children} }, $kid_data ) if $kid_data;
	}
	return ($data->{url} || @{$data->{children}}) ? $data : undef;
} ## end sub as_data

sub stringify {
	my ( $self, $indent ) = @_;
	my $str = '';
	$indent ||= '';
	$str .= $indent
	  . sprintf(
		"path: %s, label: %s, order: %s, url: %s\n",
		$self->path,
		$self->label,
		$self->order,
		$self->url,
# 		$self->url_code->(),
	  );
	foreach my $kid ( $self->all_children ) {
		$str .= $kid->stringify( $indent . "\t" );
	}
	return $str;
} ## end sub stringify



__PACKAGE__->meta->make_immutable;


1;
