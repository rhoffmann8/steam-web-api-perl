#!/usr/bin/env perl

package SteamAPI;

use strict;
use warnings;
use JSON::Parse 'json_to_perl';
use LWP::Simple;

my $API_DOMAIN = "api.steampowered.com";
my $INTERFACES = {
    "news" => "ISteamNews",
    "user" => "ISteamUser",
    "stats" => "ISteamUserStats",
    "player" => "IPlayerService"
};
my $METHODS = {
    "ISteamNews" => {
	"getNews" => "GetNewsForApp"
    },
    "ISteamUser" => {
	"summaries" => "GetPlayerSummaries",
	"friends" => "GetFriendList"
    },
    "ISteamUserStats" => {
	"globalAppAchievements" => "GetGlobalAchievementPercentagesForApp",
	"achievements" => "GetPlayerAchievements",
	"stats" => "GetUserStatsForGame"
    },
    "IPlayerService" =>  {
	"owned" => "GetOwnedGames",
	"recentlyPlayed" => "GetRecentlyPlayedGames"
    }
};

sub new {
    my ($class, $apiKey, $steamId) = @_;

    if (not defined $apiKey) {
	$apiKey = $ENV{"STEAM_API_KEY"} or die "Must pass API key or set STEAM_API_KEY environment variable"
    }

    if (not defined $steamId) {
	$steamId = $ENV{"STEAM_ID"} or die "Must pass Steam ID or set STEAM_ID environment variable"
    }

    my $self = {
	_apiKey => $apiKey,
	_steamId => $steamId
    };

    bless $self, $class;
    return $self;
}

sub getNewsForApp {
    my ($self, $appId, $count, $maxLength, $format) = @_;

    die "App ID cannot be blank\n" unless defined $appId;

    my $params = {
	"appid" => $appId,
	"count" => $count,
	"maxlength" => $maxLength,
	"format" => $format
    };

    my $interface = $INTERFACES->{"news"};
    my $method = ($METHODS->{$interface})->{"getNews"};

    return $self->_request($interface, $method, 2, $params);
}

sub getGlobalAchievementPercentagesForApp {
    my ($self, $appId, $format) = @_;
    
    die "App ID cannot be blank\n" unless defined $appId;

    my $params = {
	"gameid" => $appId,
	"format" => $format
    };

    my $interface = $INTERFACES->{"stats"};
    my $method = ($METHODS->{$interface})->{"globalAppAchievements"};
    
    return $self->_request($interface, $method, 2, $params);
}

sub getPlayerSummaries {
    my ($self, $steamIds, $format) = @_;

    die "Steam IDs cannot be blank\n" unless defined $steamIds;
     
    my $params = {
	"steamids" => $steamIds,
	"format" => $format
    };

    my $interface = $INTERFACES->{"user"};
    my $method = ($METHODS->{$interface})->{"summaries"};
    
    return $self->_request($interface, $method, 2, $params);
}

sub getFriendList {
    my ($self, $steamId, $relationship, $format) = @_;

    if (not defined $steamId) {
	$steamId = $self->{_steamId} or die "Steam ID cannot be blank\n";
    }
    
    my $params = {
	"steamid" => $steamId,
	"relationship" => $relationship,
	"format" => $format
    };

    my $interface = $INTERFACES->{"user"};
    my $method = ($METHODS->{$interface})->{"friends"};
    
    return $self->_request($interface, $method, 1, $params);
}

sub getPlayerAchievements {
    my ($self, $steamId, $appId, $lang) = @_;
    
    die "Steam ID cannot be blank\n" unless defined $steamId;
    die "App ID cannot be blank\n" unless defined $appId;

    my $params = {
	"steamid" => $steamId,
	"appid" => $appId,
	"l" => $lang
    };

    my $interface = $INTERFACES->{"stats"};
    my $method = ($METHODS->{$interface})->{"achievements"};

    return $self->_request($interface, $method, 1, $params);
}

sub getUserStatsForGame {
    my ($self, $steamId, $appId, $lang) = @_;
    
    die "Steam ID cannot be blank\n" unless defined $steamId;
    die "App ID cannot be blank\n" unless defined $appId;

    my $params = {
        "steamid" => $steamId,
        "appid" => $appId,
        "l" => $lang
    };

    my $interface = $INTERFACES->{"stats"};
    my $method = ($METHODS->{$interface})->{"stats"};

    return $self->_request($interface, $method, 2, $params);
}

sub getOwnedGames {
    my ($self, $steamId, $appInfo, $freeGames, $format, $appFilter) = @_;
    
    die "Steam ID cannot be blank\n" unless defined $steamId;
    
    my $params = {
	"steamid" => $steamId,
	"include_appinfo" => $appInfo,
	"include_played_free_games" => $freeGames,
	"format" => $format,
	"appids_filter" => $appFilter
    };

    my $interface = $INTERFACES->{"player"};
    my $method = ($METHODS->{$interface})->{"owned"};
    
    return $self->_request($interface, $method, 1, $params);
}

sub getRecentlyPlayedGames {
    my ($self, $steamId, $count, $format) = @_;

    die "Steam ID cannot be blank\n" unless defined $steamId;

    my $params = {
	"steamid" => $steamId,
	"count" => $count,
	"format" => $format
    };

    my $interface = $INTERFACES->{"player"};
    my $method = ($METHODS->{$interface})->{"recentlyPlayed"};

    return $self->_request($interface, $method, 1, $params);
}

sub _request {
    my ($self, $interface, $method, $ver, $params) = @_;

    my $url = "http://".$API_DOMAIN."/".$interface."/".$method."/v000".$ver."/?key=".$self->{_apiKey};

    foreach(keys %{$params}) {
	if (defined $params->{$_}) {
	    $url .= "&".$_."=".$params->{$_};
	}
    }

    my $content = get $url;
    die "Couldn't get $url" unless defined $content;
 
    return json_to_perl($content);
}

