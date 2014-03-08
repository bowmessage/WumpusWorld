% my_agent.pl

:- dynamic agent_x/1, agent_y/1, agent_ang/1, agent_arrow/1, agent_gold/1, breeze/3, stench/3, glitter/3, bump/3, scream/1, visited/2, shotAt/2.

square(1,1).
square(1,2).
square(1,3).
square(1,4).

square(2,1).
square(2,2).
square(2,3).
square(2,4).

square(3,1).
square(3,2).
square(3,3).
square(3,4).

square(4,1).
square(4,2).
square(4,3).
square(4,4).

%===============================================
%INTERFACE RULES
%===============================================

init_agent:-
	retractall(agent_x(_)),
	retractall(agent_y(_)),
	retractall(agent_gold(_)),
	retractall(agent_ang(_)),
	retractall(agent_arrow(_)),
	retractall(breeze(_,_,_)),
	retractall(stench(_,_,_)),
	retractall(glitter(_,_,_)),
	retractall(bump(_,_,_)),
	retractall(scream(_)),
  retractall(visited(_,_)),
  retractall(shotAt(_,_)),

	assert(agent_x(1)),
	assert(agent_y(1)),
	assert(agent_gold(0)),
	assert(agent_ang(0)),
	assert(agent_arrow(1)).

run_agent(Percept, Action):-

	agent_x(X), agent_y(Y), agent_ang(A),

  assert(visited(X,Y)),

	format('Im at: ~d ~d, angle ~d\n',[X,Y,A]),

	update_percepts(Percept),

	get_action(Action),

	update_position(Action),

	display_world.

%===============================================
%GET ACTION RULES
%===============================================

get_action(grab):-
	agent_x(X), agent_y(Y), glitter(yes,X,Y).

get_action(shoot):-
	\+scream(yes), %no scream yet anywhere. Wumpus is still around!
	agent_arrow(Ar),
	Ar > 0,
  %if wumpus is definitely ahead of where we're facing, shoot it!
  findall([Xw,Yw], (square(Xw,Yw), possible_wumpus_location(Xw,Yw)), Dwls),
  length(Dwls, 1), %we know of only one possible wumpus location.
  nth0(0, Dwls, Dwl),
  nth0(0, Dwl, Xdw), nth0(1, Dwl, Ydw),
  facing(Xdw, Ydw) ;
  %else, if we've been everywhere, better shoot at one of its possible spots that we're facing.
  
  explored_all(yes),
  findall([Xw,Yw], (square(Xw,Yw), possible_wumpus_location(Xw,Yw), facing(Xw, Yw)), Dwls),
  length(Dwls, Len), %better have at least one
  Len > 0.

get_action(climb):-
	agent_x(X), agent_y(Y), agent_gold(G),
  (explored_all(yes) ; G > 0), %either we've been everywhere or we have 1 gold
  X =:= 1, Y =:= 1. %make sure we've been everywhere possible and at 1 1 now.

get_action(goforward):-
  random(10) > 4,
	agent_x(X), agent_y(Y), agent_ang(A),

	NewX is X + round(cos((A/360)*(pi*2))),
	NewY is Y + round(sin((A/360)*(pi*2))),

	safe(NewX, NewY),  format('it is!\n'), valid(NewX,NewY), format('it is!\n').

get_action(turnleft):- true.
%get_action(turnright):- true. never turn right... slightly wasteful

%===============================================
%HELPER RULES
%===============================================

explored_all(yes):-
  findall([Xu, Yu], (square(Xu, Yu), \+visited(Xu,Yu), square(Xo, Yo), visited(Xo, Yo), neighbor(Xo, Yo, Xu, Yu), \+possible_wumpus_location(Xu,Yu), \+possible_pit_location(Xu,Yu)), Unvisited),
  %still safe squares to visit?! Don't leave  yet!
  length(Unvisited, Len), 
  Len =:= 0.

explored_all(no).

