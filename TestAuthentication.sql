/***************************************************************************************************************/
-- Authentication

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

-- End Authentication
/***************************************************************************************************************/

/***************************************************************************************************************/
-- Localization

if not exists (select Top 1 1 from sysObjects where name = 'Languages')
create table Languages 
(
	LanguageId		integer not null primary key clustered,
	LanguageName	nvarchar(100) not null,
	LanguageCode	nvarchar(2) not null,
	CultureCode		nvarchar(10) not null,
	IsActive		integer not null default 1,
	IsDefault		integer not null default 0
)
go

if not exists (select Top 1 1 from Languages where LanguageId = 1)
begin
	insert into Languages (LanguageId, LanguageName, LanguageCode, CultureCode, IsActive, IsDefault) values (1, 'Türkçe', 'TR', 'tr-TR', 1, 1);
end;
if not exists (select Top 1 1 from Languages where LanguageId = 2)
begin
	insert into Languages (LanguageId, LanguageName, LanguageCode, CultureCode, IsActive, IsDefault) values (2, 'English', 'EN', 'en-EN', 1, 0);
end;

if not exists (select Top 1 1 from sysObjects where name = 'Keyword')
create table Keyword
(
	KeywordId		integer not null identity(1, 1) primary key clustered,
	Keyword			nvarchar(150)
)
go

if not exists (select Top 1 1 from sysObjects where name = 'Dictionary')
create table Dictionary
(
	DictionaryId	integer not null identity(1, 1) primary key clustered,
	KeywordId		integer not null,
	LanguageId		integer not null,
	KeywordValue	ntext
)
go

create view Vocabulary as 
	select 
		D.DictionaryId, D.KeywordId, D.LanguageId, K.Keyword, D.KeywordValue 
	from Dictionary(NoLock) D
	left join Keyword(NoLock) K on D.KeywordId = K.KeywordId;
go

create type LocalizationItem as table
(
	LanguageId		integer,
	Keyword			nvarchar(150),
	KeywordValue	ntext
)
go

if exists (select Top 1 1 from sysObjects where name = 'sp_selectLanguages')
drop procedure sp_selectLanguages
go
create procedure sp_selectLanguages
as
begin
	select * from Languages(NoLock)
end;
go

if exists (select Top 1 1 from sysObjects where name = 'sp_insertLocalizations')
drop procedure sp_insertLocalizations
go
create procedure sp_insertLocalizations
	@tbl_localization	dbo.LocalizationItem ReadOnly
as
begin
	declare @Result as integer;
	if not exists (select Top 1 1 from @tbl_localization)
	begin	
		declare @KeywordId as integer;
		declare @LanguageId as integer;
		declare @Keyword as nvarchar(150);
		declare @KeywordValue as nvarchar(MAX);
		declare cr_x cursor fast_forward read_only for select LanguageId, Keyword, KeywordValue from @tbl_localization;
		open cr_x;
		fetch next from cr_x into @LanguageId, @Keyword, @KeywordValue;
		while @@FETCH_STATUS = 0
		begin
			
			if not exists (select Top 1 1 from Keyword(NoLock) where Keyword = @Keyword)
			begin
				insert into Keyword (Keyword) values (@Keyword);
				select @KeywordId = SCOPE_IDENTITY(); 
				set @Result = @Result + 1;
			end else 
			begin
				select @KeywordId = KeywordId from Keyword(NoLock) where Keyword = @Keyword;
			end;

			if not exists (select Top 1 1 from Dictionary(NoLock) where KeywordId = @KeywordId and LanguageId = @LanguageId)
			begin
				insert into Dictionary (KeywordId, LanguageId, KeywordValue) values (@KeywordId, @LanguageId, @KeywordValue);
				set @Result = @Result + 1;
			end;

			fetch next from cr_x into @LanguageId, @Keyword, @KeywordValue;
		end;
		close cr_x;
		deallocate cr_x;
	end;
	select @Result as 'Result';
