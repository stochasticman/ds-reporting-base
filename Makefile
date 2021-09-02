 
.PHONY: help tex-build py-build int all
.DEFAULT_GOAL: help
DATAFILES=$(wildcard working/dat/*)
SRCFILES=$(wildcard working/srcpy/*)
include .env

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(firstword $(MAKEFILE_LIST)) | \
	awk 'BEGIN {FS = ":.*?##"; \
	printf "\n\
	Usage:\n  \
	make \033[36m<target>\033[0m\n\n\
	Targets:\n"}; \
	{printf "  \033[36m%-30s\033[0m %s\n", $$1, $$2}'

.tex-built: latex.Dockerfile
	docker build -t latexcompiler:latest -f latex.Dockerfile .
	touch .tex-built

tex-build: .tex-built

tex-build: ## build base latex compiling image

.py-built: python.Dockerfile requirements.txt
	docker build -t pythonrunner:latest --build-arg PYTHON_VERSION=$(PYTHON_VERSION) -f python.Dockerfile .
	touch .py-built

py-build: .py-built

py-build: ## build base image for running python scripts

$(DATAFILES) : .py-built $(SRCFILES)

int: ## run all intermediate python scrips

int: $(DATAFILES)

main.pdf: .tex-built .py-built working/srctex/main.tex $(SRCFILES) $(DATAFILES)
	docker run -v ${PWD}/working:/working latexcompiler latexmk -aux-directory=/working/aux -output-format=pdf -emulate-aux-dir srctex/main.tex


pdf: ## build the pdf file

pdf: main.pdf

all: tex-build py-build int pdf

all: ## just run it all and give me my pdf
