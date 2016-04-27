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
   NCoinInit
   MainURL={OS.getCWD}
   PacManImg={QTk.newImage photo(url:MainURL#"/pacman.gif")}
   GhostImg={QTk.newImage photo(url:MainURL#"/ghost.gif")}
   CoinImg={QTk.newImage photo(url:MainURL#"/yellow-coin.gif")}
   WidthCell=40
   HeightCell=40
   
   Command
   CommandPort = {NewPort Command}
   
   proc{DrawBox Number X Y}
      case Number of 0 then  %Empty case
	 {Canvas create(image X*WidthCell + WidthCell div 2 Y*HeightCell + HeightCell div 2   image:CoinImg)}
      [] 1 then %Wall
	 {Canvas create(rect X*WidthCell Y*HeightCell X*WidthCell+WidthCell Y*HeightCell+HeightCell fill:white outline:black)}
      [] 2 then %Power pellets
	 skip
      [] 3 then %Ghost
	 {Canvas create(image X*WidthCell + WidthCell div 2 Y*HeightCell + HeightCell div 2   image:GhostImg)}
      [] 4 then %Pacman
	 {Canvas create(image X*WidthCell + WidthCell div 2  Y*HeightCell + HeightCell div 2    image:PacManImg)}
      else %Whorhole
	 {Canvas create(rect X*WidthCell Y*HeightCell X*WidthCell+WidthCell Y*HeightCell+HeightCell fill:black outline:black)}
      end
   end
   
   proc{Game MySelf Ghosts Command MAP}
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
	 if NewX<0 orelse NewX>(NW-1) orelse NewY<0 orelse NewY>(NH-1) orelse {GetElement NewX NewY MAP} == 1 then
	    r(Color OldX OldY)
	 else
	    {DrawBox black OldX OldY}
	    {DrawBox 4 NewX NewY}
	    r(Color NewX NewY)
	 end
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
      {Game MyNewState GhostNewStates1 NextCommand MAP}
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

      {CreateTable MAP {Record.arity MAP}}

   end

   proc {CreateTable MAP ARITY}
      case ARITY of H|T then
	 {CreateLine MAP.H {Record.arity MAP.H} H-1}
	 {CreateTable MAP T}
      else
	 skip
      end
   end

   proc {CreateLine LINE ARITY Y}
      case ARITY of H|T then
	 {DrawBox LINE.H H-1 Y}
	 {CreateLine LINE T Y}
      else
	 skip
      end
   end

   fun {GetElement X Y MAP}
      Line in
      if X > (NW - 1) orelse X < 0 orelse Y > (NH - 1) orelse Y < 0 then
	 MAP
      else
	 Line = MAP.(Y+1)
	 Line.(X+1)
      end
   end
   
   proc {StartGame MAP}
      MySelf
      Ghosts
   in
      %{Browse show}
      
      {CreateGame MAP}
      %{Browse aftershow}
      %Initialize ghosts and user
      MySelf = r(white 1 1)
      Ghosts = nil
      %{InitLayout MySelf|Ghosts}
      {Game MySelf Ghosts Command MAP}
   end

  
   
end
