all: run 
ARGS = -h true

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
