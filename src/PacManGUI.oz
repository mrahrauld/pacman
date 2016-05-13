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
   TIMESCARED = 1
   TIMETIMER = 300
   LIVES %PARAM NOMBRE DE VIES
   COINS %PARAM NOMBRE DE PIECE AU DEBUT
   NOMBREPACMAN %PARAM NOMBRE DE PACMAN DANS LA PARTIE
   WORMHOLES %PARAM LISTE DES POSITIONS DES TROUS
   W %LARGEUR D'UNE CASE
   H %HAUTEUR D'UNE CASE
   NW %NOMBRE DE CASE DANS LA LONGUEUR
   NH %NOMBRE DE CASE DANS LA HAUTEUR
   MainURL={OS.getCWD}
   PacManImg={QTk.newImage photo(url:MainURL#"/pacman.gif")}
   PacManUImg={QTk.newImage photo(url:MainURL#"/pacmanU.gif")}
   PacManDImg={QTk.newImage photo(url:MainURL#"/pacmanD.gif")}
   PacManLImg={QTk.newImage photo(url:MainURL#"/pacmanL.gif")}
   PacManRImg={QTk.newImage photo(url:MainURL#"/pacmanR.gif")}
   WormholeImg={QTk.newImage photo(url:MainURL#"/wormhole.gif")}
   WallImg={QTk.newImage photo(url:MainURL#"/wall.gif")}
   PowerImg={QTk.newImage photo(url:MainURL#"/power.gif")}
   GhostScaredImg={QTk.newImage photo(url:MainURL#"/ghostScared.gif")}
   GhostImg={QTk.newImage photo(url:MainURL#"/ghost.gif")}
   CoinImg={QTk.newImage photo(url:MainURL#"/yellow-coin.gif")}
   WinImg={QTk.newImage photo(url:MainURL#"/youwin.gif")}
   OverImg={QTk.newImage photo(url:MainURL#"/gameover.gif")}
   WidthCell=40
   HeightCell=40

   TimerStream
   TimerPort = {NewPort TimerStream}
   Command
   CommandPort = {NewPort Command}
   ReadCommand
   ReadCommandPort = {NewPort ReadCommand}
   GhostStream
   GhostPort = {NewPort GhostStream}
   PacmanStream
   PacmanPort = {NewPort PacmanStream}
   AlivePacmanStream
   AlivePacmansPort = {NewPort AlivePacmanStream}
   ScaredModeStream
   ScaredModePort = {NewPort ScaredModeStream}


   proc{Scared ScaredModeStream}
      case ScaredModeStream of scared(Time)|T then
	 Stream
	 Port = {NewPort Stream} in
	 {Send GhostPort scared(33)}
	 thread {Delay Time} {Send Port 1}  end
	 thread
	    %scared(Time)
	    %case T of H|L then
	    {Wait T.1}
	       {Send Port 2}
	   % end
	 end
	 {Wait Stream.1}

	 %Temps fini
	 if Stream.1 == 1 then
	    {Send GhostPort scared(3)}
	 end
	 {Scared T}
      end
   end

   proc{ContinuousGame ReadCommand Current Last}
      case ReadCommand of H|T then
	 case H of r(A B) then
	    {ContinuousGame T r(A B) Current}
	 [] time(_) then
	    {Send CommandPort Current#Last}
	    {ContinuousGame T Current Last}
	 else
	    skip
	 end
      end
   end
   
   proc{Timer TimerStream}
      Stream
      Port = {NewPort Stream} in
      thread {Delay TIMETIMER} {Send Port 1} end
      thread
	 {Wait TimerStream.1}
	    {Send Port 2}
      end
      {Wait Stream.1}
      if Stream.1 == 1 then
	 {Send ReadCommandPort time(1)}
	 {Timer TimerStream}
      end
      {Send ReadCommandPort ~1}
   end
   
   proc{DrawBox Number X Y}
      case Number of 0 then  %Empty case
	 {Canvas create(image (X-1)*WidthCell + WidthCell div 2 (Y-1)*HeightCell + HeightCell div 2   image:CoinImg)}
      [] ~1 then
	 {Canvas create(rect (X-1)*WidthCell (Y-1)*HeightCell (X-1)*WidthCell+WidthCell (Y-1)*HeightCell+HeightCell fill:black outline:black)}
      [] 1 then %Wall
	 {Canvas create(image (X-1)*WidthCell + WidthCell div 2 (Y-1)*HeightCell + HeightCell div 2   image:WallImg)}
      [] 2 then %Power pellets
	 {Canvas create(image (X-1)*WidthCell + WidthCell div 2 (Y-1)*HeightCell + HeightCell div 2   image:PowerImg)}
      [] 3 then %Ghost
	 {Canvas create(image (X-1)*WidthCell + WidthCell div 2 (Y-1)*HeightCell + HeightCell div 2   image:GhostImg)}
      [] 33 then
	 {Canvas create(image (X-1)*WidthCell + WidthCell div 2 (Y-1)*HeightCell + HeightCell div 2   image:GhostScaredImg)}
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
      [] 37 then
	 {Canvas create(image (X-1)*WidthCell + WidthCell div 2  (Y-1)*HeightCell + HeightCell div 2    image:WinImg)}
      [] 38 then
	 {Canvas create(image (X-1)*WidthCell + WidthCell div 2  (Y-1)*HeightCell + HeightCell div 2    image:OverImg)}
      else %Whorhole
	 
	 {Canvas create(rect (X-1)*WidthCell (Y-1)*HeightCell (X-1)*WidthCell+WidthCell (Y-1)*HeightCell+HeightCell fill:black outline:black)}
      end
   end

   fun {MouvementIsAvailable OldState Dir LastDir MAP}
      NewX NewY DX DY OldX OldY Color LastDX LastDY NewX2 NewY2 
      r(Color OldX OldY) = OldState
   in
      r(DX DY) = Dir
      r(LastDX LastDY) = LastDir
      NewX = OldX + DX
      NewY = OldY + DY
      NewX2 = OldX + LastDX
      NewY2 = OldY + LastDY
      if NewX<1 orelse NewX>NW orelse NewY<1 orelse NewY>NH orelse {GetElement NewX NewY MAP} == 1 then
	 if NewX2<1 orelse NewX2>NW orelse NewY2<1 orelse NewY2>NH orelse {GetElement NewX2 NewY2 MAP} == 1 then
	    false
	 elseif {GetElement NewX2 NewY2 MAP} == 5 then
	    {ChooseNewHole r(Color NewX2 NewY2) WORMHOLES}
	 else
	    r(NewX2 NewY2)
	 end
      elseif {GetElement NewX NewY MAP} == 5 then
	 {ChooseNewHole r(Color NewX NewY) WORMHOLES}
      else 
	    r(NewX NewY)
      end 
   end

   %% Si Pacman/Ghost rentre dans un trou, sa nouvelles position sera choisie aléatoirement entre tous les autres trous.
   %Ils ne peuvent pas être bloqués entre deux trous
   fun {ChooseNewHole OH HoleList}
      N RAND OX OY in
      r(_ OX OY) = OH     %Enleve color
      N = {List.length HoleList}
      RAND = {Int.'mod' {OS.rand} N} +1
      local
	 r(C X Y) = {List.nth HoleList RAND}
      in 
	 if r(C X Y) \= r(C OX OY) then
	    r(X Y)
	 else
	    {ChooseNewHole OH HoleList}
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

      fun {MovePacman MAP OldState NewState Move CoinCount NewCoinCount Coins NewCoins}
	 NewX NewY OldX OldY NewMAP DX DY in
	 r(OldX OldY) = OldState
	 r(NewX NewY) = NewState
	 r(DX DY) = Move

	 case {GetElement NewX NewY MAP} of 0 then
	    NewMAP = {ChangeMap MAP ~1 NewX NewY}
	    NewCoinCount = CoinCount-1
	    NewCoins = Coins+1
	 [] 2 then
	    NewMAP = {ChangeMap MAP ~1 NewX NewY}
	    NewCoinCount = CoinCount
	    NewCoins = Coins
	 else
	    NewMAP = MAP
	    NewCoinCount = CoinCount
	    NewCoins = Coins
	 end
	 {DrawBox ~1 OldX OldY}
	 {DrawBox {GetElement OldX OldY MAP} OldX OldY}
	 {DrawBox ~1 NewX NewY}
	 if DX == 1 then
	    {DrawBox 44 NewX NewY}
	 elseif DX == ~1 then
	    {DrawBox 43 NewX NewY}
	 elseif DY == 1 then
	    {DrawBox 42 NewX NewY}
	 elseif DY == ~1 then
	    {DrawBox 41 NewX NewY}
	 else
	    {DrawBox 4 NewX NewY}
	 end
	 NewMAP
      end
      

      proc{MoveGhost OldStates NewStates NX NY OX OY}
	    OldX OldY NewX NewY C C2 in
	    case OldStates of nil then skip
	    []H|_ then
	       r(C2 OldX OldY) = H
	       r(C NewX NewY) = NewStates.1
	       {DrawBox ~1 OldX OldY}
	       {DrawBox {GetElement OldX OldY MAP} OldX OldY}
	       if  NX==OldX andthen NY==OldY then %Si pacman est juste derriere ghost
		  if OX\= NewX orelse OY\=NewY then
		     {DrawBox 4 OldX OldY}
		  end
	       end
	       {DrawBox C NewX NewY}
	       {MoveGhost OldStates.2 NewStates.2 NX NY OX OY}
	    end
      end
      fun{IsDead Lives NewLives OX OY NX NY OG NG NbreGhost NewGhost}
	 GOX GOY GNX GNY C C2 ACK  in
	 case OG of nil then
	    NewLives  = Lives
	    NewGhost
	 [] H|T then
	    r(C GOX GOY) = H
	    r(C2 GNX GNY) = NG.1
	    if GNX==NX  andthen GNY==NY then % si les nouvelles positions sont les mêmes
	       if C2 == 33 then
		  {Send GhostPort dead(NbreGhost-{List.length T} GNX GNY ACK)} %Si le ghost est en mode scared
		  
		  NewLives = Lives
		  ACK
	       else
		  {System.show 'Tu perds une vie'}
		  
		  NewLives = Lives-1
		  NewGhost
	       end
	    elseif GNX==OX andthen GNY==OY andthen NX==GOX andthen NY==GOY then % S'ils se croisent
	       if C2 == 33 then
		  {Send GhostPort dead(NbreGhost-{List.length T} GNX GNY ACK)} %Si le ghost est en mode scared
		 
		  NewLives = Lives
		   ACK
	       else
		  {System.show 'Tu perds une vie'}
		  
		  NewLives = Lives-1
		  NewGhost
	       end
	    else
	        
	       {IsDead Lives NewLives OX OY NX NY OG.2 NG.2 NbreGhost NewGhost}
	    end
	 end
      end
      fun{WaitStream OldMAP NewMAP MapStream GhostPort CoinCount NewCoinCount }
	 NewCoins NewPos GhostPos NX NY NewLives OldGhost NewGhost OG NG in
	 case MapStream of H|T then
	    {Send GhostPort GhostPos}
	    OG#NG=GhostPos
	    OldGhost = OG
	    case H of move(C OX OY DX DY OriginX OriginY Lives Coins LastDX LastDY)#Ack then
	       NewPos = {MouvementIsAvailable r(C OX OY) r(DX DY) r(LastDX LastDY) OldMAP}
	       case NewPos of r(X Y) then
		  
                  % GHOST PASSE EN MODE SCARED 
		  if {GetElement X Y OldMAP} == 2 then
		     {Send ScaredModePort scared(TIMESCARED)}
		  end
		  
		  NX = X
		  NY = Y
		  NewGhost = {IsDead Lives NewLives OX OY NX NY  OG NG {List.length OG} NG}
		  if NewLives==Lives then
		     Ack= pos(C NX NY OriginX OriginY Lives NewCoins)
		     NewMAP = {MovePacman OldMAP r(OX OY) r(NX NY) r(DX DY) CoinCount NewCoinCount Coins NewCoins}
		  else
		     Ack= pos(C OriginX OriginY OriginX OriginY NewLives NewCoins)
		     NewMAP = {MovePacman OldMAP r(OX OY) r(OriginX OriginY) r(DX DY) CoinCount NewCoinCount Coins NewCoins} 
		  end	  
	       else
		  NX = OX
		  NY = OY
		  NewGhost = {IsDead Lives NewLives OX OY OX OY OG NG {List.length OldGhost} NG}
		  if NewLives==Lives then
		  NewMAP = MAP
		  Ack = pos(C OX OY OriginX OriginY Lives Coins)
		  NewCoinCount = CoinCount
		  else
		     NewMAP = {MovePacman OldMAP r(OX OY) r(OriginX OriginY) r(DX DY) CoinCount NewCoinCount Coins NewCoins} 
		     Ack = pos(C OriginX OriginY OriginX OriginY NewLives Coins)
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
      if NewAlivePacmans==0 then
	 {DrawBox 38 {Int.'div' NW 2} {Int.'div' NH 2}}
	 {Send GhostPort ~1} % s'il n'y a plus de pacman en vie on previent le thread Ghost
	 {Send TimerPort ~1}
      elseif NewCoinCount == 0 then
	 {DrawBox 37 {Int.'div' NW 2} {Int.'div' NH 2}}
	 {Send GhostPort ~1}
	 {Send TimerPort ~1}
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
	 case Command of r(DX DY)#r(LastDX LastDY)|T then
	    {Send PacmanPort move(C X Y DX DY OX OY Lives Coins LastDX LastDY)#Ack}
	    
	    {Wait Ack} % Ack = pos(X Y Lives Coins)
	    NewState = Ack
	    T
	 end
      end in
      NextCommand = {UserCommand Command MySelf MyNewState}
      case MyNewState of pos(_ _ _ _ _ Lives _) then
	 if Lives \= 0 then
	    {Send AlivePacmansPort 0}
	    {Pacman MyNewState NextCommand}
	 else
	    pos(_ _ _ _ _ LastLives _)
	    if Lives > LastLives then
	       {Delay 3000}
	    end
	    {Send AlivePacmansPort 1}
	 end
      end
   end







   
   
   %%%% GHOST %%%%
   proc{Ghost MySelf GhostStream MAP InitDir Scared OriginalPos}

      GhostNewState
      NextGhostStream
      NewDir
      NewScared
      LastDir

      fun {MoveGhost Movement OldState}
	 NewX NewY DX DY OldX OldY Color  in
	 case Movement of nil then nil
	 [] H|T then
   	 r(Color OldX OldY) = OldState.1
   	 r(DX DY) = H
	    NewX = OldX + DX
	    NewY = OldY + DY
	    case {GetElement NewX NewY MAP} of 5 then
	       local X Y in
		  r(X Y) = {ChooseNewHole r(Color NewX NewY) WORMHOLES}
		  r(Color X Y)|{MoveGhost T OldState.2}
	       end
	    else	    
	       r(Color NewX NewY)|{MoveGhost T OldState.2}
	    end
	 end
      end

       %
       % Regarde si une autre direction est disponible pour le Ghost
       %
      fun {OtherDirAvailaible State LastDir}
	 fun {MouvementIsAvailable OldState Dir MAP}
	    NewX NewY DX DY OldX OldY 
	    r(_ OldX OldY) = OldState
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
       fun {NewDirection OldState LastDir}
   	  Dir = {Int.'mod' {OS.rand} 4}
   	  DX DY 
       in
   	  case Dir of 1 then r(DX DY) = r(1 0)
   	  [] 2 then  r(DX DY) = r(~1 0)
   	  [] 3 then r(DX DY) = r(0 1)
   	  else
   	    r(DX DY) = r(0 ~1)
   	  end

	  if LastDir \= nil andthen {MouvementIsAvailable OldState LastDir LastDir MAP} \= false  andthen r(~DX ~DY) == LastDir then
	     {NewDirection OldState LastDir}
   	  elseif {MouvementIsAvailable OldState r(DX DY) r(DX DY) MAP} == false then
	     {NewDirection OldState LastDir}
   	  else
   	     r(DX DY)
   	  end
       end

       fun{MakeScared Scared A}
	  case Scared of _|T then
	     A|{MakeScared T A}
	  else
	     nil
	  end
       end

       fun{MakeScaredOneGhost Scared A N}
	  case Scared of H|T then
	     if N == 0 then
		A|{MakeScaredOneGhost T A N-1}
	     else
		H|{MakeScaredOneGhost T A N-1}
	     end
	  else
	     nil
	  end
       end

       fun{MakeScaredState Scared OldState}
	  X Y Color in
	  case Scared of H|T then
	     r(Color X Y) = OldState.1
	     r(H X Y)|{MakeScaredState T OldState.2}
	  else
	     nil
	  end
       end

       fun{MakeScaredStateDead Scared OldState N OriginalPos}
	  X Y Color OX OY OColor in
	  case Scared of H|T then
	     r(Color X Y) = OldState.1
	     r(OColor OX OY) = OriginalPos.1
	     if N == 0 then
		r(H OX OY)|{MakeScaredStateDead T OldState.2 N-1 OriginalPos.2}
	     else
		r(H X Y)|{MakeScaredStateDead T OldState.2 N-1 OriginalPos.2}
	     end
	  else
	     nil
	  end
       end
       
       fun {GhostCommand GhostStream OldState LastDir Scared OriginalPos GhostNewState NewDir NewScared}
	  fun{GhostCommand2 OldState LastDir}
	     case OldState of nil then nil
	     [] H|T then
		if {OtherDirAvailaible H LastDir.1} == false andthen {MouvementIsAvailable H LastDir.1 LastDir.1 MAP} \= false then
		   LastDir.1|{GhostCommand2 T LastDir.2}
		else
		   {NewDirection H LastDir.1}|{GhostCommand2 T LastDir.2}
		end
	     end
	  end
	  in
	  case GhostStream of H|T then
	     case H of ~1 then
		H
	     [] scared(A) then
		NewScared = {MakeScared Scared A}
		GhostNewState = {MakeScaredState NewScared OldState}
		NewDir = LastDir
		T
	     [] dead(N _ _ ACK) then
		NewScared = {MakeScaredOneGhost Scared 3 N-1}
		GhostNewState = {MakeScaredStateDead NewScared OldState N-1 OriginalPos}
		NewDir = LastDir
		ACK = GhostNewState
		T
	     else
		NewDir = {GhostCommand2 OldState LastDir}
		GhostNewState = {MoveGhost NewDir OldState}
		H = OldState#GhostNewState
		NewScared = Scared
		T
	     end
   	 end
       end in

      if InitDir == nil then
   	 LastDir = {NewDirection MySelf nil}
      else
   	 LastDir = InitDir
      end
      
      NextGhostStream = {GhostCommand GhostStream MySelf LastDir Scared OriginalPos GhostNewState NewDir NewScared}
      
      if NextGhostStream== ~1 then {System.show 'Quelques chose à faire ici mais quoi ? '}
      else
	 {Ghost GhostNewState NextGhostStream MAP NewDir NewScared OriginalPos}
      end
   end








   %%%% CREATEGAME %%%%
   
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
	 [] nil|_ then
	       NGHOST = nil
	 else
	    skip
	 end
      end

      fun {NombrePacman MapStream}
	 case MapStream of r(C _ _)|T then
	    case C of 4 then
	       1 + {NombrePacman T}
	    else
	       {NombrePacman T}
	    end
	 [] nil|_ then
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
	 else
	       nil
	 end
      end
      

      fun {AdaptMap MapStream MAP}
	 case MapStream of r(C X Y)|T then
	    if C \= 5 andthen C \= 2 then
	       {AdaptMap T {ChangeMap MAP ~1 X Y}}
	    else
	       {AdaptMap T MAP}
	    end
	 else 
	    MAP
	 end
      end

      proc {CreateList N List A}
	 NewList in
	 if N == 0 then
	    List = A
	 else
	    {CreateList N-1 NewList A}
	    List = A|NewList
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
      {Record.width MAP.1 NW}
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
      {Window bind(event:"<Up>" action:proc{$} {Send ReadCommandPort r(0 ~1)} end)}
      {Window bind(event:"<Left>" action:proc{$} {Send ReadCommandPort r(~1 0)} end)}
      {Window bind(event:"<Down>" action:proc{$} {Send ReadCommandPort r(0 1)}  end)}
      {Window bind(event:"<Right>" action:proc{$} {Send ReadCommandPort r(1 0)} end)}

      {Window show}

      {CreateTable MAP {Record.arity MAP} COINS}

      local GHOST2 in
	 {CreateList {List.length GHOSTS} GHOST2 nil}
	 thread {Ghost GHOSTS GhostStream MAP GHOST2 GHOST2 GHOSTS} end
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
      NewMAP
   in
      LIVES = LIVE

      thread {Scared ScaredModeStream} end
      thread {ContinuousGame ReadCommand r(1 0) r(1 0)} end
      
      
      NewMAP = {CreateGame MAP}

      %Liste des WORMHOLES DANS la variable globale WORMHOLES !!!
      
      thread {Map PacmanStream GhostPort NewMAP COINS NOMBREPACMAN AlivePacmanStream} end
      
      {Timer TimerStream}
      {Delay 3000}
      {Window close}
   end

  
   
end
