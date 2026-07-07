  --[dbo].[AspNetUsers] -> select, pogledati LockoutEnd
  
  update AspNetUsers
  set LockoutEnd = NULL
  where id = '2c9ee4a3-4bb3-4e00-88c2-81385746f970'