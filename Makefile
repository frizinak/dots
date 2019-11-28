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

FONTSLIST = $(UNIFONTS) \
	$(FONTS)/bitmap-fonts \
	$(FONTS)/tamzen

MISC = misc/.xinitrc misc/.xbindkeysrc

WALLPAPERS = $(patsubst themes/wallpapers/%.png,themes/%,$(wildcard themes/wallpapers/*))
WALLPAPERS += $(patsubst themes/wallpapers/%.jpg,themes/%,$(wildcard themes/wallpapers/*))

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

.PHONY: fonts
fonts: $(FONTSLIST) misc/friz-fonts.conf

.PHONY: misc
misc: $(MISC)

.PHONY: theme
theme: $(WALLPAPERS) | themes
	./utils/theme-picker $(THEME)
	$(MAKE) all

themes/%: themes/wallpapers/%.* $(BIN)/friz-theme $(CONFIG)/wallpaper-contrast | themes
	$(BIN)/friz-theme -export -contrast $$(cat $(CONFIG)/wallpaper-contrast) "$<" > "$@.tmp"
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
	@echo 'Hello'
	@echo '- requires golang, systemd and imagemagick'
	@echo '- no functional install target, run "make install" for help installing' 
	@echo '- wip, too little documentation, not all my dots migrated, ...'
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
	@echo '- generate themes from themes/wallpapers and activate one'
	@echo
	@echo '$$ make reload'
	@echo '- restart awesomewm'
	@echo '- reload qutebrowser config'
	@echo
	@echo '$$ make install'
	@echo '- removes all files on your hdd'
	@echo '- nah, just a help text explaining how to install everything'
	@echo '- dont think it makes much sense to install everyting, you pick, choose and ln'

.PHONY: list
list:
	@echo $(ALL)
	@echo update theme reload

.PHONY: install
install:
	@echo "tl;dr: backup and ln -s"
	@echo
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

$(CONTRIB)/st/st: themes/active $(CONTRIB)/st $(CONFIG)/st-config.h | $(BIN)/friz-theme
	cp $(CONFIG)/st-config.h $(CONTRIB)/st/config.h
	$(BIN)/friz-theme -st $(CONTRIB)/st -st-noinstall "$<"
	make -C $(CONTRIB)/st
	touch $(CONTRIB)/st/st

$(CONTRIB)/st: | $(CONTRIB)
	git clone git://git.suckless.org/st "$@"

$(CONTRIB)/goclip: | $(CONTRIB)
	git clone https://github.com/frizinak/goclip "$@"

$(CONTRIB)/fzf: | $(CONTRIB)
	git clone https://github.com/junegunn/fzf "$@"

$(QUTE)/config.py: $(QUTE)/config.def.py themes/active | $(BIN)/friz-theme
	cp "$<" "$@"
	$(BIN)/friz-theme -qutebrowser "$@" themes/active

$(AWESOME)/vars.lua: $(AWESOME)/vars.def.lua $(CONFIG)/soundcard
	sed "s#soundcard =.*#soundcard = \"$$(cat "$(CONFIG)/soundcard")\"#" "$<" > "$@.tmp"
	mv "$@.tmp" "$@"

$(AWESOME)/theme.lua: themes/active $(AWESOME)/theme.def.lua | $(BIN)/friz-theme
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

$(FONTS)/bitmap-fonts: | $(FONTS)
	git clone https://github.com/Tecate/bitmap-fonts.git "$@"

$(FONTS)/tamzen: | $(FONTS)
	git clone https://github.com/sunaku/tamzen-font "$@"

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

$(CONFIG) $(BIN) $(CONTRIB) $(FONTS):
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
