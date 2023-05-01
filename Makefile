.DEFAULT_GOAL := help

include .env

# export all .env vars
$(eval export $(shell sed -ne 's/ *#.*$$//; /./ s/=.*$$// p' .env))

.PHONY: help
help: ## Prints help for targets with comments
	@echo "Usage: make [target]\n"
	@cat ${MAKEFILE_LIST} | grep "[#]# " | grep -v grep | sort | column -t -s '##' | sed -e 's/^/- /'
	@echo ""


.PHONY: run
run: ## Run the proxy
	@go run .
