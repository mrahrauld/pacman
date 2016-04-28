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
   LIVES
   COINS
   W
   H
   NW
   NH
   NCoinInit
   MainURL={OS.getCWD}
   PacManImg={QTk.newImage photo(url:MainURL#"/pacman.gif")}
   PacManUImg={QTk.newImage photo(url:MainURL#"/pacmanU.gif")}
   PacManDImg={QTk.newImage photo(url:MainURL#"/pacmanD.gif")}
   PacManLImg={QTk.newImage photo(url:MainURL#"/pacmanL.gif")}
   PacManRImg={QTk.newImage photo(url:MainURL#"/pacmanR.gif")}
   WormholeImg={QTk.newImage photo(url:MainURL#"/wormhole.gif")}
   
   GhostImg={QTk.newImage photo(url:MainURL#"/ghost.gif")}
   CoinImg={QTk.newImage photo(url:MainURL#"/yellow-coin.gif")}
   WidthCell=40
   HeightCell=40

   
   Command
   CommandPort = {NewPort Command}
   GhostStream
   GhostPort = {NewPort GhostStream}
   PacmanStream
   PacmanPort = {NewPort PacmanStream}
   
   proc{DrawBox Number X Y}
      case Number of 0 then  %Empty case
	 {Canvas create(image (X-1)*WidthCell + WidthCell div 2 (Y-1)*HeightCell + HeightCell div 2   image:CoinImg)}
      [] ~1 then
	 {Canvas create(rect (X-1)*WidthCell (Y-1)*HeightCell (X-1)*WidthCell+WidthCell (Y-1)*HeightCell+HeightCell fill:black outline:black)}
      [] 1 then %Wall
	 {Canvas create(rect (X-1)*WidthCell (Y-1)*HeightCell (X-1)*WidthCell+WidthCell (Y-1)*HeightCell+HeightCell fill:white outline:black)}
      [] 2 then %Power pellets
	 skip
      [] 3 then %Ghost
	 {Canvas create(image (X-1)*WidthCell + WidthCell div 2 (Y-1)*HeightCell + HeightCell div 2   image:GhostImg)}
      [] 4 then %Pacman
	 {Canvas create(image (X-1)*WidthCell + WidthCell div 2  (Y-1)*HeightCell + HeightCell div 2    image:PacManImg)}
      [] 5 then %Pacman
	 {Canvas create(image (X-1)*WidthCell + WidthCell div 2  (Y-1)*HeightCell + HeightCell div 2    image:WormholeImg)}
      []41 then
	 {Canvas create(image (X-1)*WidthCell + WidthCell div 2  (Y-1)*HeightCell + HeightCell div 2    image:PacManUImg)}
      []42 then
	 {Canvas create(image (X-1)*WidthCell + WidthCell div 2  (Y-1)*HeightCell + HeightCell div 2    image:PacManDImg)}
      []43 then
	 {Canvas create(image (X-1)*WidthCell + WidthCell div 2  (Y-1)*HeightCell + HeightCell div 2    image:PacManLImg)}
      []44 then
	 {Canvas create(image (X-1)*WidthCell + WidthCell div 2  (Y-1)*HeightCell + HeightCell div 2    image:PacManRImg)}
      else %Whorhole
	 {Canvas create(rect (X-1)*WidthCell (Y-1)*HeightCell (X-1)*WidthCell+WidthCell (Y-1)*HeightCell+HeightCell fill:black outline:black)}
      end
   end

   fun {MouvementIsAvailable OldState Dir MAP}
      NewX NewY DX DY OldX OldY Color 
      r(Color OldX OldY) = OldState
   in
      
      r(DX DY) = Dir
      NewX = OldX + DX
      NewY = OldY + DY
      
      if NewX<1 orelse NewX>NW orelse NewY<1 orelse NewY>NH orelse {GetElement NewX NewY MAP} == 1 then
	     false
	  else
	     
	     r(NewX NewY)
	  end 
   end
   proc {Map MapStream GhostPort MAP CoinCount}
      NextMapStream
      NewMAP
      NewCoinCount

      fun {MovePacman MAP OldState NewState CoinCount NewCoinCount Coins NewCoins}
	 NewX NewY OldX OldY NewMAP in
	 r(OldX OldY) = OldState
	 r(NewX NewY) = NewState

	 case {GetElement NewX NewY MAP} of 0 then
	    NewMAP = {ChangeMap MAP ~1 NewX NewY}
	    NewCoinCount = CoinCount-1
	    NewCoins = Coins+1
	 else
	    NewMAP = MAP
	    NewCoinCount = CoinCount
	    NewCoins = Coins
	 end
	 {DrawBox ~1 OldX OldY}
	 {DrawBox {GetElement OldX OldY MAP} OldX OldY}
	 {DrawBox ~1 NewX NewY}
	 if OldX-NewX == ~1 then
	    {DrawBox 44 NewX NewY}
	 elseif OldX-NewX == 1 then
	    {DrawBox 43 NewX NewY}
	 elseif OldY-NewY == ~1 then
	    {DrawBox 42 NewX NewY}
	 elseif OldY-NewY == 1 then
	    {DrawBox 41 NewX NewY}
	 else
	    {DrawBox 4 NewX NewY}
	 end
	 NewMAP
	 
      end
      
      fun{IsDead Lives OX OY NX NY OldGhost NewGhost}
	 GOX GOY GNX GNY C C2 in
	 case OldGhost of nil then Lives
	 [] H|T then
	    r(C GOX GOY) = H
	    r(C2 GNX GNY) = NewGhost.1
	    if GNX==NX andthen GNY==NY then % si les nouvelles positions sont les mêmes
	       {IsDead Lives-1 OX OY NX NY OldGhost.2 NewGhost.2}
	    elseif GNX==OX andthen GNY==OY andthen NX==GOX andthen NY==GOY then % S'ils se croisent
	       {IsDead Lives-1 OX OY NX NY OldGhost.2 NewGhost.2}
	    else
	       {IsDead Lives OX OY NX NY OldGhost.2 NewGhost.2}
	    end
	 end
      end
      proc{MoveGhost OldStates NewStates}
	    OldX OldY NewX NewY C C2 in
	    case OldStates of nil then skip
	    []H|T then
	       r(C2 OldX OldY) = H
	       r(C NewX NewY) = NewStates.1
	       {DrawBox ~1 OldX OldY}
	       {DrawBox {GetElement OldX OldY MAP} OldX OldY}
	       {DrawBox 3 NewX NewY}
	       {MoveGhost OldStates.2 NewStates.2}
	    end
      end
      fun{WaitStream OldMAP NewMAP MapStream GhostPort CoinCount NewCoinCount }
	 NewCoins NewPos GhostPos NX NY NewLives OldGhost NewGhost in
	 case MapStream of H|T then
	    {Send GhostPort GhostPos}	 
	    OldGhost#NewGhost=GhostPos
	    
	    case H of move(C OX OY DX DY OriginX OriginY Lives Coins)#Ack then
	       NewPos = {MouvementIsAvailable r(C OX OY) r(DX DY) OldMAP}
	       case NewPos of r(NX NY) then
	       	  NewLives = {IsDead Lives OX OY NX NY OldGhost NewGhost}
		  if NewLives==Lives then
		     Ack= pos(C NX NY Lives NewCoins)
		     NewMAP = {MovePacman OldMAP r(OX OY) r(NX NY)  CoinCount NewCoinCount Coins NewCoins}
		  else
		     {System.show NewLives}
		     Ack= pos(C OriginX OriginY NewLives NewCoins)
		     NewMAP = {MovePacman OldMAP r(OX OY) r(OriginX OriginY)  CoinCount NewCoinCount Coins NewCoins} 
		  end	  
	       else
	       	  NewLives = {IsDead Lives OX OY OX OY OldGhost NewGhost}
		  if NewLives==Lives then
		  NewMAP = MAP
		  Ack = pos(C OX OY Lives Coins)
		     NewCoinCount = Coins
		  else
		     NewMAP = {MovePacman OldMAP r(OX OY) r(OriginX OriginY)  CoinCount NewCoinCount Coins NewCoins} 
		     Ack = pos(C OriginX OriginY NewLives Coins)
		     NewCoinCount = Coins
		  end
	       end
	       
	       {MoveGhost OldGhost NewGhost}
	      
	    end
	    T
	 end
	 
      end

      in
      NextMapStream = {WaitStream MAP NewMAP MapStream GhostPort CoinCount NewCoinCount}
      {Map NextMapStream  GhostPort NewMAP  NewCoinCount}
   end
   
      
   
   proc {Pacman MySelf Command}

      MyNewState
      NextCommand

      fun {UserCommand Command OldState NewState}
	 X Y Ack Lives Coins C in

	 pos(C X Y Lives Coins) = OldState
	 case Command of r(DX DY)|T then
	    {Send PacmanPort move(C X Y DX DY 2 2 Lives Coins)#Ack}
	    
	    {Wait Ack} % Ack = pos(X Y Lives Coins)
	    NewState = Ack
	    T
	 end
      end in
      NextCommand = {UserCommand Command MySelf MyNewState}
      case MyNewState of pos(C X Y Lives Coins) then
	 if Lives \= 0 then
	    {Pacman MyNewState NextCommand}
	 else
	    skip
	 end
      end
   end

   proc{Ghost MySelf GhostStream MAP InitDir}

      GhostNewState
      NextGhostStream
      NewDir
      LastDir

      fun {MoveGhost Movement OldState}
	 NewX NewY DX DY OldX OldY Color  in
	 case Movement of nil then nil
	 [] H|T then
   	 r(Color OldX OldY) = OldState.1
   	 r(DX DY) = H
   	 NewX = OldX + DX
   	 NewY = OldY +  DY
	    r(Color NewX NewY)|{MoveGhost T OldState.2}
	 end
       end

       %
       % Regarde si une autre direction est disponible pour le Ghost
       %
      fun {OtherDirAvailaible State LastDir}
	 fun {MouvementIsAvailable OldState Dir MAP}
	    NewX NewY DX DY OldX OldY Color 
	    r(Color OldX OldY) = OldState
	 in
	    
	    r(DX DY) = Dir
	    NewX = OldX + DX
	    NewY = OldY + DY
	    
	    if NewX<1 orelse NewX>NW orelse NewY<1 orelse NewY>NH orelse {GetElement NewX NewY MAP} == 1 then
	       false
	    else
	       
	       true
	    end 
	 end in
	 if LastDir \= r(1 0) andthen LastDir \= r(~1 0) andthen {MouvementIsAvailable State r(1 0) MAP} then
	    true
	 elseif LastDir \= r(1 0) andthen LastDir \= r(~1 0) andthen {MouvementIsAvailable State r(~1 0) MAP} then
	    true
	 elseif LastDir \= r(0 ~1) andthen LastDir \= r(0 1) andthen {MouvementIsAvailable State r(0 1) MAP} then
	    true
	 elseif LastDir \= r(0 ~1) andthen LastDir \= r(0 1) andthen {MouvementIsAvailable State r(0 ~1) MAP} then
	    true
	 else
	    false
	 end
      end
       

       %
       % Choisit une nouvelle direction pour le Ghost
       %
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
	  fun{GhostCommand2 OldState LastDir}
	     case OldState of nil then nil
	     [] H|T then
		if {OtherDirAvailaible H LastDir.1} == false andthen {MouvementIsAvailable H LastDir.1 MAP} == true then
		   LastDir|{GhostCommand2 T LastDir.2}
		else
		   {NewDirection H}|{GhostCommand2 T LastDir.2}
		end
	     end
	  end
	  in
	  case GhostStream of H|T then
	     
	     NewDir = {GhostCommand2 OldState LastDir}
	     GhostNewState = {MoveGhost NewDir OldState}
	     H = OldState#GhostNewState
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




   
   fun {CreateGame MAP}
      CreateGhostStream
      CreateGhostPort = {NewPort CreateGhostStream}
      NewMap
      GHOSTS

      proc {CreateTable MAP ARITY COINS}
	 NewCoins1 NewCoins2 in
	 case ARITY of H|T then
	    {CreateLine MAP.H {Record.arity MAP.H} H NewCoins1}
	    {CreateTable MAP T NewCoins2}
	    COINS = NewCoins1 + NewCoins2
	 else
	    {Send CreateGhostPort nil}
	    COINS = 0
	 end
      end


      proc {CreateLine LINE ARITY Y COINS}
	 COINS2 NewCoins in
	 case ARITY of X|T then
	    {DrawBox LINE.X X Y}
	    case LINE.X of 3 then %Launch Ghost
	       {NewGhost X Y}
	       COINS2 = 0
	    [] 4 then %Launch Pacman
	       {NewPacman X Y}
	       COINS2 = 0
	    [] 0 then
	       COINS2 = 1
	    else COINS2 = 0 end
	    {CreateLine LINE T Y NewCoins}
	    COINS = COINS2 + NewCoins
	 else
	    COINS = 0
	 end
	 
      end

      proc {NewGhost X Y}
	 {Send CreateGhostPort r(3 X Y)}
      end

      proc {NewPacman X Y}
	 {Send CreateGhostPort r(4 X Y)}
	 thread {Pacman pos(4 X Y LIVES 0) Command} end
      end

      proc {CreateGhost CreateGhostStream NGHOST}
	 NewGHOST in
	 case CreateGhostStream of r(C X Y)|T then
	    {CreateGhost T NewGHOST}
	    case C of 3 then 
	       NGHOST = r(C X Y)|NewGHOST
	    else
	       NGHOST = NewGHOST
	    end
	 [] nil|T then
	       NGHOST = nil
	 else
	    skip
	 end
      end

      fun {AdaptMap MapStream MAP}
	 case MapStream of r(C X Y)|T then
	       {AdaptMap T {ChangeMap MAP ~1 X Y}}
	 [] nil|T then
	    MAP
	 end
      end

      proc {CreateNilList N NilList}
	 NewNilList in
	 if N == 0 then
	    NilList = nil
	 else
	    {CreateNilList N-1 NewNilList}
	    NilList = nil|NewNilList
	 end
      end
      
      
   in

      thread
	 {CreateGhost CreateGhostStream GHOSTS}
	 NewMap = {AdaptMap CreateGhostStream MAP}
      end

      %Taille du tableau 
      {Record.width MAP NW}
      {Record.width MAP NH}

      W =WidthCell*NW
      H =HeightCell*NH

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

      {CreateTable MAP {Record.arity MAP} COINS}

      local GHOST2 in
	 {CreateNilList {List.length GHOSTS} GHOST2}
	 thread {Ghost GHOSTS GhostStream MAP GHOST2} end
      end

      NewMap
 
   end

   fun {ChangeMap MAP C X Y}
      
     {AdjoinList MAP [Y#{AdjoinList MAP.Y [X#C]}]}

   end

   fun {GetElement X Y MAP}
      Line in
      if X > NW orelse X < 1 orelse Y > NH orelse Y < 1 then
	 MAP
      else
	 Line = MAP.Y
	 Line.X
      end
   end
   
   proc {StartGame MAP LIVE}
      MySelf
      Ghosts
      Ghosts2
      Ghosts3
      NewMap
   in
      LIVES = LIVE
      %{Browse show}
      
      NewMap = {CreateGame MAP}
      
      {Map PacmanStream GhostPort NewMap COINS}

      {System.show 'Jeu fini'}
   end

  
   
end
