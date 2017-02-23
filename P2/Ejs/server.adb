with Lower_Layer_UDP;
with Ada.Strings.Unbounded;
with Ada.Text_IO;
with Ada.Exceptions;
with Ada.Command_Line;

procedure Server is
   package LLU renames Lower_Layer_UDP;
   package ASU renames Ada.Strings.Unbounded;
	package ACL renames Ada.Command_Line;

	type mess is (Int,Pal);	

   Server_EP: LLU.End_Point_Type;
   Client_EP: LLU.End_Point_Type;
   Buffer:    aliased LLU.Buffer_Type(1024);
   Request: ASU.Unbounded_String;
   Reply: ASU.Unbounded_String := ASU.To_Unbounded_String ("¡Bienvenido!");
   Expired : Boolean;
	Port: Integer;
	Maquina: ASU.Unbounded_String;
	IP: ASU.Unbounded_String; 
	Message: mess;
	Num: Integer:= 0;

begin

	Port:= Integer'Value(ACL.Argument(1));
	Maquina:= ASU.To_Unbounded_String(LLU.Get_Host_Name);
	IP:= ASU.To_Unbounded_String(LLU.To_IP(ASU.To_String(Maquina)));
   Server_EP := LLU.Build (ASU.To_String(IP), Port);

   LLU.Bind (Server_EP);

   loop

      LLU.Reset(Buffer);

      
      LLU.Receive (Server_EP, Buffer'Access, 1000.0, Expired);

      if Expired then
         Ada.Text_IO.Put_Line ("Plazo expirado, vuelvo a intentarlo");
      else
			Message:= mess'Input(Buffer'Access);
         Client_EP := LLU.End_Point_Type'Input (Buffer'Access);
				if Message = Int then
					Num:= Integer'Input(Buffer'Access);
					Num:= Num * 2;
					LLU.Reset(Buffer);
					mess'Output(Buffer'Access,Int);
					Integer'Output(Buffer'Access,Num);
					LLU.Send (Client_EP, Buffer'Access);
				elsif Message = Pal then
					Request := ASU.Unbounded_String'Input (Buffer'Access);
					LLU.Reset(Buffer);
					Num:= ASU.Length(Request);
					mess'Output(Buffer'Access,Pal);
					Integer'Output(Buffer'Access,Num);
					LLU.Send(Client_EP, Buffer'Access);
				end if;

         LLU.Reset (Buffer);


      end if;
   end loop;

   -- nunca se alcanza este punto
   -- si se alcanzara, habría que llamar a LLU.Finalize;

exception
   when Ex:others =>
      Ada.Text_IO.Put_Line ("Excepción imprevista: " &
                            Ada.Exceptions.Exception_Name(Ex) & " en: " &
                            Ada.Exceptions.Exception_Message(Ex));
      LLU.Finalize;

end Server;
