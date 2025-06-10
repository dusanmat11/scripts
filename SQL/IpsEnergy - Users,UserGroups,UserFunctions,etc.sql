SELECT  * FROM UsrUsersGroups WHERE UserId NOT IN (SELECT  UserId FROM UsrUsers )

SELECT  * FROM UsrUsersGroups WHERE GroupID NOT IN (SELECT GroupID FROM UsrGroups)

SELECT  * FROM UsrFunctionsGroups WHERE  GroupID NOT IN (SELECT GroupID FROM UsrGroups)

SELECT  * FROM UsrFunctionsGroups WHERE  FunctionID NOT IN (SELECT FunctionID FROM UsrFunctions)

SELECT * FROM UsrInvisibleObjects WHERE  GroupID NOT IN (SELECT GroupID FROM UsrGroups)