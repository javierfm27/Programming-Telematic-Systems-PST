with Ada.Text_IO;
with Ada.Command_Line;
with Ada.Strings.Unbounded;
with Ada.Exceptions;
with Ada.IO_Exceptions;
with fichero;

package comandos is

	package ACL renames Ada.Command_Line;
	package ATI renames Ada.Text_IO;
	package ASU renames Ada.Strings.Unbounded;
	use type ASU.Unbounded_String;


	procedure mostrar (File: in out ATI.File_Type;C1: out Boolean;C2: out Boolean);

end comandos;