end;
go

if exists (select Top 1 1 from sysObjects where name = 'sp_selectDictionaries')
drop procedure sp_selectDictionaries
go
create procedure sp_selectDictionaries
as
begin
	select * from Vocabulary
end;
go

-- End Localization
/***************************************************************************************************************/

/***************************************************************************************************************/
-- Page

if not exists (select Top 1 1 from sysObjects where name = 'PageType')
create table PageType
(
	PageTypeId			integer not null primary key,
	PageTypeKeyword		nvarchar(150)	
)
go

if not exists (select Top 1 1 from PageType(NoLock) where PageTypeId = 1)
begin
	insert into PageType (PageTypeId, PageTypeKeyword) values (1, 'Dynamic Content');
end;
if not exists (select Top 1 1 from PageType(NoLock) where PageTypeId = 2)
begin
	insert into PageType (PageTypeId, PageTypeKeyword) values (2, 'Master Detail Content');
end;
go

if not exists (select Top 1 1 from sysObjects where name = 'Pages')
create table Pages
(
	PageId				integer not null identity(1,1) primary key clustered,
	PageTitleKeyword	nvarchar(150),
	PageSubTitleKeyword	nvarchar(150),
	IsActive			integer not null default 1,
	IsVisible			integer not null default 1
)
go

if not exists (select Top 1 1 from sysObjects where name = 'PageContents')
create table PageContents
(
	ContentId			integer not null identity(1,1) primary key clustered,
	PageId				integer not null,
	PageTypeId			integer not null,
	ContentKeyword		nvarchar(150),
	MasterKeyword		nvarchar(150),
	DetailKeyword		nvarchar(150),
	IsVisible			integer not null default 0
)
go

if not exists (select Top 1 1 from sysObjects where name = 'UploadedFiles')
create table UploadedFiles
(
	FileId				integer not null identity(1,1) primary key clustered,
	FileName			nvarchar(500),
	FilePath			nvarchar(500)
)
go

-------------------------------------------------------------------------------------

if exists (select Top 1 1 from sysObjects where name = 'sp_selectPages')
drop procedure sp_selectPages
go
create procedure sp_selectPages
	@LanguageId		integer = 1
as
begin
	select 
		PageId, 
		PageTitleKeyword, 
		Vt.KeywordValue as PageTitle,
		PageSubTitleKeyword, 
		Vs.KeywordValue as PageSubTitle,
		IsActive, 
		IsVisible
	from Pages(NoLock) P
	left join Vocabulary Vt on P.PageTitleKeyword = Vt.Keyword and Vt.LanguageId = @LanguageId
	left join Vocabulary Vs on P.PageSubTitleKeyword = Vs.Keyword and Vs.LanguageId = @LanguageId
end;
go

if exists (select Top 1 1 from sysObjects where name = 'sp_selectPage')
drop procedure sp_selectPage
go
create procedure sp_selectPage
	@PageId			integer,
	@LanguageId		integer = 1
as
begin
	select 
		PageId, 
		PageTitleKeyword, 
		Vt.KeywordValue as PageTitle,
		PageSubTitleKeyword, 
		Vs.KeywordValue as PageSubTitle,
		IsActive, 
		IsVisible
	from Pages(NoLock) P
	left join Vocabulary Vt on P.PageTitleKeyword = Vt.Keyword and Vt.LanguageId = @LanguageId
	left join Vocabulary Vs on P.PageSubTitleKeyword = Vs.Keyword and Vs.LanguageId = @LanguageId
	where P.PageId = @PageId;
end;
go

if exists (select Top 1 1 from sysObjects where name = 'sp_insertPage')
drop procedure sp_insertPage
go
create procedure sp_insertPage
	@PageTitleKeyword		nvarchar(150),
	@PageSubTitleKeyword	nvarchar(150),
	@IsActive				integer = 1,
	@IsVisible				integer = 1
