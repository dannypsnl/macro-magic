SCRBL := scribble ++main-xref-in --redirect-main http://docs.racket-lang.org/

gh-pages:
	@git clone git@github.com:dannypsnl/macro-magic.git gh-pages -b gh-pages

OUT_DIR = gh-pages
.PHONY: build
build: $(OUT_DIR)
	@$(SCRBL) --dest $(OUT_DIR) scribblings/macro-magic.scrbl

.PHONY: publish
publish: build
	@cd $(OUT_DIR); git add -A
	@cd $(OUT_DIR); git commit -m "update $$(date +%Y/%m/%d-%H:%M:%S)"
	@cd $(OUT_DIR); git push origin gh-pages
