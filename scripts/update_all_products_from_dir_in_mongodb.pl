#!/usr/bin/perl -w

# This file is part of Product Opener.
#
# Product Opener
# Copyright (C) 2011-2023 Association Open Food Facts
# Contact: contact@openfoodfacts.org
# Address: 21 rue des Iles, 94100 Saint-Maur des Fossés, France
#
# Product Opener is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

use Modern::Perl '2017';
use utf8;

use CGI::Carp qw(fatalsToBrowser);

use ProductOpener::Config qw/:all/;
use ProductOpener::Paths qw/%BASE_DIRS/;
use ProductOpener::Store qw/retrieve/;
use ProductOpener::Index qw/:all/;
use ProductOpener::Display qw/:all/;
use ProductOpener::Tags qw/:all/;
use ProductOpener::Users qw/:all/;
use ProductOpener::Images qw/:all/;
use ProductOpener::Lang qw/:all/;
use ProductOpener::Mail qw/:all/;
use ProductOpener::Products qw/product_id_for_owner product_path_from_id retrieve_product/;
use ProductOpener::Food qw/:all/;
use ProductOpener::Ingredients qw/:all/;
use ProductOpener::Images qw/:all/;
use ProductOpener::Data qw/get_products_collection/;

use CGI qw/:cgi :form escapeHTML/;
use URI::Escape::XS;
use Storable qw/dclone/;
use Encode;
use JSON::MaybeXS;

use Data::Dumper;

# Get a list of all products

use Getopt::Long;

my @products = ();
my $owner = undef;

GetOptions('products=s' => \@products, 'owner=s' => \$owner);
@products = split(/,/, join(',', @products));

my $d = 0;

sub find_products($$) {

	my $dir = shift;
	my $code = shift;

	my $dh;

	opendir $dh, "$dir" or die "could not open $dir directory: $!\n";
	foreach my $file (sort readdir($dh)) {
		chomp($file);
		#print "file: $file\n";
		if ($file eq 'product.sto') {
			push @products, $code;
			$d++;
			(($d % 1000) == 1) and print "$d products - $code\n";
			#print "code: $code\n";
		}
		else {
			$file =~ /\./ and next;
			if (-d "$dir/$file") {
				find_products("$dir/$file", "$code$file");
			}
		}
	}
	closedir $dh or print "could not close $dir dir: $!\n";

	return;
}

if (scalar $#products < 0) {
	if ((defined $server_options{private_products}) and ($server_options{private_products})) {
		if (not defined $owner) {
			die("The owner must be specified on the producers platform");
		}
		find_products("$BASE_DIRS{PRODUCTS}/$owner", '');
	}
	else {
		find_products($BASE_DIRS{PRODUCTS}, '');
	}
}

my $count = $#products;
my $i = 0;

my %codes = ();

print STDERR "$count products to update\n";

my $products_collection = get_products_collection();
foreach my $code (@products) {

	#next if ($code ne "4072700318675");

	my $product_id = product_id_for_owner($owner, $code);

	my $path = product_path_from_id($product_id);

	#my $product_ref = retrieve_product($code);
	my $product_ref = retrieve("$BASE_DIRS{PRODUCTS}/$path/product.sto")
		or print "not defined $BASE_DIRS{PRODUCTS}/$path/product.sto\n";

	if ((defined $product_ref)) {

		foreach my $k (keys %{$product_ref}) {
			$k =~ /\./ and print "$k\t";
		}

		if (exists $product_ref->{"countries.20131226"}) {
			delete $product_ref->{"countries.20131226"};
		}
		if (exists $product_ref->{"countries.20131227"}) {
			delete $product_ref->{"countries.20131227"};
		}
		if (exists $product_ref->{"countries.beforescanbot"}) {
			delete $product_ref->{"countries.beforescanbot"};
		}
		if (exists $product_ref->{"traces.tags"}) {
			delete $product_ref->{"traces.tags"};
		}
		if (exists $product_ref->{"categories.tags"}) {
			delete $product_ref->{"categories.tags"};
		}
		if (exists $product_ref->{"packaging.tags"}) {
			delete $product_ref->{"packaging.tags"};
		}
		if (exists $product_ref->{"labels.tags"}) {
			delete $product_ref->{"labels.tags"};
		}
		if (exists $product_ref->{"origins.tags"}) {
			delete $product_ref->{"origins.tags"};
		}
		if (exists $product_ref->{"brands.tags"}) {
			delete $product_ref->{"brands.tags"};
		}

		foreach my $k (keys %{$product_ref}) {
			$k =~ /\./ and print "$k\t";
		}

	}

	if ((defined $product_ref) and ($code ne '')) {
		next if ((defined $product_ref->{empty}) and ($product_ref->{empty} == 1));
		next if ((defined $product_ref->{deleted}) and ($product_ref->{deleted} eq 'on'));
		print STDERR "updating product $code -- " . $product_ref->{code} . " \n";
		my $return = $products_collection->replace_one({"_id" => $product_ref->{_id}}, $product_ref, {upsert => 1});
		print STDERR "return $return\n";
		$i++;
		$codes{$code} = 1;
	}
}

print STDERR "$count products to update - $i products not empty or deleted\n";
print STDERR "scalar keys codes : " . (scalar keys %codes) . "\n";

exit(0);

