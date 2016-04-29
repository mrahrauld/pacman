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
   LIVES %PARAM NOMBRE DE VIES
   COINS %PARAM NOMBRE DE PIECE AU DEBUT
   NOMBREPACMAN %PARAM NOMBRE DE PACMAN DANS LA PARTIE
   WORMHOLES %PARAM LISTE DES POSITIONS DES TROUS
   W %LARGEUR D'UNE CASE
   H %HAUTEUR D'UNE CASE
   NW %NOMBRE DE CASE DANS LA LONGUEUR
   NH %NOMBRE DE CASE DANS LA HAUTEUR
   NCoinInit
   MainURL={OS.getCWD}
   PacManImg={QTk.newImage photo(url:MainURL#"/pacman.gif")}
   PacManUImg={QTk.newImage photo(url:MainURL#"/pacmanU.gif")}
   PacManDImg={QTk.newImage photo(url:MainURL#"/pacmanD.gif")}
   PacManLImg={QTk.newImage photo(url:MainURL#"/pacmanL.gif")}
   PacManRImg={QTk.newImage photo(url:MainURL#"/pacmanR.gif")}
   WormholeImg={QTk.newImage photo(url:MainURL#"/wormhole.gif")}
   WallImg={QTk.newImage photo(url:MainURL#"/wall.gif")}
   
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
   AlivePacmanStream
   AlivePacmansPort = {NewPort AlivePacmanStream}
   
   proc{DrawBox Number X Y}
      case Number of 0 then  %Empty case
	 {Canvas create(image (X-1)*WidthCell + WidthCell div 2 (Y-1)*HeightCell + HeightCell div 2   image:CoinImg)}
      [] ~1 then
	 {Canvas create(rect (X-1)*WidthCell (Y-1)*HeightCell (X-1)*WidthCell+WidthCell (Y-1)*HeightCell+HeightCell fill:black outline:black)}
      [] 1 then %Wall
	 {Canvas create(image (X-1)*WidthCell + WidthCell div 2 (Y-1)*HeightCell + HeightCell div 2   image:WallImg)}
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
      elseif {GetElement NewX NewY MAP} == 5 then 
	 {ChooseNewHole OldState WORMHOLES}
      else 
	     r(NewX NewY)
      end 
   end

   fun {ChooseNewHole OH HoleList}
      N RAND in
      N = {List.length HoleList}
      case N of 2 then
	 unit
      else
	 RAND = {Int.'mod' {OS.rand} N}
	 {System.show RAND}
	 local
	    r(C X Y) = {List.nth HoleList RAND}
	 in 
	    if r(C X Y) \= OH then
	       r(X Y)
	    else
	       {ChooseNewHole OH HoleList}
	    end
	 end
      end
   end
   
   
   %%%%% MAP %%%%
   proc {Map MapStream GhostPort MAP CoinCount AlivePacmans AlivePacmanStream}
      NextMapStream
      NewMAP
      NewCoinCount
      NewAlivePacmans
      NextAlivePacmanStream

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
	       Lives-1
	    elseif GNX==OX andthen GNY==OY andthen NX==GOX andthen NY==GOY then % S'ils se croisent
	       Lives-1
	    else
	       {IsDead Lives OX OY NX NY OldGhost.2 NewGhost.2}
	    end
	 end
      end
      proc{MoveGhost OldStates NewStates NX NY OX OY}
	    OldX OldY NewX NewY C C2 in
	    case OldStates of nil then skip
	    []H|T then
	       r(C2 OldX OldY) = H
	       r(C NewX NewY) = NewStates.1
	       {DrawBox ~1 OldX OldY}
	       {DrawBox {GetElement OldX OldY MAP} OldX OldY}
	       if  NX==OldX andthen NY==OldY then %Si pacman est juste derriere ghost
		  if OX\= NewX orelse OY\=NewY then
		     {DrawBox 4 OldX OldY}
		  end
	       end
	       {DrawBox 3 NewX NewY}
	       {MoveGhost OldStates.2 NewStates.2 NX NY OX OY}
	    end
      end
      fun{WaitStream OldMAP NewMAP MapStream GhostPort CoinCount NewCoinCount }
	 NewCoins NewPos GhostPos NX NY NewLives OldGhost NewGhost in
	 case MapStream of H|T then
	    {Send GhostPort GhostPos}	 
	    OldGhost#NewGhost=GhostPos
	    
	    case H of move(C OX OY DX DY OriginX OriginY Lives Coins)#Ack then
	       NewPos = {MouvementIsAvailable r(C OX OY) r(DX DY) OldMAP}
	       case NewPos of r(X Y) then
		  NX = X
		  NY = Y
	       	  NewLives = {IsDead Lives OX OY NX NY OldGhost NewGhost}
		  if NewLives==Lives then
		     Ack= pos(C NX NY OriginX OriginY Lives NewCoins)
		     NewMAP = {MovePacman OldMAP r(OX OY) r(NX NY)  CoinCount NewCoinCount Coins NewCoins}
		  else
		     Ack= pos(C OriginX OriginY OriginX OriginY NewLives NewCoins)
		     NewMAP = {MovePacman OldMAP r(OX OY) r(OriginX OriginY)  CoinCount NewCoinCount Coins NewCoins} 
		  end	  
	       else
		  NX = OX
		  NY = OY
	       	  NewLives = {IsDead Lives OX OY OX OY OldGhost NewGhost}
		  if NewLives==Lives then
		  NewMAP = MAP
		  Ack = pos(C OX OY OriginX OriginY Lives Coins)
		     NewCoinCount = Coins
		  else
		     NewMAP = {MovePacman OldMAP r(OX OY) r(OriginX OriginY)  CoinCount NewCoinCount Coins NewCoins} 
		     Ack = pos(C OriginX OriginY OriginX OriginY NewLives Coins)
		     NewCoinCount = Coins
		  end
		  

	       end
	       {MoveGhost OldGhost NewGhost NX NY OX OY}
	    end
	    T
	 end
	 
      end

   in
      NextMapStream = {WaitStream MAP NewMAP MapStream GhostPort CoinCount NewCoinCount}
      case AlivePacmanStream of H|T then %recalcul du nombre de pacman en vie
	 NextAlivePacmanStream = T
	 NewAlivePacmans = AlivePacmans-H
	 
      end
      if NewAlivePacmans==0 then {Send GhostPort ~1} % s'il n'y a plus de pacman en vie on previent le thread Ghost
      else
	 {Map NextMapStream  GhostPort NewMAP  NewCoinCount NewAlivePacmans NextAlivePacmanStream}
      end
   end
   
      
   %%%% PACMAN %%%%
   proc {Pacman MySelf Command}

      MyNewState
      NextCommand

      fun {UserCommand Command OldState NewState}
	 X Y OX OY Ack Lives Coins C in

	 pos(C X Y OX OY Lives Coins) = OldState
	 case Command of r(DX DY)|T then
	    {Send PacmanPort move(C X Y DX DY OX OY Lives Coins)#Ack}
	    
	    {Wait Ack} % Ack = pos(X Y Lives Coins)
	    NewState = Ack
	    T
	 end
      end in
      NextCommand = {UserCommand Command MySelf MyNewState}
      case MyNewState of pos(C X Y OX OY Lives Coins) then
	 if Lives \= 0 then
	    {System.show 'test'}
	    {Send AlivePacmansPort 0}
	    {Pacman MyNewState NextCommand}
	 else
	    {System.show 'test3'}
	    {Send AlivePacmansPort 1}
	 end
      end
   end

   
   %%%% GHOST %%%%
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
	     if H == ~1 then
		H
	     else
		NewDir = {GhostCommand2 OldState LastDir}
		GhostNewState = {MoveGhost NewDir OldState}
		H = OldState#GhostNewState
		T
	     end
   	 end
       end in

      if InitDir == nil then
   	 LastDir = {NewDirection MySelf}
      else
   	 LastDir = InitDir
      end
      
      NextGhostStream = {GhostCommand GhostStream MySelf LastDir GhostNewState NewDir}
      
      if NextGhostStream== ~1 then {System.show NextGhostStream}
      else
	 {Ghost GhostNewState NextGhostStream MAP NewDir}
      end
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
	    [] 5 then
	       {NewWormhole X Y}
	       COINS2 = 0
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
	 thread {Pacman pos(4 X Y X Y LIVES 0) Command} end
      end

      proc {NewWormhole X Y}
	 {Send CreateGhostPort r(5 X Y)}
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

      fun {NombrePacman MapStream}
	 case MapStream of r(C X Y)|T then
	    case C of 4 then
	       1 + {NombrePacman T}
	    else
	       {NombrePacman T}
	    end
	 [] nil|T then
	       0
	 end
      end

      fun {WormholesList MapStream}
	 case MapStream of r(C X Y)|T then
	    case C of 5 then
	       r(C X Y)|{WormholesList T}
	    else
	       {WormholesList T}
	    end
	 [] nil|T then
	       nil
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
	 NOMBREPACMAN = {NombrePacman CreateGhostStream}
	 WORMHOLES = {WormholesList CreateGhostStream}
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
      NewMAP
   in
      LIVES = LIVE
      %{Browse show}
      
      NewMAP = {CreateGame MAP}

      %Liste des WORMHOLES DANS la variable globale WORMHOLES !!!
      
      {Map PacmanStream GhostPort NewMAP COINS NOMBREPACMAN AlivePacmanStream}

   end

  
   
end
