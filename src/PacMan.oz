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
  
   %% Default values
   MAP  = map(r(1 1 1 1 1 1 1 1 1 1 1 1 1 1 1)
	r(0 0 0 0 0 0 3 0 0 0 0 0 0 0 0)
	r(0 1 1 1 1 1 1 1 1 1 1 1 1 1 0)
	r(0 0 0 0 4 0 0 0 0 0 0 0 0 0 0)
	r(0 1 1 1 1 1 1 1 1 1 1 1 1 1 0)
	r(0 0 0 0 0 0 0 5 0 0 0 0 0 0 0)
	r(0 1 1 1 1 1 1 1 1 1 1 1 1 1 0)
	r(0 0 0 0 0 0 0 0 0 3 0 0 0 0 0)
	r(0 1 1 1 1 1 1 1 1 1 1 1 1 1 0)
	r(0 0 0 0 3 0 0 0 0 0 0 0 0 0 0)
	r(0 1 1 1 1 1 1 1 1 1 1 1 1 1 0)
	r(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0)
	r(0 1 1 1 1 1 1 1 1 1 1 1 1 1 0)
	r(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0)
	r(1 1 1 1 1 1 1 1 1 1 1 1 1 1 1))
   LIVES    = 1

   %% For feedback
   Say    = System.showInfo

   % Posible arguments
   % Args = {Application.getArgs
   %            record(
   %                   map(single char:&m type:atom default:MAP)
   %                   lives(single char:&l type:int default:LIVES)
   %                   help(single char:[&? &h] default:false)
   %                  )}

in
   
   % Help message
   % if Args.help then
   %    {Say "Usage: "#{Property.get 'application.url'}#" [option]"}
   %    {Say "Options:"}
   %    {Say "  -m, --map FILE\tFile containing the map (default "#MAP#")"}
   %    {Say "  -l, --lives INT\tNumber of pac-man lives"}
   %    {Say "  -h, -?, --help\tThis help"}
   %    {Application.exit 0}
   % end

   {System.show 'These are the arguments to run the application'}
   %{Say "Map:\t"#Args.map}
   %{Say "Pac-man lives:\t"#Args.lives}

   %{System.show MAP}

   {GUI.startGame MAP LIVES}
   {System.show 'fin pacman'}
   % {Delay 1000}
   % {Application.exit 0}
    {System.show 'fin pacman'}
end
