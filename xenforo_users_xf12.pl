#!/usr/bin/perl
###############################
# XenForo Munin V2.3          #
# Matt Worthington            #
# https://mattwservices.co.uk #
# XenForo 1.2 Version         #
###############################

my $ret = undef;
if (! eval "require LWP::UserAgent;")
{
        $ret = "LWP::UserAgent not found";
        if ( ! defined $ARGV[0] ) {
                die $ret;
        }
}
# Add your own URL below
my $SITE = "https://mattwservices.co.uk/";
my $URL = exists $ENV{'url'} ? $ENV{'url'} : $SITE;
my $timeout = 30;
if ( defined $ARGV[0] and $ARGV[0] eq "autoconf" )
{
        if ($ret)
        {
                print "no ($ret)\n";
                exit 0;
        }
        my $ua = LWP::UserAgent->new(timeout => $timeout);
        my $url = sprintf $URL;
        my $response = $ua->request(HTTP::Request->new('GET',$url));
                if ($response->is_success) {
                        if ($response->content =~ /<html\sid=\"XenForo\"/im ){
                        }
                        else {
                                print "Not a XenForo Site\n";
                                exit 0;
                        }
                }
                elsif ($response->code == 404) {
                        print "Page Not Found\n";
                        exit 0;
                }
                elsif ($response->code == 403) {
                        print "Access is being blocked\n";
                }
        exit 0;
}
if ( defined $ARGV[0] and $ARGV[0] eq "config" )
{
        print "graph_title Forum Users\n";
        print "graph_args --base 1000 -l 0\n";
        print "graph_vlabel current users\n";
        print "graph_category Forum\n";
        print "graph_total Total\n";
        print "members.label Members\n";
        print "members.draw AREA\n";
        print "guests.label Guests\n";
        print "guests.draw STACK\n";
        print "robots.label Robots\n";
        print "robots.draw STACK\n";
        exit 0;
}
my $ua = LWP::UserAgent->new(timeout => $timeout);
my $url = sprintf $URL;
my $response = $ua->request(HTTP::Request->new('GET',$url));
# part of the output we want to catch : Online now: 79 (members: 18, guests: 61, robots: 0) --> 18 - 61
if ($response->content =~ /\:\s(.*)\s\(members\:\s(.*),\sguests\:\s(.*),\srobots\:\s(.*)\)/im)
        {
                @results = ("members.value $2\n","guests.value $3\n","robots.value $4\n");
                for (@results) {
                s/,//;
                }
                print @results;
        } else {
                print "members.value U\n";
                print "guests.value U\n";
                print "robots.value U\n";
        }
# vim:syntax=perl
