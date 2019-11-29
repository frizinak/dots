# Dots

Collection of my dotfiles using make to customize them.
- requires golang, systemd, imagemagick and probably a few other things
- since everything is optional, you can run `make awesome` instead of
  `make all` but Meta+Space will still try to spawn st, ...
- no functional install target, run "make install" for help installing
- wip, too little documentation, not all my dots migrated, ...

ATM contains:
- my awesomewm config [https://raw.githubusercontent.com/frizinak/dots/master/.repo/awesome.png]
    - frizinak/goclip, an fzf powered clipboard fuzzy matcher thingy (Meta+Shift+P)
      depends on misc/.xinitrc and misc/.xbindkeysrc
    - a lightweight load widget
      (cpu-clock, temp, load, freemem, totalmem, pctmem, netup, netdown, volume)
- st as a terminal
- qutebrowser
- theming target for all of the above `make theme`
- generate themes from wallpapers
- bunch of fonts

$ make config
- prepares ./configs directory, which allows you to make config changes

$ make -j [all]
- builds all targets

$ make -j update
- update this repo and contribs

$ make list
- print available targets

$ make -j theme
- generate themes from ./themes/wallpapers and activate one
- themes are stored in ./themes if you like an autogenerated one
  rename it so it does not get overwritten by a wallpaper colorscheme

$ make reload
- restart awesomewm
- reload qutebrowser config

$ make install
- removes all files on your hdd
- nah, just a help text explaining how to install everything
- don't think it makes much sense to install everything, you pick, choose and ln

About fonts:
- monospace everything
- monospacebmp force bitmap version (st)
- monospacettf force ttf version (awesome / pango)

- change font of st: configs/st-config.h
- change font of awesome: configs/awesome-vars.lua
- don't like something in the supplied friz-fonts.conf, override it
  with an e.g. $HOME/.config/fontconfig/conf.d/20-stupid-friz.conf
  or if nothing suits you: remove the friz-fonts.conf symlink
  note: you will need to reconfigure st and awesome (see higher)

