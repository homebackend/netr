#!/bin/bash

set -e

flutter build web --release --verbose --base-href /netr/
rm -f netr-web.tar.xz
cd build/web && tar cvJf netr-web.tar.xz * && cd -
