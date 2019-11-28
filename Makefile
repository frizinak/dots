BIN = bin
CONTRIB = contrib
CONFIG = config
SERVICES = services
FONTS = $(CONTRIB)/fonts

FONTSLIST = $(FONTS)/unifont_upper-12.1.03.ttf \
	$(FONTS)/unifont_csur-12.1.03.ttf \
	$(FONTS)/unifont-12.1.03.ttf \
	$(FONTS)/unifont-12.1.03.bdf.gz \
	$(FONTS)/bitmap-fonts \
	$(FONTS)/tamzen

ALL = st awesome qutebrowser fonts
.PHONY: all
all: $(ALL)

.PHONY: st
st: $(BIN)/st

.PHONY: awesome
awesome: wm/awesome/vars.lua wm/awesome/theme.lua $(SERVICES)/friz-load.service

.PHONY: qutebrowser
qutebrowser: browser/qutebrowser/config.py 

.PHONY: fonts
fonts: $(FONTSLIST)

.PHONY: help
help:
	@echo 'Hello'
	@echo '- requires golang and systemd'
	@echo '- no functional install target, run "make install" for help installing' 
	@echo '- wip, too little documentation, not all my dots migrated, ...'
	@echo
	@echo '$$ make [all]'
	@echo '- builds all targets'
	@echo
	@echo '$$ make list'
	@echo '- print available targets'
	@echo
	@echo '$$ make install'
	@echo '- removes all files on your hdd'
	@echo '- nah, just a help text explaining how to install everything'
	@echo '- dont think it makes much sense to install everyting, you pick, choose and ln'

.PHONY: list
list:
	@echo $(ALL)

.PHONY: install
install:
	@echo "tl;dr: backup and ln -s"
	@echo
	@echo
	@echo "################################################################################"
	@echo "################################# QUTEBROWSER ##################################"
	@echo "################################################################################"
	@echo "> Backup your own .config/qutebrowser/config.py"
	@echo "> symlink: ln -s '$(PWD)/browser/qutebrowser/config.py' '$(HOME)/.config/qutebrowser/config.py'"
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
	@echo "> ln -s '$(PWD)/wm/awesome' '$(HOME)/.config/awesome'"
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
	@echo "> ln -s '$(PWD)/fonts/friz.conf' '$(HOME)/.config/fontconfig/conf.d/10-friz.conf'"
	@echo "> ln -s '$(PWD)/contrib/fonts' '$(HOME)/.fonts/friz-contrib-fonts'"
	@echo "> fc-cache -rf"
	@echo

$(BIN)/friz-load: utils/load $(shell find utils/load -type f -name '*.go') | $(BIN)
	sh -c 'cd "$<" && go build -o "$(PWD)/$@" ./'

$(BIN)/friz-theme: utils/linuxtheme $(shell find utils/linuxtheme -type f -name '*.go') | $(BIN)
	sh -c 'cd "$<" && go build -o "$(PWD)/$@" ./cmd/linuxtheme'

$(BIN)/st: themes/active | $(CONTRIB)/st $(BIN)/friz-theme
	$(BIN)/friz-theme -st $(CONTRIB)/st -st-noinstall "$<"
	make -C $(CONTRIB)/st
	cp $(CONTRIB)/st/st $(BIN)/st

$(CONTRIB)/st: | $(CONTRIB)
	git clone git://git.suckless.org/st "$@"

wm/awesome/vars.lua: wm/awesome/vars.def.lua $(CONFIG)/soundcard
	sed "s#soundcard =.*#soundcard = \"$$(cat "$(CONFIG)/soundcard")\"#" "$<" > "$@"

wm/awesome/theme.lua: themes/active | $(BIN)/friz-theme
	$(BIN)/friz-theme -awesome "$@" "$<"

themes/active:
	ln -sf one themes/active

$(SERVICES)/friz-load.service: $(SERVICES)/friz-load.service.def | $(BIN)/friz-load
	sed "s#{bin}#$$(realpath "$(BIN)")#" "$<" > "$@.tmp"
	sed -i "s#{iface}#$$(cat "$(CONFIG)/netiface")#" "$@.tmp"
	mv "$@.tmp" "$@"

browser/qutebrowser/config.py: browser/qutebrowser/config.def.py themes/active | $(BIN)/friz-theme
	cp "$<" "$@"
	$(BIN)/friz-theme -qutebrowser "$@" themes/active

$(UNIFONTS): | $(FONTS)
	curl -Ss "http://unifoundry.com/pub/unifont/unifont-12.1.03/font-builds/$$(basename "$@")" > "$@"

$(FONTS)/bitmap-fonts: | $(FONTS)
	git clone https://github.com/Tecate/bitmap-fonts.git "$@"

$(FONTS)/tamzen: | $(FONTS)
	git clone https://github.com/sunaku/tamzen-font "$@"

$(BIN) $(CONTRIB) $(FONTS):
	@mkdir "$@" 2>/dev/null || true
