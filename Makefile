all: run 

bin:
	mkdir -p bin
	
compile: bin 
	ozc -c src/PacMan.oz -o bin/PacMan.ozf
	ozc -c src/PacManGUI.oz -o bin/PacManGUI.ozf
	
run: compile 
	ozengine bin/PacMan.ozf $(MAKECMDGOALS)

clean:
	rm -rf bin
	
mrproper: clean
