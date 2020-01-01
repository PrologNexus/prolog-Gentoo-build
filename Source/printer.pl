/*
  Author:   Pieter Van den Abeele
  E-mail:   pvdabeel@mac.com
  Copyright (c) 2005-2020, Pieter Van den Abeele

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

printer:printable_element(rule(uri(_,_,_),_)) :- !.
printer:printable_element(rule(uri(_),_)) :- !.
printer:printable_element(rule(_Repository://_Entry:run,_)) :- !.
printer:printable_element(rule(_Repository://_Entry:download,_)) :- !.
printer:printable_element(rule(_Repository://_Entry:install,_)) :- !.
printer:printable_element(assumed(rule(_Repository://_Entry:_Action,_))) :- !.
printer:printable_element(assumed(rule(package_dependency(_,_,_,_,_,_,_,_),_))) :- !.
printer:printable_element(rule(assumed(package_dependency(_,_,_,_,_,_,_,_)),_)) :- !.


%! printer:element_weight(+Literal)
%
% Declares a weight for ordering elements of a step in a plan

printer:element_weight(assumed(_),                                 0) :- !. % assumed
printer:element_weight(rule(assumed(_),_),                         0) :- !. % assumed
printer:element_weight(rule(uri(_),_),                             0) :- !. % provide
printer:element_weight(rule(uri(_,_,_),_),                         1) :- !. % fetch
printer:element_weight(rule(package_dependency(_,_,_,_,_,_,_,_),_),1) :- !. % confirm
printer:element_weight(rule(_Repository://_Entry:run,_),           2) :- !. % run
printer:element_weight(rule(_Repository://_Entry:download,_),      3) :- !. % download
printer:element_weight(rule(_Repository://_Entry:install,_),       4) :- !. % install
printer:element_weight(_,                                          6) :- !. % everything else


%! printer:sort_by_weight(+Comparator,+Literal,+Literal)
%
% Sorts elements in a plan by weight

printer:sort_by_weight(C,L1,L2) :-
  printer:element_weight(L1,W1),
  printer:element_weight(L2,W2),
  compare(C,W1:L1,W2:L2).


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
  message:column(38,Repository://Entry),
  message:color(normal),
  printer:print_config(Repository://Entry:Action).



% -------------------------------------------------
% CASE: simple package, is not a target of the plan
% -------------------------------------------------

printer:print_element(_://_:_,rule(Repository://Entry:Action,_)) :-
  message:color(cyan),
  message:print(Action),
  message:color(green),
  message:column(33,Repository://Entry),
  message:color(normal),
  printer:print_config(Repository://Entry:Action).


% --------------------------------------------------------------
% CASE: verify that packages that need to be running are running
% --------------------------------------------------------------

printer:print_element(_,rule(package_dependency(run,_,_C,_N,_,_,_,_),[Repository://Entry:_Action])) :-
  !,
  message:color(cyan),
  message:print('confirm'),
  message:color(green),
  message:column(33,Repository://Entry),
  message:color(normal).

% ----------------
% CASE: a download
% ----------------

printer:print_element(_,rule(uri(Protocol,Remote,_Local),_)) :-
  !,
  message:color(cyan),
  message:print('fetch'),
  message:color(green),
  message:column(33,Protocol://Remote),
  message:color(normal).

printer:print_element(_,rule(uri(Local),_)) :-
  !,
  message:color(cyan),
  message:print('provide'),
  message:color(green),
  message:column(33,Local),
  message:color(normal).





% ---------------------------------------------------------------
% CASE: an assumed dependency on a non-existent installed package
% ---------------------------------------------------------------

printer:print_element(_,rule(assumed(package_dependency(install,_,C,N,_,_,_,_)),[])) :-
  message:color(red),
  message:print('verify'),
  atomic_list_concat([C,'/',N],P),
  message:column(28,P),
  message:print([' (non-existent, assumed installed)']),
  message:color(normal).


% -------------------------------------------------------------
% CASE: an assumed dependency on a non-existent running package
% -------------------------------------------------------------

printer:print_element(_,rule(assumed(package_dependency(run,_,C,N,_,_,_,_)),[])) :-
  message:color(red),
  message:print('verify'),
  atomic_list_concat([C,'/',N],P),
  message:column(28,P),
  message:print([' (non-existent, assumed running)']),
  message:color(normal).


% ----------------------------------
% CASE: an assumed installed package
% ----------------------------------

printer:print_element(_,assumed(rule(Repository://Entry:install,_Body))) :-
  message:color(red),
  message:print('verify'),
  message:column(28,Repository://Entry),
  message:print(' (assumed installed)'),
  message:color(normal).


% --------------------------------
% CASE: an assumed running package
% --------------------------------

printer:print_element(_,assumed(rule(Repository://Entry:run,_Body))) :-
  message:color(red),
  message:print('verify'),
  message:column(28,Repository://Entry),
  message:print(' (assumed running) '),
  message:color(normal).


% -------------------------------------
% CASE: an assumed installed dependency
% -------------------------------------

printer:print_element(_,assumed(rule(package_dependency(install,_,C,N,_,_,_,_),_Body))) :-
  message:color(red),
  message:print('verify'),
  atomic_list_concat([C,'/',N],P),
  message:column(28,P),
  message:print(' (assumed installed) '),
  message:color(normal).


% -----------------------------------
% CASE: an assumed running dependency
% -----------------------------------

printer:print_element(_,assumed(rule(package_dependency(run,_,C,N,_,_,_,_),_Body))) :-
  message:color(red),
  message:print('verify'),
  atomic_list_concat([C,'/',N],P),
  message:column(28,P),
  message:print(' (assumed running) '),
  message:color(normal).


%! printer:print_config_prefix(+Word)
%
% prints the prefix for a config item

printer:print_config_prefix(Word) :-
  nl,write('             │          '),
  message:color(darkgray),
  message:print('└─ '),
  message:print(Word),
  message:print(' ─┤ '),
  message:color(normal).


%! printer:print_config_prefix
%
% prints the prefix for a config item

printer:print_config_prefix :-
  nl,write('             │          '),
  message:color(darkgray),
  message:print('         │ '),
  message:color(normal).




%! printer:print_config(+Repository://+Entry:+Action)
%
% Prints the configuration for a given repository entry (USE flags, USE expand, ...)

% ------------------------
% CASE 1 : download action
% ------------------------


% live downloads

printer:print_config(Repository://Ebuild:download) :-
  ebuild:is_live(Repository://Ebuild),!,
  printer:print_config_prefix('live'),
  printer:print_config_item('download','git repository','live').


% no downloads

printer:print_config(Repository://Ebuild:download) :-
  not(knowledgebase:query([manifest(_,_,_)],Repository://Ebuild)),!.


% at least one download

printer:print_config(Repository://Ebuild:download) :-
  findall([File,Size],knowledgebase:query([manifest(_,File,Size)],Repository://Ebuild),[[FirstFile,FirstSize]|Rest]),!,
  printer:print_config_prefix('file'),
  printer:print_config_item('download',FirstFile,FirstSize),
  forall(member([RestFile,RestSize],Rest),
         (printer:print_config_prefix,
          printer:print_config_item('download',RestFile,RestSize))).


% -----------------------
% CASE 2 : Install action
% -----------------------


% iuse empty

printer:print_config(Repository://Entry:install) :-
  not(knowledgebase:query([iuse(_)],Repository://Entry)),!.

% use flags to show

printer:print_config(Repository://Entry:install) :-
  knowledgebase:query([all(iuse(Iuse))],Repository://Entry),
  knowledgebase:query([all(iuse_filtered(IuseFiltered))],Repository://Entry),
  eapi:split_iuse_set(IuseFiltered,Positive,Negative),
  printer:print_config_prefix('conf'),
  printer:print_config_item('use',Positive,Negative),
  forall(eapi:use_expand(Key),
         (preference:use_expand_hidden(Key);
          (eapi:get_use_expand(Key,Iuse,LongValue),
           eapi:split_iuse_set(LongValue,LongPosValue,LongNegValue),
           eapi:shorten_use_expand(Key,LongPosValue,PosValue),
           eapi:shorten_use_expand(Key,LongNegValue,NegValue),
           (printer:bothempty(PosValue,NegValue);
            (printer:print_config_prefix,
             printer:print_config_item(Key,PosValue,NegValue)))))),!.


% -------------------
% CASE 3 : Run action
% -------------------

printer:print_config(_://_:run) :- !.


% ----------------------
% CASE 4 : Other actions
% ----------------------

printer:print_config(_://_:_) :- !.


printer:bothempty([],[]).


%! printer:print_config_item(+Key,+Value)
%
% Prints a configuration item for a given repository entry

printer:print_config_item('download',File,Size) :-
  !,
  message:color(magenta),
  message:print_bytes(Size),
  message:color(normal),
  message:print(' '),
  message:print(File).

printer:print_config_item(Key,Positive,Negative) :-
  !,
  message:print(Key),
  message:print(' = "'),
  printer:print_use_flag_sets(Positive,Negative),
  message:print('"').


%! printer:print_use_flag_sets(+Positive,+Negative)
%
% Prints a list of Enabled and Disabled Use flags

printer:print_use_flag_sets([],Negative) :-
  !,
  printer:print_use_flag(Negative,negative).

printer:print_use_flag_sets(Positive,[]) :-
  !,
  printer:print_use_flag(Positive,positive).

printer:print_use_flag_sets(Positive,Negative) :-
  !,
  printer:print_use_flag(Positive,positive),
  write(' '),
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

printer:print_use_flag([Flag|Rest],positive) :-
  message:color(red),
  message:print(Flag),
  message:print(' '),
  message:color(normal),!,
  printer:print_use_flag(Rest,positive).


printer:print_use_flag([Flag],negative) :-
  message:color(magenta),
  message:print('-'),
  message:print(Flag),
  message:color(normal),
  !.

printer:print_use_flag([Flag|Rest],negative) :-
  message:color(magenta),
  message:print('-'),
  message:print(Flag),
  message:print(' '),
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


%! printer:print_body(+Plan,+Model,+Call,-Steps)
%
% Prints the body for a given plan and model, returns the number of printed steps

printer:print_body(Target,Plan,Call,Steps) :-
  printer:print_steps_in_plan(Target,Plan,Call,0,Steps).



%! printer:print_steps(+Target,+Plan,+Call,+Count,-NewCount)
%
% Print the steps in a plan

printer:print_steps_in_plan(_,[],_,Count,Count) :- !.

printer:print_steps_in_plan(Target,[Step|Rest],Call,Count,CountFinal) :-
  predsort(printer:sort_by_weight,Step,SortedStep),
  printer:print_first_in_step(Target,SortedStep,Count,CountNew),
  call(Call,SortedStep),!,
  printer:print_steps_in_plan(Target,Rest,Call,CountNew,CountFinal).


%! printer:print_first_in_step(+Target,+Step,+Call,+Count,-NewCount)
%
% Print a step in a plan

printer:print_first_in_step(_,[],Count,Count) :- !.

printer:print_first_in_step(Target,[Rule|Rest],Count,NewCount) :-
  printer:printable_element(Rule),
  NewCount is Count + 1,
  format(atom(AtomNewCount),'~t~0f~2|',[NewCount]),
  !,
  write(' └─ step '),write(AtomNewCount), write(' ─┤ '),
  printer:print_element(Target,Rule),
  printer:print_next_in_step(Target,Rest).

printer:print_first_in_step(Target,[_|Rest],Count,NewCount) :-
  printer:print_first_in_step(Target,Rest,Count,NewCount).


%! printer:print_next_in_step(+Target,+Step)
%
% Print a step in a plan

printer:print_next_in_step(_,[]) :- nl,nl,!.

printer:print_next_in_step(Target,[Rule|Rest]) :-
  printer:printable_element(Rule),
  !,
  nl,
  write('             │ '),
  printer:print_element(Target,Rule),
  printer:print_next_in_step(Target,Rest).

printer:print_next_in_step(Target,[_|Rest]) :-
  !,
  printer:print_next_in_step(Target,Rest).


%! printer:print_footer(+Plan)
%
% Print the footer for a given plan

printer:print_footer(Plan,Model,PrintedSteps) :-
  countlist(assumed(_),Model,_Assumptions),
  countlist(constraint(_),Model,_Constraints),
  countlist(naf(_),Model,_Nafs),
  countlist(_://_:_,Model,Actions),
  aggregate_all(sum(T),(member(R://E:download,Model),ebuild:download_size(R://E,T)),TotalDownloadSize),
  countlist(_://_:download,Model,Downloads),
  countlist(_://_:run,Model,Runs),
  countlist(_://_:install,Model,Installs),
  countlist(package_dependency(run,_,_,_,_,_,_,_),Model,_Verifs),
  Total is Actions, % + Verifs,
  length(Plan,_Steps),
  message:print(['Total: ', Total, ' actions (', Downloads, ' downloads, ', Installs,' installs, ', Runs,' runs), grouped into ',PrintedSteps,' steps.' ]),nl,
  message:print(['       ']),
  message:convert_bytes(TotalDownloadSize,A),
  message:print([A,' to be downloaded.']),nl,
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
