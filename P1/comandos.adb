package body comandos is


	procedure mostrar (File: in out ATI.File_Type;C1: out Boolean; C2: out Boolean) is
		Entrada: ASU.Unbounded_String;
		Entrada2: ASU.Unbounded_String;
		File_Name: ASU.Unbounded_String;
		Command_Error: exception;
	begin

		
		if ACL.Argument_Count = 1 then
			File_Name:= ASU.To_Unbounded_String(ACL.Argument(1));
			fichero.Abrir(File,File_Name);	
		elsif ACL.Argument_Count = 2 then
			Entrada:= ASU.To_Unbounded_String(ACL.Argument(1));
			File_Name:= ASU.To_Unbounded_String(ACL.Argument(2));
			if Entrada = "-i" then
				C1:= True;
				C2:= False;
			elsif  Entrada = ASU.To_Unbounded_String("-l") then
				C1:= False;
				C2:= True;			
			else
				raise Command_Error;
			end if;
			fichero.Abrir(File,File_Name);

		elsif ACL.Argument_Count = 3 then 
			Entrada:= ASU.To_Unbounded_String(ACL.Argument(1));
			Entrada2:= ASU.To_Unbounded_String(ACL.Argument(2));
			File_Name:= ASU.To_Unbounded_String(ACL.Argument(3));
			if Entrada = "-i" or Entrada = "-l" then
				C1:= True;
			else
				raise Command_Error;
			end if;
			if Entrada2 = "-i" or Entrada2 = "-l" then
				C2:= True;
			else
				raise Command_Error;
			end if;

			fichero.Abrir(File,File_Name);
		end if;		




	exception 
	

			when Command_Error =>
				ATI.Put_Line("Debes introducir ['-i'] ó ['-l']  ['-i' '-l'] ó ['-l' '-i'] ó [<nombre de fichero>]");

	end mostrar;





end comandos;