as
begin
	declare @Result as integer = 0;
	if not exists (select Top 1 1 from Pages(NoLock) where PageTitleKeyword = @PageTitleKeyword)
	begin
		insert into Pages (PageTitleKeyword, PageSubTitleKeyword, IsActive, IsVisible)
		values (@PageTitleKeyword, @PageSubTitleKeyword, @IsActive, @IsVisible);
		select @Result = SCOPE_IDENTITY();
	end else 
	begin
		select @Result = PageId from Pages(NoLock) where PageTitleKeyword = @PageTitleKeyword;
	end;
	select @Result as 'Result';
end;
go

if exists (select Top 1 1 from sysObjects where name = 'sp_updatePage')
drop procedure sp_updatePage
go
create procedure sp_updatePage
	@PageId					integer,
	@PageTitleKeyword		nvarchar(150),
	@PageSubTitleKeyword	nvarchar(150),
	@IsActive				integer = 1,
	@IsVisible				integer = 1
as
begin
	declare @Result as integer = 0;
	if exists (select Top 1 1 from Pages(NoLock) where PageTitleKeyword = @PageTitleKeyword)
	begin
		update Pages 
		set PageTitleKeyword = @PageTitleKeyword, 
			PageSubTitleKeyword = @PageSubTitleKeyword,
			IsActive = @IsActive,
			IsVisible = @IsVisible
		where PageId = @PageId;
		select @Result = 1;
	end;
	select @Result as 'Result';
end;
go

-------------------------------------------------------------------------------------

if exists (select Top 1 1 from sysObjects where name = 'sp_selectPageContents')
drop procedure sp_selectPageContents
go
create procedure sp_selectPageContents
	@PageId			integer,
	@LanguageId		integer = 1
as
begin
	select 
		PG.ContentId, 
		PG.PageId, 
		PG.PageTypeId, 
		PG.ContentKeyword, 
		VC.KeywordValue AS Content,
		PG.MasterKeyword, 
		VM.KeywordValue AS MasterContent,
		PG.DetailKeyword, 
		VD.KeywordValue AS DetailContent,
		PG.IsVisible
	from PageContents(NoLock) PG
	left join Vocabulary VC on PG.ContentKeyword = VC.Keyword and VC.LanguageId = @LanguageId
	left join Vocabulary VM on PG.MasterKeyword = VM.Keyword and VM.LanguageId = @LanguageId
	left join Vocabulary VD on PG.DetailKeyword = VD.Keyword and VD.LanguageId = @LanguageId
	where PG.PageId = @PageId;
end;
go

if exists (select Top 1 1 from sysObjects where name = 'sp_insertPageContent')
drop procedure sp_insertPageContent
go
create procedure sp_insertPageContent
	@PageId					int,
	@PageTypeId				int,
	@ContentKeyword			nvarchar(150),
	@MasterKeyword			nvarchar(150),
	@DetailKeyword			nvarchar(150),
	@IsVisible				integer = 1
as
begin
	declare @Result as integer = 0;
	
	insert into PageContents (PageId, PageTypeId, ContentKeyword, MasterKeyword, DetailKeyword, IsVisible)
	values (@PageId, @PageTypeId, @ContentKeyword, @MasterKeyword, @DetailKeyword, @IsVisible);

	select @Result = SCOPE_IDENTITY();

	select @Result as 'Result';
end;
go

if exists (select Top 1 1 from sysObjects where name = 'sp_updatePageContent')
drop procedure sp_updatePageContent
go
create procedure sp_updatePageContent
	@ContentId				int,
	@PageId					int,
	@PageTypeId				int,
	@ContentKeyword			nvarchar(150),
	@MasterKeyword			nvarchar(150),
	@DetailKeyword			nvarchar(150),
	@IsVisible				integer = 1
