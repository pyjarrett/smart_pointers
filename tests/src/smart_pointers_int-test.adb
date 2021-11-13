with Ada.Numerics.Discrete_Random;
with Trendy_Test.Assertions;
with Ada.Text_IO;

package body Smart_Pointers_Int.Test is

   use Trendy_Test.Assertions.Integer_Assertions;
   use all type Trendy_Test.Operation;

   procedure Test_Count (Op : in out Trendy_Test.Operation'Class) is
   begin
      Op.Register;

      declare
         I : Integer_Pointers.Arc;
         J : Integer_Pointers.Arc := Integer_Pointers.Make_Null_Arc;
      begin
         -- An "uninitialized" Arc is null.
         Assert_EQ (Op, Integer (I.Count), 0);
         Assert_EQ (Op, Integer (J.Count), 0);
         Assert (Op, not I.Is_Valid);
         Assert (Op, not J.Is_Valid);

         -- Trying to track a null Arc from another one doesn't affect future
         -- operations.  This means null Arcs can't be made to track each other.

         -- Assign a new item to the first Arc.
         I := Integer_Pointers.Make_Arc (new Integer'(5));
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

   package Stress is
      -- Create a small group of overlapping Arcs.
      type Shared_Index is new Positive range 1 .. 10;
      Shared : array (Shared_Index) of Integer_Pointers.Arc;

      package Integer_Random is new Ada.Numerics.Discrete_Random(Shared_Index);

      protected Shared_Generator is
         procedure Reset;
         function Next return Shared_Index;
      private      
         Gen : Integer_Random.Generator;
      end Shared_Generator;
   end Stress;

   package body Stress is
      protected body Shared_Generator is
         procedure Reset is
         begin
            Integer_Random.Reset (Gen);
         end Reset;

         function Next return Shared_Index is (Integer_Random.Random (Gen));
      end Shared_Generator;
   end Stress;

   -- A test of many different tasks indexing into the array of integer arcs.
   procedure Test_Stress (Op : in out Trendy_Test.Operation'Class) is
      use Stress;

      task type Stress_Task is end;

      task body Stress_Task is
         Target : Integer_Pointers.Arc;
      begin
         for X in 1 .. 10_000 loop
            Target := Shared (Shared_Generator.Next);
         end loop;
      end Stress_Task;
   begin
      Op.Register;
      Shared_Generator.Reset;

      for Ptr of Shared loop
         Assert_EQ (Op, 0, Integer (Ptr.Count));
      end loop;

      for Index in Shared'Range loop
         Shared (Index) := Integer_Pointers.Make_Arc (new Integer);
         Shared (Index).Get := Integer (Index);
      end loop;

      for Ptr of Shared loop
         Assert_LT (Op, 0, Integer (Ptr.Count));
      end loop;

      declare
         Tasks : array (Integer range 1 .. 128) of Stress_Task;
      begin
         -- Wait for tasks to complete and release their references.
         null;
      end;

      for Ptr of Shared loop
         Assert_EQ (Op, 1, Integer (Ptr.Count));
      end loop;
   end Test_Stress;

   ---------------------------------------------------------------------------
   -- Test Registry
   ---------------------------------------------------------------------------
   function All_Tests return Trendy_Test.Test_Group is
     (Test_Count'Access,
      Test_Stress'Access);

end Smart_Pointers_Int.Test;
