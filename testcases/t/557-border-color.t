#!perl
# vim:ts=4:sw=4:expandtab
#
# Please read the following documents before working on tests:
# • https://build.i3wm.org/docs/testsuite.html
#   (or docs/testsuite)
#
# • https://build.i3wm.org/docs/lib-i3test.html
#   (alternatively: perldoc ./testcases/lib/i3test.pm)
#
# • https://build.i3wm.org/docs/ipc.html
#   (or docs/ipc)
#
# • https://i3wm.org/downloads/modern_perl_a4.pdf
#   (unless you are already familiar with Perl)
#
# Verifies the per-window border_color command.
use i3test i3_autostart => 0;

sub border_color {
    my ($ws) = @_;
    my ($nodes, $focus) = get_ws_content($ws);
    ok(@{$nodes} == 1, 'precisely one container on workspace');
    return $nodes->[0]->{'border_color'};
}

my $config = <<"EOT";
font -misc-fixed-medium-r-normal--13-120-75-75-C-70-iso10646-1
for_window [class="borderme"] border_color #ff0000
EOT
my $pid = launch_with_config($config);

my $tmp = fresh_workspace;
open_window(wm_class => 'borderme');
is(border_color($tmp), '#ff0000', 'for_window sets border_color');

my $result = cmd 'border_color #00ff0080';
ok($result->[0]->{success}, 'border_color with alpha succeeds');
is(border_color($tmp), '#00ff0080', 'border_color changed');

$result = cmd 'border_color red';
ok(!$result->[0]->{success}, 'invalid color rejected');
is(border_color($tmp), '#00ff0080', 'border_color unchanged after invalid color');

cmd 'border_color none';
is(border_color($tmp), undef, 'border_color reset');

# for_window rules re-run on restart, so check persistence on an unmatched window.
$tmp = fresh_workspace;
open_window;
cmd 'border_color #0000ff';
cmd 'restart';
does_i3_live;
is(border_color($tmp), '#0000ff', 'border_color survives restart');

exit_gracefully($pid);

done_testing;