as
begin
	declare @Result as integer = 0;
	
	update PageContents set 
		PageTypeId = @PageTypeId,
		ContentKeyword = @ContentKeyword,
		MasterKeyword = @MasterKeyword,
		DetailKeyword = @DetailKeyword,
		IsVisible = @IsVisible
	where ContentId = @ContentId;

	select @Result = 1;

	select @Result as 'Result';
end;
go

-------------------------------------------------------------------------------------

if exists (select Top 1 1 from sysObjects where name = 'sp_insertUploadedFile')
drop procedure sp_insertUploadedFile
go
create procedure sp_insertUploadedFile
	@FileName		nvarchar(500),
	@FilePath		nvarchar(500)
as
begin
	declare @Result as integer = 0;

	insert into UploadedFiles (FileName, FilePath)
	values (@FileName, @FilePath);

	select @Result = SCOPE_IDENTITY();

	select @Result as 'Result';
end;
go

-- End Page
/***************************************************************************************************************/

/***************************************************************************************************************/
-- Category 

if not exists (select Top 1 1 from sysObjects where name = 'Category')
create table Category
(
	CategoryId			integer not null identity(1, 1) primary key clustered,
	CategoryKeyword		nvarchar(150) not null,
	Description			nvarchar(max),
	IsActive			integer not null default 1
)
go

if not exists (select Top 1 1 from sysObjects where name = 'CategoryFirstItem')
create table CategoryFirstItem
(
	ItemId				integer not null identity(1, 1) primary key clustered,
	CategoryId			integer not null,
	PageId				integer,
	MenuKeyword			nvarchar(150),
	TitleKeyword		nvarchar(150),
	ContentKeyword		nvarchar(150),
	OrderNumber			integer not null default 0,
	ImageUrl			nvarchar(500),
	IconUrl				nvarchar(500),
	IsVisible			integer not null default 1
)
go

if not exists (select Top 1 1 from sysObjects where name = 'CategorySecondItem')
create table CategorySecondItem
(
	ItemId				integer not null identity(1, 1) primary key clustered,
	CategoryFirstItemId	integer not null,
	PageId				integer,
	MenuKeyword			nvarchar(150),
	TitleKeyword		nvarchar(150),
	ContentKeyword		nvarchar(150),
	OrderNumber			integer not null default 0,
	ImageUrl			nvarchar(500),
	IconUrl				nvarchar(500),
	IsVisible			integer not null default 1
)
go

if not exists (select Top 1 1 from sysObjects where name = 'CategoryThirtItem')
create table CategoryThirtItem
(
	ItemId					integer not null identity(1, 1) primary key clustered,
	CategorySecondItemId	integer not null,
	PageId					integer,
	MenuKeyword				nvarchar(150),
	TitleKeyword			nvarchar(150),
	ContentKeyword			nvarchar(150),
	OrderNumber				integer not null default 0,
	ImageUrl				nvarchar(500),
	IconUrl					nvarchar(500),
	IsVisible				integer not null default 1
)
go

-------------------------------------------------------------------------------------------------

if exists (select Top 1 1 from sysObjects where name = 'sp_selectCategories')
drop procedure sp_selectCategories
go
create procedure sp_selectCategories
	@LanguageId			integer = 1
as
begin
	select 
		C.CategoryId,
		C.CategoryKeyword,
		V.KeywordValue as Category,
		C.Description, 
		C.IsActive
	from Category(NoLock) C 
	left join Vocabulary V on C.CategoryKeyword = V.Keyword and V.LanguageId = @LanguageId;
end;
go

if exists (select Top 1 1 from sysObjects where name = 'sp_selectCategory')
drop procedure sp_selectCategory
go
create procedure sp_selectCategory
	@CategoryId			integer,
	@LanguageId			integer = 1
as
begin
	select 
		C.CategoryId,
		C.CategoryKeyword,
		V.KeywordValue as Category,
		C.Description, 
		C.IsActive
	from Category(NoLock) C 
	left join Vocabulary V on C.CategoryKeyword = V.Keyword and V.LanguageId = @LanguageId
	where C.CategoryId = @CategoryId;
