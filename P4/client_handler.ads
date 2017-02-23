--Javier Fernández Morata
with Lower_Layer_UDP;
with chat_message;
with Ada.Strings.Unbounded;
with Ada.Text_IO;
with Ada.Command_Line;
with retransmission_times;
with Ada.Real_Time;
with hash_maps_g;
with protected_ops;

package client_handler is

	package LLU renames  Lower_Layer_UDP;
	package CM renames chat_message;	
	package ASU renames Ada.Strings.Unbounded;
	package ATI renames Ada.Text_IO;
	package ACL renames Ada.Command_Line;
	package RT renames retransmission_times;
	package ART renames Ada.Real_Time;
	package PO renames protected_ops;

	use type CM.Message_Type;
	use type ASU.Unbounded_String;
	use type RT.Seq_N_T;
	use type ART.Time;

	type Key is record 
		Client_EP_Handler: LLU.End_Point_Type;
		Server_EP: LLU.End_Point_Type;
		Seq_N: RT.Seq_N_T:= 0;
	end record;
	
	type Value is record
		Nick: ASU.Unbounded_String:= ASU.To_Unbounded_String(ACL.Argument(3));
		Texto: ASU.Unbounded_String;
	end record;

	Id: Key;
  Secuencia_Logout: RT.Seq_N_T:= 2;
	Secuencia_Servidor: RT.Seq_N_T:= 1;
	Mensaje: Value;
	Max_Delay: Integer:= Integer'Value(ACL.Argument(5));
	
	type Rango_Msgs is mod 50;

	function Igual_ID (K1: Key; K2: Key) return Boolean;
	
	function Image_PM (I: Key) return ASU.Unbounded_String;
		
	function Hash_Msgs (I: Key) return Rango_Msgs;

	package Pending_Msgs is new Hash_Maps_G (Key_Type => Key,
														  Value_Type => Value,
														  "=" => Igual_ID,
														  Image => Image_PM,
														  Max => 150,
														  Hash_Range => Rango_Msgs ,
														  Hash => Hash_Msgs);


	Lista_TiemposC: RT.Times_List;
	Mensajes_PendientesC: Pending_Msgs.Map;
	Traza1: Integer;

	procedure Add;

	procedure Retransmision;

	procedure Manejador  (From: in LLU.End_Point_Type;
											 To: in LLU.End_Point_Type;
											 P_Buffer: access LLU.Buffer_Type);

end client_handler;
