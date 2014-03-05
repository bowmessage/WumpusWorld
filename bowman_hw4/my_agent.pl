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

:- dynamic agent_x/1, agent_y/1, agent_ang/1, breeze/3, stench/3, glitter/3, bump/3, scream/3.

init_agent:-
  format('\n=====================================================\n'),
  format('This is init_agent:\n\tIt gets called once, use it for your initialization\n\n'),
  format('=====================================================\n\n'),
  assert(agent_x(1)),
  assert(agent_y(1)),
  assert(agent_ang(0)).


%run_agent(Percept,Action):-
%run_agent(_,_):-
%	format('\nomg\n').
%   Percept = [Stench,Breeze,Glitter,Bump,Scream]
%             The five parameters are either 'yes' or 'no'.

run_agent(Percept, Action):-

  add_percepts(Percept),

  update_position(Action),

  agent_x(X), agent_y(Y),

  format('Im at: ~d ~d\n',[X,Y]),

  %format('I think Im at ~d, ~d\n',X,Y),
  display_world.

add_percepts([Stench,Breeze,Glitter,Bump,Scream]):-
	revert(stench(_,X,Y)),
	revert(breeze(_,X,Y)),
	revert(glitter(_,X,Y)),
	revert(bump(_,X,Y)),
	revert(scream(_,X,Y)),


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

	NewX is X + round(cos(A/pi*2)),
	NewY is Y + round(sin(A/pi*2)),

	assert(agent_x(NewX)), 
  	assert(agent_y(NewY)).