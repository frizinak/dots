BIN = bin
CONTRIB = contrib
CONFIG = config
SERVICES = services

ALL = st awesome qutebrowser
.PHONY: all
all: $(ALL)

.PHONY: st
st: $(BIN)/st

.PHONY: awesome
awesome: wm/awesome/vars.lua wm/awesome/theme.lua $(SERVICES)/friz-load.service

.PHONY: qutebrowser
qutebrowser: browser/qutebrowser/config.py 

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

$(BIN) $(CONTRIB):
	@mkdir "$@" 2>/dev/null || true

# BIN = "$(PWD)/bin"
# CONFIG = "$(PWD)/config"
# SERVICES = "$(PWD)/services"
# .PHONY: all
# all: build theme
# 
# .PHONY: build
# build: | $(BIN)
# 	echo $(PATHS)
# 	@find ./ -mindepth 2 -type f -name 'Makefile' -not -path './contrib/*' -print0 | \
# 		while IFS= read -r -d '' file; do \
# 			BIN="$(BIN)" CONFIG=$(CONFIG) make -C "$$(dirname "$$file")"; \
# 		done
# 
# .PHONY: build
# theme: build | themes/active
# 	$(BIN)/friz-theme \
# 		-awesome wm/awesome/theme.lua \
# 		-st contrib/st \
# 		themes/active
# 
# themes/active:
# 	ln -sf one "$@"
# 
