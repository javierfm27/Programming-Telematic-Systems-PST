with Ada.Text_IO;
with Lower_Layer_UDP;
with Ada.Strings.Unbounded;
with Ada.Exceptions;
with Ada.Command_Line;
with chat_message;
with client_collections;

procedure chat_server is
	
	package ATI renames Ada.Text_IO;
	package LLU renames Lower_Layer_UDP;
	package ASU renames Ada.Strings.Unbounded;
	package ACL renames Ada.Command_Line;
	package CM renames chat_message;
	package CC renames client_collections;
	
	use type CM.Message_Type;
	use type ASU.Unbounded_String;
	
	Port: Integer;
	Expired: Boolean;
	Salir: Boolean:= False;
	Maquina: ASU.Unbounded_String;
	Nick: ASU.Unbounded_String;
	Texto: ASU.Unbounded_String;
	Data: ASU.Unbounded_String;
	Password: ASU.Unbounded_String;
	Password_A: ASU.Unbounded_String;
	Server_EP: LLU.End_Point_Type;
	Client_EP: LLU.End_Point_Type;
	Admin_EP: LLU.End_Point_Type;
	Buffer: aliased LLU.Buffer_Type(1024);
	Message: CM.Message_Type;
	Clientes_E: CC.Collection_Type;
	Clientes_L: CC.Collection_Type;	
	
begin
	
	Port:= Integer'Value(ACL.Argument(1));
	Password:= ASU.To_Unbounded_String(ACL.Argument(2));
	Maquina:= ASU.To_Unbounded_String(LLU.Get_Host_Name);
	Server_EP:= LLU.Build(LLU.To_IP(ASU.To_String(Maquina)),Port);
	LLU.Bind(Server_EP);
	loop	
		LLU.Reset(Buffer);
		LLU.Receive(Server_EP,Buffer'Access,1000.0,Expired);
		if Expired then
			ATI.Put_Line("Plazo Expirado");
		else
			Message:= CM.Message_Type'Input(Buffer'Access);
			if Message = CM.Init then
				Client_EP:= LLU.End_Point_Type'Input(Buffer'Access);
				Nick:= ASU.Unbounded_String'Input(Buffer'Access);
				LLU.Reset(Buffer);
				if Nick = "reader" then
					CC.Add_Client(Clientes_L,Client_EP,Nick,False);
				else
					CC.Add_Client(Clientes_E,Client_EP,Nick,True);
					Nick:= CC.Search_Client(Clientes_E,Client_EP);
					if Nick /= "" then					
						Texto:= ASU.To_Unbounded_String(ASU.To_String(Nick) & " joins the chat");
						Nick:= ASU.To_Unbounded_String("server");
						CM.Message_Type'Output(Buffer'Access,CM.Server);
						ASU.Unbounded_String'Output(Buffer'Access,Nick); 
						ASU.Unbounded_String'Output(Buffer'Access,Texto);
						CC.Send_To_All(Clientes_L,Buffer'Access);					
					end if;				
				end if;		
			elsif Message = CM.Writer then
				Client_EP:= LLU.End_Point_Type'Input(Buffer'Access);
				Texto:= ASU.Unbounded_String'Input(Buffer'Access);
				LLU.Reset(Buffer);
				Nick:= CC.Search_Client(Clientes_E,Client_EP);
				if Nick /= "" then					
						CM.Message_Type'Output(Buffer'Access,CM.Server);
						ASU.Unbounded_String'Output(Buffer'Access,Nick); 
						ASU.Unbounded_String'Output(Buffer'Access,Texto);
						CC.Send_To_All(Clientes_L,Buffer'Access);		
						ATI.Put_Line("WRITER received from " & ASU.To_String(Nick) & ": " & ASU.To_String(Texto));
				else
						ATI.Put_Line("WRITER received from unknown client. IGNORED");
				end if;
			elsif Message = CM.Collection_Request then
				Admin_EP:= LLU.End_Point_Type'Input(Buffer'Access);
				Password_A:= ASU.Unbounded_String'Input(Buffer'Access);
				if Password_A = Password then
					LLU.Reset(Buffer);
					CM.Message_Type'Output(Buffer'Access,CM.Collection_Data);
					Data:= ASU.To_Unbounded_String(CC.Collection_Image(Clientes_E));
					ASU.Unbounded_String'Output(Buffer'Access,Data);
					LLU.Send(Admin_EP,Buffer'Access);
					ATI.Put_Line("LIST_REQUEST received.");
				else
					ATI.Put_Line("LIST_REQUEST received. IGNORED, incorrect password");
				end if;
				LLU.Reset(Buffer);
			elsif Message = CM.Ban then
				Password_A:= ASU.Unbounded_String'Input(Buffer'Access);
				Nick:= ASU.Unbounded_String'Input(Buffer'Access);
				if Password_A = Password then
					LLU.Reset(Buffer);
					CC.Delete_Client(Clientes_E,Nick);
				end if;	
				LLU.Reset(Buffer);
			elsif Message = CM.Shutdown then
				Password_A:= ASU.Unbounded_String'Input(Buffer'Access);
				if Password_A = Password then
					LLU.Reset(Buffer);
					ATI.Put_Line("SHUTDOWN received");
					Salir:= True;
				end if;
				LLU.Reset(Buffer);		
			end if;
		end if;
	exit when Salir = True;	
	end loop;

	ATI.New_Line;	
	LLU.Finalize;	

end chat_server;
