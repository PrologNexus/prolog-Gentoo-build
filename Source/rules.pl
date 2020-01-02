/*
  Author:   Pieter Van den Abeele
  E-mail:   pvdabeel@mac.com
  Copyright (c) 2005-2020, Pieter Van den Abeele

  Distributed under the terms of the LICENSE file in the root directory of this
  project.
*/


/** <module> RULES
This file contains domain-specific rules for dealing with software dependencies
*/

:- module(rules, [rule/2]).

% ******************
% RULES declarations
% ******************

% Skip masked ebuilds without failing

rule(Repository://Ebuild:_,[]) :-
  preference:masked(Repository://Ebuild),!.


% An ebuild is downloaded if its sources are downloaded

rule(_Repository://_Ebuild:download,[]) :-
  !.
  %knowledgebase:query([all(src_uri(S))],Repository://Ebuild).


% Ebuild sources are included in the build plan

% rule(uri(_Protocol,_Remote,_Local),[]) :- !.

% rule(uri(_Local),[]) :- !.


% An ebuild can be installed, if the following conditions are satisfied:
% - it is downloaded (if it is not a virtual, a group or a user)
% - its compiletime dependencies are satisfied
% - it can occupy an installation slot

% ----------------
% CASE 1 : Virtual
% ----------------

rule(Repository://Ebuild:install,[constraint(slot(C,N,S):{[Ebuild]})|D]) :-
  knowledgebase:query([category(C),name(N),slot(slot(S)),all(depend(D))],Repository://Ebuild),
  memberchk(C,['virtual','acct-group','acct-user']),!.


% -------------------
% CASE 2: Non-Virtual
% -------------------

rule(Repository://Ebuild:install,[Repository://Ebuild:download,constraint(slot(C,N,S):{[Ebuild]})|D]) :-
  !,
  knowledgebase:query([category(C),name(N),slot(slot(S)),all(depend(D))],Repository://Ebuild).


% An ebuild can be run, if it is installed and if its runtime dependencies are satisfied

rule(Repository://Ebuild:run,[Repository://Ebuild:install|D]) :-
  !,
  knowledgebase:query([all(rdepend(D))],Repository://Ebuild).


% Conflicting package: EAPI 8.2.6.2: a weak block can be ignored by the package manager

rule(package_dependency(_,weak,_,_,_,_,_,_),[]) :- !.


% Conflicting package: EAPI 8.2.6.2: a strong block is satisfied when no suitable candidate is satisfied

rule(package_dependency(_Action,strong,_C,_N,_,_,_,_),[]) :- !.

%rule(package_dependency(Action,strong,C,N,_,_,_,_),Nafs) :-
%  findall(naf(Repository://Choice:Action),cache:entry(Repository,Choice,_,C,N,_,_),Nafs),!.


% Dependencies on the system profile are assumed satisfied

rule(package_dependency(_,no,'app-arch','bzip2',_,_,_,_),[]) :- !.
rule(package_dependency(_,no,'app-arch','gzip',_,_,_,_),[]) :- !.
rule(package_dependency(_,no,'app-arch','tar',_,_,_,_),[]) :- !.
rule(package_dependency(_,no,'app-arch','xz-utils',_,_,_,_),[]) :- !.
rule(package_dependency(_,no,'app-shells','bash',_,_,_,_),[]) :- !.
rule(package_dependency(_,no,'dev-lang','perl',_,_,_,_),[]) :- !.
rule(package_dependency(_,no,'dev-lang','python',_,_,_,_),[]) :- !.
rule(package_dependency(_,no,'dev-libs','libpcre',_,_,_,_),[]) :- !.
rule(package_dependency(_,no,'net-misc','iputils',_,_,_,_),[]) :- !.
rule(package_dependency(_,no,'net-misc','rsync',_,_,_,_),[]) :- !.
rule(package_dependency(_,no,'net-misc','wget',_,_,_,_),[]) :- !.
rule(package_dependency(_,no,'sys-apps','baselayout',_,_,_,_),[]) :- !.
rule(package_dependency(_,no,'sys-apps','coreutils',_,_,_,_),[]) :- !.
rule(package_dependency(_,no,'sys-apps','diffutils',_,_,_,_),[]) :- !.
rule(package_dependency(_,no,'sys-apps','file',_,_,_,_),[]) :- !.
rule(package_dependency(_,no,'sys-apps','findutils',_,_,_,_),[]) :- !.
rule(package_dependency(_,no,'sys-apps','gawk',_,_,_,_),[]) :- !.
rule(package_dependency(_,no,'sys-apps','grep',_,_,_,_),[]) :- !.
rule(package_dependency(_,no,'sys-apps','kbd',_,_,_,_),[]) :- !.
rule(package_dependency(_,no,'sys-apps','less',_,_,_,_),[]) :- !.
rule(package_dependency(_,no,'sys-apps','sed',_,_,_,_),[]) :- !.
rule(package_dependency(_,no,'sys-apps','util-linux',_,_,_,_),[]) :- !.
rule(package_dependency(_,no,'sys-devel','automake',_,_,_,_),[]) :- !.
rule(package_dependency(_,no,'sys-devel','binutils',_,_,_,_),[]) :- !.
rule(package_dependency(_,no,'sys-devel','gcc',_,_,_,_),[]) :- !.
rule(package_dependency(_,no,'sys-devel','gnuconfig',_,_,_,_),[]) :- !.
rule(package_dependency(_,no,'sys-devel','make',_,_,_,_),[]) :- !.
rule(package_dependency(_,no,'sys-devel','patch',_,_,_,_),[]) :- !.
rule(package_dependency(_,no,'sys-fs','e2fsprogs',_,_,_,_),[]) :- !.
rule(package_dependency(_,no,'sys-libs','ncurses',_,_,_,_),[]) :- !.
rule(package_dependency(_,no,'sys-libs','readline',_,_,_,_),[]) :- !.
rule(package_dependency(_,no,'sys-process','procps',_,_,_,_),[]) :- !.
rule(package_dependency(_,no,'sys-process','psmisc',_,_,_,_),[]) :- !.
rule(package_dependency(_,no,'virtual','dev-manager',_,_,_,_),[]) :- !.
rule(package_dependency(_,no,'virtual','editor',_,_,_,_),[]) :- !.
rule(package_dependency(_,no,'virtual','libc',_,_,_,_),[]) :- !.
rule(package_dependency(_,no,'virtual','man',_,_,_,_),[]) :- !.
rule(package_dependency(_,no,'virtual','modutils',_,_,_,_),[]) :- !.
rule(package_dependency(_,no,'virtual','os-headers',_,_,_,_),[]) :- !.
rule(package_dependency(_,no,'virtual','package-manager',_,_,_,_),[]) :- !.
rule(package_dependency(_,no,'virtual','pager',_,_,_,_),[]) :- !.
rule(package_dependency(_,no,'virtual','service-manager',_,_,_,_),[]) :- !.
rule(package_dependency(_,no,'virtual','shadow',_,_,_,_),[]) :- !.
rule(package_dependency(_,no,'virtual','ssh',_,_,_,_),[]) :- !.


% A package dependency is satisfied when a suitable candidate is satisfied

rule(package_dependency(Action,no,C,N,_,_,_,_),[Repository://Choice:Action]) :-
  knowledgebase:query([name(N),category(C)],Repository://Choice).


% A package dependency that has no suitable candidates is assumed satisfied
% The planner and builder checks for assumptions before execution

rule(package_dependency(Action,no,C,N,O,V,S,U),[assumed(package_dependency(Action,no,C,N,O,V,S,U))]) :-
  not(knowledgebase:query([name(N),category(C)],_)),!.


% The dependencies in a positive use conditional group need to be satisfied when the use flag is set

rule(use_conditional_group(positive,Use,_),_) :-
  not(preference:positive_use(Use)),!.

rule(use_conditional_group(positive,_,D),D) :- !.


% The dependencies in a negative use conditional group need to be satisfied when the use is not set

rule(use_conditional_group(negative,Use,_),[]) :-
  preference:positive_use(Use),!.
  % todo : check ebuild default

rule(use_conditional_group(negative,_,D),D) :- !.


% Exactly one of the dependencies in an exactly-one-of-group should be satisfied

rule(exactly_one_of_group(Deps),[D]) :-
  member(D,Deps).


% One dependency of an any_of_group should be satisfied

rule(any_of_group(Deps),[D]) :-
  member(D,Deps).


% All dependencies in an all_of_group should be satisfied

rule(all_of_group(Deps),Deps) :- !.


% Assumptions are assumed

rule(assumed(_),[]) :- !.


% Negation as failure

rule(naf(_),[]) :- !.
