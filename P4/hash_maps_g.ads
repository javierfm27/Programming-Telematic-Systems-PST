--Javier Fernández Morata
--
--  TAD genérico de una tabla de símbolos (map) implementada como un hash
--
with Ada.Strings.Unbounded;
generic
   type Key_Type is private;
   type Value_Type is private;   
	with function "=" (K1, K2: Key_Type) return Boolean;
	with function Image (K : Key_Type) return Ada.Strings.Unbounded.Unbounded_String;
	Max: in Natural;
   type Hash_Range is mod <>;
   with function Hash (K: Key_Type) return Hash_Range;

package Hash_Maps_G is

   type Map is limited private;

   Full_Map : exception;

   procedure Get (M       : in out Map;
                  Key     : in  Key_Type;
                  Value   : out Value_Type;
                  Success : out Boolean);


   procedure Put (M     : in out Map;
                  Key   : Key_Type;
                  Value : Value_Type);

   procedure Delete (M      : in out Map;
                     Key     : in  Key_Type;
                     Success : out Boolean);

	procedure Print (M:  Map);


   function Map_Length (M : Map) return Natural;

   --
   -- Cursor Interface for iterating over Map elements
   --
   type Cursor is limited private;

   function First (M: Map) return Cursor;

   function Last (M: Map) return Cursor;

   procedure Next (C: in out Cursor);

   procedure Prev (C: in out Cursor);

   function Has_Element (C: Cursor) return Boolean;
	
	 function Map_Empty (M: in Map) return Boolean;

   type Element_Type is record
      Key:   Key_Type;
      Value: Value_Type;
   end record;

   No_Element: exception;

   -- Raises No_Element if Has_Element(C) = False;
   function Element (C: Cursor) return Element_Type;

private
	
   type Hueco is record
		Key: Key_Type;
		Value: Value_Type;
		Lleno: Boolean:= False;
		Borrado: Boolean:= False;
	end record;
	

	subtype Indice is Integer range 0..(Integer(Hash_Range'Last) + 200);--Tengo el valor +200 debido a que no hago correctamente el Put, ya que este deberia seguir buscando cuaando llega al final de la tabla, se como deberia ser pero no he podido implementarlo.
	
	type Vector_I is array (Indice) of Hueco;

	type Map is record
		Sitio: Vector_I;
		Length: Natural:= 0;
	end record;

	type Cursor is record
		M: Map;
		Posicion: Indice;
	end record;

end Hash_Maps_G;
