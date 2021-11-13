with Trendy_Test.Assertions;

package body Smart_Pointers_Int.Test is

   use Trendy_Test.Assertions.Integer_Assertions;
   use all type Trendy_Test.Operation;

   procedure Test_Count (Op : in out Trendy_Test.Operation'Class) is
   begin
      Op.Register;


      declare
         I : Integer_Pointers.Arc;
         J : Integer_Pointers.Arc := Integer_Pointers.Make_Null;
      begin
         -- An "uninitialized" Arc is null.
         Assert_EQ (Op, Integer (I.Count), 0);
         Assert_EQ (Op, Integer (J.Count), 0);
         Assert (Op, not I.Is_Valid);
         Assert (Op, not J.Is_Valid);

         -- Trying to track a null Arc from another one doesn't affect future
         -- operations.  This means null Arcs can't be made to track each other.

         -- Assign a new item to the first Arc.
         I := Integer_Pointers.Make (new Integer'(5));
         Assert_EQ (Op, Integer (I.Count), 1);
         Assert_EQ (Op, Integer (J.Count), 0);
         Assert (Op, I.Is_Valid);
         Assert (Op, not J.Is_Valid);

         -- Copy the Arc to another.
         J := I;
         Assert_EQ (Op, Integer (I.Count), 2);
         Assert_EQ (Op, Integer (J.Count), 2);
         Assert (Op, I.Is_Valid);
         Assert (Op, J.Is_Valid);

         -- Arc falling out of scope.
         declare
            K : Integer_Pointers.Arc;
         begin
            K := J;
            Assert_EQ (Op, Integer (I.Count), 3);
            Assert_EQ (Op, Integer (J.Count), 3);
            Assert (Op, I.Is_Valid);
            Assert (Op, J.Is_Valid);
            Assert (Op, K.Is_Valid);
         end;
         Assert_EQ (Op, Integer (I.Count), 2);
         Assert_EQ (Op, Integer (J.Count), 2);
         Assert (Op, I.Is_Valid);
         Assert (Op, J.Is_Valid);

         -- Reset the first Arc.
         I.Reset;
         Assert_EQ (Op, Integer (I.Count), 0);
         Assert_EQ (Op, Integer (J.Count), 1);
         Assert (Op, not I.Is_Valid);
         Assert (Op, J.Is_Valid);

         -- Reset the last Arc.
         J.Reset;
         Assert_EQ (Op, Integer (I.Count), 0);
         Assert_EQ (Op, Integer (J.Count), 0);
         Assert (Op, not I.Is_Valid);
         Assert (Op, not J.Is_Valid);
      end;
   end Test_Count;

procedure Test_Stress (Op : in out Trendy_Test.Operation'Class) is


    task Stress_Task is
            Target : Integer_Pointers.Arc;
        end;

    task body Stress_Task is
        begin
            for X in 1 .. 1_000_000 loop
                null;
            end loop;
    end Stress_Task;
begin



        declare
            Tasks : array (Integer range 1 .. 128) of Stress_Task;
        begin
            null;  -- Wait for tasks to complete
        end;
begin


end;


end Test_Stress;

   ---------------------------------------------------------------------------
   -- Test Registry
   ---------------------------------------------------------------------------
   function All_Tests return Trendy_Test.Test_Group is
     (1 => Test_Count'Access);

end Smart_Pointers_Int.Test;
