package body word_lists is

	procedure Add_Word (List: in out Word_List_Type; Word: in ASU.Unbounded_String) is
	P_Aux: Word_List_Type;
	P_Aux2: Word_List_Type:= null;
	Encontrado: Boolean:= False;
	Ultimo: Boolean:= False;
	Palabra: ASU.Unbounded_String;

	begin
	
	P_Aux:= List ;
	Palabra:= ASU.To_Unbounded_String(ACH.To_Lower(ASU.To_String(Word)));
	loop
		if List  = null then
			Ultimo:= True;
		elsif P_Aux.Next = null then
			Ultimo:= True;
		else
			P_Aux:= P_Aux.Next;
		end if;
	exit when Ultimo = True;
	end loop;


	if List = null then
		List:= new Cell'(Palabra,1,null);
	else
		P_Aux2:= List ;
		Encontrado:= False;
		loop
			if ASU.To_String(P_Aux2.Word) = ASU.To_String(Palabra) then
				P_Aux2.Count:= P_Aux2.Count + 1;
				Encontrado:= True;
			else			
				P_Aux2:= P_Aux2.Next;	
			end if;
		exit when Encontrado = True or P_Aux2 = null;
		end loop;	
		P_Aux2:= null;

		if Encontrado = False then
			P_Aux2:= new Cell'(Palabra,1,null);
			P_Aux.Next:= P_Aux2;
			P_Aux:= P_Aux2;
			P_Aux2:= null;
		end if;
	end if;
	ATI.Put_Line("Word |" & ASU.To_String(Palabra) & "| added");

	end Add_Word;




	procedure Delete_Word (List: in out Word_List_Type; Word: in ASU.Unbounded_String) is
	P_Aux: Word_List_Type;
	P_Aux2: Word_List_Type;	
	Encontrado: Boolean:= False;
	Palabra: ASU.Unbounded_String;

	begin
	P_Aux:= List;
	P_Aux2:= List;
	Palabra:= ASU.To_Unbounded_String(ACH.To_Lower(ASU.To_String(Word)));
	if List.Next = null and ASU.To_String(List.Word) = ASU.To_String(Palabra) then
		Free(List);
		P_Aux:= null;
	elsif List = null then
		ATI.Put_Line("No se va de aqui");
		raise Word_List_Error;
	elsif ASU.To_String(List.Word) = ASU.To_String(Palabra) then
		List:= List.Next;
		Free(P_Aux);
	else
		loop
			ATI.Put_Line(ASU.To_String(P_Aux.Word));
			if P_Aux.Next = null then
				if ASU.To_String(P_Aux.Word) /= ASU.To_String(Palabra) then
					raise Word_List_Error;
				end if;
			else
				if ASU.To_String(P_Aux.Next.Word) = ASU.To_String(Palabra) then
					Encontrado:= True;
					P_Aux2:= P_Aux.Next;
					P_Aux.Next:= P_Aux2.Next;
					Free(P_Aux2);
					P_Aux:= null;
				elsif ASU.To_String(P_Aux.Next.Word) = ASU.To_String(Palabra) and P_Aux.Next.Next = null then
					Encontrado:= True;			
					P_Aux2:= P_Aux.Next;
					P_Aux.Next:= null;
					Free(P_Aux2);
					P_Aux:= null;
				else
					P_Aux:= P_Aux.Next;
				end if;
			end if;		
		exit when P_Aux = null or Encontrado = True;
		end loop;
		
	end if;
	
	

	ATI.Put_Line("|" & ASU.To_String(Palabra) & "| deleted");

	exception
		when Word_List_Error =>
			ATI.Put_Line("NO SE ENCUENTRA LA PALABRA EN LA LISTA");

	end Delete_Word;




	procedure Search_Word (List: in Word_List_Type; Word: in ASU.Unbounded_String; Count: out Natural) is
	P_Aux: Word_List_Type;
	Palabra: ASU.Unbounded_String;
	begin
	Palabra:= ASU.To_Unbounded_String(ACH.To_Lower(ASU.To_String(Word)));
	P_Aux:= List;
	Count:= 0;
	if List = null then
		Count:= 0;
	else
		while P_Aux /= null  loop
			if ASU.To_String(P_Aux.Word) = ASU.To_String(Palabra) then
				Count:= P_Aux.Count;
				P_Aux:= null;		
			else
				P_Aux:= P_Aux.Next;		
			end if;	
		end loop;
	end if;
	
	end Search_Word;






	procedure Max_Word (List: in Word_List_Type; Word: out ASU.Unbounded_String; Count: out Natural) is
	P_Aux: Word_List_Type;
	P_Aux2: Word_List_Type;	
	
	begin
	P_Aux:= List;	
	if List = null then
		raise Word_List_Error;
	elsif List.Next = null then
		Word:= List.Word;
		Count:= List.Count;	
	else
		P_Aux2:= List.Next;
		loop
			if P_Aux.Count >= P_Aux2.Count then
				P_Aux2:= P_Aux2.Next;
			else
				P_Aux:= P_Aux2;
				P_Aux2:= P_Aux2.Next;
			end if;
		exit when P_Aux2 = null;
		end loop;
		Word:= P_Aux.Word;
		Count:= P_Aux.Count;
	end if;

	exception
		when Word_List_Error =>
			ATI.Put_Line("LA LISTA ESTA VACIA");
			Word:= ASU.To_Unbounded_String(" ");
			Count:= 0;

	end Max_Word;










	procedure Print_All (List: in Word_List_Type) is

	P_Aux: Word_List_Type:=null;
	
	begin
	P_Aux:= List;
	if List = null then
		ATI.Put_Line("NO WORDS");	
	else
		while P_Aux /= null loop
			ATI.Put("|");
			ATI.Put(ASU.To_String(P_Aux.Word));
			ATI.Put("|");
			ATI.Put(" - ");
			ATI.Put_Line(Natural'Image(P_Aux.Count));
			P_Aux:= P_Aux.Next;
		end loop;
	end if;
	
	exception 
		when STORAGE_ERROR =>
			ATI.Put_Line("NO WORDS");	
	end Print_All;


	procedure Delete_List (List: in out Word_List_Type) is
	P_Aux: Word_List_Type:= null;
	P_Aux2: Word_List_Type:= null;
	Ultimo: Boolean:= False;
	begin
	P_Aux:= List;
	if List = null then
		null;
	else
		while Ultimo = False loop
			if P_Aux.Next /= null then
				List:= List.Next;
				Free(P_Aux);
				P_Aux:= List;
			else
				Ultimo:= True;
			end if;
		end loop;

		if Ultimo = True then
			P_Aux:= null;
			Free(List);
		end if;
	end if;	
	end Delete_List;






end word_lists;
