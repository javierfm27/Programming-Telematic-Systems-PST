--Javier Fernández Morata
with Ada.Text_IO;
with Ada.Command_Line;
with Ada.Strings.Unbounded;
with Lower_Layer_UDP;
with client_handler;
with chat_message;
with Ada.Real_Time;
with retransmission_times;
with protected_ops;

procedure chat_client_3 is

	package ATI renames Ada.Text_IO;
	package ACL renames Ada.Command_Line;
	package ASU renames Ada.Strings.Unbounded;		
	package LLU renames Lower_Layer_UDP;
	package CH renames client_handler;
	package CM renames chat_message;
	package ART renames Ada.Real_Time;
	package RT renames retransmission_times;
	package PO renames protected_ops;
	
	use type LLU.End_Point_Type;
	use type CM.Message_Type;
	use type ASU.Unbounded_String;
	use type ART.Time;
	use type RT.Seq_N_T;

	Server: ASU.Unbounded_String:= ASU.To_Unbounded_String(ACL.Argument(1));
	Port: Integer:= Integer'Value(ACL.Argument(2));
	Min_Delay: Integer:= Integer'Value(ACL.Argument(4));
	Max_Delay: Integer:= Integer'Value(ACL.Argument(5));
	Fault_Pct: Integer:= Integer'Value(ACL.Argument(6));
	I: Integer;
	Max_RTT: Integer;
	Plazo_RTT: Duration;
	Client_EP_Receive: LLU.End_Point_Type;
	Buffer: aliased LLU.Buffer_Type(1024); 
	Reenvio: Boolean;
	Expired: Boolean;
	Acogido: Boolean;
	Unico : Boolean;
	Hora : ART.Time;
	Success: Boolean:= True;
	Message: CM.Message_Type;
	Mensaje_Actual: CH.Value;
	Z: RT.Seq_N_T;
	EP: LLU.End_Point_Type;
	

begin
	CH.Id.Server_EP:= LLU.Build(LLU.To_IP(ASU.To_String(Server)),Port);
	LLU.Bind_Any(Client_EP_Receive);
	LLU.Bind_Any(CH.Id.Client_EP_Handler,CH.Manejador'Access);
	ATI.Put_Line(LLU.Image(CH.Id.Client_EP_Handler));
	LLU.Set_Faults_Percent (Fault_Pct);
	Max_RTT:= 10 + (Fault_Pct/10)**2;	
	LLU.Set_Random_Propagation_Delay (Min_Delay, CH.Max_Delay);
	Plazo_RTT:= 2* Duration(Max_Delay)/1000;
	LLU.Reset(Buffer);
	CM.Message_Type'Output(Buffer'access,CM.Init);
	LLU.End_Point_Type'Output(Buffer'Access,Client_EP_Receive);
	LLU.End_Point_Type'Output(Buffer'Access,CH.Id.Client_EP_Handler);
	ASU.Unbounded_String'Output(Buffer'Access,CH.Mensaje.Nick);
	LLU.Send(CH.Id.Server_EP,Buffer'Access);
	LLU.Reset(Buffer);
	LLU.Receive(Client_EP_Receive,Buffer'Access,2.0,Reenvio);		--Hay que poner Plazo_RTT recuerdalo
	
	if Reenvio = True then
		I:= 1;
		loop
			LLU.Reset(Buffer);
			CM.Message_Type'Output(Buffer'Access,CM.Init);
			LLU.End_Point_Type'Output(Buffer'Access,Client_EP_Receive);
			LLU.End_Point_Type'Output(Buffer'Access,CH.Id.Client_EP_Handler);
			ASU.Unbounded_String'Output(Buffer'Access,CH.Mensaje.Nick);
			LLU.Send(CH.Id.Server_EP,Buffer'Access);
			LLU.Reset(Buffer);
			LLU.Receive(Client_EP_Receive,Buffer'Access,2.0,Reenvio); --Hay que poner Plazo_RTT recuerdalo
			I:= I + 1;
			Expired:= Reenvio;
		exit when Reenvio = False or I = Max_RTT;
		end loop;
	else
		Expired:= False;
	end if;

	if Expired = True then
		ATI.Put_Line("Server Unreachable");
	else
		Message:= CM.Message_Type'Input(Buffer'Access);
		Acogido:= Boolean'Input(Buffer'Access);
		if Acogido = False then
			ATI.Put_Line("Mini-Chat v2.0: IGNORED new user " & ASU.To_String(CH.Mensaje.Nick) & ", Nick already used");
		else
			ATI.Put_Line("Mini-Chat v2.0: Welcome " & ASU.To_String(CH.Mensaje.Nick));	
		end if;
		loop
			--ATI.Put_Line("         ||WRITER||      ");
			--ATI.Put_Line("-------------------------");
			CH.Mensaje.Texto:= ASU.To_Unbounded_String(ATI.Get_Line);
			if CH.Mensaje.Texto /= ".quit" then		
					LLU.Reset(Buffer);
					PO.Protected_Call(CH.Add'Access);
					CM.Message_Type'Output(Buffer'Access,CM.Writer);
					LLU.End_Point_Type'Output(Buffer'Access,CH.Id.Client_EP_Handler);
					RT.Seq_N_T'Output(Buffer'Access,CH.Id.Seq_N);
					ASU.Unbounded_String'Output(Buffer'Access,CH.Mensaje.Nick);
					ASU.Unbounded_String'Output(Buffer'Access,CH.Mensaje.Texto);
					LLU.Send(CH.Id.Server_EP,Buffer'Access);
					LLU.Reset(Buffer);
					Hora:= ART.Clock;
					RT.Get(CH.Lista_TiemposC,Hora,Z,EP,Success,Unico);
					if Unico = True then
						PO.Program_Timer_Procedure(CH.Retransmision'Access, ART.Clock + ART.Milliseconds(2* Max_Delay));
					end if;
			end if;
			--ATI.Put_Line("-------------------------------");
		exit when CH.Mensaje.Texto = ".quit";
		end loop;
	end if;
		PO.Protected_Call(CH.Add'Access);
		LLU.Reset(Buffer);
		CM.Message_Type'Output(Buffer'Access,CM.Logout);
		LLU.End_Point_Type'Output(Buffer'Access,CH.Id.Client_EP_Handler);
		RT.Seq_N_T'Output(Buffer'Access,CH.Id.Seq_N);
		ASU.Unbounded_String'Output(Buffer'Access,CH.Mensaje.Nick);
		LLU.Send(CH.Id.Server_EP,Buffer'Access);
		LLU.Reset(Buffer);
		Hora:= ART.Clock;
		RT.Get(CH.Lista_TiemposC,Hora,Z,EP,Success,Unico);
		if Unico = True then
			PO.Program_Timer_Procedure(CH.Retransmision'Access, ART.Clock + ART.Milliseconds(2* Max_Delay));
		end if;		
		loop
			if CH.Secuencia_Logout = CH.Id.Seq_N then
				delay Plazo_RTT;
				CH.Pending_Msgs.Get(CH.Mensajes_PendientesC,CH.Id,Mensaje_Actual,Success);
			else
				delay Plazo_RTT;
			end if;
		exit when Success = False;
		end loop;

		if Success = False then
			LLU.Finalize;
		end if;


end chat_client_3;
