with Ada.Text_IO;
with Lower_Layer_UDP;
with Ada.Strings.Unbounded;
with Ada.Exceptions;
with Ada.Command_Line;
with chat_message;
with client_collections;

procedure chat_admin is

	package ATI renames Ada.Text_IO;
	package LLU renames Lower_Layer_UDP;
	package ASU renames Ada.Strings.Unbounded;
	package ACL renames Ada.Command_Line;
	package CM renames chat_message;
	package CC renames client_collections;

	Server: ASU.Unbounded_String;
	Password: ASU.Unbounded_String;
	Clientes: ASU.Unbounded_String;
	Nick: ASU.Unbounded_String;
	Server_EP: LLU.End_Point_Type;
	Admin_EP: LLU.End_Point_Type;
	Buffer: aliased LLU.Buffer_Type(1024);
	Message: CM.Message_Type;	
	Puerto: Integer;
	Option: Integer;	
	Expired: Boolean:= False;
	FINISH_ERROR: exception;

begin
	Server:= ASU.To_Unbounded_String(ACL.Argument(1));
	Puerto:= Integer'Value(ACL.Argument(2));
	Password:= ASU.To_Unbounded_String(ACL.Argument(3));
	Server_EP:= LLU.Build(LLU.To_IP(ASU.To_String(Server)),Puerto);
	LLU.Bind_Any(Admin_EP);
	loop
		ATI.Put_Line("Options");
		ATI.Put_Line("=======");
		ATI.Put_Line("1 Show client list");
		ATI.Put_Line("2 Ban client");
		ATI.Put_Line("3 Shutdown server");
		ATI.Put_Line("4 Quit");
		ATI.New_Line;
		ATI.Put("Your option? ");
		Option:= Integer'Value(ATI.Get_Line);
		ATI.New_Line;
			if Option = 1 then
				LLU.Reset(Buffer);
				CM.Message_Type'Output(Buffer'Access,CM.Collection_Request);
				LLU.End_Point_Type'Output(Buffer'Access,Admin_EP);
				ASU.Unbounded_String'Output(Buffer'Access,Password);
				LLU.Send(Server_EP,Buffer'Access);
				LLU.Reset(Buffer);
				LLU.Receive(Admin_EP,Buffer'Access,5.0,Expired);
				if Expired = True then
					raise FINISH_ERROR;
				else
					Message:= CM.Message_Type'Input(Buffer'Access);
					Clientes:= ASU.Unbounded_String'Input(Buffer'Access);
					ATI.Put_Line(ASU.To_String(Clientes));
					ATI.New_Line;
				end if;
			elsif Option = 2 then
				ATI.Put("Nick to ban? ");
				Nick:= ASU.To_Unbounded_String(ATI.Get_Line);
				LLU.Reset(Buffer);
				CM.Message_Type'Output(Buffer'Access,CM.Ban);
				ASU.Unbounded_String'Output(Buffer'Access,Password);
				ASU.Unbounded_String'Output(Buffer'Access,Nick);
				LLU.Send(Server_EP,Buffer'Access);
				ATI.New_Line;
			elsif Option = 3 then
				LLU.Reset(Buffer);
				CM.Message_Type'Output(Buffer'Access,CM.Shutdown);
				ASU.Unbounded_String'Output(Buffer'Access,Password);
				LLU.Send(Server_EP,Buffer'Access);
				ATI.New_Line;
		end if;
	exit when Option = 4;
	end loop;

	LLU.Finalize;
	

	exception
		when FINISH_ERROR =>
			ATI.Put_Line("Incorrect password");	
			LLU.Finalize;		

end chat_admin;
