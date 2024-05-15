#. Automatic Map Changer
#. By catcity
#. https://forums.openkore.com/viewtopic.php?t=18322

#. CONFIGURATION
#. Add These Lines to config.txt:

#. autoMapChange [0|1]
#. autoMapChange_time [Number of Seconds]
#. autoMapChange_timeSeed [Number of Seconds]
#. autoMapChange_list [Comma Seperated List]

#. autoMapChange is a boolean. Set it to 0 to turn the plugin off. Set it to 1 to turn the plugin on.
#. autoMapChange_time is the number of seconds that you would like the plugin to wait until the next map change.
#. autoMapChange_timeSeed is a random seed. The plugin will take any amount of seconds between 0 and the number you set here and add it to the time.
#. autoMapChange_list is a comma seperated list of lockMaps that you would like the plugin to randomly draw from.

#. EXAMPLE CONFIG.TXT
#. autoMapChange 1
#. autoMapChange_time 3600
#. autoMapChange_timeSeed 3600
#. autoMapChange_list prt_fild01, prt_fild02, prt_fild03, prt_fild04

#. Between every 60 and 120 minutes this example config will randomly choose a map from the list and set it as your lockMap.

#. It is possible that it will select the same map from the list twice in a row.
#. It is possible that it will select the same map from the list three times in a row.
#. It is possible that it will... Well you get the message.
#. You can use this to give preference to certain maps that you want to spend more time on than others.
#. Add multiple instances of the same map to the list and it has a greater chance of being the selected map.

#. CONSOLE COMMANDS
#. Automatic Map Changer has two additional console commands.

#. Typing 'automapc' into the console forces an immediate random change and resets the time.
#. Typing 'automapt' into the console gives the time since last change and the time until the next change.

package autoMapChange;

use strict;
use Plugins;
use Globals;
use Network;
use Misc;
use Log qw(debug message warning error);
use Commands;
use Time::HiRes qw(gettimeofday tv_interval);

Plugins::register('autoMapChange', \&on_unload, \&on_reload);
my $hooks = Plugins::addHooks(
	['mainLoop_pre', \&on_mainLoop],
	['start3', \&on_start],
	);
	
my $commands = Commands::register(
	['automapt', 'Check Automap Timings', \&cmdMapTime],
	['automapc', 'Force an Automap Change', \&cmdMapChange],
);
	
my $changeTime = 0;
my $timeElapsed01 = 0;

my $validation = 0;

sub on_unload {
	Plugins::delHooks($hooks);
	Commands::unregister($commands)
}

sub on_reload {
	&on_unload;
}

sub on_start {
	if ($config{'autoMapChange'}) {
		message "\n";
		message "########################################\n";
		message "VALIDATING AUTOMATIC MAP CHANGER CONFIG.\n";
		message "\n";
		if ($config{'autoMapChange_time'} eq "") {
			configModify('autoMapChange_time', 3600, 1);
			warning "Detected that your autoMapChange_time config is undefined.\n";
			warning "Automatically setting autoMapChange_time to 3600 seconds [1 Hour]\n";
			message "\n";
			$validation -= 1;
		}
		elsif ($config{'autoMapChange_time'} <= 120 && $config{'autoMapChange_time'} != 0) {
			warning "Detected that your autoMapChange_time is set to a very low value.\n";
			warning "This can have a negative impact on your bot performance.\n";
			message "\n";
			$validation -= 1;
		}
		elsif ($config{'autoMapChange_time'} == 0) {
			configModify('autoMapChange', 0, 1);
			warning "Detected that your autoMapChange_time has been set to 0.\n";
			warning "This will spam your bot with lockMap changes.\n";
			error "Disabling autoMapChange plugin..\n";
			message "\n";
			$validation -= 1;
		}
		elsif ($config{'autoMapChange_time'}) {
			message "Time config is declared.\n";
			message "\n";
			$validation += 1;
		}
		
		if ($config{'autoMapChange_timeSeed'} eq "") {
			configModify('autoMapChange_timeSeed', 0, 1);
			warning "Detected that your autoMapChange_timeSeed is undefined.\n";
			warning "Automatically setting autoMapChange_timeSeed to 0.\n";
			message "\n";
			$validation -= 1;
		}
		elsif ($config{'autoMapChange_timeSeed'}) {
			message "Seed config is declared.\n";
			message "\n";
			$validation += 1;
		}
		elsif ($config{'autoMapChange_timeSeed'} == 0) {
			message "Seed config is declared as 0.\n";
			message "This is fine, but please note that it is for precision time changes.\n";
			message "Your lockMap will change exactly on the time specified with no randomness or variation.\n";
			message "\n";
			$validation += 1;
		}
		
		if ($config{'autoMapChange_list'} eq "") {
			configModify('autoMapChange', 0, 1);
			warning "Detected that your autoMapChange_list is empty.\n";
			error "Disabling autoMapChange plugin.\n";
			message "\n";
			$validation -= 1;
		}
		elsif ($config{'autoMapChange_list'}) {
			message "List config is declared.\n";
			message "\n";
			$validation += 1;
		}
		
		if ($validation < 3) {
			warning "Please review your configuration for the automatic map changer plugin in config.txt.\n";
			message "########################################\n";
		}
		elsif ($validation == 3) {
			message "Everything okay!\n";
			message "########################################\n";
		}
	}
}

sub on_mainLoop {
	if ($config{'autoMapChange'} && time - $KoreStartTime > $changeTime && $net->getState() == Network::IN_GAME) {
		my @lockMapList = split(/,\s*/, $config{'autoMapChange_list'});
		my $lockMapNew = $lockMapList[rand @lockMapList];
		configModify('lockMap', $lockMapNew, 1);
		message "Setting lockMap to '$lockMapNew' [After $changeTime seconds]\n";
		
		$timeout_ex{'master'}{'time'} = time;
		$KoreStartTime = time + $timeout_ex{'master'}{'timeout'};
		initChangeMap();
	}
}

sub initChangeMap {
	if ($config{'autoMapChange'}) {
		$changeTime = $config{'autoMapChange_time'} + int(rand $config{'autoMapChange_timeSeed'});
		$timeElapsed01 = [gettimeofday];
	}
}

sub cmdMapTime {
	if ($config{'autoMapChange'} && $net->getState() == Network::IN_GAME) {
		my $timeElapsed02 = tv_interval ($timeElapsed01, [gettimeofday]);
		my $rounded = int($timeElapsed02);
		my $timeUntil = $changeTime - $rounded;
		message "It has been ($rounded) seconds since your last lockMap change.\n";
		message "Your next change will occur in ($timeUntil) seconds.\n";
	}
}

sub cmdMapChange {
	if ($config{'autoMapChange'} && $net->getState() == Network::IN_GAME) {
		my @lockMapList = split(/,\s*/, $config{'autoMapChange_list'});
		my $lockMapNew = $lockMapList[rand @lockMapList];
		configModify('lockMap', $lockMapNew, 1);
		message "Setting lockMap to '$lockMapNew' [Request by User]\n";
		
		$timeout_ex{'master'}{'time'} = time;
		$KoreStartTime = time + $timeout_ex{'master'}{'timeout'};
		initChangeMap();
	}
}

return 1
