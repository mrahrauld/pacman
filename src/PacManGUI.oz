functor
import
   Module
   OS
   System
export
   StartGame
define
   [QTk]={Module.link ["x-oz://system/wp/QTk.ozf"]}
   Say    = System.showInfo
   Desc
   Window
   Canvas
   W
   H
   NW
   NH
   MainURL={OS.getCWD}
   PacManImg={QTk.newImage photo(url:MainURL#"/pacman.gif")}
   GhostImg={QTk.newImage photo(url:MainURL#"/ghost.gif")}
   WidthCell=40
   HeightCell=40
   
   Command
   CommandPort = {NewPort Command}
   
   proc{DrawBox Number X Y}
      case Number of 4 then
	 {Canvas create(image X*WidthCell+WidthCell div 2 Y*HeightCell+HeightCell div 2 image:PacManImg)}
      [] 3 then
	    {Canvas create(image X*WidthCell+WidthCell div 2 Y*HeightCell+HeightCell div 2 image:GhostImg)}
      else
	 {Canvas create(rect X*WidthCell Y*HeightCell X*WidthCell+WidthCell Y*HeightCell+HeightCell fill:black outline:black)}
      end
   end
   proc{InitLayout ListToDraw}
      proc{DrawHline X1 Y1 X2 Y2}
	 if X1>W orelse X1<0 orelse Y1>H orelse Y1<0 then
	    skip
	 else
	    {Canvas create(line X1 Y1 X2 Y2 fill:black)}
	    {DrawHline X1+HeightCell Y1 X2+HeightCell Y2}
	 end
      end
      proc{DrawVline X1 Y1 X2 Y2}
	 if X1>W orelse X1<0 orelse Y1>H orelse Y1<0 then
	    skip
	 else
	    {Canvas create(line X1 Y1 X2 Y2 fill:black)}
	    {DrawVline X1 Y1+WidthCell X2 Y2+WidthCell}
	 end
      end
      proc{DrawUnits L}
	 case L of r(Color X Y)|T then
	    {DrawBox Color X Y}
	    {DrawUnits T}
	 else
	    skip
	 end
      end
   in
      {DrawHline 0 0 0 W}
      {DrawVline 0 0 W 0}
      {DrawUnits ListToDraw}
   end
   proc{Game MySelf Ghosts Command}
      MyNewState
      NextCommand
      GhostNewStates
      GhostNewStates1
      fun {MoveTo Movement OldState}
	 NewX NewY DX DY OldX OldY Color  in
	 r(Color OldX OldY) = OldState
	 r(DX DY) = Movement
	 NewX = OldX + DX
	 NewY = OldY + DY
	 {DrawBox black OldX OldY}
	 {DrawBox Color NewX NewY}
	 r(Color NewX NewY)
      end
      fun {UserCommand Command OldState NewState}
	 case Command of r(DX DY)|T then
	    NewState = {MoveTo r(DX DY) OldState}
	    T
	 end
      end
      fun {MoveAll OldState NewState}
	 Dir
         in
	 case OldState
	 of Old|T then
	    Dir = {Int.'mod' {OS.rand} 4}
	    case Dir of 0 then
	       {MoveAll T {MoveTo r(~1 0) Old}|NewState}
	       [] 1 then {MoveAll T  {MoveTo r(0 1) Old}|NewState}
	       [] 2 then {MoveAll T  {MoveTo r(1 0) Old}|NewState}
	       [] 3 then {MoveAll T  {MoveTo r(0 ~1) Old}|NewState}
	    end
	 [] nil then  NewState
	 end
      end
   in
      NextCommand = {UserCommand Command MySelf MyNewState}
      GhostNewStates = {MoveAll Ghosts nil}
      GhostNewStates1 = {MoveAll GhostNewStates nil}
      {Game MyNewState GhostNewStates1 NextCommand}
   end

   proc {CreateGame MAP}

      %Taille du tableau 
      {Record.width MAP NW}
      {Record.width MAP NH}

      W =WidthCell*NW
      H =HeightCell*NH
      %NH = NW

      %Creation de la window
      Desc=td(canvas(bg:black
                  width:W
                  height:H
                  handle:Canvas))
      Window={QTk.build Desc}

      %Ajout des commandes
      {Window bind(event:"<Up>" action:proc{$} {Send CommandPort r(0 ~1)} end)}
      {Window bind(event:"<Left>" action:proc{$} {Send CommandPort r(~1 0)} end)}
      {Window bind(event:"<Down>" action:proc{$} {Send CommandPort r(0 1)}  end)}
      {Window bind(event:"<Right>" action:proc{$} {Send CommandPort r(1 0)} end)}

      {Window show}

      {Say "test1"}
      {CreateTable MAP {Record.arity MAP}}
      {Say "test2"}

   end

   proc {CreateTable MAP ARITY}
      case ARITY of H|T then
	 {CreateLine MAP.H {Record.arity MAP.H} H}
	 {CreateTable MAP T}
      else
	 skip
      end
   end

   proc {CreateLine LINE ARITY Y}
      case ARITY of H|T then
	 {DrawBox LINE.H H Y}
	 {CreateLine LINE T Y}
      else
	 skip
      end
   end

   
   proc {StartGame}
      MySelf
      Ghosts
      MAP = map(r(1 1 1 1 1 1 1 5 1 1 1 1 1 1 1)
	r(1 4 0 0 0 0 0 0 0 1 0 0 0 0 1)
	r(1 0 0 0 0 0 0 0 0 1 2 0 0 0 1)
	r(1 0 0 0 0 0 0 0 0 1 0 0 0 0 1)
	r(1 0 0 0 3 0 0 0 0 1 1 1 0 0 1)
	r(1 0 0 0 0 0 0 0 0 1 0 0 0 0 1)
	r(1 0 0 0 0 0 0 0 0 1 0 0 0 0 1)
	r(1 1 1 0 0 1 1 1 1 1 0 0 0 0 1)
	r(1 0 0 0 0 0 0 1 0 0 0 0 0 0 1)
	r(1 3 0 0 0 0 0 1 0 0 0 0 0 3 1)
	r(1 0 0 0 0 0 0 1 0 0 0 0 0 0 1)
	r(1 0 0 0 0 0 0 1 0 0 0 0 0 0 1)
	r(1 0 0 0 0 0 0 1 2 0 0 0 0 0 1)
	r(1 0 0 0 0 0 0 0 0 0 0 0 0 0 1)
	r(1 1 1 1 1 1 1 1 1 1 1 1 1 1 1))
   in
      {System.show 'test3'}
      %{Browse show}
      {CreateGame MAP}
      %{Browse aftershow}
      %Initialize ghosts and user
      MySelf = r(white 1 1)
      Ghosts = [r(red 4 4)]
      %{InitLayout MySelf|Ghosts}
      {Game MySelf Ghosts Command}
   end
end
