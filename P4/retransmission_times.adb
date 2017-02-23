--Javier Fernández Morata

package body Retransmission_Times  is

	procedure Put (TL : in out Times_List; H: in ARL.Time; I: Seq_N_T; EP: LLU.End_Point_Type) is 
	P_Aux: Cell_A;	
	P_Aux2: Cell_A;
	Introducir: Boolean:= False;
	Meter: Boolean;
	begin 
	P_Aux:= TL.P_First;
	if TL.P_First = null then
		TL.P_First:= new Cell'(H,EP,I,null);
		TL.Length:= TL.Length + 1;
	else
		P_Aux:= TL.P_First;
		loop
			if H > P_Aux.Hora then
				if P_Aux.Next = null then
					P_Aux2:= new Cell'(H,EP,I,null);
					P_Aux.Next:= P_Aux2;
					Introducir:= True;
				end if;
				P_Aux:= P_Aux.Next;
			else
				Meter:= True;
			end if;
		exit when Introducir = True or P_Aux = null;
		end loop;
		if Meter = True then
			P_Aux2:= new Cell'(H,EP,I,TL.P_First);
		end if;
	end if;
	end Put;
	

	procedure Get (TL: Times_List; H: in ARL.Time; I: out Seq_N_T; EP: out LLU.End_Point_Type ;Success: out Boolean; Unico: out Boolean)  is
	P_Aux: Cell_A;
	begin
	P_Aux:= TL.P_First;
	Unico:= False;
	Success:= False;
	if P_Aux = null then
		Success:= False;
	elsif P_Aux.Next = null then
		Unico:= True;
		if H > TL.P_First.Hora then
			Success:= True;
			I:= TL.P_First.Seq_N;
			EP:= TL.P_First.End_Point;
		end if;
	else
		if H > TL.P_First.Hora then
			Success:= True;
			I:= TL.P_First.Seq_N;
			EP:= TL.P_First.End_Point;
		end if;
	end if;
	end Get;



	procedure Delete (TL: in out Times_List; H: ARL.Time) is
	P_Aux: Cell_A;
	I : Integer:= 0;
	procedure Free is new Ada.Unchecked_Deallocation (Cell, Cell_A );
	
	begin
	P_Aux:= TL.P_First;
	if H > P_Aux.Hora then
		TL.P_First:= P_Aux.Next;
		if I < 1 then		
			Free(P_Aux); 
			I:= I + 1;
		end if;
	end if;
	end Delete;

	procedure Imprimir (TL: in Times_List) is
	P_Aux: Cell_A;
	begin
	P_Aux:= TL.P_First;
	if P_Aux = null then
		ATI.Put_Line("The list is empty");
	else
		loop
			ATI.Put_Line(Seq_N_T'Image(P_Aux.Seq_N) & "--" & LLU.Image(P_Aux.End_Point));
			P_Aux:= P_Aux.Next;
		exit when P_Aux = null;
		end loop;
	end if;
	end Imprimir;
	
	procedure Last_Seq (TL: in Times_List; I: out Seq_N_T; Success: out Boolean) is
	P_Aux: Cell_A;
	begin
		P_Aux:= TL.P_First;
		if P_Aux = null then
			Success:= False;
		elsif P_Aux.Next = null then
			I:= P_Aux.Seq_N;
			Success:= True;
		else
			loop
				P_Aux:= P_Aux.Next;
			exit when P_Aux.Next = null;
			end loop;
			I:= P_Aux.Seq_N;
			Success:= True;
		end if;
	end Last_Seq;

end retransmission_times;
