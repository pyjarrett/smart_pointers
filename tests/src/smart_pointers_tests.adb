with Smart_Pointers_Int.Test;
with Trendy_Test.Reports;

procedure Smart_Pointers_Tests is
begin
    Trendy_Test.Register (Smart_Pointers_Int.Test.All_Tests);
    Trendy_Test.Reports.Print_Basic_Report (Trendy_Test.Run);
end Smart_Pointers_Tests;
