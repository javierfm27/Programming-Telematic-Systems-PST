--Javier Fernández Morata
package body client_handler is

	function Igual_ID (K1: Key; K2: Key) return Boolean is
	Id1: ASU.Unbounded_String;
	Id2: ASU.Unbounded_String; 
	begin
		Id1:= ASU.To_Unbounded_String(LLU.Image(K1.Client_EP_Handler)) & ASU.To_Unbounded_String(LLU.Image(K1.Server_EP)) & ASU.To_Unbounded_String(RT.Seq_N_T'Image(K1.Seq_N));
		Id2:=  ASU.To_Unbounded_String(LLU.Image(K2.Client_EP_Handler)) & ASU.To_Unbounded_String(LLU.Image(K2.Server_EP)) & ASU.To_Unbounded_String(RT.Seq_N_T'Image(K2.Seq_N));
		if Id1 = Id2 then
			return True;
		else
			return False;
		end if;
	end Igual_ID;

	function Hash_Msgs (I: Key) return Rango_Msgs is
	N: String:= LLU.Image(I.Client_EP_Handler) & LLU.Image(I.Server_EP) & RT.Seq_N_T'Image(I.Seq_N);
	Suma: Integer := 0;	
	begin
		for I in N'First..N'Last loop
			Suma := Suma + Character'Pos(N(I));
		end loop;
		return Rango_Msgs'Mod(Suma);
	end Hash_Msgs;


	function Image_PM (I: Key) return ASU.Unbounded_String is
	N: ASU.Unbounded_String;
	A: String:= LLU.Image(I.Client_EP_Handler);
	B: String:= LLU.Image(I.Server_EP);	
	C: String:= RT.Seq_N_T'Image(I.Seq_N);
	begin
	N:= ASU.To_Unbounded_String(A) & ("    ") & ASU.To_Unbounded_String(B) & ("    ") & ASU.To_Unbounded_String(C);
	return N;

	end Image_PM;



	procedure Add is
	Hora: ART.Time;
	begin
		--ATI.Put_Line("             ||AÑADIR||       ");
		--ATI.Put_Line("------------------------------");
		Traza1:= Traza1 + 1;
		Hora:= ART.Clock + ART.Milliseconds (2*(Max_Delay));
		Id.Seq_N:= RT.Seq_N_T(Traza1);
		Secuencia_Logout:= RT.Seq_N_T(Traza1);
		RT.Put(Lista_TiemposC,Hora,Id.Seq_N,Id.Server_EP);
		Pending_Msgs.Put(Mensajes_PendientesC,Id,Mensaje);
		--ATI.Put_Line("--------------------------------·");
	end Add;

	procedure Retransmision is
	Success: Boolean;
	Unico: Boolean;
	Hora: ART.Time;
	Hora_Actualizada: ART.Time;
	Seq_N: RT.Seq_N_T;
	End_Point: LLU.End_Point_Type;
	Mensaje_Actual: Value;
	Existe: Boolean; 
	Buffer: aliased LLU.Buffer_Type(1024); 
	begin
			Hora:= ART.Clock;	
			RT.Get(Lista_TiemposC,Hora,Seq_N,End_Point,Success,Unico);
			if Success = True then
				Id.Seq_N:= Seq_N;
				Pending_Msgs.Get(Mensajes_PendientesC,Id,Mensaje_Actual,Existe);
				if Existe = True then
					if Mensaje_Actual.Texto /= ".quit" then
						LLU.Reset(Buffer);
						CM.Message_Type'Output(Buffer'Access,CM.Writer);
						LLU.End_Point_Type'Output(Buffer'Access,Id.Client_EP_Handler);
						RT.Seq_N_T'Output(Buffer'Access,Id.Seq_N);
						ASU.Unbounded_String'Output(Buffer'Access,Mensaje_Actual.Nick);
						ASU.Unbounded_String'Output(Buffer'Access,Mensaje_Actual.Texto);
						LLU.Send(Id.Server_EP,Buffer'Access);
						LLU.Reset(Buffer);
						RT.Delete(Lista_TiemposC,Hora);
						Hora_Actualizada := Hora + ART.Milliseconds (2*(Max_Delay));
						RT.Put(Lista_TiemposC,Hora_Actualizada,Id.Seq_N,Id.Server_EP);
						PO.Program_Timer_Procedure(Retransmision'Access, ART.Clock );
					else
						LLU.Reset(Buffer);
						CM.Message_Type'Output(Buffer'Access,CM.Logout);
						LLU.End_Point_Type'Output(Buffer'Access,Id.Client_EP_Handler);
						RT.Seq_N_T'Output(Buffer'Access,Id.Seq_N);
						ASU.Unbounded_String'Output(Buffer'Access,Mensaje_Actual.Nick);
						LLU.Send(Id.Server_EP,Buffer'Access);
						LLU.Reset(Buffer);
						RT.Delete(Lista_TiemposC,Hora);
						Hora_Actualizada := Hora + ART.Milliseconds (2*(Max_Delay));
						RT.Put(Lista_TiemposC,Hora_Actualizada,Id.Seq_N,Id.Server_EP);
						PO.Program_Timer_Procedure(Retransmision'Access, ART.Clock );
					end if;		
				else
					RT.Delete(Lista_TiemposC,Hora);
				end if;	
				PO.Program_Timer_Procedure(Retransmision'Access, ART.Clock + ART.Milliseconds(2* Max_Delay));
			end if;
	end Retransmision;



	procedure Manejador (From: in LLU.End_Point_Type; To: in LLU.End_Point_Type; P_Buffer: access LLU.Buffer_Type) is
	Message: CM.Message_Type;
	Server_EP: LLU.End_Point_Type;
	Seq_N: RT.Seq_N_T;
	Nick: ASU.Unbounded_String;
	Texto: ASU.Unbounded_String;
	Identificador: Key;
	Borrado: Boolean;
	begin
		Message:= CM.Message_Type'Input(P_Buffer);
		if Message = CM.Server then
			Server_EP:= LLU.End_Point_Type'Input(P_Buffer);
			Seq_N:= RT.Seq_N_T'Input(P_Buffer);
			Nick:= ASU.Unbounded_String'Input(P_Buffer);
			Texto:= ASU.Unbounded_String'Input(P_Buffer);
			if Secuencia_servidor = Seq_N then 		
				if Nick = "server: " then
					ATI.Put_Line(ASU.To_String(Nick) & ASU.To_String(Texto));
				else
					ATI.Put_Line(ASU.To_String(Nick) & ": "  & ASU.To_String(Texto));
				end if;
				LLU.Reset(P_Buffer.all);
				CM.Message_Type'Output(P_Buffer,CM.Ack);
				LLU.End_Point_Type'Output(P_Buffer,Id.Client_EP_Handler);
				RT.Seq_N_T'Output(P_Buffer,Seq_N);
				LLU.Send(Server_EP,P_Buffer);
				LLU.Reset(P_Buffer.all);
				Secuencia_servidor:= Secuencia_servidor + 1;
			elsif Secuencia_servidor > Seq_N then
				LLU.Reset(P_Buffer.all);
				CM.Message_Type'Output(P_Buffer,CM.Ack);
				LLU.End_Point_Type'Output(P_Buffer,Id.Client_EP_Handler);
				RT.Seq_N_T'Output(P_Buffer,Seq_N);
				LLU.Send(Server_EP,P_Buffer);
				LLU.Reset(P_Buffer.all);
			end if;
		elsif Message = CM.Ack then
		--	ATI.Put_Line("         ||ACK||         ");
			--ATI.Put_Line("¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿");
			Identificador.Server_EP:= LLU.End_Point_Type'Input(P_Buffer);
			Identificador.Seq_N:= RT.Seq_N_T'Input(P_Buffer);
			--ATI.Put_Line(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
		--	ATI.Put_Line("VOY A BORRAR   " & RT.Seq_N_T'Image(Identificador.Seq_N));
			LLU.Reset(P_Buffer.all);
		--	ATI.Put_Line("<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<");
			Identificador.Client_EP_Handler:= Id.Client_EP_Handler;
			--Pending_Msgs.Print(Mensajes_PendientesC);
			Pending_Msgs.Delete(Mensajes_PendientesC,Identificador,Borrado);
			--Pending_Msgs.Print(Mensajes_PendientesC);
			--ATI.Put_Line("¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿");
		end if;
	end Manejador;





end client_handler;
