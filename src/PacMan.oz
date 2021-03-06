/*-------------------------------------------------------------------------
 *
 * This is a template for the Project of INGI1131: PacMan 
 * The objective is to porvide you with a starting point for application
 * programming in Mozart-Oz, and with a standard way of recibing arguments for
 * the program.
 *
 * Compile in Mozart 2.0
 *     ozc -c PacMan.oz  **This will generate PacMan.ozf
 *     ozengine PacMan.ozf
 * Examples of execution
 *    ozengine PacMan --help
 *    ozengine PacMan --map mymap
 *    ozengine PacMan -m mymap --z 4 -i 4
 *
 *-------------------------------------------------------------------------
 */

functor
import
   Application
   Property
   System
   GUI at 'PacManGUI.ozf'
   Open
   Pickle

define


   % MAP  = map(
   % 	r(1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1)
   % 	r(1 5 0 0 0 0 0 3 0 1 0 0 2 0 0 0 1)
   % 	r(1 1 1 0 1 1 1 0 1 1 1 1 1 1 1 0 1)
   % 	r(1 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 1)
   % 	r(1 0 0 0 1 1 1 1 1 1 1 0 1 1 1 1 1)
   % 	r(1 0 1 0 0 0 4 3 2 0 0 0 0 0 0 0 1)
   % 	r(1 1 1 1 1 0 1 1 1 1 0 1 1 1 1 0 1)
   % 	r(1 0 0 0 0 0 0 0 0 1 0 1 5 0 0 0 1)
   % 	r(1 0 1 1 1 1 1 1 0 1 0 1 1 1 1 0 1)
   % 	r(1 0 0 0 0 3 0 0 0 1 0 0 0 0 0 0 1)
   % 	r(1 1 1 0 1 1 1 1 0 1 1 1 1 1 0 1 1)
   % 	r(1 0 0 0 0 0 2 0 0 0 0 1 2 0 0 0 1)
   % 	r(1 1 1 1 1 0 1 1 1 1 0 1 1 1 1 0 1)
   % 	r(1 0 0 0 0 0 1 0 5 0 0 0 0 0 0 0 1)
   % 	r(1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1))
   LIVES   = 5
   %MAP = map(
   %r(1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1)
   %r(1 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 1)
   %r(1 2 1 1 0 1 1 1 0 1 0 1 1 1 0 1 1 2 1)
   %r(1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1)
   %r(1 0 1 1 0 1 0 1 1 1 1 1 0 1 0 1 1 0 1)
   %r(1 0 0 0 0 1 0 0 0 1 0 0 0 1 0 0 0 0 1)
   %r(1 1 1 1 0 1 1 1 0 1 0 1 1 1 0 1 1 1 1)
   %r(1 1 1 1 0 1 0 0 0 0 0 0 0 1 0 1 1 1 1)
   %r(1 1 1 1 0 1 0 1 1 0 1 1 0 1 0 1 1 1 1)
   %r(1 5 0 0 0 0 0 1 3 3 3 1 0 0 0 0 0 5 1)
   %r(1 1 1 1 0 1 0 1 1 1 1 1 0 1 0 1 1 1 1)
   %r(1 1 1 1 0 1 0 0 0 0 0 0 0 1 0 1 1 1 1)
   %r(1 1 1 1 0 1 0 1 1 5 1 1 0 1 0 1 1 1 1)
   %r(1 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 1)
   %r(1 0 1 1 0 1 1 1 0 1 0 1 1 1 0 1 1 0 1)
   %r(1 2 0 1 0 0 0 0 0 4 0 0 0 0 0 1 0 2 1)
   %r(1 1 0 1 0 1 0 1 1 1 1 1 0 1 0 1 0 1 1)
   %r(1 0 0 0 0 1 0 0 0 1 0 0 0 1 0 0 0 0 1)
   %r(1 0 1 1 1 1 1 1 0 1 0 1 1 1 1 1 1 0 1)
   %r(1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1)
   %r(1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1))
   DEFMAP = 'default_map.ozp' 
   LIVES   = 5
   

   %% For feedback
   Say    = System.showInfo

   % Posible arguments
   Args = {Application.getArgs
               record(
		  map(single char:&m type:atom default:DEFMAP)
		  lives(single char:&l type:int default:LIVES)
		  help(single char:[&? &h] default:false)
		  )}


   fun {LoadPickle URL}
      F={New Open.file init(url:URL flags:[read])}
   in
      try
	 VBS
      in
	 {F read(size:all list:VBS)}
	 {Pickle.unpack VBS}
      finally
	 {F close}
      end
   end

   
in
   
    %Help message
    if Args.help then
       {Say "Usage: "#{Property.get 'application.url'}#" [option]"}
       {Say "Options:"}
       {Say "  -m, --map FILE\tFile containing the map (default "#DEFMAP#")"}
       {Say "  -l, --lives INT\tNumber of pac-man lives (default "#LIVES#")"}
       {Say "  -h, -?, --help\tThis help"}
    
       {Application.exit 0}
    end
    
   {System.show 'These are the arguments to run the application'}
    {Say "Map:\t"#Args.map}
    {Say "Pac-man lives:\t"#Args.lives}

    {GUI.startGame {LoadPickle Args.map} Args.lives}

    {System.show 'test'}
   {Application.exit 0}
end
