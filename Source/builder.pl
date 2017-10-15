% ********************
% BUILDER declarations
% ********************


builder:execute(Plan) :-
  forall(member(E,Plan),
    (write(' -  STEP:  | '),builder:firststep(E))).

builder:firststep([]) :-  nl, !.

builder:firststep([rule(E:Action,_)|L]) :-
  !,
  message:color(green),
  write(E),
  message:color(blue),
  write(' '),
  write(Action),
  message:color(normal),
  builder:build(E),
  nl,
  builder:nextstep(L).

builder:firststep([rule(_,_)|L]) :-
  builder:firststep(L).


builder:nextstep([]) :- nl,!.

builder:nextstep([rule(E:Action,_)|L]) :- 
  !,
  write('           | '),
  message:color(green),
  write(E),
  message:color(blue),
  write(' '),
  write(Action),
  message:color(normal),
  builder:build(E),
  nl,
  builder:nextstep(L).

builder:nextstep([rule(_,_)|L]) :- 
  builder:nextstep(L).


builder:build(Entry) :-
  portage:get_location(L),
  portage:ebuild(Entry,Category,Package,Version),
  atomic_list_concat(['ebuild ',L,'/',Category,'/',Package,'/',Package,'-',Version,'.ebuild install qmerge clean'],Cmd),
  shell(Cmd),!.



builder:test(Repository) :-
  system:time(
              system:forall(cache:entry(Repository,E,_,_,_,_,_),
 	                    ((nl,message:header(["Planning ",E]),
                              prover:prove(E:install,[],Proof,[],_),
			      planner:plan(Proof,[],[],Plan),
                              builder:execute(Plan));
			     (message:failure(E)))
                           )
             ),
  system:findall(E,Repository:entry(E),L),
  system:length(L,H),
  system:write('% built plan for '),system:write(H),system:write(' cache entries.\n').