facing(Xt,Yt):-
  agent_x(X), agent_y(Y), agent_ang(A),
    (X =:= Xt, Y =\= Yt,
    ShouldDir is (Yt - Y) / abs(Yt - Y),
    IsDir is round(sin((A/360)*(pi*2))),
    IsDir =:= ShouldDir
   ;
  
    Y =:= Yt, X =\= Xt,
    ShouldDir is (Xt - X) / abs(Xt - X),
    IsDir is round(cos((A/360)*(pi*2))),
    IsDir =:= ShouldDir).

possible_wumpus_location(Xw, Yw):-
  \+scream(yes), %no scream so far. If there has been scream, can't be wumpus.
  \+shotAt(Xw, Yw), %not shot at this square. If we have, he must be dead.
  \+visited(Xw,Yw),
  findall([Xn, Yn], (square(Xn, Yn), neighbor(Xw, Yw, Xn, Yn), stench(yes, Xn, Yn)), Nyes), %findall neighbors with stenches
  findall([Xnn, Ynn], (square(Xnn, Ynn), neighbor(Xw, Yw, Xnn, Ynn), stench(no, Xnn, Ynn)), Nno), %findall neighbors without
  length(Nyes, LenYes),
  length(Nno, LenNo),
  LenYes > 0,
  LenNo < 1.

possible_pit_location(Xw, Yw):-
  \+visited(Xw, Yw),
  findall([Xn, Yn], (square(Xn, Yn), neighbor(Xw, Yw, Xn, Yn), breeze(yes, Xn, Yn)), Nyes), %findall neighbors with stenches
  findall([Xnn, Ynn], (square(Xnn, Ynn), neighbor(Xw, Yw, Xnn, Ynn), breeze(no, Xnn, Ynn)), Nno), %findall neighbors without
  length(Nyes, LenYes),
  length(Nno, LenNo),
  LenYes > 0,
  LenNo < 1.

neighbor(X,Y,Xn,Yn):-
  abs(X-Xn) =:= 1, Y =:= Yn ;
  abs(Y-Yn) =:= 1, X =:= Xn.

safe(X,Y):-
  valid(X,Y),
	format('Is ~d, ~d safe?\n', [X,Y]),
  \+possible_wumpus_location(X,Y),
  \+possible_pit_location(X,Y).

valid(X,Y):- square(X,Y).

%===============================================
%UPDATE PERCEPT RULE
%===============================================

update_percepts([Stench,Breeze,Glitter,Bump,Scream]):-
	format('[~a,~a,~a,~a,~a]',[Stench,Breeze,Glitter,Bump,Scream]),

	agent_x(X), agent_y(Y),

	retractall(stench(_,X,Y)),
	retractall(breeze(_,X,Y)),
	retractall(glitter(_,X,Y)),
	retractall(bump(_,X,Y)),
	%don't retract screams.. once it happens anywhere we don't want anymore shooting.

	assert(stench(Stench,X,Y)),
	assert(breeze(Breeze,X,Y)),
	assert(glitter(Glitter,X,Y)),
	assert(bump(Bump,X,Y)),
	assert(scream(Scream)).

%===============================================
%UPDATE POSITION RULES
%===============================================

update_position(climb):-
	true.

update_position(shoot):-
	retract(agent_arrow(Ar)),
	NewAr is Ar-1,
	assert(agent_arrow(NewAr)),
  foreach((square(Xs, Ys), facing(Xs, Ys)), assert(shotAt(Xs, Ys))). %marked these squares that we shot at

update_position(grab):-
	retract(agent_gold(G)),
	NewG is G + 1,
	assert(agent_gold(NewG)).

update_position(turnleft):-
	retract(agent_ang(A)),
	NewA is (A + 90) mod 360,
	assert(agent_ang(NewA)).

update_position(turnright):-
	retract(agent_ang(A)),
	NewA is (A - 90) mod 360,
	assert(agent_ang(NewA)).

update_position(goforward):-
	agent_ang(A),

	retract(agent_x(X)),
  retract(agent_y(Y)),

	NewX is X + round(cos((A/360)*(pi*2))),
	NewY is Y + round(sin((A/360)*(pi*2))),

	assert(agent_x(NewX)), 
  assert(agent_y(NewY)).
