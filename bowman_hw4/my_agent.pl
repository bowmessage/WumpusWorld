%my_agent.pl

%   this procedure requires the external definition of two procedures:
%
%     init_agent: called after new world is initialized.  should perform
%                 any needed agent initialization.
%
%     run_agent(percept,action): given the current percept, this procedure
%                 should return an appropriate action, which is then
%                 executed.
%
% This is what should be fleshed out

:- dynamic agent_x/1, agent_y/1, agent_ang/1, agent_arrow/1, agent_gold/1, breeze/3, stench/3, glitter/3, bump/3, scream/3.


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
	retractall(scream(_,_,_)),



	assert(agent_x(1)),
	assert(agent_y(1)),
	assert(agent_gold(0)),
	assert(agent_ang(0)),
	assert(agent_arrow(1)).


%run_agent(Percept,Action):-
%run_agent(_,_):-
%	format('\nomg\n').
%   Percept = [Stench,Breeze,Glitter,Bump,Scream]
%             The five parameters are either 'yes' or 'no'.

run_agent(Percept, Action):-

	agent_x(X), agent_y(Y), agent_ang(A),

	format('Im at: ~d ~d, angle ~d\n',[X,Y,A]),

	update_percepts(Percept),

	get_action(Action),

	update_position(Action),

	

	%format('I think Im at ~d, ~d\n',X,Y),
	display_world.
	

get_action(grab):-
	agent_x(X), agent_y(Y), glitter(yes,X,Y).

get_action(climb):-
	agent_x(X), agent_y(Y), agent_gold(G),
	X == 1, Y == 1, G > 0.

get_action(shoot):-
	\+scream(yes,_,_), %no scream yet anywhere. Wumpus is still around!
	agent_arrow(Ar),
	Ar > 0,
	format('maybeshoot?\n'),
	agent_x(X), agent_y(Y), stench(yes,X,Y), format('asdf').

get_action(goforward):-
	random(10) > 4,
	agent_x(X), agent_y(Y), agent_ang(A),

	NewX is X + round(cos((A/360)*(pi*2))),
	NewY is Y + round(sin((A/360)*(pi*2))),

	safe(NewX, NewY),  format('it is!\n'), valid(NewX,NewY), format('it is!\n').

get_action(turnleft):- random(10) > 4. % random(2) returns 0 or 1.
get_action(turnright):- true.

safe(X,Y):-
	format('Is ~d, ~d safe?\n', [X,Y]),
	safe_breeze(X,Y),
	safe_stench(X,Y).
	

safe_breeze(X,Y):-
	format('Is ~d, ~d breeze-safe?\n', [X,Y]),
	X1 is X + 1,
	X0 is X - 1,
	Y1 is Y + 1,
	Y0 is Y - 1,
	(
		( breeze(no,X1,Y) ;
		breeze(no,X0,Y) ;
		breeze(no,X,Y1) ;
		breeze(no,X,Y0) )
		;
		breeze(_,X,Y) %its safe if there's no breeze neighboring it or if we already know if there's a breeze there or not.
	).

safe_stench(X,Y):-
	format('Is ~d, ~d stench-safe?\n', [X,Y]),
	X1 is X + 1,
	X0 is X - 1,
	Y1 is Y + 1,
	Y0 is Y - 1,
	(
		( stench(no,X1,Y) ;
		stench(no,X0,Y) ;
		stench(no,X,Y1) ;
		stench(no,X,Y0) )
		;
		stench(_,X,Y) %its safe if there's no stench neighboring it or if we already know if there's a stench there or not.
		;
		scream(yes,_,_) % OR if the wumpus is dead :)
	).

/*
neighbor(X,Y, List):-
	valid(X+1, Y) -> List is [[X+1,Y]|List],
	valid(X-1, Y) -> List is [[X-1,Y]|List],
	valid(X, Y+1) -> List is [[X,Y+1]|List],
	valid(X, Y-1) -> List is [[X,Y-1]|List].

neighbor(X,Y, []):-
	neighbor(X,Y,[[X+1,Y]]).
*/
valid(X,Y):-
	format('valid checking ~d ~d \n',[X,Y]),
	X > 0, X < 5, Y > 0, Y < 5.

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
	assert(scream(Scream,X,Y)).

%------------------------------------------------------------------------
% execute(Action,Percept): executes Action and returns Percept
%
%   Action is one of:
%     goforward: move one square along current orientation if possible
%     turnleft:  turn left 90 degrees
%     turnright: turn right 90 degreesS
%     grab:      pickup gold if in square
%     shoot:     shoot an arrow along orientation, killing wumpus if
%                in that direction
%     climb:     if in square 1,1, leaves the cave and adds 1000 points
%                for each piece of gold
%
%   Percept = [Stench,Breeze,Glitter,Bump,Scream]
%             The five parameters are either 'yes' or 'no'.

update_position(climb):-
	true.

update_position(shoot):-
	retract(agent_arrow(Ar)),
	NewAr is Ar-1,
	assert(agent_arrow(NewAr)).

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