with Ada.Text_IO;
with Lower_Layer_UDP;
with Ada.Strings.Unbounded;
with Ada.Exceptions;
with Ada.Command_Line;
with chat_message;
with client_collections;

procedure prueba_collection is
	
	package ATI renames Ada.Text_IO;
	package LLU renames Lower_Layer_UDP;
	package ASU renames Ada.Strings.Unbounded;
	package ACL renames Ada.Command_Line;
	package CM renames chat_message;
	package CC renames client_collections;
	
	use type CM.Message_Type;
	use type ASU.Unbounded_String;
	
	List: CC.Collection_Type;
	EP1: LLU.End_Point_Type;
	EP2: LLU.End_Point_Type;
	EP3: LLU.End_Point_Type;
	Clientes: ASU.Unbounded_String;

begin
	LLU.Bind_Any(EP1);
	LLU.Bind_Any(EP2);	
	LLU.Bind_Any(EP3);
	CC.Add_Client(List,EP1,ASU.To_Unbounded_String("Juanito"),True);
	CC.Add_Client(List,EP2,ASU.To_Unbounded_String("Jaimito"),True);
	CC.Add_Client(List,EP3,ASU.To_Unbounded_String("Jorgito"),True);
	Clientes:= ASU.To_Unbounded_String(CC.Collection_Image(List));
	ATI.Put_Line(ASU.To_String(Clientes));
	CC.Delete_Client(List,ASU.To_Unbounded_String("Jorgito"));
		ATI.Put_Line("despues de deletear");	
	Clientes:= ASU.To_Unbounded_String(CC.Collection_Image(List));
	ATI.Put_Line(ASU.To_String(Clientes));

end prueba_collection;
