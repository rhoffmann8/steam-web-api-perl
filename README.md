steam-web-api-perl
==================

Simple Perl wrappers for Steam Web API calls.

Usage:
* Create a SteamAPI object:
```
    $apiObj = new SteamAPI($myApiKey, $mySteamId64);
```
  * If the API key and Steam ID params are omitted or either is passed 
    as undef, the script will search for the environment variables
    STEAM_API_KEY and STEAM_ID respectively. If values for either are still not found the script will exit.
* Invoke one of the provided wrappers, passing in GET parameters as defined by the method signature:
```
my $resp = $apiObj->getNewsForApp(440, 3, 150); #appid, count, maxlength
```

The JSON response is converted to a Perl structure via the json_to_perl function of the JSON::Parse module
for the user to read from however they choose. For example,

```
foreach my $item (@{$resp->{appnews}->{newsitems}) {
  print $item->{title}."\n";
}
```

will print the title of each news item in the response.
