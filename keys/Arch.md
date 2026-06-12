# Support for installing on Arch Linux

1. Import Key into Pacman Keyring:

```bash
sudo pacman-key --add netr-public.asc
```

2. Locally Trust the Key:

```bash
sudo pacman-key --lsign-key 85801078E69D75B2
```

3. Install package:

```bash
sudo pacman -U https://github.com/homebackend/netr/releases/download/v2.7.2/netr-linux-x64.pkg.tar.zst
```
Substitute version in the above URL with appropriate version string.
