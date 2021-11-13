with Smart_Pointers;

package Smart_Pointers_Int is

    type Integer_Pointer is access Integer;
    package Integer_Pointers is new Smart_Pointers (T => Integer, T_Access => Integer_Pointer);

end Smart_Pointers_Int;
