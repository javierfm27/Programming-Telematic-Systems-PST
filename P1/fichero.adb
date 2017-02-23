
package body fichero is
	

	
	procedure Abrir ( File: in out ATI.File_Type;File_Name: ASU.Unbounded_String) is
	begin

		ATI.Open(File, ATI.In_File  ,ASU.To_String(File_Name));
	end Abrir;
	


	procedure Leer (File: in ATI.File_Type; Linea: out ASU.Unbounded_String; Finish:out  Boolean) is

	begin

			Linea:= ASU.To_Unbounded_String(ATI.Get_Line(File));

			
	exception
		when Ada.Io_Exceptions.End_Error =>
			Finish:= True;
	end Leer;


	

end fichero;
