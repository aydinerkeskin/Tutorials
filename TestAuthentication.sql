if not exists (select * from sysObjects where name = 'Users')
create table Users
(
	UserId		integer not null identity(1, 1) primary key clustered,
	UserName	nvarchar(50) not null ,
	FirstName	nvarchar(50),
	LastName	nvarchar(50),
	Email		nvarchar(150),
	[Password]	nvarchar(255),
	IsActive	integer not null default 1,
	InsertDate	datetime not null default getDate(),
	UpdateDate	datetime not null default getDate()
)
go

if not exists (select Top 1 1 from Users(NoLock) where UserId = 1)
begin
	set identity_insert Users on;
	insert into Users(UserId, UserName, FirstName, LastName, Email, [Password], IsActive)
	values (1, 'Admin', '', '', 'admin@acme.com', 'Admin', 1);
	set identity_insert Users off;
end;
go

if not exists (select * from sysObjects where name = 'Roles')
create table Roles
(
	RoleId		integer not null identity(1, 1) primary key clustered,
	RoleName	nvarchar(30) not null,
	InsertDate	datetime not null default getDate(),
	UpdateDate	datetime not null default getDate()
)
go

if not exists (select Top 1 1 from Roles(NoLock) where RoleId = 1)
begin
	set identity_insert Roles on;
	insert into Roles(RoleId, RoleName)
	values (1, 'SysAdmin');
	set identity_insert Roles off;
end;
go

if not exists (select * from sysObjects where name = 'UserRoles')
create table UserRoles
(
	UserId		integer, 
	RoleId		integer,
	InsertDate	datetime not null default getDate()

	Constraint PK_UserRoles primary key (UserId, RoleId)
)
go

if not exists (select Top 1 1 from UserRoles(NoLock) where UserId = 1 and RoleId = 1)
begin
	insert into UserRoles(UserId, RoleId)
	values (1, 1);
end;
go


if exists (select Top 1 1 from sysObjects where name = 'sp_selectUser')
drop procedure sp_selectUser
go
create procedure sp_selectUser
	@UserName	nvarchar(30)
as
begin
	select 
		UserId, UserName, FirstName, LastName, Email, [Password], IsActive, InsertDate, UpdateDate 
	from Users(NoLock) 
	where UserName = @UserName;
end;
go

if exists (select Top 1 1 from sysObjects where name = 'sp_validateUser')
drop procedure sp_validateUser
go
create procedure sp_validateUser
	@UserName	nvarchar(30),
	@Password	nvarchar(255)
as
begin
	declare @Result as integer = 0;

	if exists (select Top 1 1 from Users(NoLock) where UserName = @UserName and [Password] = @Password) 
	begin
		set @Result = 1;
	end;

	select @Result as 'Result';
end;
go

if exists (select Top 1 1 from sysObjects where name = 'sp_selectUserRoles')
drop procedure sp_selectUserRoles
go
create procedure sp_selectUserRoles
	@UserName	nvarchar(30)
as
begin
	declare @UserId as integer = 0;

	if exists (select Top 1 1 from Users(NoLock) where UserName = @UserName)
	begin
		select 
			@UserId = UserId 
		from Users(NoLock) 
		where UserName = @UserName;
	end;

	select 
		RoleId, RoleName 
	from Roles(NoLock) 
	where RoleId in (select RoleId from UserRoles(NoLock) where UserId = @UserId);
end;
go


if exists (select Top 1 1 from sysObjects where name = 'sp_selectRoleUsers')
drop procedure sp_selectRoleUsers
go
create procedure sp_selectRoleUsers
	@UserName	nvarchar(30)
as
begin
	declare @UserId as integer = 0;
	
	if exists (select Top 1 1 from Users(NoLock) where UserName = @UserName)
	begin
		select 
			@UserId = UserId 
		from Users(NoLock) 
		where UserName = @UserName;
	end;

	select 
		UserId, UserName, FirstName, LastName, Email, [Password], IsActive, InsertDate, UpdateDate 
	from Users(NoLock) 
	where UserId in (select UserId from UserRoles(NoLock) where UserId = @UserId);
end;
go

