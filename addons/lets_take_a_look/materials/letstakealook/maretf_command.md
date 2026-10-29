### Command

Converting the running skeleton GIF to a VTF: `maretf create -i running_skeleton.gif --width 1024 --height 512 --format DXT1_ONE_BIT_ALPHA`

Note: For the previous frame not being cleared, consider converting the GIF to an APNG first and then using that.

Note 2: Also -coalesce on ezgif seems to work (and probably the imagemagick/gifsicle version of this as well), as an alternative to having to convert to APNG first
