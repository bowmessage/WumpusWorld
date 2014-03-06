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

:- dynamic agent_x/1, agent_y/1, agent_ang/1, agent_gold/1, breeze/3, stench/3, glitter/3, bump/3, scream/3.

init_agent:-
	format('\n=====================================================\n'),
	format('This is init_agent:\n\tIt gets called once, use it for your initialization\n\n'),
	format('=====================================================\n\n'),
	assert(agent_x(1)),
	assert(agent_y(1)),
	assert(agent_gold(0)),
	assert(agent_ang(0)).


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
	agent_x(X), agent_y(Y).

get_action(goforward):-
	agent_x(X), agent_y(Y), agent_ang(A),

	NewX is X + round(cos((A/360)*(pi*2))),
	NewY is Y + round(sin((A/360)*(pi*2))),

	safe(NewX, NewY),  format('it is!\n'), valid(NewX,NewY), format('it is!\n').

get_action(turnleft):- true.

safe(X,Y):-
	format('Is ~d, ~d safe?\n', [X,Y]),
	X1 is X + 1,
	X0 is X - 1,
	Y1 is Y + 1,
	Y0 is Y - 1,
	(
		\+( breeze(yes,X1,Y) ;
		breeze(yes,X0,Y) ;
		breeze(yes,X,Y1) ;
		breeze(yes,X,Y0) )
		;
		breeze(_,X,Y)
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

update_position(grab):-
	agent_x(X), agent_y(Y), glitter(yes,X,Y),
	retract(agent_gold(G)),
	NewG is G + 1,
	assert(agent_gold(NewG)).

update_position(turnleft):-
	retract(agent_ang(A)),
	NewA is A + 90,
	assert(agent_ang(NewA)).

update_position(turnright):-
	retract(agent_ang(A)),
	NewA is A - 90,
	assert(agent_ang(NewA)).

update_position(goforward):-
	agent_ang(A),

	retract(agent_x(X)),
  	retract(agent_y(Y)),

	NewX is X + round(cos((A/360)*(pi*2))),
	NewY is Y + round(sin((A/360)*(pi*2))),

	assert(agent_x(NewX)), 
  	assert(agent_y(NewY)).