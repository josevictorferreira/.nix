.DEFAULT_GOAL := help

.PHONY: help secrets rebuild clean push_configs

GIT_BASE_ADDRESS := git@github.com:josevictorferreira
SUBTREES := nvim tmux zsh ghostty hypr kitty waybar

SUBTRESS := \
	nvim=$(GIT_BASE_ADDRESS)/.nvim.git@main \
	tmux=$(GIT_BASE_ADDRESS)/.tmux.git@main \
	zsh=$(GIT_BASE_ADDRESS)/.zsh.git@main \
	ghostty=$(GIT_BASE_ADDRESS)/.ghostty.git@main \
	hypr=$(GIT_BASE_ADDRESS)/.hypr.git@main \
	kitty=$(GIT_BASE_ADDRESS)/.kitty.git@main \
	waybar=$(GIT_BASE_ADDRESS)/.waybar.git@main

subtree_sync: ## Add or sync subtrees to the config directory.
	@for entry in $(SUBTRESS); do \
		name=$$(echo $$entry | cut -d= -f1); \
		repo=$$(echo $$entry | cut -d= -f2 | cut -d@ -f1,2); \
		branch=$$(echo $$entry | cut -d@ -f3); \
		if [ ! -d "config/$$name" ]; then \
			echo "Adding $$repo -> config/$$name (branch $$branch)..."; \
			git subtree add --prefix=config/$$name $$repo $$branch --squash; \
		else \
			echo "Syncing config/$$name with $$repo (branch $$branch)..."; \
			git subtree push --prefix=config/$$name $$repo $$branch; \
		fi; \
	done

up_keys: ## Update keys for secrets files
	sops updatekeys secrets/secrets.enc.yaml

secrets: ## Edit the secrets file
	sops secrets/secrets.enc.yaml

update: ## Update flake
	sudo nix flake update

rebuild: ## Rebuild NixOS configuration.
	@if [ "$(shell uname)" = "Darwin" ]; then \
		darwin-rebuild switch --flake .#macos-macbook --impure; \
	else \
		sudo nixos-rebuild switch --flake .#nixos-desktop --impure; \
	fi

clean: ## Clean up the Nix store.
	nix-collect-garbage -d

help: ## Show this help.
	@printf "Usage: make [target]\n\nTARGETS:\n"; grep -F "##" $(MAKEFILE_LIST) | grep -Fv "grep -F" | grep -Fv "printf " | sed -e 's/\\$$//' | sed -e 's/##//' | column -t -s ":" | sed -e 's/^/    /'; printf "\n"
