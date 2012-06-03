use Test::More tests => 1;

require_ok('AutoMemoize');

sub foo { print "bar\n" }

#my $fathom  = B::Fathom->new('-v');
#my $score   = $fathom->fathom(\&foo);

#if ($score =~ /very readable/) { print "ok 2\n" }
#else                           { print "not ok 2\n" }

my $am = AutoMemoize->new;
$am->run(\%AutoMemoize::);
diag($am);

