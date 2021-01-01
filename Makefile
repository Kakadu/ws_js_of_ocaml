.PHONY: release all client server run clean celan watch

OPTS =
release: OPTS += --profile=release
all: server client

#client:
	#dune build foo.bs.js

#server:
#	dune build server-stats/server.bc.js

.PHONY: server-stats run-server-stats
server-stats:
	dune build @server-stats/all

run-server-stats:
	node _build/default/server-stats/server.bc.js

celan: clean
clean:
	@dune clean

watch:
	dune build -w
