with Ada.Strings.Unbounded;
with Ada.Text_IO;
with Ada.Unchecked_Deallocation;
with Ada.Characters.Handling;
with Ada.Strings.Maps;

package Word_Lists is

	package ASU renames Ada.Strings.Unbounded;
	package ATI renames Ada.Text_IO;
	package ACH renames Ada.Characters.Handling;
	package ASM renames Ada.Strings.Maps;

	type Cell;
	type Word_List_Type is access Cell;
	type Cell is record
		Word: ASU.Unbounded_String;
		Count: Natural := 0;
		Next: Word_List_Type;
	end record;
	
	procedure Free is new Ada.Unchecked_Deallocation (Cell, Word_List_Type );

	Word_List_Error: exception;

	procedure Add_Word (List: in out Word_List_Type;
				Word: in ASU.Unbounded_String);

	procedure Delete_Word (List: in out Word_List_Type;
				Word: in ASU.Unbounded_String);

	procedure Search_Word (List: in Word_List_Type;
				Word: in ASU.Unbounded_String;
				Count: out Natural);

	procedure Max_Word (List: in Word_List_Type;
				Word: out ASU.Unbounded_String;
				Count: out Natural);
	procedure Print_All (List: in Word_List_Type);
	
	procedure Delete_List (List: in out Word_List_Type);

end Word_Lists;
