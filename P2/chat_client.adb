with Ada.Text_IO;
with Lower_Layer_UDP;
with Ada.Strings.Unbounded;
with Ada.Exceptions;
with Ada.Command_Line;
with chat_message;

procedure chat_client is
	
	package ATI renames Ada.Text_IO;
	package LLU renames Lower_Layer_UDP;
	package ASU renames Ada.Strings.Unbounded;
	package ACL renames Ada.Command_Line;
	package CM renames chat_message;
	
	use type ASU.Unbounded_String;
	
	Server: ASU.Unbounded_String;				--Nombre de la maquina donde esta el server
	Nick: ASU.Unbounded_String;
	Texto: ASU.Unbounded_String;
	Server_EP: LLU.End_Point_Type;
	Client_EP: LLU.End_Point_Type;
	Message: CM.Message_Type;
	Buffer: aliased LLU.Buffer_Type (1024);	
	Port: Integer;
	Expired: Boolean;
	
		
begin

	Server:= ASU.To_Unbounded_String(ACL.Argument(1));
	Port:= Integer'Value(ACL.Argument(2));
	NIck:= ASU.To_Unbounded_String(ACL.Argument(3));
	Server_EP:= LLU.Build(LLU.To_IP(ASU.To_String(Server)),Port);
	LLU.Bind_Any(Client_EP);
	LLU.Reset(Buffer);
	CM.Message_Type'Output(Buffer'Access,CM.Init);
	LLU.End_Point_Type'Output(Buffer'Access,Client_EP);
	ASU.Unbounded_String'Output(Buffer'Access,Nick);
	LLU.Send(Server_EP,Buffer'Access);
	LLU.Reset(Buffer);
	if Nick = "reader" then
		loop
			LLU.Receive(Client_EP,Buffer'Access,1000.0, Expired);
			Message:= CM.Message_Type'Input(Buffer'Access);
			Nick:= ASU.Unbounded_String'Input(Buffer'Access);
			Texto:= ASU.Unbounded_String'Input(Buffer'Access);
			ATI.Put_Line(ASU.To_String(Nick) & ": " & ASU.To_String(Texto));
		end loop;
	else
		loop
			ATI.Put("Message: ");
			Texto:= ASU.To_Unbounded_String(ATI.Get_Line);
			if Texto /= ".quit" then 
				CM.Message_Type'Output(Buffer'Access,CM.Writer);
				LLU.End_Point_Type'Output(Buffer'Access,Client_EP);
				ASU.Unbounded_String'Output(Buffer'Access,Texto);
				LLU.Send(Server_EP,Buffer'Access);
				LLU.Reset(Buffer);
			end if;
		exit when Texto = ".quit";
		end loop;
		LLU.Finalize;
	end if;
	


end chat_client;
