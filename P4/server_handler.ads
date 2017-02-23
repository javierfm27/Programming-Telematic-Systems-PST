--Javier Fernández Morata
with Ada.Text_IO;
with Ada.Command_Line;
with Ada.Strings.Unbounded;
with Lower_Layer_UDP;
with chat_message;
with hash_maps_g;
with Ada.Calendar;
with retransmission_times;
with protected_ops;
with Ada.Real_Time;

package server_handler is
	
	package ATI renames Ada.Text_IO;
	package ACL renames Ada.Command_Line;
	package ASU renames Ada.Strings.Unbounded;		
	package LLU renames Lower_Layer_UDP;
	package CM renames chat_message;
	package AC renames Ada.Calendar;
	package RT renames retransmission_times;
	package PO renames protected_ops;
	package ART renames Ada.Real_Time;

	use type LLU.End_Point_Type;
	use type CM.Message_Type;
	use type ASU.Unbounded_String;
	use type ART.Time;
	use type AC.Time;
	use type RT.Seq_N_T;

	type Activo is record
		EP: LLU.End_Point_Type;
		Hora: AC.Time;	
		Seq_N: RT.Seq_N_T:= 0;
		Seq_S: RT.Seq_N_T:= 0; --Numeor de secuencia correspondiente a un cliente de su mensaje server
	end record;
	
	type Key is record 
		Client_EP_Handler: LLU.End_Point_Type;
		Server_EP: LLU.End_Point_Type;
		Seq_N: RT.Seq_N_T:= 0;
	end record;
	
	type Value is record
		Nick: ASU.Unbounded_String;
		Texto: ASU.Unbounded_String;
	end record;

	type Rango_Activos is mod 50;
	type Rango_Msgs is mod 150;

	function Igual_ID (K1: Key; K2: Key) return Boolean;	
		
	function Hash_Msgs (I: Key) return Rango_Msgs;
		
	function Image_PM (I: Key) return ASU.Unbounded_String;
		
	function Image_Client (N: ASU.Unbounded_String) return ASU.Unbounded_String;	

	function Activo_Hash (Nick: ASU.Unbounded_String) return Rango_Activos;
	
	Max_Clientes: Natural:= Natural'Value(ACL.Argument(2));
	Id: Key;
	Mensaje: Value;
	Max_Delay: Integer:= Integer'Value(ACL.Argument(4));

	package Clientes_Activos is new Hash_Maps_G (Key_Type => ASU.Unbounded_String,
																Value_Type => Activo,
																"=" => ASU."=",
																Image => Image_Client,
																Max => Max_Clientes,
																Hash_Range  => Rango_Activos,
																Hash => Activo_Hash);
	

	package Pending_Msgs is new Hash_Maps_G (Key_Type => Key,
														  Value_Type => Value,
														  "=" => Igual_ID,
														  Image => Image_PM,
														  Max => 150,
														  Hash_Range => Rango_Msgs ,
														  Hash => Hash_Msgs);


	Lista_TiemposS: RT.Times_List;
	Mensajes_PendientesS: Pending_Msgs.Map;
	Clientes: Clientes_Activos.Map;

	procedure Retransmision;

	procedure Add;

	procedure Enviar_Clientes(M: in Clientes_Activos.Map;
									  Nick: in ASU.Unbounded_String;
									  P_Buffer: access LLU.Buffer_Type);

	procedure Manejador (From: in LLU.End_Point_Type;
								To: in LLU.End_Point_Type;
								P_Buffer: access LLU.Buffer_Type);





end server_handler;
