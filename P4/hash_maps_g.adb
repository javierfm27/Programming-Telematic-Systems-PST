--Javier Fernández Morata
with Ada.Text_IO;
with Ada.Strings.Unbounded;

package body hash_maps_g is
	
	package ATI renames Ada.Text_IO;
	package ASU renames Ada.Strings.Unbounded;
		

	procedure Get (M: in out Map; Key: in Key_Type; Value: out Value_Type; Success: out Boolean) is
	X: Indice;
	I: Indice;
	L: Indice;
	Igual: Boolean:= False;
	Found: Boolean:= False;
	Borrado: Boolean:= False;
	Vacio: Boolean:= False;	
	begin
		Success:= False;
		X:= Indice(Hash(Key));
		I:= X;
		L:= X;
		loop
			if M.Sitio(L).Lleno = False and M.Sitio(L).Borrado = False then
				Vacio:= True;
			else
				if M.Sitio(L).Lleno = True then	
					Igual:= "="(M.Sitio(L).Key,Key);
					if Igual = True then
						Value:= M.Sitio(L).Value;
						Success:= True;
						Found:= True;
					end if;
				end if;
				L:= L + 1;
			end if;
		exit when Vacio = True or Igual = True ;
		end loop;
	if Found = True and I < L then
		loop
			if I < L then
				if M.Sitio(I).Borrado = True then					
					Delete(M,Key,Success);
					M.Sitio(I).Key:= Key;
					M.Sitio(I).Value:= Value;
					M.Sitio(I).Lleno:= True;
					M.Sitio(I).Borrado:= False;
					Borrado:= True;
				else
					I:= I + 1;
				end if;
			else
				Borrado:= True;
			end if;
		exit when Borrado = True or I = Indice'Last;
		end loop;
	end if;
	end Get;



	procedure Put (M: in out Map; Key: Key_Type; Value: Value_Type) is
	X: Indice;
	I: Indice;
	Found: Boolean:= False;
	Vacio: Boolean:= False;
	begin
	--ATI.Put_Line("                  ||PUT PM||");
	--ATI.Put_Line("                  /////////////////////////////");
	X:= Indice(Hash(Key));
	if M.Sitio(X).Lleno = False and M.Sitio(X).Borrado = False then
		M.Sitio(X).Key:= Key;
		M.Sitio(X).Value:= Value;
		M.Sitio(X).Lleno:= True;
		--M.Length:= M.Length + 1;
		--ATI.Put_Line(Integer'Image(X));
	else
		I:= X;
		loop
		--	ATI.Put_Line("                                INICIO BUCLE");
			--ATI.Put_Line(Integer'Image(I));
			if M.Sitio(I).Lleno = False and M.Sitio(I).Borrado = False then
				Vacio:= True;
			else
				Found:= "="(M.Sitio(X).Key,Key);
			end if;
			X:= I;
			if I < Indice'Last then
				I:= I + 1;
			end if;
		exit when Vacio = True or Found = True;
		end loop;
		--ATI.Put_Line("                                     ACABA BUCLE");
	end if;

	if Found = True then
		M.Sitio(X).Value:= Value;		
	elsif Vacio = True then
		M.Sitio(X).Key:= Key;
		M.Sitio(X).Value:= Value;
		M.Sitio(X).Lleno:= True;
		M.Length:= M.Length + 1;	
	end if;
--	ATI.Put_Line("                    //////////////////////////");
	end Put;



	
                  
	procedure Delete (M: in out Map; Key: Key_Type; Success: out Boolean) is
	X: Integer;
	I: Integer;
	Found: Boolean:= False;
	Vacio: Boolean:= False;
	O: Natural;
	Borro: ASU.Unbounded_String;
	begin
	--ATI.Put_Line("                ||DELETE PM||");
--	ATI.Put_Line("       ======================");
	X:= Integer(Hash(Key));
	Success:= False;
	loop
		if M.Sitio(X).Lleno = False and M.Sitio(X).Borrado = False then
			Vacio:= True;
		else
			if M.Sitio(X).Lleno = True then
				Found:= "="(M.Sitio(X).Key,Key);
				I:= X;
			end if;
			X:= X + 1;	 
		end if;
	exit when Vacio = True or Found = True;
	end loop;


	if Found = True then
		M.Sitio(I).Borrado:= True;
		M.Sitio(I).Lleno:= False;
		O:= Map_Length (M);
		--ATI.Put_Line(Natural'Image(O));
		--M.Length:= M.Length - 1;   Mirar que pasa al borrar
		Success:= True;
	else
		Success:= False;
	end if;
	--ATI.Put_Line("       =====================");
	end Delete;       



	procedure Print (M:Map) is
	I: Integer;
	Impresion: ASU.Unbounded_String;
	begin
		ATI.Put_Line("<<<<<<<<<<<<<<<<<<<<<<<<<PRINT PM<<<<<<<<<<<<<<<<<<<<<");
		I:= 0;
		loop
			if M.Sitio(I).Lleno = False then
				I:= I + 1;
			else
				Impresion:= Image(M.Sitio(I).Key);
				ATI.Put_Line(ASU.To_String(Impresion));
				I:= I + 1;
			end if;
		exit when I = Indice'Last;	
		end loop;
		ATI.Put_Line("<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<");
	end Print;
	
	

	function Map_Length (M : Map) return Natural is
	begin
		return M.Length;
	end Map_Length;	




	function First (M: Map) return Cursor is
	X: Indice;
	Elemento: Boolean:= False;
	begin
		X:= Indice'First;
		loop
			if M.Sitio(X).Lleno = True then
				Elemento:= True;	
			else 
				X:= X + 1;
			end if;
		exit when Elemento = True or X = Indice'Last;
		end loop;

		if Elemento = False then
			raise No_Element;
		end if;

	--when No_Element =>
		--ATI.Put_Line("LISTA VACIA");
		
	return(M,X);
	end First;
	

	function Last (M: Map) return Cursor is
	X: Indice;
	Elemento: Boolean:= False;
	begin
		X:= Indice'Last;
		loop
			if M.Sitio(X).Lleno = True then
				Elemento:= True;
			else
				X:= X - 1;
			end if;
		exit when Elemento = True;
		end loop;
	return(M,X);
	end Last;


	procedure Next (C: in out Cursor) is 
	X: Indice;
	Siguiente: Boolean:= False;
	L: Indice;	
	begin
	C.M:= C.M;
	L:= C.Posicion;
	X:= C.Posicion + 1;
	loop
		if C.M.Sitio(X).Lleno = True then
			Siguiente:= True;
		else
			X:= X + 1;
		end if;
	exit when Siguiente = True or X = Indice'Last;
	end loop;	
	if Siguiente = True then
		C.Posicion := X ;	
	else
		C.Posicion:= L + 1;
	end if;
	end Next;

	procedure Prev (C: in out Cursor) is 
	X: Indice;
	L: Indice;
	Anterior: Boolean:= False;	
	begin
	C.M:= C.M;
	L:= C.Posicion;
	X:= C.Posicion - 1;
	loop
		if C.M.Sitio(X).Lleno = True then
			Anterior:= True;
		else
			X:= X - 1;
		end if;
	exit when Anterior = True or X = Indice'First;
	end loop;
	if Anterior = True then
		C.Posicion:= X;
	else
		C.Posicion:= L - 1;
	end if;	
	end Prev;
	

	function Has_Element (C: Cursor) return Boolean is
	begin
		if C.M.Sitio(C.Posicion).Lleno = True then
			return True;
		else
			return False;
		end if;
	end Has_Element;

	
	function Map_Empty (M: in Map) return Boolean is 
	I: Indice;
	B: Boolean:= True;
	begin
	I:= Indice'First;
		loop
			if M.Sitio(I).Lleno = False then
				I:= I + 1;
			elsif M.Sitio(I).Lleno = True then
				B:= False;
			end if;	
		exit when I = Indice'Last or B = False;
		end loop;
			
	return B;
	end Map_Empty;




	function Element (C: Cursor) return Element_Type is
	Elemento: Element_Type;
	begin
		if C.M.Sitio(C.Posicion).Lleno = True and C.M.Sitio(C.Posicion).Borrado = False then
			Elemento.Key:= C.M.Sitio(C.Posicion).Key;
			Elemento.Value:= C.M.Sitio(C.Posicion).Value;
			return(Elemento);
		else
			raise No_Element;
		end if;
	end Element;



end hash_maps_g;
