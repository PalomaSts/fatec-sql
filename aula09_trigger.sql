--Escreva um trigger que realize a atualização do campo valor médio 
--do Imóvel a cada nova oferta cadastrada, alterada ou excluída.

alter table Imovel add vl_OfertaMedia money;
go
create trigger tr_AtualizaMedia on Oferta
	for Insert, delete, update
as
	begin
		declare @Media money, @Imovel int
		if exists(select * from Inserted)
			set @Imovel = (select cd_Imovel from inserted)
		else 
			set @Imovel = (select cd_Imovel from deleted)
		set @media = (select avg(vl_Oferta) from Oferta
			where cd_Imovel = @Imovel)
		update Imovel set vl_OfertaMedia = @Media where cd_Imovel = @Imovel
	end

--Escreva um trigger que não permita a alteração de dados na tabela Faixa_Imovel a sua exclusão.
create trigger tr_NaoAltera on Faixa_Imovel
	for insert, delete, update
as 
	begin
		if exists (select * from inserted) and not exists (select * from deleted)
		begin
			rollback transaction;
			print('não é permitido fazer insert nessa tabela');
			return;
		end
		if exists (select * from deleted) and not exists (select * from inserted)
		begin
			rollback transaction;
			print('não é permitido fazer delete nessa tabela');
			return;
		end
		if exists (select * from inserted) and exists (select * from deleted)
		begin
			rollback transaction;
			print('não é permitido fazer update nessa tabela');
			return;
		end
	end

--Fazer um procedimento que no ato da inclusão de uma nova oferta, o banco atualize 
--automaticamente a quantidade de ofertas no campo qt_Ofertas da tabela Imóvel.

create trigger tr_AtualizaOfertas on Oferta
	for insert
as
	begin
		update Imovel set I.qt_Ofertas = I.qt_Ofertas + 1
		from Imovel I, inserted N
		where I.cd_Imovel = N.cd_Imovel;
	end

--No ato da gravação do contrato, o banco deverá gerar automaticamente os registros de mensalidades 
--do parcelamento com os Imóveis, mesmo em pagamento a vista, deverá gerar um registro.

create trigger tr_RegisParcelas on Contrato
	for insert
as
	begin 
		insert into Parcelas(cd_Contrato, qt_Parcela)
		values ((select cd_Contrato from inserted), (select qt_Parcela from inserted));
	end


--Fazer um procedimento que no ato da alteração da data do pagamento de uma parcela, 
--o banco atualize automaticamente o valor da multa, caso existir atraso. Calcular o 
--valor da multa em 3% por dia de atraso. Caso a data de pagamento seja nula, o banco 
--deve zerar o valor da multa.

create trigger tr_Multa on Parcelas
	for update
as
	begin
	declare @Novadata datetime, @DataPag datetime, @Contrato int
	set @Contrato = (select cd_Contrato from inserted)
		if exists (select dt_Vencimento from inserted)
		begin
			set @Novadata = (select dt_Vencimento from inserted)
			set @DataPag = (select dt_Pagamento from Parcelas where cd_Contrato = @Contrato)
			if @Novadata < @DataPag
				update Parcelas
				set vl_Multa = vl_Parcela * (0.03 * (DATEDIFF(DAY, @Novadata, @DataPAg)))
		end
		else
			update Parcelas
			set vl_Multa = 0
	end
		
--Fazer um procedimento para gerar uma tabela temporária (Inadimplentes) informando o 
--código do contrato, o número da parcela, a data de vencimento e o valor a ser pago 
--dos Imóveis que estão inadimplentes no mês anterior ao mês corrente, para gerar a 
--cobrança dos pagamentos em atraso.

--não sei


	select * from Inadimplentes

	update Faixa_Imovel set nm_Faixa = 'teste' where cd_Faixa = 1