end;
go

if exists (select Top 1 1 from sysObjects where name = 'sp_insertCategory')
drop procedure sp_insertCategory
go
create procedure sp_insertCategory
	@CategoryKeyword	nvarchar(150),
	@Description		nvarchar(MAX),
	@IsActive			integer = 1
as
begin
	declare @Result as integer = 0;
	if not exists (select Top 1 1 from Category(NoLock) where CategoryKeyword = @CategoryKeyword)
	begin
		insert into Category(CategoryKeyword, Description, IsActive)
		values (@CategoryKeyword, @Description, @IsActive);
		select @Result = SCOPE_IDENTITY();
	end else 
	begin
		select @Result = CategoryId from Category(NoLock) where CategoryKeyword = @CategoryKeyword;
	end;
	select @Result as 'Result';
end;
go

if exists (select Top 1 1 from sysObjects where name = 'sp_updateCategory')
drop procedure sp_updateCategory
go
create procedure sp_updateCategory
	@CategoryId			integer,
	@CategoryKeyword	nvarchar(150),
	@Description		nvarchar(MAX),
	@IsActive			integer = 1
as
begin
	declare @Result as integer = 0;
	
	update Category set 
		CategoryKeyword = @CategoryKeyword,
		Description = @Description,
		IsActive = @IsActive
	where CategoryId = @CategoryId;

	select @Result as 'Result';
end;
go

-------------------------------------------------------------------------------------------------

if exists (select Top 1 1 from sysObjects where name = 'sp_selectCategoryFirstItems')
drop procedure sp_selectCategoryFirstItems
go
create procedure sp_selectCategoryFirstItems
	@CategoryId			integer,
	@LanguageId			integer = 1
as
begin
	select 
		C.ItemId, 
		C.CategoryId, 
		C.PageId, 
		C.MenuKeyword, 
		VM.KeywordValue as MenuValue,
		C.TitleKeyword, 
		VT.KeywordValue as TitleValue,
		C.ContentKeyword, 
		VC.KeywordValue as ContentValue,
		C.OrderNumber, 
		C.ImageUrl, 
		C.IconUrl, 
		C.IsVisible
	from CategoryFirstItem(NoLock) C 
	left join Vocabulary VM on C.MenuKeyword = VM.Keyword and VM.LanguageId = @LanguageId
	left join Vocabulary VT on C.TitleKeyword = VT.Keyword and VT.LanguageId = @LanguageId
	left join Vocabulary VC on C.ContentKeyword = VC.Keyword and VC.LanguageId = @LanguageId
	WHERE C.CategoryId = @CategoryId;
end;
go


if exists (select Top 1 1 from sysObjects where name = 'sp_selectCategoryFirstItem')
drop procedure sp_selectCategoryFirstItem
go
create procedure sp_selectCategoryFirstItem
	@FirstItemId		integer,
	@CategoryId			integer,
	@LanguageId			integer = 1
as
begin
	select 
		C.ItemId, 
		C.CategoryId, 
		C.PageId, 
		C.MenuKeyword, 
		VM.KeywordValue as MenuValue,
		C.TitleKeyword, 
		VT.KeywordValue as TitleValue,
		C.ContentKeyword, 
		VC.KeywordValue as ContentValue,
		C.OrderNumber, 
		C.ImageUrl, 
		C.IconUrl, 
		C.IsVisible
	from CategoryFirstItem(NoLock) C 
	left join Vocabulary VM on C.MenuKeyword = VM.Keyword and VM.LanguageId = @LanguageId
	left join Vocabulary VT on C.TitleKeyword = VT.Keyword and VT.LanguageId = @LanguageId
	left join Vocabulary VC on C.ContentKeyword = VC.Keyword and VC.LanguageId = @LanguageId
	WHERE C.CategoryId = @CategoryId and C.ItemId = @FirstItemId;
end;
go

