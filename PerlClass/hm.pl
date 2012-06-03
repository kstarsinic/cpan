#!/usr/bin/perl

use strict;
#use warnings;

require B;
require B::Deparse;
use Data::Dumper;

print "begin\n";

sub klass(*&) {
    my ($class, $sub)   = @_;
    my $cv              = B::svref_2object($sub);
    my $proto           = $cv->FLAGS & B::SVf_POK() ? '(' . $cv->PV . ')' : '';

    print "class $class sub $sub$proto\n";

    #show_sub($sub, '    ');
    print "\n";
    #B::walkoptree(B::svref_2object($sub)->ROOT, 'walk_class');
    my $d = B::Deparse->new;
    my $text = $d->coderef2text($sub);
    print "\n$text\n";
}


#sub UNIVERSAL::declare {
sub UNIVERSAL::class {
    no strict;
    my ($self, @etc)    = @_;
    #print "AUTOLOAD [$UNIVERSAL::AUTOLOAD]($self) $#etc @etc\n";
    print "declare($self) $#etc @etc\n";
}

#class MyClass, sub (foo) {
#declare MyClass sub (foo) {
class MyClass sub (foo) {
    no strict;
    public:
        $foo     = 1;
    private:
        $pfoo    = 2;
        $pbar    = 3;
    protected:
        $rfoo    = 4;
        $rbaz    = 5;
};

do {
    public:
        foo     => 1;
    private:
        bar     => 2;
    protected:
        baz     => 3;
        quux    => 4,
};

sub dummy {
}

print "end\n";


my $n;
my $CURCOP;
sub B::OBJECT::walk_class {
    my ($self)      = @_;
    my $safename    = $self->can('SAFENAME') ? $self->SAFENAME : '-';
    my $ppaddr      = $self->can('ppaddr') ? $self->ppaddr : '-';
    my $name        = $self->name;

    printf "%3d %-24s %-20s %-20s %-20s\n", ++$n, $ppaddr, ref($self), $safename, $name;
    $CURCOP = $self if $name eq 'nextstate';

    if ($self->can('first')) {
        my $first   = $self->first;
        print "    first $first\n";
    }

    if (ref $self eq 'B::SVOP') {
        my $sv      = $self->sv;
        my $gv      = $self->gv;
        my $name    = $gv->can('SAFENAME') ? $gv->SAFENAME : '-';

        printf "    sv %s\n",       ref($sv);           show_special($sv, '        ');
        printf "    gv %s %s\n",    ref($gv), $name;    show_special($gv, '        ');
    }
}


sub show_special {
    my ($s, $indent)    = @_;

    if (ref $s) {
        my $i       = $$s;
        my $svname  = $B::specialsv_name[$i] // '-';
        my $optype  = $B::optype[$i] // '-';

        printf "${indent}svname %-20s optype %-20s\n", $svname, $optype;
    }
}


sub show_sub {
    my ($sub, $indent)  = (@_, '');

    if (ref $sub eq 'CODE') {
        my $cv      = B::svref_2object($sub);
        my $name    = '?';
        my $proto   = $cv->FLAGS & B::SVf_POK() ? '(' . $cv->PV . ')' : '';
        my $root    = $cv->ROOT;

        printf "%s%s %s\n", $indent, $name, $proto, $root // '?';

        if (B::class($root) ne 'NULL') {
            my $lineseq = $root->first;

            printf "%s lineseq %s %s\n", $indent, ref($lineseq), $lineseq->name;

            my @ops;
            for (my $o = $lineseq->first; $$o; $o = $o->sibling) {
                printf "%s op %s\n", $indent, $o;
                push @ops, $o;
            }

            #print lineseq(undef, undef, @ops) . ";\n";
        }
    }
}


