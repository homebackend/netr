# Netr App

Netr is a mobile App written in flutter for my personal use, to monitor my CCTV cameras both over intranet and internet (using SSH). It is not available at any app store. If you want to use it, build and deploy to your mobile.

## Features
- Supports Android/Ios
- Supports multiple CCTV streams both over local intranet and internet (using SSH).
- Supports watching CCTV streams using VLC remote web interface.
- Supports update over OTA from your local intranet (or apk hosted on some URL).

## Configuration
All configuration information is stored in `lib/config.dart`. Edit it to your liking before build App.

### Generate refresh token for Dropbox
To generate a refresh token for Dropbox follow these steps. Note here we are not using redirect url.
If you want to use a redirect url, modify accordingly. Also, replace values such as $appKey in urls and commands appropriately.

Steps are as follows:
1. *Create Dropbox app:* Post creation of dropbox app, please note the following values: _App key_ (_$appKey_), _App secret_ (_$appSecret_)
2. *Getting authorization code:* Open the following url: https://www.dropbox.com/oauth2/authorize?client_id=$appKey&token_access_type=offline&response_type=code. Note replace the _$appKey_ value from above. Note down _Access Code_ (_$accessCode_).
3. *Getting refresh token:* Execute the following command to get refresh token: `curl https://api.dropbox.com/oauth2/token -d code=$accessCode -d grant_type=authorization_code  -u $appKey:$appSecret`. Note down the _Refresh Token_ (_$refreshToken_).
4. *Testing refresh token (optional):* Execute the following command: `curl https://api.dropbox.com/oauth2/token -d grant_type=refresh_token -d refresh_token=$refreshToken -u $appKey:$appSecret`. If you receive _access_token_, you are all set.

## Building App
To build app use `build.sh`. To build check steps in this shell script.

# Screenshots

## Main screen

![Main Screen](https://gitlab.com/slashblog/netr-app/-/raw/main/screenshots/main.png?inline=false "Main Screen")

## Live video screen
![Live Video Screen](https://gitlab.com/slashblog/netr-app/-/raw/main/screenshots/video.png?inline=false "Live Video Screen")

## Upgrade screen
![Upgrade Screen](https://gitlab.com/slashblog/netr-app/-/raw/main/screenshots/upgrade.png?inline=false "Upgrade Screen")

# Debug

# Firestick
adb connect <ip-addr>
