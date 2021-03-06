with Ada.Text_IO;
with Ada.Command_Line;
with Ada.Strings.Unbounded;
with Ada.Exceptions;
with Ada.IO_Exceptions;
with word_lists;
with Ada.Strings.Maps;

package lista is

	package ACL renames Ada.Command_Line;
	package ATI renames Ada.Text_IO;
	package ASU renames Ada.Strings.Unbounded;
	package WL renames word_lists;
	package ASM renames Ada.Strings.Maps;
	
	use type WL.Word_List_Type;

	procedure enlazar_words (L: in out ASU.Unbounded_String; Lista: in out WL.Word_List_Type);

end lista;
