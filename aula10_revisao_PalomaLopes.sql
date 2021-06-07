--revisao Paloma Lopes ADS Noite 
--1-) Crie stored procedures que: sempre que uma ação de alteração, inclusão
--ou exclusão for executada na tabela departamentos, a tabela auditoria deverá
--ser atualizada automaticamente. 
create trigger tr_AtualizaAuditoria on DEPARTAMENTOS
	for insert, delete, update
as
	begin
		declare @DataAuditoria datetime, @Descr varchar(80)
		set @DataAuditoria = CONVERT (DATE, SYSDATETIME());
		if exists (select * from inserted) and not exists (select * from deleted)
		begin
			set @Descr = 'Insersão na tabela departamento';
		end
		if exists (select * from deleted) and not exists (select * from inserted)
		begin
			set @Descr = 'Excusão na tabela departamento';
		end
		if exists (select * from inserted) and exists (select * from deleted)
		begin
			set @Descr = 'Alteração na tabela departamento';
		end
		insert into AUDITORIA(dt_Auditoria, ds_Auditoria) values (@DataAuditoria, @Descr);
	end

--2-) Crie um stored procedure que assim que um empregado seja demitido, ou
--seja, preenchida sua data de rescisão, o sistema inclua automaticamente um
--registro na tabela VagaDisponivel. No campo ds_VagaDisponivel inserir os
--dizeres “Precisa-se de <ds_Cargo>, salário de <vl_Salario>”. 
create trigger tr_NovaVaga on EMPREGADOS
	for insert, update
as
	begin
	declare @Datavaga datetime, @Codvaga int, @Descrvaga varchar(90), @Cargo varchar(40), @Salario money;
		if exists (select dt_Rescisao from inserted)
		begin
			set @Codvaga = (select MAX(cd_VagaDisponivel) from VagaDisponivel) + 1;
			set @Datavaga = SYSDATETIME();
			set @Cargo = (select ds_Cargo from EMPREGADOS where cd_Empregado = (select cd_Empregado from inserted));
			set @Salario = (select vl_Salario from EMPREGADOS where cd_Empregado = (select cd_Empregado from inserted));
			set @Descrvaga = 'Precisa-se de ' + @Cargo + ', salário de ' + @Salario;
			insert into VagaDisponivel(cd_VagaDisponivel, dt_VagaDisponivel, ds_VagaDisponivel) values (@Codvaga, @Datavaga, @Descrvaga);
		end
	end
	
--3-) Crie um procedure chamado vagas_em_aberto que mostre a quantidade de
--vagas disponíveis. 
create procedure vagas_em_aberto 
as
declare @quant int;
if exists (select cd_VagaDisponivel from VagaDisponivel)
	begin
		select @quant=COUNT(*) from VagaDisponivel where dt_Preenchida = null;
		if ( @quant > 0)
			print 'Há ' + @quant + ' vagas disponíveis no momento'
		else
			print 'Não há vagas disponíveis no momento'
	end
else
	print 'Não há vagas no momento'

--4-) Faça um stored procedure que assim que uma vaga seja excluída,
--armazene na tabela de auditoria a data e a vaga excluída
create trigger tr_RegistraVaga on VagaDisponivel
	for delete
as
	begin
		declare @DataAuditoria datetime, @Descr varchar(80)
		set @DataAuditoria = CONVERT (DATE, SYSDATETIME());
		set @Descr = (select ds_VagaDisponivel from deleted);
		insert into AUDITORIA(dt_Auditoria, ds_Auditoria) values (@DataAuditoria, @Descr);
	end

--5-) Crie um stored procedure que somente quando a vaga for preenchida, isto
--é, inserido um ‘S’, atualize o campo dt_Preenchida com a data do sistema.
create trigger tr_AtualizaVaga on VagaDisponivel
	for insert, update
as
	begin
		declare @DataVaga datetime, @Letra char(1);
		if exists (select ic_Preenchida from inserted)
			begin
				set @Letra = (select ic_Preenchida from inserted);
				if (@Letra = 'S')
					begin
						set @DataVaga = CONVERT (DATE, SYSDATETIME());
						update VagaDisponivel set dt_Preenchida = @DataVaga where cd_VagaDisponivel = (select cd_VagaDisponivel from inserted);
					end
			end
	end

--6-) Crie um stored procedure antes que um departamento seja excluído, ele
--mostre na tela a quantidade e os nomes de todos os funcionários que ficarão
--sem departamento. Nestes funcionários, alterar o depto para 0 (zero) 
create trigger tr_DepartamentoExcluido on DEPARTAMENTOS
for delete
as
	begin
	declare @Quant int;
	set @Quant = (select COUNT(*) from EMPREGADOS where cd_Depto = (select cd_Depto from deleted));
	print 'A ação irá deixar ' + @Quant + ' funcionarios sem departamento'
	select nm_Empregado from EMPREGADOS where cd_Depto = (select cd_Depto from deleted);
	update EMPREGADOS set cd_Depto = 0 where cd_Depto = (select cd_Depto from deleted);
	end
