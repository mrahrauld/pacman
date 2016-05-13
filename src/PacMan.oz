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

define

   
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
   %% Default values

   MAP3
   
   MAP  = map(
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
   LIVES   = 5

   

   MAP2 = './test_map.ozp'

   %{Value.toVirtualString MAP 1000 1000}

   %% For feedback
   Say    = System.showInfo

   % Posible arguments
   Args = {Application.getArgs
               record(
		  map(single char:&m type:atom default:MAP)
		  lives(single char:&l type:int default:LIVES)
		  help(single char:[&? &h] default:false)
		  )}
in
   
    %Help message
    if Args.help then
       {Say "Usage: "#{Property.get 'application.url'}#" [option]"}
       {Say "Options:"}
       {Say "  -m, --map FILE\tFile containing the map (default "#MAP2#")"}
       {Say "  -l, --lives INT\tNumber of pac-man lives (default "#LIVES#")"}
       {Say "  -h, -?, --help\tThis help"}
    
       {Application.exit 0}
    end

    MAP3 = {LoadPickle MAP2}

   {System.show 'These are the arguments to run the application'}
   %{Say "Map:\t"#Args.map}
    {Say "Pac-man lives:\t"#Args.lives}

   {GUI.startGame MAP Args.lives}
   {Application.exit 0}
end
