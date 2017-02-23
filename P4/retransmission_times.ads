--Javier Fernández Morata
with Ada.Text_IO;
with Ada.Strings.Unbounded;
with Ada.Real_Time;
with Ada.Unchecked_Deallocation;
with Ada.Calendar;
with Lower_Layer_UDP;

package Retransmission_Times is

	package ATI renames Ada.Text_IO;
	package ASU renames Ada.Strings.Unbounded;
	package ARL renames Ada.Real_Time;
	package AC renames Ada.Calendar;
	package LLU renames Lower_Layer_UDP;	
	
	use type ARL.Time;
	use type AC.Time;

	type Times_List is limited private;
		
	type Seq_N_T is mod Integer'Last;
	
	No_Element: exception;

	procedure Put (TL: in out Times_List; H: in ARL.Time; I: Seq_N_T; EP: LLU.End_Point_Type);

	procedure Get (TL: Times_List;H: in ARL.Time; I: out Seq_N_T;EP:  out LLU.End_Point_Type ;Success: out Boolean; Unico: out Boolean);

	procedure Delete (TL: in out Times_List; H: ARL.Time);
	
	procedure Imprimir (TL: in Times_List);

	procedure Last_Seq (TL: in Times_List; I: out Seq_N_T; Success: out Boolean);


private

	type Cell;
	type Cell_A is access Cell;
	type Cell is record
		Hora: ARL.Time;
		End_Point: LLU.End_Point_Type;
		Seq_N: Seq_N_T:= 0;
		Next: Cell_A;
	end record;

	type Times_List is record
		P_First: Cell_A;
		Length: Natural:= 0;
	end record;

end Retransmission_Times;
