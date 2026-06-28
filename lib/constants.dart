/*
 * Copyright (c) 2024 Neeraj Jakhar
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

const String appName = 'Netr App';
const String appIcon = 'icons/netr.png';
const String appEyeIcon = 'icons/eye.png';
const String githubOrganization =
    String.fromEnvironment('GH_OWNER', defaultValue: 'homebackend');
const String githubRepo =
    String.fromEnvironment('GH_REPO', defaultValue: 'netr');
const String baseAssetName = 'netr';
const String upgradeFileName = 'netr-release.apk';