if exists (select Top 1 1 from sysObjects where name = 'sp_insertCategoryFirstItem')
drop procedure sp_insertCategoryFirstItem
go
create procedure sp_insertCategoryFirstItem
	@CategoryId			integer,
	@PageId				integer,
	@MenuKeyword		nvarchar(150),
	@TitleKeyword		nvarchar(150),
	@ContentKeyword		nvarchar(150),
	@OrderNumber		integer,
	@ImageUrl			nvarchar(500),
	@IconUrl			nvarchar(500),
	@IsVisible			integer = 1
as
begin
	declare @Result as integer = 0;
	insert into CategoryFirstItem (CategoryId, PageId, MenuKeyword, TitleKeyword, ContentKeyword, OrderNumber, ImageUrl, IconUrl, IsVisible)
	values (@CategoryId, @PageId, @MenuKeyword, @TitleKeyword, @ContentKeyword, @OrderNumber, @ImageUrl, @IconUrl, @IsVisible);
	select @Result = SCOPE_IDENTITY();
	select @Result as 'Result';
end;
go

if exists (select Top 1 1 from sysObjects where name = 'sp_updateCategoryFirstItem')
drop procedure sp_updateCategoryFirstItem
go
create procedure sp_updateCategoryFirstItem
	@FirstItemId		integer,
	@CategoryId			integer,
	@PageId				integer,
	@MenuKeyword		nvarchar(150),
	@TitleKeyword		nvarchar(150),
	@ContentKeyword		nvarchar(150),
	@OrderNumber		integer,
	@ImageUrl			nvarchar(500),
	@IconUrl			nvarchar(500),
	@IsVisible			integer = 1
as
begin
	declare @Result as integer = 0;
	update CategoryFirstItem set 
		CategoryId = @CategoryId,
		PageId = @PageId,
		MenuKeyword = @MenuKeyword,
		TitleKeyword = @TitleKeyword,
		ContentKeyword = @ContentKeyword,
		OrderNumber = @OrderNumber,
		ImageUrl = @ImageUrl,
		IconUrl = @IconUrl,
		IsVisible = @IsVisible
	where ItemId = @FirstItemId;
	select @Result = 1;
	select @Result as 'Result';
end;
go

----------------------------------------------------------------------------------------------

if exists (select Top 1 1 from sysObjects where name = 'sp_selectCategorySecondItems')
drop procedure sp_selectCategorySecondItems
go
create procedure sp_selectCategorySecondItems
	@FirstItemId		integer,
	@LanguageId			integer = 1
as
begin
	select 
		C.ItemId, 
		C.CategoryFirstItemId, 
		C.PageId, 
		C.MenuKeyword, 
		VM.KeywordValue as MenuValue,
		C.TitleKeyword, 
		VT.KeywordValue as TitleValue,
		C.ContentKeyword, 
		VC.KeywordValue as ContentValue,
		C.OrderNumber, 
		C.ImageUrl, 
		C.IconUrl, 
		C.IsVisible
	from CategorySecondItem(NoLock) C 
	left join Vocabulary VM on C.MenuKeyword = VM.Keyword and VM.LanguageId = @LanguageId
	left join Vocabulary VT on C.TitleKeyword = VT.Keyword and VT.LanguageId = @LanguageId
	left join Vocabulary VC on C.ContentKeyword = VC.Keyword and VC.LanguageId = @LanguageId
	WHERE C.CategoryFirstItemId = @FirstItemId;
end;
go


if exists (select Top 1 1 from sysObjects where name = 'sp_selectCategorySecondItem')
drop procedure sp_selectCategorySecondItem
go
create procedure sp_selectCategorySecondItem
	@SecondItemId		integer,
	@FirstItemId		integer,
	@LanguageId			integer = 1
