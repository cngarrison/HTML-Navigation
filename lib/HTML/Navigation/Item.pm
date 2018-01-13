package HTML::Navigation::Item;
# ABSTRACT: Create items (menus) representing web navigation elements, output as data structure

use v5.16;
use Moose;
# use MooseX::ClassAttribute;
use namespace::autoclean;
use MooseX::Types::URI qw(Uri);
use Data::Printer;

our $VERSION = 'v0.0.6';

sub BUILD {
	my ( $self, $args ) = @_;
	foreach my $kid ( @{ $args->{children} } ) {
		$kid->{no_sorting} = $self->no_sorting;
		$kid->{parent}     = $self; ## Need to set parent before ->new so that ->parent->make_active will work
		$self->insert_child( HTML::Navigation::Item->new($kid) );
	}
} ## end sub BUILD


has label => (
	is       => 'rw',
	isa      => 'Str',
	required => 1,
);

has title => (
	is  => 'rw',
	isa => 'Str|Undef',
);

has description => (
	is  => 'rw',
	isa => 'Str|CodeRef|Undef',
);

has icon => (
	is  => 'rw',
	isa => 'Str|Undef',
);

has category => (
	is  => 'rw',
	isa => 'Str|Undef',
);

has _url => (
	is       => 'rw',
	isa      => Uri,
	coerce   => 1,
	default  => '',
	init_arg => 'url',
);
has _url_cb => (
	is       => 'rw',
	isa      => 'CodeRef',
	init_arg => 'url_cb',
	clearer  => '_clear_url_cb',
);

sub url {
	my $self = shift;
	my $url  = shift;
	if ($url) {
		if ( ref $url eq 'CODE' ) {
			$self->_url_cb($url);
		} else {
			$self->_clear_url_cb();
			$self->_url($url);
		}
	} ## end if ($url)
	if ( $self->_url_cb ) {
		return $self->_url_cb->();
	} else {
		return $self->_url;
	}
} ## end sub url

sub get_url {
	my $self = shift;
	my $ctx  = shift;
	if ( $self->_url_cb ) {
		return $self->_url_cb->($ctx);
	} else {
		return $self->_url;
	}
} ## end sub get_url


# path to menu item, not url/href path
has path => (
	is       => 'ro',
	isa      => 'Str',
	required => 1,
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
		get_child       => 'get',
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
} ## end sub _sort_children

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
	trigger => sub {
		my $self = shift;
		$self->parent->make_active if defined $self->parent && $self->is_active;
	},
);

has css_classes => (
	is      => 'rw',
	isa     => 'ArrayRef[Str]',
	traits  => ['Array'],
	default => sub { [] },
);

has dom_id => (
	isa => 'Str|Undef',
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
		return $kid if $kid->is_active;
	}
	return;
}

sub as_data {
	my ( $self, $ctx ) = @_;
	my $url  = $self->get_url($ctx);
	my $data = {
		path        => $self->path,
		is_active   => $self->is_active,
		label       => $self->label,
		order       => $self->order,
		icon        => $self->icon,
		category    => $self->category,
		description => ref $self->description ? $self->description->($ctx) : $self->description,
		css_classes => $self->css_classes,
		dom_id      => $self->dom_id,
		url         => ref $url ? $url->as_string : $url,
	};
	$data->{children} = [] if $self->has_children;

  ITEM: foreach my $kid ( $self->all_children ) {
		foreach my $condition ( $kid->all_conditions ) {
			next ITEM unless $condition->($ctx);
		}
		my $kid_data = $kid->as_data($ctx);
		push( @{ $data->{children} }, $kid_data ) if $kid_data;
	}
	## If we've got either a URL or at least one child, then return $data
	return ( $data->{url} || ( exists $data->{children} && @{ $data->{children} } ) ) ? $data : undef;
} ## end sub as_data

sub stringify {
	my ( $self, $indent ) = @_;
	my $str = '';
	$indent ||= '';
	$str .= $indent . sprintf(
		"path: %s, label: %s, order: %s, url: %s\n",
		$self->path,
		$self->label,
		$self->order,
		$self->url,
# 		$self->url_cb->(),
	);
	foreach my $kid ( $self->all_children ) {
		$str .= $kid->stringify( $indent . "\t" );
	}
	return $str;
} ## end sub stringify



__PACKAGE__->meta->make_immutable;


1;
