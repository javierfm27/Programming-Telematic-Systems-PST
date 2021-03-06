package body lista is 

	procedure enlazar_words (L: in out ASU.Unbounded_String; Lista: in out WL.Word_List_Type) is

	Blanco: Natural;
	Palabra: ASU.Unbounded_String;

	P_Aux: WL.Word_List_Type;
	P_Aux2: WL.Word_List_Type;

	Igual: Boolean:= False;
	Ultimo: Boolean:= False;

	begin
	P_Aux:= Lista;
	loop
		if Lista = null then
			Ultimo:= True;
		elsif P_Aux.Next = null then
			Ultimo:= True;
		else
			P_Aux:= P_Aux.Next;
		end if;
	exit when Ultimo = True;
	end loop;
	
	loop
		Blanco:= ASU.Index(L,ASM.To_Set(" ,.-"));
		if Blanco = 1 then	
																											--Sentencia if que me ayuda a cortar las palabras
			L:= ASU.Tail(L, ASU.Length(L) - Blanco);	
																											--Para poder guardarlas en una lista							
		elsif Blanco = 0 and ASU.Length(L)/= 0 then	
			Palabra:= L;
			if Lista = null then
				Lista:= new WL.Cell'(Palabra,1,null);
				P_Aux:= Lista;			
			else
				P_Aux2:= Lista;
				Igual:= False;
				loop
					if ASU.To_String(P_Aux2.Word) = ASU.To_String(Palabra) then
						P_Aux2.Count:= P_Aux2.Count + 1;
						Igual:= True;
					else			
						P_Aux2:= P_Aux2.Next;	
					end if;
				exit when Igual = True or P_Aux2 = null;
				end loop;	
				P_Aux2:= null;

				if Igual = False then
					P_Aux2:= new WL.Cell'(Palabra,1,null);
					P_Aux.Next:= P_Aux2;
					P_Aux:= P_Aux2;
					P_Aux2:= null;
				end if;
			end if;		
			L:= ASU.Tail(L,ASU.Length(L)-ASU.Length(L));






		elsif Blanco > 1 then
			Palabra:= ASU.Head(L, Blanco - 1);
			L:= ASU.Tail (L, ASU.Length(L) - Blanco);
			
			if Lista = null then
				Lista:= new WL.Cell'(Palabra,1,null);
				P_Aux:= Lista;			
			else
				P_Aux2:= Lista;
				Igual:= False;
				loop
					if ASU.To_String(P_Aux2.Word) = ASU.To_String(Palabra) then
						P_Aux2.Count:= P_Aux2.Count + 1;
						Igual:= True;
					else			
						P_Aux2:= P_Aux2.Next;	
					end if;
				exit when Igual = True or P_Aux2 = null;
				end loop;	
				P_Aux2:= null;

				if Igual = False then
					P_Aux2:= new WL.Cell'(Palabra,1,null);
					P_Aux.Next:= P_Aux2;
					P_Aux:= P_Aux2;
					P_Aux2:= null;
				end if;
			end if;


		end if;
	exit when ASU.Length(L) = 0;
	end loop; 			
	end enlazar_words;





end lista;