as
begin
	select 
		C.ItemId, 
		C.CategoryFirstItemId, 
		C.PageId, 
		C.MenuKeyword, 
		VM.KeywordValue as MenuValue,
		C.TitleKeyword, 
		VT.KeywordValue as TitleValue,
		C.ContentKeyword, 
		VC.KeywordValue as ContentValue,
		C.OrderNumber, 
		C.ImageUrl, 
		C.IconUrl, 
		C.IsVisible
	from CategorySecondItem(NoLock) C 
	left join Vocabulary VM on C.MenuKeyword = VM.Keyword and VM.LanguageId = @LanguageId
	left join Vocabulary VT on C.TitleKeyword = VT.Keyword and VT.LanguageId = @LanguageId
	left join Vocabulary VC on C.ContentKeyword = VC.Keyword and VC.LanguageId = @LanguageId
	WHERE C.CategoryFirstItemId = @FirstItemId and C.ItemId = @SecondItemId;
end;
go

if exists (select Top 1 1 from sysObjects where name = 'sp_insertCategorySecondItem')
drop procedure sp_insertCategorySecondItem
go
create procedure sp_insertCategorySecondItem
	@FirstItemId		integer,
	@PageId				integer,
	@MenuKeyword		nvarchar(150),
	@TitleKeyword		nvarchar(150),
	@ContentKeyword		nvarchar(150),
	@OrderNumber		integer,
	@ImageUrl			nvarchar(500),
	@IconUrl			nvarchar(500),
	@IsVisible			integer = 1
as
begin
	declare @Result as integer = 0;
	insert into CategorySecondItem (CategoryFirstItemId, PageId, MenuKeyword, TitleKeyword, ContentKeyword, OrderNumber, ImageUrl, IconUrl, IsVisible)
	values (@FirstItemId, @PageId, @MenuKeyword, @TitleKeyword, @ContentKeyword, @OrderNumber, @ImageUrl, @IconUrl, @IsVisible);
	select @Result = SCOPE_IDENTITY();
	select @Result as 'Result';
end;
go

if exists (select Top 1 1 from sysObjects where name = 'sp_updateCategorySecondItem')
drop procedure sp_updateCategorySecondItem
go
create procedure sp_updateCategorySecondItem
	@SecondItemId		integer,
	@FirstItemId		integer,
	@PageId				integer,
	@MenuKeyword		nvarchar(150),
	@TitleKeyword		nvarchar(150),
	@ContentKeyword		nvarchar(150),
	@OrderNumber		integer,
	@ImageUrl			nvarchar(500),
	@IconUrl			nvarchar(500),
	@IsVisible			integer = 1
as
begin
	declare @Result as integer = 0;
	update CategorySecondItem set 
		CategoryFirstItemId = @FirstItemId,
		PageId = @PageId,
		MenuKeyword = @MenuKeyword,
		TitleKeyword = @TitleKeyword,
		ContentKeyword = @ContentKeyword,
		OrderNumber = @OrderNumber,
		ImageUrl = @ImageUrl,
		IconUrl = @IconUrl,
		IsVisible = @IsVisible
	where ItemId = @SecondItemId;
	select @Result = 1;
	select @Result as 'Result';
end;
go

----------------------------------------------------------------------------------------------

if exists (select Top 1 1 from sysObjects where name = 'sp_selectCategoryThirdItems')
drop procedure sp_selectCategoryThirdItems
go
create procedure sp_selectCategoryThirdItems
	@SecondItemId		integer,
	@LanguageId			integer = 1
as
begin
	select 
		C.ItemId, 
		C.CategorySecondItemId, 
		C.PageId, 
		C.MenuKeyword, 
		VM.KeywordValue as MenuValue,
		C.TitleKeyword, 
		VT.KeywordValue as TitleValue,
		C.ContentKeyword, 
		VC.KeywordValue as ContentValue,
		C.OrderNumber, 
		C.ImageUrl, 
		C.IconUrl, 
		C.IsVisible
	from CategoryThirtItem(NoLock) C 
	left join Vocabulary VM on C.MenuKeyword = VM.Keyword and VM.LanguageId = @LanguageId
	left join Vocabulary VT on C.TitleKeyword = VT.Keyword and VT.LanguageId = @LanguageId
	left join Vocabulary VC on C.ContentKeyword = VC.Keyword and VC.LanguageId = @LanguageId
	WHERE C.CategorySecondItemId = @SecondItemId;
