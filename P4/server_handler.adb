--Javier Fernández Morata
package body server_handler is

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


	function Image_Client (N: ASU.Unbounded_String) return ASU.Unbounded_String is	
	A: ASU.Unbounded_String;	
	begin
		A:= N ;
		return A;
	end Image_Client;
	

	function Activo_Hash (Nick: ASU.Unbounded_String) return Rango_Activos is
	N: String:= ASU.To_String(Nick);	
	Suma: Integer := 0;	
	begin
		for I in N'First..N'Last loop
			Suma := Suma + Character'Pos(N(I));
		end loop;
		return Rango_Activos'Mod(Suma);
	end Activo_Hash;

	procedure Retransmision is
	H: ART.Time;
	Seq_N: RT.Seq_N_T;
	End_Point: LLU.End_Point_Type;
	Success: Boolean;
	Mensaje_Actual: Value;
	Existe: Boolean; 
	Unico: Boolean;
	Buffer: aliased LLU.Buffer_Type(1024); 
	begin
		H:= ART.Clock;
		RT.Get(Lista_TiemposS,H,Seq_N,End_Point,Success,Unico);
		if Success = True then
			Id.Seq_N:= Seq_N;
			Id.Client_EP_Handler:= End_Point;
			Pending_Msgs.Get(Mensajes_PendientesS,Id,Mensaje_Actual,Existe);
			if Existe = True then
				RT.Delete(Lista_TiemposS,H);
				LLU.Reset(Buffer);
				CM.Message_Type'Output(Buffer'Access,CM.Server);
				LLU.End_Point_Type'Output(Buffer'Access,Id.Server_EP);
				RT.Seq_N_T'Output(Buffer'Access,Id.Seq_N);
				ASU.Unbounded_String'Output(Buffer'Access,Mensaje_Actual.Nick);
				ASU.Unbounded_String'Output(Buffer'Access,Mensaje_Actual.Texto);
				LLU.Send(End_Point,Buffer'Access);
				LLU.Reset(Buffer);
				RT.Put(Lista_TiemposS,ART.Clock + ART.Milliseconds(2* Max_Delay),Id.Seq_N,Id.Client_EP_Handler);
				PO.Program_Timer_Procedure(Retransmision'Access, ART.Clock );
			else
  					RT.Delete(Lista_TiemposS,H);
			end if;	
			PO.Program_Timer_Procedure(Retransmision'Access, ART.Clock + ART.Milliseconds(2* Max_Delay));
		end if;
	end Retransmision;

	procedure Add is
	Hora: ART.Time;
	begin
		Hora:= ART.Clock + ART.Milliseconds(2* Max_Delay) ;
		RT.Put(Lista_TiemposS,Hora,Id.Seq_N,Id.Client_EP_Handler);
		Pending_Msgs.Put(Mensajes_PendientesS,Id,Mensaje);
	end Add;


	procedure Enviar_Clientes (M: in Clientes_Activos.Map;Nick: in ASU.Unbounded_String; P_Buffer: access LLU.Buffer_Type) is
	Iterador: Clientes_Activos.Cursor:= Clientes_Activos.First(M);	
	Actual: Clientes_Activos.Element_Type;
	Lleno: Boolean;
	Hora: ART.Time;
	Unico: Boolean;
	Success: Boolean;
	I: RT.Seq_N_T;
	EP: LLU.End_Point_Type;
	begin
		loop
			Lleno:= Clientes_Activos.Has_Element(Iterador);
			if Lleno = True then
				Actual:= Clientes_Activos.Element(Iterador);
				if Actual.Key /= Nick then
					Id.Seq_N:= Actual.Value.Seq_S;
					Id.Client_EP_Handler:= Actual.Value.EP;
					PO.Protected_Call(Add'Access);
					CM.Message_Type'Output(P_Buffer,CM.Server);
					LLU.End_Point_Type'Output(P_Buffer,Id.Server_EP);
					RT.Seq_N_T'Output(P_Buffer,Id.Seq_N);
					ASU.Unbounded_String'Output(P_Buffer,Mensaje.Nick);
					ASU.Unbounded_String'Output(P_Buffer,Mensaje.Texto);
					LLU.Send(Actual.Value.EP,P_Buffer);	
					LLU.Reset(P_Buffer.all);
					Actual.Value.Seq_S:= Actual.Value.Seq_S + 1;
					Clientes_Activos.Put(Clientes,Actual.Key,Actual.Value);
					Hora:= ART.Clock;
					RT.Get(Lista_TiemposS,Hora,I,EP,Success,Unico);
					if Unico = True then
						PO.Program_Timer_Procedure(Retransmision'Access, ART.Clock + ART.Milliseconds(2* Max_Delay));
					end if;
				end if;
			end if;
			Clientes_Activos.Next(Iterador);
		exit when Lleno = False;
		end loop;
		LLU.Reset(P_Buffer.all);
	end Enviar_Clientes; 



	procedure Manejador (From: in LLU.End_Point_Type; To: in LLU.End_Point_Type; P_Buffer: access LLU.Buffer_Type) is
	Message: CM.Message_Type;
	Client_EP_Receive: LLU.End_Point_Type;
	Client_EP_Handler: LLU.End_Point_Type;
	Nick: ASU.Unbounded_String;
	Texto: ASU.Unbounded_String;
	Nick_Server: ASU.Unbounded_String:= ASU.To_Unbounded_String("server: ");
	Actual: Activo;
	Success: Boolean;
	Seq_N: RT.Seq_N_T;
	Borrado: Boolean;
	Vacio: Boolean;

	begin
		Message:= CM.Message_Type'Input(P_Buffer);
		
		if Message = CM.Init then
			Client_EP_Receive:= LLU.End_Point_Type'Input(P_Buffer);
			Client_EP_Handler:= LLU.End_Point_Type'Input(P_Buffer);
			Nick:= ASU.Unbounded_String'Input(P_Buffer);
			LLU.Reset(P_Buffer.all);
			Clientes_Activos.Get(Clientes,Nick,Actual,Success);
			if	Success = True and Client_EP_Handler = Actual.EP then
				CM.Message_Type'Output(P_Buffer,CM.Welcome);
				Boolean'Output(P_Buffer,True);
				LLU.Send(Client_EP_Receive,P_Buffer);
				LLU.Reset(P_Buffer.all);
			elsif Success = True and Client_EP_Handler /= Actual.EP then
				CM.Message_Type'Output(P_Buffer,CM.Welcome);
				Boolean'Output(P_Buffer,False);
				LLU.Send(Client_EP_Receive,P_Buffer);
				LLU.Reset(P_Buffer.all);
			else
				CM.Message_Type'Output(P_Buffer,CM.Welcome);
				Boolean'Output(P_Buffer,True);
				LLU.Send(Client_EP_Receive,P_Buffer);
				LLU.Reset(P_Buffer.all);
				ATI.Put_Line("INIT received from " & ASU.To_String(Nick) & ": ACCEPTED");
				Actual.EP:= Client_EP_Handler;
				Actual.Hora:= AC.Clock;
				Actual.Seq_N:= 1;
				Actual.Seq_S:= 1;
				Clientes_Activos.Put(Clientes,Nick,Actual);
				Mensaje.Nick:= Nick_Server;
				Mensaje.Texto:= Nick & ASU.To_Unbounded_String(" joins the chat") ;	 
				Enviar_Clientes(Clientes,Nick,P_Buffer);
			end if;
		elsif Message = CM.Writer then
			Client_EP_Handler:= LLU.End_Point_Type'Input(P_Buffer);
			Seq_N:= RT.Seq_N_T'Input(P_Buffer);
			Nick:= ASU.Unbounded_String'Input(P_Buffer);
			Texto:= ASU.Unbounded_String'Input(P_Buffer);
			Clientes_Activos.Get(Clientes,Nick,Actual,Success);
			if	Client_EP_Handler = Actual.EP then
				if Seq_N = Actual.Seq_N then
					Actual.Seq_N:= Actual.Seq_N + 1;
					Actual.EP:= Client_EP_Handler;
					Actual.Hora:= AC.Clock;
					Clientes_Activos.Put(Clientes,Nick,Actual);
					LLU.Reset(P_Buffer.all);
					CM.Message_Type'Output(P_Buffer,CM.Ack);
					LLU.End_Point_Type'Output(P_Buffer,Id.Server_EP);
					RT.Seq_N_T'Output(P_Buffer,Seq_N);
					LLU.Send(Actual.EP,P_Buffer);
					LLU.Reset(P_Buffer.all);
					ATI.Put_Line("WRITER received from " & ASU.To_String(Nick)& ": " & ASU.To_String(Texto));	
					Mensaje.Nick:= Nick;
					Mensaje.Texto:= Texto;
					Enviar_Clientes(Clientes,Nick,P_Buffer);
				elsif Seq_N < Actual.Seq_N then	
					LLU.Reset(P_Buffer.all);
					CM.Message_Type'Output(P_Buffer,CM.Ack);
					LLU.End_Point_Type'Output(P_Buffer,Id.Server_EP);
					RT.Seq_N_T'Output(P_Buffer,Seq_N);	
					LLU.Send(Actual.EP,P_Buffer);
					LLU.Reset(P_Buffer.all);
				end if;
			else
				ATI.Put_Line("WRITER received from unknown client. IGNORED");
			end if;
		elsif Message = CM.Logout then
			Client_EP_Handler:= LLU.End_Point_Type'Input(P_Buffer);
			Seq_N:= RT.Seq_N_T'Input(P_Buffer);
			Nick:= ASU.Unbounded_String'Input(P_Buffer);
			LLU.Reset(P_Buffer.all);
			Clientes_Activos.Get(Clientes,Nick,Actual,Success);
			if Client_EP_Handler = Actual.EP then
				if Seq_N = Actual.Seq_N then
					Actual.Seq_N:= Actual.Seq_N + 1;
					Actual.EP:= Client_EP_Handler;
					Actual.Hora:= AC.Clock;
					Clientes_Activos.Put(Clientes,Nick,Actual);
					LLU.Reset(P_Buffer.all);
					CM.Message_Type'Output(P_Buffer,CM.Ack);
					LLU.End_Point_Type'Output(P_Buffer,Id.Server_EP);
					RT.Seq_N_T'Output(P_Buffer,Seq_N);
					LLU.Send(Actual.EP,P_Buffer);
					ATI.Put_Line("LOGOUT received from " & ASU.To_String(Nick)); 
					Clientes_Activos.Delete(Clientes,Nick,Borrado);
					Mensaje.Nick:= Nick_Server;
					Mensaje.Texto:= Nick & ASU.To_Unbounded_String(" leaves the chat") ;
					Vacio:= Clientes_Activos.Map_Empty(Clientes);
					if Vacio = False then
						Enviar_Clientes(Clientes,Nick,P_Buffer);
					end if;
				elsif Seq_N < Actual.Seq_N then
					CM.Message_Type'Output(P_Buffer,CM.Ack);
					LLU.End_Point_Type'Output(P_Buffer,Id.Server_EP);
					RT.Seq_N_T'Output(P_Buffer,Seq_N);
					LLU.Send(Actual.EP,P_Buffer);
				end if;
			else
				ATI.Put_Line("LOGOUT received from uknow client. IGNORED");
			end if;
		elsif Message = CM.Ack then
			Pending_Msgs.Print(Mensajes_PendientesS);
			Id.Client_EP_Handler:= LLU.End_Point_Type'Input(P_Buffer);
			Id.Seq_N:= RT.Seq_N_T'Input(P_Buffer);
			LLU.Reset(P_Buffer.all);
			Pending_Msgs.Delete(Mensajes_PendientesS,Id,Success);
		end if;
	end Manejador;


end server_handler;
