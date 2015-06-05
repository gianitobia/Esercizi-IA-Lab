% esempio TWO + TWO = FOUR da Russell e Norvig


cifra(t).
cifra(w).
cifra(o).
cifra(f).
cifra(u).
cifra(r).

% riporti
rip(x1).
rip(x2).
rip(x3).

% esattamente un valore per ogni cifra e riporto
1{val(C,0..9)}1:- cifra(C).
1{val(X,0..1)}1:- rip(X).

% valori diversi per ogni cifra
:- val(C1,V), val(C2,V), cifra(C1), cifra(C2), C1!=C2.

% la prima cifra a sinistra di ogni numero non puo' essere 0
:- val(f,0).
:- val(t,0).


% calcolo della somma per le quattro colonne

:- val(o,Val_o), val(r,Val_r), val(x1,Val_x1), Val_o+Val_o != Val_r+10*Val_x1.
	
:- val(w,Val_w), val(u,Val_u), val(x1,Val_x1), val(x2,Val_x2), Val_x1+Val_w+Val_w != Val_u+10*Val_x2.
	
:- val(t,Val_t), val(o,Val_o), val(x2,Val_x2), val(x3,Val_x3), Val_x2+Val_t+Val_t != Val_o+10*Val_x3.

:- val(f,Val_f), val(x3,Val_x3), Val_x3 != Val_f.


#show val/2.


% con un vincolo unico ci mette molto piu' tempo
% :- val(t,Vt), val(w,Vw), val(f,Vf), val(o,Vo), val(u,Vu), val(r,Vr), 
%	((Vt*100+Vw*10+Vo)+(Vt*100+Vw*10+Vo)) != (Vf*1000+Vo*100+Vu*10+Vr).




%two +
%765
%two = 
%765
%four
%1530