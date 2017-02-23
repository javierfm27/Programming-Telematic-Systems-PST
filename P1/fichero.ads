with Ada.Text_IO;
with Ada.Command_Line;
with Ada.Strings.Unbounded;
with Ada.Exceptions;
with Ada.IO_Exceptions;

package fichero is

	package ACL renames Ada.Command_Line;
	package ATI renames Ada.Text_IO;
	package ASU renames Ada.Strings.Unbounded;

	procedure Abrir (File: in out ATI.File_Type;File_Name: ASU.Unbounded_String);
	procedure Leer (File: in ATI.File_Type; Linea: out ASU.Unbounded_String; Finish: out Boolean);

	
end fichero;
