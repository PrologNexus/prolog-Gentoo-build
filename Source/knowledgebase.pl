/*
  Author:   Pieter Van den Abeele
  E-mail:   pvdabeel@mac.com
  Copyright (c) 2005-2019, Pieter Van den Abeele

  Distributed under the terms of the LICENSE file in the root directory of this
  project.
*/


/** <module> KNOWLEDGE BASE
The Knowledge Base is a concept that enables different repositories to register,
serialize their rules and facts to disk. This is used as a mechanism to maintain
state across application relaunches.
*/

:- module(knowledgebase,[]).

% **************************
% KNOWLEDGEBASE declarations
% **************************

:- class.

% public interface

:- dpublic('knowledgebase'/0).
:- dpublic('~knowledgebase'/0).

:- dpublic(register/1).
:- dpublic(sync/0).
:- dpublic(save/0).
:- dpublic(load/0).
:- dpublic(compile/0).
:- dpublic(clear/0).

:- dpublic(query/2).
:- dpublic(entry/1).

% protected interface

:- dprotected(repository/1).
:- dprotected(state/1).

% static interface

:- dstatic(query/2).


%! Constructor
%
% Public predicate

'knowledgebase' ::-
  true.


%! Destructor
%
% Public predicate

'~knowledgebase' ::-
  true.


%! knowledgebase:register(+Repository)
%
% Public predicate
%
% Register a repository with the knowledge base

register(Repository) ::-
  <+repository(Repository),!.


%! knowledgebase:deregister(+Repository)
%
% Public predicate
%
% Deregister a repository with the knowledge base

deregister(Repository) ::-
  <-repository(Repository),!.


%! knowledgebase:sync
%
% Public predicate
%
% Sync all registered repositories

sync ::-
  forall(::repository(Repository),
	 Repository:sync).


%! knowledgebase:save
%
% Public predicate
%
% Save state to file

save ::-
  tell('kb.raw'),
  writeln(':- module(cache,[]).'),
  prolog_listing:listing(cache:_),
  told,
  qcompile('kb.raw'),!.


%! knowledgebase:compile
%
% Public predicate
%
% Save state to stand-alone program

compile ::-
  qsave_program('portage-ng',[stand_alone(true),goal(prolog)]).


% knowledgebase:load
%
% Public predicate
%
% Load state from file

load ::-
  exists_file('kb.qlf'),!,
  ensure_loaded('kb.qlf').

load ::-
  true.


% knowledgebase:clear
%
% Public predicate
%
% Clear state file

clear ::-
  exists_file('kb.qlf'),!,
  delete_file('kb.qlf').

clear ::-
  true.


% knowledgebase:query(+Query,-Result)
%
% Public predicate
%
% Retrieves metadata cache which satisfies a given query

query(Query,Result) ::-
  knowledgebase:query(Query,Result).


% knowledgebase:state(+File)
%
% Protected predicate
%
% State file

state(File) ::-
  :this(Context),
  atomic_list_concat([Context,'.raw'],File).


% knowledgebase:entry(?Repository://?Entry)
%
% Protected predicate
%
% Knowledgebase entries

entry(Repository://Entry) ::-
  cache:entry(Repository,Entry,_,_,_,_).


% knowledgebase:repository(?Repository)
%
% Protected predicate
%
% Registered repositories

repository(_Repository) ::-
  true.


%! knowledgebase:query(+Query,-Result)
%
% Public class predicate
%
% Retrieves metadata cache which satisfies a given query

query([],Repository://Id) :-
  !,
  cache:entry(Repository,Id,_,_,_,_).

query([not(Statement)|Rest],Repository://Id) :-
  !,
  not(query([Statement],Repository://Id)),
  query(Rest,Repository://Id).

query([all(Statement)|Rest],Repository://Id) :-
  !,
  Statement =.. [Key,Values],
  findall(Value,cache:entry_metadata(Repository,Id,Key,Value),Values),
  query(Rest,Repository://Id).

query([repository(Repository)|Rest],Repository://Id) :-
  !,
  cache:entry(Repository,Id,_,_,_,_),
  query(Rest,Repository://Id).

query([name(Name)|Rest],Repository://Id) :-
  !,
  cache:entry(Repository,Id,_,_,Name,_),
  query(Rest,Repository://Id).

query([category(Category)|Rest],Repository://Id) :-
  !,
  cache:entry(Repository,Id,_,Category,_,_),
  query(Rest,Repository://Id).

query([version(Version)|Rest],Repository://Id) :-
  !,
  cache:entry(Repository,Id,_,_,_,Version),
  query(Rest,Repository://Id).

query([manifest(Type,Binary,Size)|Rest],Repository://Id) :-
  cache:entry(Repository,Id,_,Category,Name,_),
  cache:entry_metadata(Repository,Id,src_uri,uri(Binary)),
  cache:manifest(Repository,_,Category,Name,Manifest),
  member(manifest(Type,Binary,Size,_),Manifest),
  query(Rest,Repository://Id).

query([manifest(Type,Binary,Size)|Rest],Repository://Id) :-
  cache:entry(Repository,Id,_,Category,Name,_),
  cache:entry_metadata(Repository,Id,src_uri,uri(_,_,Binary)),
  cache:manifest(Repository,_,Category,Name,Manifest),
  member(manifest(Type,Binary,Size,_),Manifest),
  query(Rest,Repository://Id).

query([manifest(Type,Binary,Size)|Rest],Repository://Id) :-
  !,
  cache:entry(Repository,Id,_,Category,Name,_),
  cache:entry_metadata(Repository,Id,src_uri,uri(_,Path,"")),
  cache:manifest(Repository,_,Category,Name,Manifest),
  member(manifest(Type,Binary,Size,_),Manifest),
  file_base_name(Path,Binary),
  query(Rest,Repository://Id).

query([Statement|Rest],Repository://Id) :-
  !,
  Statement =.. [Key,Arg],
  cache:entry_metadata(Repository,Id,Key,Arg),
  query(Rest,Repository://Id).
