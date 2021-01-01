.PHONY: release all client server run clean celan watch

OPTS =
release: OPTS += --profile=release
all: server client

#client:
	#dune build foo.bs.js

#server:
#	dune build server-stats/server.bc.js
define MAKE_RULES0
.PHONY: $(1) run-$(1)
$(1):
	dune build @$(1)/all

run-$(1):
	node _build/default/$(1)/server.bc.js
endef

DEMOS=server-stats chat
$(foreach i,$(DEMOS),$(eval $(call MAKE_RULES0,$(i)) ) )




celan: clean
clean:
	@dune clean

watch:
	dune build -w
