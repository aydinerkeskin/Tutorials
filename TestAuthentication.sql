USE [master]
GO
/****** Object:  Database [AdwentureWorks]    Script Date: 18.01.2019 10:58:25 ******/
CREATE DATABASE [AdwentureWorks]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'AdwentureWorks', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL14.SQLEXPRESS\MSSQL\DATA\AdwentureWorks.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'AdwentureWorks_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL14.SQLEXPRESS\MSSQL\DATA\AdwentureWorks_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
GO
ALTER DATABASE [AdwentureWorks] SET COMPATIBILITY_LEVEL = 140
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [AdwentureWorks].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [AdwentureWorks] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [AdwentureWorks] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [AdwentureWorks] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [AdwentureWorks] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [AdwentureWorks] SET ARITHABORT OFF 
GO
ALTER DATABASE [AdwentureWorks] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [AdwentureWorks] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [AdwentureWorks] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [AdwentureWorks] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [AdwentureWorks] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [AdwentureWorks] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [AdwentureWorks] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [AdwentureWorks] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [AdwentureWorks] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [AdwentureWorks] SET  DISABLE_BROKER 
GO
ALTER DATABASE [AdwentureWorks] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [AdwentureWorks] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [AdwentureWorks] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [AdwentureWorks] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [AdwentureWorks] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [AdwentureWorks] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [AdwentureWorks] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [AdwentureWorks] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [AdwentureWorks] SET  MULTI_USER 
GO
ALTER DATABASE [AdwentureWorks] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [AdwentureWorks] SET DB_CHAINING OFF 
GO
ALTER DATABASE [AdwentureWorks] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [AdwentureWorks] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [AdwentureWorks] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [AdwentureWorks] SET QUERY_STORE = OFF
GO
USE [AdwentureWorks]
GO
/****** Object:  UserDefinedTableType [dbo].[LocalizationItem]    Script Date: 18.01.2019 10:58:25 ******/
CREATE TYPE [dbo].[LocalizationItem] AS TABLE(
	[LanguageId] [int] NULL,
	[Keyword] [nvarchar](150) NULL,
	[KeywordValue] [ntext] NULL
)
GO
/****** Object:  Table [dbo].[Dictionary]    Script Date: 18.01.2019 10:58:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Dictionary](
	[DictionaryId] [int] IDENTITY(1,1) NOT NULL,
	[KeywordId] [int] NOT NULL,
	[LanguageId] [int] NOT NULL,
	[KeywordValue] [ntext] NULL,
PRIMARY KEY CLUSTERED 
(
	[DictionaryId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Keyword]    Script Date: 18.01.2019 10:58:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Keyword](
	[KeywordId] [int] IDENTITY(1,1) NOT NULL,
	[Keyword] [nvarchar](150) NULL,
PRIMARY KEY CLUSTERED 
(
	[KeywordId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[Vocabulary]    Script Date: 18.01.2019 10:58:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[Vocabulary] as 
	select 
		D.DictionaryId, D.KeywordId, D.LanguageId, K.Keyword, D.KeywordValue 
	from Dictionary(NoLock) D
	left join Keyword(NoLock) K on D.KeywordId = K.KeywordId;
GO
/****** Object:  Table [dbo].[Category]    Script Date: 18.01.2019 10:58:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Category](
	[CategoryId] [int] IDENTITY(1,1) NOT NULL,
	[CategoryKeyword] [nvarchar](150) NOT NULL,
	[Description] [nvarchar](max) NULL,
	[IsActive] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[CategoryId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CategoryFirstItem]    Script Date: 18.01.2019 10:58:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CategoryFirstItem](
	[ItemId] [int] IDENTITY(1,1) NOT NULL,
	[CategoryId] [int] NOT NULL,
	[PageId] [int] NULL,
	[MenuKeyword] [nvarchar](150) NULL,
	[TitleKeyword] [nvarchar](150) NULL,
	[ContentKeyword] [nvarchar](150) NULL,
	[OrderNumber] [int] NOT NULL,
	[ImageUrl] [nvarchar](500) NULL,
	[IconUrl] [nvarchar](500) NULL,
	[IsVisible] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ItemId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CategorySecondItem]    Script Date: 18.01.2019 10:58:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CategorySecondItem](
	[ItemId] [int] IDENTITY(1,1) NOT NULL,
	[CategoryFirstItemId] [int] NOT NULL,
	[PageId] [int] NULL,
	[MenuKeyword] [nvarchar](150) NULL,
	[TitleKeyword] [nvarchar](150) NULL,
	[ContentKeyword] [nvarchar](150) NULL,
	[OrderNumber] [int] NOT NULL,
	[ImageUrl] [nvarchar](500) NULL,
	[IconUrl] [nvarchar](500) NULL,
	[IsVisible] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ItemId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CategoryThirtItem]    Script Date: 18.01.2019 10:58:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CategoryThirtItem](
	[ItemId] [int] IDENTITY(1,1) NOT NULL,
	[CategorySecondItemId] [int] NOT NULL,
	[PageId] [int] NULL,
	[MenuKeyword] [nvarchar](150) NULL,
	[TitleKeyword] [nvarchar](150) NULL,
	[ContentKeyword] [nvarchar](150) NULL,
	[OrderNumber] [int] NOT NULL,
	[ImageUrl] [nvarchar](500) NULL,
	[IconUrl] [nvarchar](500) NULL,
	[IsVisible] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ItemId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Languages]    Script Date: 18.01.2019 10:58:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Languages](
	[LanguageId] [int] IDENTITY(1,1) NOT NULL,
	[LanguageName] [nvarchar](100) NOT NULL,
	[LanguageCode] [nvarchar](2) NOT NULL,
	[CultureCode] [nvarchar](10) NOT NULL,
	[IsActive] [int] NOT NULL,
	[IsDefault] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[LanguageId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PageContents]    Script Date: 18.01.2019 10:58:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PageContents](
	[ContentId] [int] IDENTITY(1,1) NOT NULL,
	[PageId] [int] NOT NULL,
	[PageTypeId] [int] NOT NULL,
	[ContentKeyword] [nvarchar](150) NULL,
	[MasterKeyword] [nvarchar](150) NULL,
	[DetailKeyword] [nvarchar](150) NULL,
	[IsVisible] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ContentId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Pages]    Script Date: 18.01.2019 10:58:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Pages](
	[PageId] [int] IDENTITY(1,1) NOT NULL,
	[PageTitleKeyword] [nvarchar](150) NULL,
	[PageSubTitleKeyword] [nvarchar](150) NULL,
	[IsActive] [int] NOT NULL,
	[IsVisible] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[PageId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PageType]    Script Date: 18.01.2019 10:58:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PageType](
	[PageTypeId] [int] NOT NULL,
	[PageTypeKeyword] [nvarchar](150) NULL,
PRIMARY KEY CLUSTERED 
(
	[PageTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Roles]    Script Date: 18.01.2019 10:58:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Roles](
	[RoleId] [int] IDENTITY(1,1) NOT NULL,
	[RoleName] [nvarchar](30) NOT NULL,
	[InsertDate] [datetime] NOT NULL,
	[UpdateDate] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[RoleId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UploadedFiles]    Script Date: 18.01.2019 10:58:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UploadedFiles](
	[FileId] [int] IDENTITY(1,1) NOT NULL,
	[FileName] [nvarchar](500) NULL,
	[FilePath] [nvarchar](500) NULL,
PRIMARY KEY CLUSTERED 
(
	[FileId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UserRoles]    Script Date: 18.01.2019 10:58:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserRoles](
	[UserId] [int] NOT NULL,
	[RoleId] [int] NOT NULL,
	[InsertDate] [datetime] NOT NULL,
 CONSTRAINT [PK_UserRoles] PRIMARY KEY CLUSTERED 
(
	[UserId] ASC,
	[RoleId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Users]    Script Date: 18.01.2019 10:58:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Users](
	[UserId] [int] IDENTITY(1,1) NOT NULL,
	[UserName] [nvarchar](50) NOT NULL,
	[FirstName] [nvarchar](50) NULL,
	[LastName] [nvarchar](50) NULL,
	[Email] [nvarchar](150) NULL,
	[Password] [nvarchar](255) NULL,
	[IsActive] [int] NOT NULL,
	[InsertDate] [datetime] NOT NULL,
	[UpdateDate] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[UserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Category] ADD  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[CategoryFirstItem] ADD  DEFAULT ((0)) FOR [OrderNumber]
GO
ALTER TABLE [dbo].[CategoryFirstItem] ADD  DEFAULT ((1)) FOR [IsVisible]
GO
ALTER TABLE [dbo].[CategorySecondItem] ADD  DEFAULT ((0)) FOR [OrderNumber]
GO
ALTER TABLE [dbo].[CategorySecondItem] ADD  DEFAULT ((1)) FOR [IsVisible]
GO
ALTER TABLE [dbo].[CategoryThirtItem] ADD  DEFAULT ((0)) FOR [OrderNumber]
GO
ALTER TABLE [dbo].[CategoryThirtItem] ADD  DEFAULT ((1)) FOR [IsVisible]
GO
ALTER TABLE [dbo].[Languages] ADD  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[Languages] ADD  DEFAULT ((0)) FOR [IsDefault]
GO
ALTER TABLE [dbo].[PageContents] ADD  DEFAULT ((0)) FOR [IsVisible]
GO
ALTER TABLE [dbo].[Pages] ADD  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[Pages] ADD  DEFAULT ((1)) FOR [IsVisible]
GO
ALTER TABLE [dbo].[Roles] ADD  DEFAULT (getdate()) FOR [InsertDate]
GO
ALTER TABLE [dbo].[Roles] ADD  DEFAULT (getdate()) FOR [UpdateDate]
GO
ALTER TABLE [dbo].[UserRoles] ADD  DEFAULT (getdate()) FOR [InsertDate]
GO
ALTER TABLE [dbo].[Users] ADD  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[Users] ADD  DEFAULT (getdate()) FOR [InsertDate]
GO
ALTER TABLE [dbo].[Users] ADD  DEFAULT (getdate()) FOR [UpdateDate]
GO
/****** Object:  StoredProcedure [dbo].[sp_deleteLanguage]    Script Date: 18.01.2019 10:58:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[sp_deleteLanguage]
	@LanguageId		integer
as
begin
	SET NOCOUNT ON;
	declare @result as integer = 0;
	DELETE FROM Languages where LanguageId = @LanguageId;
	set @result = 1;
	select @result as 'Result';
end;
GO
/****** Object:  StoredProcedure [dbo].[sp_insertCategory]    Script Date: 18.01.2019 10:58:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[sp_insertCategory]
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
GO
/****** Object:  StoredProcedure [dbo].[sp_insertCategoryFirstItem]    Script Date: 18.01.2019 10:58:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[sp_insertCategoryFirstItem]
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
GO
/****** Object:  StoredProcedure [dbo].[sp_insertCategorySecondItem]    Script Date: 18.01.2019 10:58:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[sp_insertCategorySecondItem]
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
GO
/****** Object:  StoredProcedure [dbo].[sp_insertCategoryThirtItem]    Script Date: 18.01.2019 10:58:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[sp_insertCategoryThirtItem]
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
GO
/****** Object:  StoredProcedure [dbo].[sp_insertLanguage]    Script Date: 18.01.2019 10:58:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [dbo].[sp_insertLanguage]
	@LanguageName	nvarchar(100),
	@LanguageCode	nvarchar(2),
	@CultureCode	nvarchar(10),
	@IsActive		integer,
	@IsDefault		integer
as
begin
	SET NOCOUNT ON;
	declare @result as integer = 0;
	insert into Languages (LanguageName, LanguageCode, CultureCode, IsActive, IsDefault)
	values (@LanguageName, @LanguageCode, @CultureCode, @IsActive, @IsDefault);
	select @result = SCOPE_IDENTITY();
	select @result as 'Result';
end;
GO
/****** Object:  StoredProcedure [dbo].[sp_insertLocalizations]    Script Date: 18.01.2019 10:58:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[sp_insertLocalizations]
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
GO
/****** Object:  StoredProcedure [dbo].[sp_insertPageContent]    Script Date: 18.01.2019 10:58:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[sp_insertPageContent]
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
GO
/****** Object:  StoredProcedure [dbo].[sp_insertUploadedFile]    Script Date: 18.01.2019 10:58:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[sp_insertUploadedFile]
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
GO
/****** Object:  StoredProcedure [dbo].[sp_selectCategories]    Script Date: 18.01.2019 10:58:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[sp_selectCategories]
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
GO
/****** Object:  StoredProcedure [dbo].[sp_selectCategory]    Script Date: 18.01.2019 10:58:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[sp_selectCategory]
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
GO
/****** Object:  StoredProcedure [dbo].[sp_selectCategoryFirstItem]    Script Date: 18.01.2019 10:58:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[sp_selectCategoryFirstItem]
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
GO
/****** Object:  StoredProcedure [dbo].[sp_selectCategoryFirstItems]    Script Date: 18.01.2019 10:58:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[sp_selectCategoryFirstItems]
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
GO
/****** Object:  StoredProcedure [dbo].[sp_selectCategorySecondItem]    Script Date: 18.01.2019 10:58:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[sp_selectCategorySecondItem]
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
GO
/****** Object:  StoredProcedure [dbo].[sp_selectCategorySecondItems]    Script Date: 18.01.2019 10:58:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[sp_selectCategorySecondItems]
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
GO
/****** Object:  StoredProcedure [dbo].[sp_selectCategoryThirdItems]    Script Date: 18.01.2019 10:58:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[sp_selectCategoryThirdItems]
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
GO
/****** Object:  StoredProcedure [dbo].[sp_selectCategoryThirtItem]    Script Date: 18.01.2019 10:58:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[sp_selectCategoryThirtItem]
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
GO
/****** Object:  StoredProcedure [dbo].[sp_selectDictionaries]    Script Date: 18.01.2019 10:58:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[sp_selectDictionaries]
as
begin
	select * from Vocabulary
end;
GO
/****** Object:  StoredProcedure [dbo].[sp_selectLanguages]    Script Date: 18.01.2019 10:58:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[sp_selectLanguages]
as
begin
	select * from Languages(NoLock)
end;
GO
/****** Object:  StoredProcedure [dbo].[sp_selectPage]    Script Date: 18.01.2019 10:58:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[sp_selectPage]
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
GO
/****** Object:  StoredProcedure [dbo].[sp_selectPageContents]    Script Date: 18.01.2019 10:58:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[sp_selectPageContents]
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
GO
/****** Object:  StoredProcedure [dbo].[sp_selectPages]    Script Date: 18.01.2019 10:58:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[sp_selectPages]
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
GO
/****** Object:  StoredProcedure [dbo].[sp_selectRoleUsers]    Script Date: 18.01.2019 10:58:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[sp_selectRoleUsers]
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
GO
/****** Object:  StoredProcedure [dbo].[sp_selectUser]    Script Date: 18.01.2019 10:58:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[sp_selectUser]
	@UserName	nvarchar(30)
as
begin
	select 
		UserId, UserName, FirstName, LastName, Email, [Password], IsActive, InsertDate, UpdateDate 
	from Users(NoLock) 
	where UserName = @UserName;
end;
GO
/****** Object:  StoredProcedure [dbo].[sp_selectUserRoles]    Script Date: 18.01.2019 10:58:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[sp_selectUserRoles]
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
GO
/****** Object:  StoredProcedure [dbo].[sp_updateCategory]    Script Date: 18.01.2019 10:58:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[sp_updateCategory]
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
GO
/****** Object:  StoredProcedure [dbo].[sp_updateCategoryFirstItem]    Script Date: 18.01.2019 10:58:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[sp_updateCategoryFirstItem]
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
GO
/****** Object:  StoredProcedure [dbo].[sp_updateCategorySecondItem]    Script Date: 18.01.2019 10:58:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[sp_updateCategorySecondItem]
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
GO
/****** Object:  StoredProcedure [dbo].[sp_updateCategoryThirtItem]    Script Date: 18.01.2019 10:58:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[sp_updateCategoryThirtItem]
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
GO
/****** Object:  StoredProcedure [dbo].[sp_updateLanguage]    Script Date: 18.01.2019 10:58:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[sp_updateLanguage]
	@LanguageId		integer,
	@LanguageName	nvarchar(100),
	@LanguageCode	nvarchar(2),
	@CultureCode	nvarchar(10),
	@IsActive		integer,
	@IsDefault		integer
as
begin
	SET NOCOUNT ON;
	declare @result as integer = 0;
	update Languages set 
		LanguageName = @LanguageName, 
		LanguageCode = @LanguageCode, 
		CultureCode = @CultureCode, 
		IsActive = @IsActive, 
		IsDefault = @IsDefault 
	where LanguageId = @LanguageId;
	select @result = @LanguageId;
	select @result as 'Result';
end;
GO
/****** Object:  StoredProcedure [dbo].[sp_updatePageContent]    Script Date: 18.01.2019 10:58:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[sp_updatePageContent]
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
GO
/****** Object:  StoredProcedure [dbo].[sp_validateUser]    Script Date: 18.01.2019 10:58:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[sp_validateUser]
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
GO
USE [master]
GO
ALTER DATABASE [AdwentureWorks] SET  READ_WRITE 
GO