end;
go


if exists (select Top 1 1 from sysObjects where name = 'sp_selectCategoryThirtItem')
drop procedure sp_selectCategoryThirtItem
go
create procedure sp_selectCategoryThirtItem
	@ThirtItemId		integer,
	@SecondItemId		integer,
	@LanguageId			integer = 1
as
begin
	select 
		C.ItemId, 
		C.CategorySecondItemId, 
		C.PageId, 
		C.MenuKeyword, 
		VM.KeywordValue as MenuValue,
		C.TitleKeyword, 
		VT.KeywordValue as TitleValue,
		C.ContentKeyword, 
		VC.KeywordValue as ContentValue,
		C.OrderNumber, 
		C.ImageUrl, 
		C.IconUrl, 
		C.IsVisible
	from CategoryThirtItem(NoLock) C 
	left join Vocabulary VM on C.MenuKeyword = VM.Keyword and VM.LanguageId = @LanguageId
	left join Vocabulary VT on C.TitleKeyword = VT.Keyword and VT.LanguageId = @LanguageId
	left join Vocabulary VC on C.ContentKeyword = VC.Keyword and VC.LanguageId = @LanguageId
	WHERE C.CategorySecondItemId = @SecondItemId and C.ItemId = @ThirtItemId;
end;
go

if exists (select Top 1 1 from sysObjects where name = 'sp_insertCategoryThirtItem')
drop procedure sp_insertCategoryThirtItem
go
create procedure sp_insertCategoryThirtItem
	@SecondItemId		integer,
	@PageId				integer,
	@MenuKeyword		nvarchar(150),
	@TitleKeyword		nvarchar(150),
	@ContentKeyword		nvarchar(150),
	@OrderNumber		integer,
	@ImageUrl			nvarchar(500),
	@IconUrl			nvarchar(500),
	@IsVisible			integer = 1
as
begin
	declare @Result as integer = 0;
	insert into CategoryThirtItem (CategorySecondItemId, PageId, MenuKeyword, TitleKeyword, ContentKeyword, OrderNumber, ImageUrl, IconUrl, IsVisible)
	values (@SecondItemId, @PageId, @MenuKeyword, @TitleKeyword, @ContentKeyword, @OrderNumber, @ImageUrl, @IconUrl, @IsVisible);
	select @Result = SCOPE_IDENTITY();
	select @Result as 'Result';
end;
go

if exists (select Top 1 1 from sysObjects where name = 'sp_updateCategoryThirtItem')
drop procedure sp_updateCategoryThirtItem
go
create procedure sp_updateCategoryThirtItem
	@ThirtItemId		integer,
	@SecondItemId		integer,
	@PageId				integer,
	@MenuKeyword		nvarchar(150),
	@TitleKeyword		nvarchar(150),
	@ContentKeyword		nvarchar(150),
	@OrderNumber		integer,
	@ImageUrl			nvarchar(500),
	@IconUrl			nvarchar(500),
	@IsVisible			integer = 1
as
begin
	declare @Result as integer = 0;
	update CategoryThirtItem set 
		CategorySecondItemId = @SecondItemId,
		PageId = @PageId,
		MenuKeyword = @MenuKeyword,
		TitleKeyword = @TitleKeyword,
		ContentKeyword = @ContentKeyword,
		OrderNumber = @OrderNumber,
		ImageUrl = @ImageUrl,
		IconUrl = @IconUrl,
		IsVisible = @IsVisible
	where ItemId = @ThirtItemId;
	select @Result = 1;
	select @Result as 'Result';
end;
go

-- End Category 
/***************************************************************************************************************/