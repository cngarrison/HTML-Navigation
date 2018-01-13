package HTML::Navigation;
# ABSTRACT: Create items (menus) representing web navigation elements, output as data structure

use v5.16;
use Moose;
use namespace::autoclean;
use HTML::Navigation::Item;
use Data::Printer;

our $VERSION = 'v0.0.6';

sub BUILD {
	my ( $self, $args ) = @_;
	foreach my $item ( @{ $args->{items} } ) {
		$item->{no_sorting} = $self->no_sorting;
		$self->insert_item( HTML::Navigation::Item->new($item) );
	}
}


has _items => (
	traits  => ['Array'],
	is      => 'rw',
	isa     => 'ArrayRef[HTML::Navigation::Item]',
	default => sub { [] },
	handles => {
		all_items    => 'elements',
		insert_item  => 'push',
		shift_item   => 'shift',
		get_item     => 'get',
		find_item    => 'first',
		count_items  => 'count',
		has_no_items => 'is_empty',
		sort_items   => 'sort_in_place',
		map_items    => 'map',
	},
);

after 'insert_item' => sub { shift->_sort_items };
after 'shift_item'  => sub { shift->_sort_items };

sub _sort_items {
	my $self = shift;
	return unless $self->do_sorting;
	$self->sort_items(
		sub {
			if ( $_[0]->order == $_[1]->order ) {
				# We need to do a name sort on the label then.
				return $_[0]->path cmp $_[1]->path;
			}
			return $_[0]->order <=> $_[1]->order;
		}
	);
	#return; # ignored
} ## end sub _sort_items

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
		foreach my $item ( $self->all_items ) {
			$item->no_sorting( $self->no_sorting );
		}
	},
);


# sub get_child_with_path {
# 	my ($self, $path) = @_;
#
# 	return $self->find_item(sub {$_->contains_path($path)});
# }



sub as_data {
	my ( $self, $ctx ) = @_;
	my $data = [];
  ITEM: foreach my $item ( $self->all_items ) {
		foreach my $condition ( $item->all_conditions ) {
			next ITEM unless $condition->($ctx);
		}
		my $item_data = $item->as_data($ctx);
		push( @{$data}, $item_data ) if $item_data;
	}
	return $data;
} ## end sub as_data


=head2 stringify([$indent])

Returns a string containing the hierachy of the complete menu found here. This is
mostly used for debugging that menus are setup correctly.

=cut


sub stringify {
	my ( $self, $indent ) = @_;
	my $str = '';
	$indent = '' if ( !$indent );
	foreach my $item ( $self->all_items ) {
		$str .= $item->stringify($indent);
	}
	return $str;

} ## end sub stringify


__PACKAGE__->meta->make_immutable;

1;
