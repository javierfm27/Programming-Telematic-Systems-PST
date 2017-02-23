with Ada.Text_IO;
with Ada.Strings.Unbounded;
with fichero; --Abre fichero, lee del fichero
with lista;  	--Gestiona la lista dinamica
with word_lists;		--Juega con la lista, añade, borra, etc
with Ada.Exceptions;
with Ada.IO_Exceptions;
with comandos;
with Ada.Characters.Handling;



procedure words is
	
	package ATI renames Ada.Text_IO;
	package ASU renames Ada.Strings.Unbounded;
	package WL renames word_lists;
	package ACH renames  Ada.Characters.Handling;

	Palabra: ASU.Unbounded_String;
	Words: WL.Word_List_Type;
	I: Boolean:= False;
	L: Boolean:= False;
	X: Natural:= 0;
	Count: Natural;
	Finish: Boolean:= False;
	Fich: ATI.File_Type;
	Linea: ASU.Unbounded_String;

begin
		
	comandos.mostrar(Fich,I,L);
	while not Finish loop
		fichero.Leer(Fich,Linea,Finish);
		lista.enlazar_words(Linea,Words);
	end loop;

	ATI.Close(Fich);

	if L = True and I = False then
		WL.Print_All(Words);
		WL.Max_Word(Words,Palabra,X);
		ATI.Put_Line("The most frequent word: |" & ASU.To_String(Palabra) & "| - " & Natural'Image(X));
		WL.Delete_List(Words);	
	elsif I = True and L = False then
		loop
			ATI.New_Line;
			ATI.New_Line;
			ATI.Put_Line("Options");
			ATI.Put_Line("=======");
			ATI.Put_Line("1 Add word");
			ATI.Put_Line("2 Delete word");
			ATI.Put_Line("3 Search word");
			ATI.Put_Line("4 Show all words");		
			ATI.Put_Line("5 Quit");
			ATI.New_Line;
			ATI.New_Line;
			ATI.Put("Your option? ");
			X:= Integer'Value(ATI.Get_Line);
			if X = 1 then
				ATI.Put("Word? ");
				Palabra:= ASU.To_Unbounded_String(ATI.Get_Line);
				WL.Add_Word(Words,Palabra);
			elsif X = 2 then
				ATI.Put("Word? ");
				Palabra:= ASU.To_Unbounded_String(ATI.Get_Line);
				WL.Delete_Word(Words,Palabra);
			elsif X = 3 then
				ATI.Put("Word? ");
				Palabra:= ASU.To_Unbounded_String(ATI.Get_Line);
				WL.Search_Word(Words,Palabra,Count);
				ATI.Put("|" & ASU.To_String(Palabra) & "| - " & Natural'Image(Count));
			elsif X = 4 then
				WL.Print_All(Words);
			end if;
		exit when X = 5;
		end loop;
		WL.Max_Word(Words,Palabra,X);
		ATI.Put_Line("The most frequent word: |" & ASU.To_String(Palabra) & "| - " & Natural'Image(X));
		WL.Delete_List(Words);	
	elsif I = True and L = True  then
		WL.Print_All(Words);
		loop
			ATI.New_Line;
			ATI.New_Line;
			ATI.Put_Line("Options");
			ATI.Put_Line("=======");
			ATI.Put_Line("1 Add word");
			ATI.Put_Line("2 Delete word");
			ATI.Put_Line("3 Search word");
			ATI.Put_Line("4 Show all words");		
			ATI.Put_Line("5 Quit");
			ATI.New_Line;
			ATI.New_Line;
			ATI.Put("Your option? ");
			X:= Integer'Value(ATI.Get_Line);
			if X = 1 then
				ATI.Put("Word? ");
				Palabra:= ASU.To_Unbounded_String(ATI.Get_Line);
				WL.Add_Word(Words,Palabra);
			elsif X = 2 then
				ATI.Put("Word? ");
				Palabra:= ASU.To_Unbounded_String(ATI.Get_Line);
				WL.Delete_Word(Words,Palabra);
			elsif X = 3 then
				ATI.Put("Word? ");
				Palabra:= ASU.To_Unbounded_String(ATI.Get_Line);
				WL.Search_Word(Words,Palabra,Count);
				Palabra:= ASU.To_Unbounded_String(ACH.To_Lower(ASU.To_String(Palabra)));
				ATI.Put("|" & ASU.To_String(Palabra) & "| - " & Natural'Image(Count));
			elsif X = 4 then
				WL.Print_All(Words);
			end if;
		exit when X = 5;
		end loop;
		WL.Max_Word(Words,Palabra,X);
		ATI.Put_Line("The most frequent word: |" & ASU.To_String(Palabra) & "| - " & Natural'Image(X));
		WL.Delete_List(Words);
	elsif L = False and I = False then
		WL.Max_Word(Words,Palabra,X);
		ATI.Put_Line("The most frequent word: |" & ASU.To_String(Palabra) & "| - " & Natural'Image(X));
		WL.Delete_List(Words);	
	end if;








end words;
