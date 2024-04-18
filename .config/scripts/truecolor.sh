#!/usr/bin/awk -f
#
# https://gist.github.com/XVilka/8346728
#

BEGIN {
    WIDTH = 80

    for (col = 0; col < WIDTH; col++) {
        r = 255 - (col * 255 / WIDTH);
        g = col * 510 / WIDTH;
        b = col * 255 / WIDTH;
        if (g > 255) g = 510 - g;
        printf "\033[48;2;%d;%d;%dm", r, g, b;
        printf "\033[38;2;%d;%d;%dm", 255 - r, 255 - g, 255 - b;
        printf "%s\033[0m", " ";
    }

    printf "\n";
}
