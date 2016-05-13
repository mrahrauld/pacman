all: run 

ARGS = -m map(
	r(1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1)
	r(1 5 0 0 0 0 0 3 0 1 0 0 2 0 0 0 1)
	r(1 1 1 0 1 1 1 0 1 1 1 1 1 1 1 0 1)
	r(1 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 1)
	r(1 0 0 0 1 1 1 1 1 1 1 0 1 1 1 1 1)
	r(1 0 1 0 0 0 4 3 2 0 0 0 0 0 0 0 1)
	r(1 1 1 1 1 0 1 1 1 1 0 1 1 1 1 0 1)
	r(1 0 0 0 0 0 0 0 0 1 0 1 5 0 0 0 1)
	r(1 0 1 1 1 1 1 1 0 1 0 1 1 1 1 0 1)
	r(1 0 0 0 0 3 0 0 0 1 0 0 0 0 0 0 1)
	r(1 1 1 0 1 1 1 1 0 1 1 1 1 1 0 1 1)
	r(1 0 0 0 0 0 2 0 0 0 0 1 2 0 0 0 1)
	r(1 1 1 1 1 0 1 1 1 1 0 1 1 1 1 0 1)
	r(1 0 0 0 0 0 1 0 5 0 0 0 0 0 0 0 1)
	r(1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1))

bin:
	mkdir -p bin
	
compile: bin 
	ozc -c src/PacMan.oz -o bin/PacMan.ozf
	ozc -c src/PacManGUI.oz -o bin/PacManGUI.ozf
	
run: compile 
	ozengine bin/PacMan.ozf $(ARGS)

clean:
	rm -rf bin
	
mrproper: clean
