/*
  Author:   Pieter Van den Abeele
  E-mail:   pvdabeel@mac.com
  Copyright (c) 2005-2024, Pieter Van den Abeele

  Distributed under the terms of the LICENSE file in the root directory of this
  project.
*/


/** <module> RULES
This file contains domain-specific rules
*/

:- module(rules, [rule/2]).


% ******************
% RULES declarations
% ******************


% ----------------------
% Ruleset: Ebuild states
% ----------------------

% MASKED
%
% Skip masked ebuilds

rule(Repository://Ebuild:_Action,[]) :-
  preference:masked(Repository://Ebuild),!.


% DOWNLOAD
%
% An ebuild is downloaded if its sources are downloaded

rule(_Repository://_Ebuild:download,[]) :- !.


% INSTALL
%
% An ebuild is installed, either:
%
% - The os reports it as installed, and we are not proving emptytree
%
% or, if the following conditions are satisfied:
%
% - Its require_use dependencies are satisfied
% - It is downloaded (Only when it is not a virtual, a group or a user)
% - Its compile-time dependencies are satisfied
% - it can occupy an installation slot

rule(Repository://Ebuild:install,[]) :-
  not(prover:flag(emptytree)),
  os:installed_pkg(Repository://Ebuild),!.

rule(Repository://Ebuild:install,Conditions) :-
  knowledgebase:query([category(C),name(N),slot(slot(S)),model(required_use(M)),all(depend(D))],Repository://Ebuild),
  ( memberchk(C,['virtual','acct-group','acct-user']) ->
    Conditions = [constraint(use(Repository://Ebuild):{M}),
                  constraint(slot(C,N,S):{[Ebuild]})
                  |D];
    Conditions = [constraint(use(Repository://Ebuild):{M}),
                  Repository://Ebuild:download,
                  constraint(slot(C,N,S):{[Ebuild]})
                  |D] ).


% RUN
%
% An ebuild can be run, either:
%
% - The os reports it as runnable, and we are not proving emptytree
%
% or:
%
% - if it is installed and if its runtime dependencies are satisfied

rule(Repository://Ebuild:run,[]) :-
  not(prover:flag(emptytree)),
  os:installed_pkg(Repository://Ebuild),!.

rule(Repository://Ebuild:run,[Repository://Ebuild:install|D]) :-
  !,
  knowledgebase:query([all(rdepend(D))],Repository://Ebuild).


% ------------------------------
% Ruleset: Dependency resolution
% ------------------------------

% PACKAGE_DEPENDENCY
%
% Ebuilds use package dependencies to express relations (conflicts or requirements) on
% other ebuilds.


% Conflicting package:
%
% EAPI 8.2.6.2: a weak block can be ignored by the package manager

rule(package_dependency(_,_,weak,_,_,_,_,_,_),[]) :- !.


% Conflicting package:
%
% EAPI 8.2.6.2: a strong block is satisfied when no suitable candidate is satisfied

rule(package_dependency(_,_,strong,_,_,_,_,_,_),[]) :- !.

% rule(package_dependency(Action,strong,C,N,_,_,_,_),Nafs) :-
%   findall(naf(Repository://Choice:Action),cache:entry(Repository,Choice,_,C,N,_,_),Nafs),!.


% Dependencies on the system profile
%
% These type of dependencies are assumed satisfied. If they are not defined,
% portage-ng will detect a circular dependency (e.g. your compiler needs a compiler)

rule(package_dependency(_,_,no,'app-arch','bzip2',_,_,_,_),[]) :- !.
rule(package_dependency(_,_,no,'app-arch','gzip',_,_,_,_),[]) :- !.
rule(package_dependency(_,_,no,'app-arch','tar',_,_,_,_),[]) :- !.
rule(package_dependency(_,_,no,'app-arch','xz-utils',_,_,_,_),[]) :- !.
rule(package_dependency(_,_,no,'app-shells','bash',_,_,_,_),[]) :- !.
rule(package_dependency(_,_,no,'dev-lang','perl',_,_,_,_),[]) :- !.
rule(package_dependency(_,_,no,'dev-lang','python',_,_,_,_),[]) :- !.
rule(package_dependency(_,_,no,'dev-libs','libpcre',_,_,_,_),[]) :- !.
rule(package_dependency(_,_,no,'net-misc','iputils',_,_,_,_),[]) :- !.
rule(package_dependency(_,_,no,'net-misc','rsync',_,_,_,_),[]) :- !.
rule(package_dependency(_,_,no,'net-misc','wget',_,_,_,_),[]) :- !.
rule(package_dependency(_,_,no,'sys-apps','baselayout',_,_,_,_),[]) :- !.
rule(package_dependency(_,_,no,'sys-apps','coreutils',_,_,_,_),[]) :- !.
rule(package_dependency(_,_,no,'sys-apps','diffutils',_,_,_,_),[]) :- !.
rule(package_dependency(_,_,no,'sys-apps','file',_,_,_,_),[]) :- !.
rule(package_dependency(_,_,no,'sys-apps','findutils',_,_,_,_),[]) :- !.
rule(package_dependency(_,_,no,'sys-apps','gawk',_,_,_,_),[]) :- !.
rule(package_dependency(_,_,no,'sys-apps','grep',_,_,_,_),[]) :- !.
rule(package_dependency(_,_,no,'sys-apps','kbd',_,_,_,_),[]) :- !.
rule(package_dependency(_,_,no,'sys-apps','less',_,_,_,_),[]) :- !.
rule(package_dependency(_,_,no,'sys-apps','sed',_,_,_,_),[]) :- !.
rule(package_dependency(_,_,no,'sys-apps','util-linux',_,_,_,_),[]) :- !.
rule(package_dependency(_,_,no,'sys-devel','automake',_,_,_,_),[]) :- !.
rule(package_dependency(_,_,no,'sys-devel','binutils',_,_,_,_),[]) :- !.
rule(package_dependency(_,_,no,'sys-devel','gcc',_,_,_,_),[]) :- !.
rule(package_dependency(_,_,no,'sys-devel','gnuconfig',_,_,_,_),[]) :- !.
rule(package_dependency(_,_,no,'sys-devel','make',_,_,_,_),[]) :- !.
rule(package_dependency(_,_,no,'sys-devel','patch',_,_,_,_),[]) :- !.
rule(package_dependency(_,_,no,'sys-fs','e2fsprogs',_,_,_,_),[]) :- !.
rule(package_dependency(_,_,no,'sys-libs','libcap',_,_,_,_),[]) :- !.
rule(package_dependency(_,_,no,'sys-libs','ncurses',_,_,_,_),[]) :- !.
rule(package_dependency(_,_,no,'sys-libs','readline',_,_,_,_),[]) :- !.
rule(package_dependency(_,_,no,'sys-process','procps',_,_,_,_),[]) :- !.
rule(package_dependency(_,_,no,'sys-process','psmisc',_,_,_,_),[]) :- !.
rule(package_dependency(_,_,no,'virtual','dev-manager',_,_,_,_),[]) :- !.
rule(package_dependency(_,_,no,'virtual','editor',_,_,_,_),[]) :- !.
rule(package_dependency(_,_,no,'virtual','libc',_,_,_,_),[]) :- !.
rule(package_dependency(_,_,no,'virtual','man',_,_,_,_),[]) :- !.
rule(package_dependency(_,_,no,'virtual','modutils',_,_,_,_),[]) :- !.
rule(package_dependency(_,_,no,'virtual','os-headers',_,_,_,_),[]) :- !.
rule(package_dependency(_,_,no,'virtual','package-manager',_,_,_,_),[]) :- !.
rule(package_dependency(_,_,no,'virtual','pager',_,_,_,_),[]) :- !.
rule(package_dependency(_,_,no,'virtual','service-manager',_,_,_,_),[]) :- !.
rule(package_dependency(_,_,no,'virtual','shadow',_,_,_,_),[]) :- !.
rule(package_dependency(_,_,no,'virtual','ssh',_,_,_,_),[]) :- !.


% A package dependency is satisfied when a suitable candidate is satisfied,
% a package dependency that has no suitable candidates is "assumed" satisfied
%
% Portage-ng will identify these assumptions in its proof and show them to the
% user prior to continuing to the next stage (i.e. executing the plan).

% Preference: prefer installed packages over new packages, unless 'deep' flag
% is used

rule(package_dependency(_R://_E,Action,no,C,N,_O,_V,_S,_U),Conditions) :-
  not(prover:flag(deep)),
  preference:accept_keywords(K),
  knowledgebase:query([installed(true),name(N),category(C),keywords(K)],Repository://Choice),
  Conditions = [Repository://Choice:Action].

rule(package_dependency(_R://_E,Action,no,C,N,_O,_V,_S,_U),Conditions) :-
  preference:accept_keywords(K),
  knowledgebase:query([name(N),category(C),keywords(K)],Repository://Choice),
  Conditions = [Repository://Choice:Action].

rule(package_dependency(R://E,Action,no,C,N,O,V,S,U),Conditions) :-
  preference:accept_keywords(K),
  not(knowledgebase:query([name(N),category(C),keywords(K)],_)),
  Conditions = [assumed(package_dependency(R://E,Action,no,C,N,O,V,S,U))],!.


% The dependencies in a positive use conditional group need to be satisfied when
% the use flag is positive through required use constraint, preference or ebuild
% default

rule(use_conditional_group(positive,Use,R://E,D),[constraint(use(R://E)):Use|D]).

rule(use_conditional_group(positive,Use,R://E,_),[]) :-
  not(knowledgebase:query([iuse(Use,positive:_)],R://E)),!.
  %not(preference:positive_use(Use)),!.

rule(use_conditional_group(positive,_,_,D),D) :- !.


% The dependencies in a negative use conditional group need to be satisfied when
% the use flag is not positive through required use constraint, preference or
% ebuild default

rule(use_conditional_group(negative,Use,R://E,D),[constraint(use(R://E)):naf(Use)|D]).

rule(use_conditional_group(negative,Use,R://E,_),[]) :-
  knowledgebase:query([iuse(Use,positive:_)],R://E),!.
  % preference:positive_use(Use),!.

rule(use_conditional_group(negative,_,_,D),D) :- !.

% Example: feature:unification:unify([constraint(use(os)):darwin],[constraint(use(os)):{[linux,darwin]}],Result).


% Exactly one of the dependencies in an exactly-one-of-group should be satisfied

rule(exactly_one_of_group(Deps),[D|NafDeps]) :-
  member(D,Deps),
  findall(naf(N),(member(N,Deps), not(D = N)),NafDeps).


% One dependency of an any_of_group should be satisfied

rule(any_of_group(Deps),[D]) :-
  member(D,Deps).


% All dependencies in an all_of_group should be satisfied

rule(all_of_group(Deps),Deps) :- !.


% ---------------
% Ruleset: Models
% ---------------

% The following can occur within a proof:

% Src_uri:

rule(uri(_,_,_),[]) :- !.
rule(uri(_),[]) :- !.

% Blocking use

rule(blocking(Use),[naf(Use)]) :- !.

% Required use

rule(required(Use),[Use]) :- !.


% ----------------------
% Rules needed by prover
% ----------------------

% Assumptions:

rule(assumed(_),[]) :- !.

% Negation as failure:

rule(naf(_),[]) :- !.

% Atoms

rule(Literal,[]) :-
  atom(Literal),!.
