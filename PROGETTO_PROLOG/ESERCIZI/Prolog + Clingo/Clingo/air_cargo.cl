#const lastlev=5.

level(0..lastlev).
state(0..lastlev+1).

%AZIONI
action(load(C,P)) :- cargo(C), plane(P).
action(unload(C,P)) :- cargo(C), plane(P).
action(fly(P,X,Y)) :- plane(P), airport(X), airport(Y), Y!=X.
1{ occurs(A,S) : action(A) }1 :- level(S). %UNA AZIONE IN OGNI STATO

%EFFETTI
holds(in(C,P),S+1) :- occurs(load(C,P),S), state(S).
-holds(at(C,X),S+1) :- occurs(load(C,P),S), state(S), holds(at(C,X),S).
-holds(in(C,P),S+1) :- occurs(unload(C,P),S), state(S).
holds(at(C,X),S+1) :- occurs(unload(C,P),S), state(S), holds(at(P,X),S).
holds(at(P,Y),S+1) :- occurs(fly(P,X,Y),S), state(S).
-holds(at(P,X),S+1) :- occurs(fly(P,X,Y),S), state(S).

%PRECONDIZIONI
:- occurs(load(C,P),S), not holds(at(C,X),S), holds(at(P,X),S).
:- occurs(load(C,P),S), holds(at(C,X),S), not holds(at(P,X),S).
:- occurs(load(C,P),S), holds(in(C1,P),S), C1!=C.
:- occurs(unload(C,P),S), not holds(in(C,P),S).
:- occurs(fly(P,X,Y),S), not holds(at(P,X),S).

%PERSISTENZA
holds(at(P,X),S+1) :- holds(at(P,X),S), not -holds(at(P,X),S+1), state(S).
-holds(at(P,X),S+1) :- -holds(at(P,X),S), not holds(at(P,X),S+1), state(S).
holds(in(C,P),S+1) :- holds(in(C,P),S), not -holds(in(C,P),S+1), state(S).
-holds(in(C,P),S+1) :- -holds(in(C,P),S), not holds(in(C,P),S+1), state(S).

%GOAL
:- not goal.


%ESERCIZIO
plane(1..10).
airport(torino;roma;catania;milano;palermo;bologna;firenze).
cargo(c0;c1;c2;c3;c4).

holds(at(c0,torino),0).
holds(at(c2,roma),0).
holds(at(c1,torino),0).
%holds(at(c3,torino),0).
%holds(at(c4,roma),0).
%holds(at(c5,catania),0).
holds(at(1,torino),0).
holds(at(2,catania),0).
holds(at(3,catania),0).
holds(at(4,roma),0).
holds(at(5,roma),0).
holds(at(6,roma),0).
holds(at(7,catania),0).
holds(at(8,catania),0).
holds(at(9,roma),0).
holds(at(10,torino),0).

goal :-
holds(at(c0,catania),lastlev+1),
holds(at(c1,roma),lastlev+1).
%holds(at(c2,catania),lastlev+1),
%holds(at(c3,catania),lastlev+1).
%holds(at(c4,roma),lastlev+1).

#show occurs/2.
%#show holds/2.