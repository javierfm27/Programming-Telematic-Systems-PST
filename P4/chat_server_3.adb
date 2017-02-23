--Javier Fernández Morata
with Ada.Text_IO;
with Ada.Command_Line;
with Ada.Strings.Unbounded;
with Lower_Layer_UDP;
with server_handler;
with retransmission_times;

procedure chat_server_3 is

	package ATI renames Ada.Text_IO;
	package ACL renames Ada.Command_Line;
	package ASU renames Ada.Strings.Unbounded;		
	package LLU renames Lower_Layer_UDP;
	package SH renames server_handler;
	package RT renames retransmission_times;

	Port: Integer:= Integer'Value(ACL.Argument(1));
	Min_Delay: Integer:= Integer'Value(ACL.Argument(3));
	Fault_Pct: Integer:= Integer'Value(ACL.Argument(5));
	Max_RTT: Integer;
	Entrada: Character;

begin
	SH.Id.Server_EP:= LLU.Build(LLU.To_IP(LLU.Get_Host_Name),Port);
	LLU.Bind(SH.Id.Server_EP,SH.Manejador'Access);
	LLU.Set_Faults_Percent (Fault_Pct);
	Max_RTT:= 10 + (Fault_Pct/10)**2;	
	LLU.Set_Random_Propagation_Delay (Min_Delay, SH.Max_Delay);
	loop
		ATI.Get_Immediate(Entrada);
		if Entrada = 'l' then
			ATI.Put_Line("RETRASNMISSION LIST");
			ATI.Put_Line("===================");
			RT.Imprimir(SH.Lista_TiemposS);
		end if;
	end loop;


end chat_server_3;
