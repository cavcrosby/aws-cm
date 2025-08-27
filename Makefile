# special makefile variables
.DEFAULT_GOAL := help
.RECIPEPREFIX := >

# recursively expanded variables
SHELL = /usr/bin/sh

# targets
HELP = help
SETUP = setup

# executables
PYTHON = python
PIP = pip
NPM = npm
PRE_COMMIT = pre-commit

# simply expanded variables
executables := \
	${PYTHON}\
	${NPM}

_check_executables := $(foreach exec,${executables},$(if $(shell command -v ${exec}),pass,$(error "No ${exec} in PATH")))

.PHONY: ${HELP}
${HELP}:
	# inspired by the makefiles of the Linux kernel and Mercurial
>	@printf '%s\n' 'Common make targets:'
>	@printf '%s\n' '  ${SETUP}                - install the distro-independent dependencies for this'
>	@printf '%s\n' '                         project'

.PHONY: ${SETUP}
${SETUP}:
>	${NPM} install
>	${PYTHON} -m ${PIP} install --upgrade "${PIP}"
>	${PYTHON} -m ${PIP} install \
		--requirement "./requirements.txt" \
		--requirement "./requirements-dev.txt"

>	${PRE_COMMIT} install
