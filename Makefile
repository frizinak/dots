BIN = bin
CONTRIB = contrib
CONFIG = configs
SERVICES = services
FONTS = $(CONTRIB)/fonts
CONFIGS = $(patsubst $(CONFIG).def/%,$(CONFIG)/%,$(wildcard $(CONFIG).def/*))

AWESOME=wm/awesome
QUTE=browser/qutebrowser

UNIFONTS = $(FONTS)/unifont_upper-12.1.03.ttf \
	$(FONTS)/unifont_csur-12.1.03.ttf \
	$(FONTS)/unifont-12.1.03.ttf \
	$(FONTS)/unifont-12.1.03.bdf.gz \

FONTSLIST = $(UNIFONTS)

FONT_REPOS = https://github.com/Tecate/bitmap-fonts \
	https://github.com/sunaku/tamzen-font \
	https://github.com/librefonts/lekton \
	https://github.com/koemaeda/gohufont-ttf \
	https://github.com/adobe-fonts/source-code-pro

define FONT_REPO_TARGET
FONTSLIST += $(FONTS)/$(shell basename "$(1)")
$(FONTS)/$(shell basename "$(1)"): | $(FONTS)
	@echo "$(1)" "$$@"
	git clone "$(1)" "$$@"
endef

define DAFONT_TARGET
FONTSLIST += $(FONTS)/dafont/$(1).ttf
$(FONTS)/dafont/$(1).ttf: | $(FONTS) $(FONTS)/dafont
	curl -Ss "https://dl.dafont.com/dl/?f=$(1)" > "$(FONTS)/dafont/$(1).zip"
	unzip -o -d "$(FONTS)/dafont/tmp-$(1)" "$(FONTS)/dafont/$(1).zip"
	mv "$(FONTS)/dafont/tmp-$(1)/$(2)" "$$@.tmp"
	rm -rf "$(FONTS)/dafont/tmp-$(1)"
	rm "$(FONTS)/dafont/$(1).zip"
	mv "$$@.tmp" "$$@"
endef

MISC = misc/.xinitrc misc/.xbindkeysrc

WALLPAPERS = $(patsubst themes/wallpapers/%.png,themes/%,$(wildcard themes/wallpapers/*))
WALLPAPERS += $(patsubst themes/wallpapers/%.jpg,themes/%,$(wildcard themes/wallpapers/*))

_THEME = $(shell readlink themes/active)
ACTIVETHEME =
ifneq ($(_THEME),)
	ACTIVETHEME = themes/$(_THEME)
endif

CONTRIBS_UPDATE = $(patsubst $(CONTRIB)/%,$(CONTRIB)/%-update,$(wildcard $(CONTRIB)/*))
CONTRIBS_UPDATE += $(patsubst $(FONTS)/%,$(FONTS)/%-update,$(wildcard $(FONTS)/*))
BINS = $(wildcard $(BIN)/*)

ALL = config st awesome qutebrowser fonts $(MISC)
.PHONY: all
all: $(ALL)

.PHONY: config
config:  $(CONFIGS)

.PHONY: st
st: $(BIN)/st

.PHONY: awesome
awesome: $(AWESOME)/vars.lua $(AWESOME)/theme.lua $(SERVICES)/friz-load.service

.PHONY: qutebrowser
qutebrowser: $(QUTE)/config.py 

$(foreach i,$(FONT_REPOS),$(eval $(call FONT_REPO_TARGET,$(i))))
$(eval $(call DAFONT_TARGET,pixel_unicode,Pixel-UniCode.ttf))
$(eval $(call DAFONT_TARGET,saxmono,saxmono.ttf))
$(eval $(call DAFONT_TARGET,basis33,basis33.ttf))

.PHONY: fonts
fonts: $(FONTSLIST) misc/friz-fonts.conf
	fc-cache -r

.PHONY: misc
misc: $(MISC)

.PHONY: theme
theme: $(WALLPAPERS) | themes
	./utils/theme-picker $(THEME)
	$(MAKE) all

themes/%: themes/wallpapers/%.* $(BIN)/friz-theme $(CONFIG)/wallpaper-settings | themes
	c=$$(grep contrast $(CONFIG)/wallpaper-settings | cut -d: -f2); \
	s=$$(grep dark $(CONFIG)/wallpaper-settings | cut -d: -f2 | grep -qv 1 && echo '-swap'); \
	$(BIN)/friz-theme -export $$s -contrast $${c:-0} "$<" > "$@.tmp"
	mv "$@.tmp" "$@"

.PHONY: update _update
update:
	git fetch && git merge origin/master
	$(MAKE) _update

_update: $(CONTRIBS_UPDATE)
	$(MAKE) $(BINS)

.PHONY: reload
reload:
	@- pgrep qutebrowser && qutebrowser :config-source
	@- awesome-client 'awesome.restart()'

.PHONY: help
help:
	@echo 'Collection of my dotfiles using make to customize them.'
	@echo '- requires golang, systemd, imagemagick and probably a few other things'
	@echo '- since everything is optional, you can run `make awesome` instead of'
	@echo '  `make all` but Meta+Space will still try to spawn st, ...'
	@echo '- no functional install target, run "make install" for help installing' 
	@echo '- wip, too little documentation, not all my dots migrated, ...'
	@echo
	@echo 'ATM contains:'
	@echo '- my awesomewm config [https://raw.githubusercontent.com/frizinak/dots/master/.repo/awesome.png]'
	@echo '    - frizinak/goclip, an fzf powered clipboard fuzzy matcher thingy (Meta+Shift+P)'
	@echo '      depends on misc/.xinitrc and misc/.xbindkeysrc'
	@echo '    - a lightweight load widget'
	@echo '      (cpu-clock, temp, load, freemem, totalmem, pctmem, netup, netdown, volume)'
	@echo '- st as a terminal'
	@echo '- qutebrowser'
	@echo '- theming target for all of the above `make theme`'
	@echo '- generate themes from wallpapers'
	@echo '- bunch of fonts'
	@echo
	@echo '$$ make config'
	@echo '- prepares ./$(CONFIG) directory, which allows you to make config changes'
	@echo
	@echo '$$ make -j [all]'
	@echo '- builds all targets'
	@echo
	@echo '$$ make -j update'
	@echo '- update this repo and contribs'
	@echo
	@echo '$$ make list'
	@echo '- print available targets'
	@echo
	@echo '$$ make -j theme'
	@echo '- generate themes from ./themes/wallpapers and activate one'
	@echo '- themes are stored in ./themes if you like an autogenerated one'
	@echo '  rename it so it does not get overwritten by a wallpaper colorscheme'
	@echo
	@echo '$$ make reload'
	@echo '- restart awesomewm'
	@echo '- reload qutebrowser config'
	@echo
	@echo '$$ make install'
	@echo '- removes all files on your hdd'
	@echo '- nah, just a help text explaining how to install everything'
	@echo "- don't think it makes much sense to install everything, you pick, choose and ln"
	@echo
	@echo 'About fonts:'
	@echo '- monospace everything'
	@echo '- monospacebmp force bitmap version (st)' 
	@echo '- monospacettf force ttf version (awesome / pango)'
	@echo
	@echo '- change font of st: $(CONFIG)/st-config.h'
	@echo '- change font of awesome: $(CONFIG)/awesome-vars.lua'
	@echo "- don't like something in the supplied friz-fonts.conf, override it"
	@echo '  with an e.g. $$HOME/.config/fontconfig/conf.d/20-stupid-friz.conf'
	@echo '  or if nothing suits you: remove the friz-fonts.conf symlink'
	@echo '  note: you will need to reconfigure st and awesome (see higher)'
	@echo

.PHONY: list
list:
	@echo $(ALL)
	@echo update theme reload

.PHONY: install
install:
	@echo "tl;dr: backup and ln -s"
	@echo
	@echo "################################################################################"
	@echo "################################# QUTEBROWSER ##################################"
	@echo "################################################################################"
	@echo "> Backup your own .config/qutebrowser/config.py"
	@echo "> symlink: ln -s '$(PWD)/$(QUTE)/config.py' '$(HOME)/.config/qutebrowser/config.py'"
	@echo "> restart qutebrowser or run :config-source"
	@echo
	@echo "################################################################################"
	@echo "###################################### ST ######################################"
	@echo "################################################################################"
	@echo "> symlink $(PWD)/$(BIN)/st to somewhere in your path (e.g.: /usr/bin/st)"
	@echo "> sudo ln -s '$(PWD)/$(BIN)/st' /usr/bin/st"
	@echo "> alteratively add $(PWD)/$(BIN) to your path"
	@echo
	@echo "################################################################################"
	@echo "################################## AWESOMEWM ###################################"
	@echo "################################################################################"
	@echo "> ln -s '$(PWD)/$(AWESOME)' '$(HOME)/.config/awesome'"
	@echo "> requires friz-load to be running. @see services"
	@echo
	@echo "################################################################################"
	@echo "################################### SERVICES ###################################"
	@echo "################################################################################"
	@echo "> NOTE: this deletes existing service files with same name (unlikely but still):"
	@echo "> ln -sf '$(PWD)/$(SERVICES)/'*.service '$(HOME)/.config/systemd/user/'"
	@echo "> systemctl --user daemon-reload"
	@echo "> systemctl --user start friz-load"
	@echo "> systemctl --user enable friz-load"
	@echo
	@echo "################################################################################"
	@echo "##################################### FONTS ####################################"
	@echo "################################################################################"
	@echo "> ln -s '$(PWD)/misc/friz-fonts.conf' '$(HOME)/.config/fontconfig/conf.d/10-friz.conf'"
	@echo "> ln -s '$(PWD)/$(FONTS)' '$(HOME)/.fonts/friz-contrib-fonts'"
	@echo "> fc-cache -rf"
	@echo
	@echo "################################################################################"
	@echo "##################################### MISC #####################################"
	@echo "################################################################################"
	@echo "> bunch of individual dotfiles"
	@echo "> you guessed it, ln -s"
	@echo

.PHONY: readme
readme: README.md

README.md: Makefile
	@echo '# Dots' > "$@.tmp"
	@echo >> "$@.tmp"
	$(MAKE) -s help >> "$@.tmp"
	if ! diff "$@.tmp" "$@"; then \
		mv "$@.tmp" "$@" && \
		git add README.md && \
		git add Makefile && \
		git commit -m 'readme' -e; \
	fi
	rm -f "$@.tmp"

%-update:
	@echo "$*"
	@if [ -d "$*/.git" ]; then \
		git -C "$*" fetch; \
		git -C "$*" reset --hard $$(git -C "$*" rev-parse --abbrev-ref --symbolic-full-name @{u}); \
	fi

$(CONFIG)/%: | $(CONFIG).def/% $(CONFIG)
	cp "$(CONFIG).def/$$(basename "$@")" "$@"

$(BIN)/friz-load: utils/load $(shell find utils/load -type f -name '*.go') | $(BIN)
	sh -c 'cd "$<" && go build -o "$(PWD)/$@" ./'

$(BIN)/friz-theme: utils/linuxtheme $(shell find utils/linuxtheme -type f -name '*.go') | $(BIN)
	sh -c 'cd "$<" && go build -o "$(PWD)/$@" ./cmd/linuxtheme'

$(BIN)/st: $(CONTRIB)/st/st
	cp -f "$<" "$@"

$(BIN)/goclip: $(CONTRIB)/goclip
	sh -c 'cd "$<" && go build -o "$(PWD)/$@" ./'

$(BIN)/fzf: $(CONTRIB)/fzf
	sh -c 'cd "$<" && go build -o "$(PWD)/$@" ./'

$(CONTRIB)/st/st: themes/active $(ACTIVETHEME) $(CONTRIB)/st $(CONFIG)/st-config.h | $(BIN)/friz-theme
	cp $(CONFIG)/st-config.h $(CONTRIB)/st/config.h
	$(BIN)/friz-theme -st $(CONTRIB)/st -st-noinstall -st-nofont "$<"
	make -C $(CONTRIB)/st
	touch $(CONTRIB)/st/st

$(CONTRIB)/st: | $(CONTRIB)
	git clone git://git.suckless.org/st "$@"

$(CONTRIB)/goclip: | $(CONTRIB)
	git clone https://github.com/frizinak/goclip "$@"

$(CONTRIB)/fzf: | $(CONTRIB)
	git clone https://github.com/junegunn/fzf "$@"

$(QUTE)/config.py: $(QUTE)/config.def.py themes/active $(ACTIVETHEME) | $(BIN)/friz-theme
	cp "$<" "$@"
	$(BIN)/friz-theme -qutebrowser "$@" themes/active

$(AWESOME)/vars.lua: $(CONFIG)/awesome-vars.lua
	cp "$<" "$@"

$(AWESOME)/theme.lua: themes/active $(AWESOME)/theme.def.lua $(ACTIVETHEME) | $(BIN)/friz-theme
	cp $(AWESOME)/theme.def.lua "$@"
	$(BIN)/friz-theme -awesome "$@" "$<"

themes/active: | themes
	ln -sf default themes/active

themes: | themes.def
	cp -r themes.def "$@"
	mkdir "$@/wallpapers"

$(SERVICES)/friz-load.service: $(SERVICES)/friz-load.service.def $(CONFIG)/netiface | $(BIN)/friz-load
	sed "s#{bin}#$$(realpath "$(BIN)")#" "$<" > "$@.tmp"
	sed -i "s#{iface}#$$(cat "$(CONFIG)/netiface")#" "$@.tmp"
	mv "$@.tmp" "$@"

$(UNIFONTS): | $(FONTS)
	curl -Ss "http://unifoundry.com/pub/unifont/unifont-12.1.03/font-builds/$$(basename "$@")" > "$@.tmp"
	mv "$@.tmp" "$@"

misc/.xinitrc: misc/.xinitrc.def $(CONFIG)/xinit $(CONFIG)/goclip
	sed '/^{custom}$$/,$$d' "$<" > "$@.tmp"
	cat $(CONFIG)/xinit >> "$@.tmp"
	@if grep -q '^1' $(CONFIG)/goclip; then \
		$(MAKE) $(BIN)/goclip $(BIN)/fzf; \
		echo 'goclip &' >> "$@.tmp"; \
	fi
	sed '1,/^{custom}$$/d' "$<" >> "$@.tmp"
	mv "$@.tmp" "$@"
	chmod +x "$@"

misc/.xbindkeysrc: misc/.xbindkeysrc.def misc/.xbindkeysrc.goclip $(CONFIG)/xbindkeys $(CONFIG)/goclip
	cp "$<" "$@.tmp"
	@if grep -q '^1' $(CONFIG)/goclip; then \
		cat misc/.xbindkeysrc.goclip >> "$@.tmp"; \
	fi
	cat $(CONFIG)/xbindkeys >> "$@.tmp"
	mv "$@.tmp" "$@"

misc/friz-fonts.conf: misc/friz-fonts.conf.def
	cp "$<" "$@"

$(CONFIG) $(BIN) $(CONTRIB) $(FONTS) $(FONTS)/dafont:
	@mkdir -p "$@" 2>/dev/null || true

.PHONY: reset
reset:
	@echo -en '\033[31m'
	@echo '################################################################################'
	@echo '# This is mainly for debugging purposes, all your configs etc will be deleted! #'
	@echo '################################################################################'
	@echo -en '\033[0m'
	@echo
	git clean -dnx | sed 's/^Would/Will/' | grep -v 'skip repository.* $(CONTRIB)'
	@echo "Will remove $(CONTRIB)"
	@echo -n "Continue? [y/N] "
	@read -n 1 delete; \
		if [ "$$delete" == "y" ]; then \
			echo \
			git clean -dxf && \
			rm -rf "$(CONTRIB)" && \
			echo cleaned; \
		fi

.PHONY: clean
clean:
	rm -rf $(BIN) $(CONTRIB) $(FONTS)
	rm -f $(AWESOME)/vars.lua
	rm -f $(AWESOME)/theme.lua
	rm -f $(QUTE)/config.py
	rm -f $(MISC)
	rm -f $(SERVICES)/friz-load.service
	rm -f misc/friz-fonts.conf
