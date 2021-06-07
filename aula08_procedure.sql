--Escreva uma fun��o que receba o c�digo do Im�vel como par�metro e retorne a quantidade de ofertas recebidas 
--de todos os im�veis mesmo que n�o tenha oferta cadastrada, mostrando zero na quantidade. 

create procedure consultaOfertas
@codigo int, @quant smallint output 
as
select @quant=COUNT(*) from Oferta where cd_Imovel = @codigo;

use IMOVEIS
declare @quant smallint
exec consultaOfertas 5, @quant output
select @quant quantidade


--Escreva uma fun��o que receba o c�digo do Im�vel como par�metro e mostre o 
--nome do comprador que fez a �ltima oferta.

create procedure ultimoComprador
@codigo int
as
select nm_Comprador from Comprador where cd_Comprador = (select top 1 o.cd_Comprador from Oferta o where o.cd_Imovel = @codigo order by dt_Oferta desc)

exec ultimoComprador 2

--Escreva uma procedure que receba um valor monet�rio e um valor percentual de desconto como par�metro e 
--aplique o desconto no valor do Im�vel somente 
--nos Im�veis que tenha o valor do im�vel maior que o valor informado e seja do estado de S�o Paulo

create procedure reajImovelSP
@valorref money, @percet decimal(4,2)
as
if(select vl_Imovel from Imovel where sg_Estado = 'SP') > @valorref
	update Imovel set vl_Imovel = vl_Imovel-(vl_Imovel*@percet)

--Criar uma stored procedure que informe se o pre�o de um determinado Im�vel � 
--maior, menor ou igual a m�dia de pre�o das ofertas desse Im�veis

create procedure consultaMed
@codigo int
as
declare @valor money, @media money
select @valor = (select vl_Imovel from Imovel where cd_Imovel = @codigo)
select @media = (select AVG(vl_Oferta) from Oferta where cd_Imovel = @codigo)
if @valor > @media
	print 'Valor maior que a media'
if @valor = @media
	print 'Valor igual a media'
if @valor < @media
	print 'Valor menor que a media'

exec consultaMed 3

--Crie uma SP que, passando o c�digo do comprador e a sigla de Estado como par�metro,
--mostre a quantidade de Im�veis que ele fez oferta apenas no Estado informado. 
--Verificar se o c�digo do comprador existe no banco

create procedure consultaOfertaEstado 
@codigo int, @sigla char(2), @quant smallint output
as
if exists (select cd_Comprador from Comprador where cd_Comprador = @codigo)
	select @quant=COUNT(*) from Oferta where cd_Comprador = @codigo and cd_Imovel = (select cd_Imovel from Imovel where sg_Estado = @sigla and cd_Imovel = @codigo)
else
	print 'Comprador nao existe'


declare @quant smallint
exec consultaOfertaEstado 1, 'SP', @quant output
select @quant quantidade


--Altere o procedimento anterior para retornar um par�metro com a quantidade de ofertas do Comprador
create procedure consultaOfertaEstado 
@codigo int, @quant smallint output
as
if exists (select cd_Comprador from Comprador where cd_Comprador = @codigo)
	select @quant=COUNT(*) from Oferta where cd_Comprador = @codigo
else
	print 'Comprador nao existe'


--Escreva uma procedure que calcule a m�dia dos valores das ofertas 
--de cada im�vel e salve esta m�dia no registro do im�vel.
create procedure mediaImoveis
as
alter table Imovel add row_id int identity(1,1) null
alter table Imovel add mediaOferta money
declare @row int, @cont int
set @row = 1
set @cont = (select COUNT(row_id) from Imovel)
while (@row <= @cont)
begin
	update Imovel set mediaOferta = (select AVG(vl_Oferta) from Oferta where cd_Imovel = @row) where cd_Imovel = @row
end
delete from Imovel alter table Imovel drop column row_id

