/****** Object:  StoredProcedure [dbo].[AddNewUsers]    Script Date: 08-Aug-23 8:39:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- testing 123456
CREATE procedure [dbo].[AddNewUsers]

	@Username varchar(100),
	@Email varchar(100)

AS
BEGIN

	create table #ReturnTable (ReturnMessage varchar(100), ReturnValue varchar (10))

	if exists (select top 1 * from users where username = @username)
	begin
		insert into #returntable (returnmessage, returnvalue) values ('Username already exists!','Failed')
	end
	else if exists (select top 1 * from users where username = @username)
	begin
		insert into #returntable (returnmessage, returnvalue) values ('Email already exists!','Failed')
	end
	else
	begin
		insert into Users (username, email, cakemodeactivated) values (@username, @email, 0)
	end

	select * from #ReturnTable
	drop table #ReturnTable

END

GO
