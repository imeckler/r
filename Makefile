all:
	dune b src/r.exe
	mv _build/default/src/r.exe ./r
