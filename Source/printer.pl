/*
  Author:   Pieter Van den Abeele
  E-mail:   pvdabeel@mac.com
  Copyright (c) 2005-2019, Pieter Van den Abeele

  Distributed under the terms of the LICENSE file in the root directory of this
  project.
*/


/** <module> PRINTER
The Printer takes a plan from the Planner and pretty prints it.
*/

:- module(printer, []).

% ********************
% PRINTER declarations
% ********************

%! printer:printable_element(+Literal)
%
% Declares which Literals are printable

printer:printable_element(rule(_Repository://_Entry:_Action,_)) :- !.
printer:printable_element(assumed(rule(_Repository://_Entry:_Action,_))) :- !.
printer:printable_element(assumed(rule(package_dependency(_,_,_,_,_,_,_,_),_))) :- !.
printer:printable_element(rule(assumed(package_dependency(_,_,_,_,_,_,_,_)),_)) :- !.


% Uncomment if you want 'confirm' steps shown in the plan:
%
% printer:printable_element(rule(package_dependency(run,_,_,_,_,_,_,_),_)) :- !.


%! printer:print_element(+Printable)
%
% Prints a printable Literal

% ---------------------------------------------
% CASE: simple package, is a target of the plan
% ---------------------------------------------

printer:print_element(Repository://Entry:Action,rule(Repository://Entry:Action,_)) :-
  !,
  message:color(cyan),
  message:print(Action),
  message:style(bold),
  message:color(green),
  message:column(35,Repository://Entry),
  message:color(normal),
  printer:print_iuse(Repository://Entry).



% -------------------------------------------------
% CASE: simple package, is not a target of the plan
% -------------------------------------------------

printer:print_element(_://_:_,rule(Repository://Entry:Action,_)) :-
  message:color(cyan),
  message:print(Action),
  message:color(green),
  message:column(30,Repository://Entry),
  message:color(normal),
  printer:print_iuse(Repository://Entry).


% --------------------------------------------------------------
% CASE: verify that packages that need to be running are running
% --------------------------------------------------------------

printer:print_element(_,rule(package_dependency(run,_,_C,_N,_,_,_,_),[Repository://Entry:_Action])) :-
  !,
  message:color(cyan),
  message:print('confirm'),
  message:color(green),
  message:column(30,Repository://Entry),
  message:color(normal).


% ---------------------------------------------------------------
% CASE: an assumed dependency on a non-existent installed package
% ---------------------------------------------------------------

printer:print_element(_,rule(assumed(package_dependency(install,_,C,N,_,_,_,_)),[])) :-
  message:color(red),
  message:print('verify'),
  atomic_list_concat([C,'/',N],P),
  message:column(25,P),
  message:print([' (non-existent, assumed installed)']),
  message:color(normal).


% -------------------------------------------------------------
% CASE: an assumed dependency on a non-existent running package
% -------------------------------------------------------------

printer:print_element(_,rule(assumed(package_dependency(run,_,C,N,_,_,_,_)),[])) :-
  message:color(red),
  message:print('verify'),
  atomic_list_concat([C,'/',N],P),
  message:column(25,P),
  message:print([' (non-existent, assumed running)']),
  message:color(normal).


% ----------------------------------
% CASE: an assumed installed package
% ----------------------------------

printer:print_element(_,assumed(rule(Repository://Entry:install,_Body))) :-
  message:color(red),
  message:print('verify'),
  message:column(25,Repository://Entry),
  message:print(' (assumed installed)'),
  message:color(normal).


% --------------------------------
% CASE: an assumed running package
% --------------------------------

printer:print_element(_,assumed(rule(Repository://Entry:run,_Body))) :-
  message:color(red),
  message:print('verify'),
  message:column(25,Repository://Entry),
  message:print(' (assumed running) '),
  message:color(normal).


% -------------------------------------
% CASE: an assumed installed dependency
% -------------------------------------

printer:print_element(_,assumed(rule(package_dependency(install,_,C,N,_,_,_,_),_Body))) :-
  message:color(red),
  message:print('verify'),
  atomic_list_concat([C,'/',N],P),
  message:column(25,P),
  message:print(' (assumed installed) '),
  message:color(normal).


% -----------------------------------
% CASE: an assumed running dependency
% -----------------------------------

printer:print_element(_,assumed(rule(package_dependency(run,_,C,N,_,_,_,_),_Body))) :-
  message:color(red),
  message:print('verify'),
  atomic_list_concat([C,'/',N],P),
  message:column(25,P),
  message:print(' (assumed running) '),
  message:color(normal).



%! printer:print_iuse(+Repository://+Entry)
%
% Prints the USE flags for a given repository

printer:print_iuse(Repository://Entry) :-
  ebuild:get(iuse,Repository://Entry,[]),!.

printer:print_iuse(Repository://Entry) :-
  message:print(' USE="'),
  ebuild:get(iuse,Repository://Entry,IUseFlags),
  preference:use(SystemEnabledFlags),
  subtract(IUseFlags,SystemEnabledFlags,NegativeUse),
  subtract(IUseFlags,NegativeUse,PositiveUse),
  printer:print_use_flag_sets(PositiveUse,NegativeUse),
  message:print('"').


%! printer:print_use_flag_sets(+Positive,+Negative)
%
% Prints a list of Enabled and Disabled Use flags

printer:print_use_flag_set([],Negative) :-
  !,
  printer:print_use_flag(Negative,negative).

printer:print_use_flag_sets(Positive,Negative) :-
  !,
  printer:print_use_flag(Positive,positive),
  printer:print_use_flag(Negative,negative).


%! printer:print_use_flag(+Flags)
%
% Prints a list of USE flags

printer:print_use_flag([],_) :-
  !.

printer:print_use_flag([Flag],positive) :-
  message:color(red),
  message:print(Flag),
  message:color(normal),
  !.

printer:print_use_flag([Flag],negative) :-
  message:color(magenta),
  message:print('-'),
  message:print(Flag),
  message:color(normal),
  !.

printer:print_use_flag([Flag|Rest],positive) :-
  message:color(red),
  message:print(Flag),
  message:print(' '),
  message:color(normal),!,
  printer:print_use_flag(Rest,positive).

printer:print_use_flag([Flag|Rest],negative) :-
  message:color(magenta),
  message:print(Flag),
  message:print(' -'),
  message:color(normal),!,
  printer:print_use_flag(Rest,negative).


%! printer:check_assumptions(+Model)
%
% Checks whether the Model contains assumptions

printer:check_assumptions(Model) :-
  member(assumed(_),Model),!.


%! Some helper predicates

unify(A,B) :- unifiable(A,B,_),!.

countlist(Predicate,List,Count) :-
  include(unify(Predicate),List,Sublist),!,
  length(Sublist,Count).

countlist(_,_,0) :- !.


%! printer:print_header(+Target)
%
% Prints the header for a given target

printer:print_header(Target) :-
  message:header(['Emerging ', Target]),
  nl,
  message:color(green),
  message:print('These are the packages that would be merged, in order:'),nl,
  nl,
  message:color(normal),
  message:print('Calculating dependencies... done!'),nl,
  nl.


%! printer:print_debug(+Model,+Proof,+Plan)
%
% Prints debug info for a given Model, Proof and Plan

printer:print_debug(_Model,_Proof,Plan) :-
  message:color(darkgray),
  % message:inform(['Model : ',Model]),nl,
  % message:inform(['Proof : ',Proof]),nl,
  forall(member(X,Plan),(write(' -> '),writeln(X))),nl,
  message:color(normal).


%! printer:print_body(+Plan,+Model,-Steps)
%
% Prints the body for a given plan and model, returns the number of printed steps

printer:print_body(Target,Plan,Call,Steps) :-
  aggregate_all(count,(member(Step,Plan),
                (printer:print_first_in_step(Target,Step,Printed),
                 call(Call,Step),
                 Printed = true)),
                Steps).


%! printer:print_first_in_step(+Target,+Step,+Call,-Printed)
%
% Print a step in a plan

printer:print_first_in_step(_,[],false) :- !.

printer:print_first_in_step(Target, [Rule|L],true) :-
  printer:printable_element(Rule),
  !,
  write(' └─ step ─┤ '),
  printer:print_element(Target,Rule),
  printer:print_next_in_step(Target,L).

printer:print_first_in_step(Target,[_|L],Printed) :-
  printer:print_first_in_step(Target,L,Printed).


%! printer:print_next_in_step(+Step)
%
% Print a step in a plan

printer:print_next_in_step(_,[]) :- nl,nl,!.

printer:print_next_in_step(Target,[Rule|L]) :-
  printer:printable_element(Rule),
  !,
  nl,
  write('          │ '),
  printer:print_element(Target,Rule),
  printer:print_next_in_step(Target,L).

printer:print_next_in_step(Target,[_|L]) :-
  printer:print_next_in_step(Target,L).


%! printer:print_footer(+Plan)
%
% Print the footer for a given plan

printer:print_footer(Plan,Model,PrintedSteps) :-
  countlist(assumed(_),Model,_Assumptions),
  countlist(constraint(_),Model,_Constraints),
  countlist(naf(_),Model,_Nafs),
  countlist(_://_:_,Model,Actions),
  countlist(_://_:run,Model,Runs),
  countlist(_://_:install,Model,Installs),
  countlist(package_dependency(run,_,_,_,_,_,_,_),Model,_Verifs),
  Total is Actions, % + Verifs,
  length(Plan,_Steps),
  message:print(['Total: ', Total, ' actions (', Installs,' installs, ', Runs,' runs), grouped into ',PrintedSteps,' steps.' ]),nl,
  nl.


%! printer:print_warnings(+Model, +Proof)
%
% Print the assumptions taken by the prover

printer:print_warnings(Model,Proof) :-
  printer:check_assumptions(Model),!,
  message:color(red),message:print('Error: '),
  message:print('The proof for your build plan contains assumptions. Please verify:'),nl,nl,
  forall(member(assumed(rule(C,_)),Proof),
    (message:print([' - Circular dependency: ',C]),nl)),
  forall(member(rule(assumed(U),_),Proof),
    (message:print([' - Non-existent ebuild: ',U]),nl)),
  nl,
  message:color(normal),nl.

printer:print_warnings(_Model,_Proof) :- !, nl.



%! printer:print(+Target,+Model,+Proof,+Plan)
%
% Print a given plan for a given target, with a given model, proof and plan
% Calls the printer:dry_run predicate for building a step

printer:print(Target,Model,Proof,Plan) :-
  printer:print(Target,Model,Proof,Plan,printer:dry_run).


%! printer:print(+Target,+Model,+Proof,+Plan,+Call)
%
% Print a given plan for a given target, with a given model, proof and plan
% Calls the given call for elements of the build plan

printer:print(Target,Model,Proof,Plan,Call) :-
  printer:print_header(Target),
% printer:print_debug(Model,Proof,Plan),
  printer:print_body(Target,Plan,Call,Steps),
  printer:print_footer(Plan,Model,Steps),
  printer:print_warnings(Model,Proof).


%! printer:dry_run(+Step)
%
% Default execution strategy for building steps in a plan

printer:dry_run(_Step) :-
  true.
  %message:color(darkgray),
  %message:print(['building step : ',Step]),nl,
  %message:color(normal).


%! printer:test(+Repository)
%
% Proves and prints every entry in a given repository, reports using the default reporting style

printer:test(Repository) :-
  config:test_style(Style),
  printer:test(Repository,Style).


%! printer:test(+Repository,+Style)
%
% Proves and prints every entry in a given repository, reports using a given reporting style

printer:test(Repository,single_verbose) :-
  Repository:get_size(S),
  count:newinstance(counter),
  count:init(0,S),
  config:time_limit(T),
  config:proving_target(Action),
  time(forall(Repository:entry(E),
 	      (catch(call_with_time_limit(T,(count:increase,
                                             count:percentage(P),
                                             nl,message:topheader(['[',P,'] - Printing plan for ',Repository://E:Action]),
                                             prover:prove(Repository://E:Action,[],Proof,[],Model,[],_Constraints),
                                             planner:plan(Proof,[],[],Plan),
                                             printer:print(Repository://E:Action,Model,Proof,Plan))),
                     time_limit_exceeded,
                     assert(prover:broken(Repository://E)));
	       message:failure(E)))),!,
  message:inform(['printed plan for ',S,' ',Repository,' entries.']).


printer:test(Repository,parallel_verbose) :-
  Repository:get_size(S),
  count:newinstance(counter),
  count:init(0,S),
  config:time_limit(T),
  config:proving_target(Action),
  config:number_of_cpus(Cpus),
  findall((catch(call_with_time_limit(T,(prover:prove(Repository://E:Action,[],Proof,[],Model,[],_Constraints),!,
                                         planner:plan(Proof,[],[],Plan),
                                         with_mutex(mutex,(count:increase,
                                                           count:percentage(P),
                                                           nl,message:topheader(['[',P,'] - Printing plan for ',Repository://E:Action]),
                                                           printer:print(Repository://E:Action,Model,Proof,Plan))))),
                 time_limit_exceeded,
                 assert(prover:broken(Repository://E)))),
           Repository:entry(E),
           Calls),
  time(concurrent(Cpus,Calls,[])),!,
  message:inform(['printed plan for ',S,' ',Repository,' entries.']).


printer:test(Repository,parallel_fast) :-
  printer:test(Repository,paralell_verbose).
