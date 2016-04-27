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
   GhostStream
   GhostPort = {NewPort GhostStream}
   MapStream
   MapPort = {NewPort MapStream}
   
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

   fun {MouvementIsAvailable OldState Dir MAP}
	  NewX NewY DX DY OldX OldY Color 
	  r(Color OldX OldY) = OldState
	  in
	  r(DX DY) = Dir
	  NewX = OldX + DX
	  NewY = OldY + DY
	  
	  if NewX<0 orelse NewX>(NW-1) orelse NewY<0 orelse NewY>(NH-1) orelse {GetElement NewX NewY MAP} == 1 then
	     false
	  else
	     true
	  end 
   end
   
   
   proc{Pacman MySelf Command MAP}

      MyNewState
      NextCommand
      
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
	    {Send GhostPort r(NewX NewY)} 
	    r(Color NewX NewY)
	 end
       end

       fun {UserCommand Command OldState NewState}
	 case Command of r(DX DY)|T then
	    NewState = {MoveTo r(DX DY) OldState}
	    T
	 end
      end in

       NextCommand = {UserCommand Command MySelf MyNewState}
       {Pacman MyNewState NextCommand MAP}
   end

   proc{Ghost MySelf GhostStream MAP InitDir}

      GhostNewState
      NextGhostStream
      NewDir
      LastDir
      
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
	    {DrawBox {GetElement OldX OldY MAP} OldX OldY}
	    {DrawBox 3 NewX NewY}
	    r(Color NewX NewY)
	 end
       end

       fun {NewDirection OldState}
	  Dir = {Int.'mod' {OS.rand} 4}
	  NewX NewY DX DY OldX OldY Color
       in
	  r(Color OldX OldY) = OldState
	  
	  case Dir of 1 then r(DX DY) = r(1 0)
	  [] 2 then  r(DX DY) = r(~1 0)
	  [] 3 then r(DX DY) = r(0 1)
	  else
	    r(DX DY) = r(0 ~1)
	  end
	  
	  NewX = OldX + DX
	  NewY = OldY + DY
	  
	  if {MouvementIsAvailable OldState r(DX DY) MAP} == false then
	     {NewDirection OldState}
	  else
	     r(DX DY)
	  end
       end

       fun {GhostCommand GhostStream OldState LastDir GhostNewState NewDir}
	  case GhostStream of r(DX DY)|T then
	     if {MouvementIsAvailable OldState LastDir MAP} == true then
		GhostNewState = {MoveTo LastDir OldState}
	     else
		GhostNewState = {MoveTo {NewDirection OldState} OldState}
	     end
		T
	 end
       end in

      if InitDir == nil then
	 LastDir = {NewDirection MySelf}
      else
	 LastDir = InitDir
      end

       NextGhostStream = {GhostCommand GhostStream MySelf LastDir GhostNewState NewDir}
       {Ghost GhostNewState NextGhostStream MAP NewDir}
   end

   % proc{GameBis MySelf Ghosts Command MAP}
   %    MyNewState
   %    NextCommand
   %    GhostNewStates
   %    GhostNewStates1

   %    fun {MoveTo Movement OldState}
   % 	 NewX NewY DX DY OldX OldY Color  in
   % 	 r(Color OldX OldY) = OldState
   % 	 r(DX DY) = Movement
   % 	 NewX = OldX + DX
   % 	 NewY = OldY + DY
   % 	 if NewX<0 orelse NewX>(NW-1) orelse NewY<0 orelse NewY>(NH-1) orelse {GetElement NewX NewY MAP} == 1 then
   % 	    r(Color OldX OldY)
   % 	 else
   % 	    {DrawBox black OldX OldY}
   % 	    {DrawBox 4 NewX NewY}
   % 	    r(Color NewX NewY)
   % 	 end
   %    end
      
   %    fun {MoveAll OldState NewState}
   % 	 Dir
   %       in
   % 	 case OldState
   % 	 of Old|T then
   % 	    Dir = {Int.'mod' {OS.rand} 4}
   % 	    case Dir of 0 then
   % 	       {MoveAll T {MoveTo r(~1 0) Old}|NewState}
   % 	       [] 1 then {MoveAll T  {MoveTo r(0 1) Old}|NewState}
   % 	       [] 2 then {MoveAll T  {MoveTo r(1 0) Old}|NewState}
   % 	       [] 3 then {MoveAll T  {MoveTo r(0 ~1) Old}|NewState}
   % 	    end
   % 	 [] nil then  NewState
   % 	 end
   %    end
   %    fun {UserCommand Command OldState NewState}
   % 	 case Command of r(DX DY)|T then
   % 	    NewState = {MoveTo r(DX DY) OldState}
   % 	    T
   % 	 end
   %    end
   % in
   %    NextCommand = {UserCommand Command MySelf MyNewState}
   %    GhostNewStates = {MoveAll Ghosts nil}
   %    GhostNewStates1 = {MoveAll GhostNewStates nil}
   %    {GameBis MyNewState GhostNewStates1 NextCommand MAP}
   % end

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
      Ghosts = r(white 2 9)
      %{InitLayout MySelf|Ghosts}
      thread {Ghost Ghosts GhostStream MAP nil} end
      {Pacman MySelf Command MAP}
   end

  
   
end
